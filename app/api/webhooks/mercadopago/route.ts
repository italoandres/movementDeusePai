import { NextRequest, NextResponse } from 'next/server';
import { paymentClient } from '@/lib/mercadopago/client';
import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

/**
 * POST /api/webhooks/mercadopago
 * 
 * Receives payment notifications from Mercado Pago.
 * 
 * Documentation requirements implemented:
 * 1. Returns HTTP 200/201 within 22 seconds
 * 2. Validates x-signature header (HMAC SHA256)
 * 3. Fetches payment details via SDK
 * 4. Handles idempotency (no duplicate processing)
 * 5. Saves purchase and generates access token
 */

// Supabase admin client (bypasses RLS)
function getSupabaseAdmin() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  );
}

// Generate secure access token
function generateAccessToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

/**
 * Validate webhook signature as per Mercado Pago documentation.
 * 
 * Template: id:[data.id_url];request-id:[x-request-id_header];ts:[ts_header];
 * Compare HMAC SHA256 of template with v1 from x-signature header.
 */
function validateSignature(
  xSignature: string | null,
  xRequestId: string | null,
  dataId: string | null,
): boolean {
  const secret = process.env.MERCADOPAGO_WEBHOOK_SECRET;
  
  // If no secret configured, skip validation (development mode)
  if (!secret) {
    console.warn('[Webhook] No MERCADOPAGO_WEBHOOK_SECRET configured, skipping signature validation');
    return true;
  }

  if (!xSignature) {
    console.error('[Webhook] Missing x-signature header');
    return false;
  }

  // Extract ts and v1 from x-signature
  // Format: ts=1742505638683,v1=ced36ab6d33566bb...
  let ts: string | null = null;
  let hash: string | null = null;

  const parts = xSignature.split(',');
  for (const part of parts) {
    const [key, value] = part.split('=', 2);
    if (key?.trim() === 'ts') ts = value?.trim() || null;
    if (key?.trim() === 'v1') hash = value?.trim() || null;
  }

  if (!ts || !hash) {
    console.error('[Webhook] Could not extract ts or v1 from x-signature');
    return false;
  }

  // Build manifest string according to documentation template
  // id:[data.id_url];request-id:[x-request-id_header];ts:[ts_header];
  let manifest = '';
  if (dataId) manifest += `id:${dataId};`;
  if (xRequestId) manifest += `request-id:${xRequestId};`;
  manifest += `ts:${ts};`;

  // Calculate HMAC SHA256
  const computedHash = crypto
    .createHmac('sha256', secret)
    .update(manifest)
    .digest('hex');

  if (computedHash !== hash) {
    console.error('[Webhook] Signature mismatch');
    return false;
  }

  return true;
}

export async function POST(request: NextRequest) {
  try {
    // Extract headers for signature validation
    const xSignature = request.headers.get('x-signature');
    const xRequestId = request.headers.get('x-request-id');
    
    // Extract data.id from query params (as per documentation)
    const url = new URL(request.url);
    const dataIdFromQuery = url.searchParams.get('data.id');
    
    const body = await request.json();

    // Validate signature
    const dataIdForValidation = dataIdFromQuery || body.data?.id?.toString();
    const isValid = validateSignature(xSignature, xRequestId, dataIdForValidation);
    
    if (!isValid) {
      return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
    }

    // Only process payment notifications
    if (body.type !== 'payment') {
      // Return 200 immediately as documentation requires
      return NextResponse.json({ received: true });
    }

    const paymentId = body.data?.id;
    if (!paymentId) {
      return NextResponse.json({ received: true });
    }

    // Fetch payment details from Mercado Pago API (using SDK)
    const payment = await paymentClient.get({ id: paymentId });

    if (!payment || payment.status !== 'approved') {
      // Not approved yet - acknowledge receipt (return 200)
      // Mercado Pago will send another notification when status changes
      return NextResponse.json({ received: true, status: payment?.status });
    }

    const email = payment.payer?.email || payment.external_reference;
    const paymentIdStr = String(payment.id);

    if (!email) {
      console.error('[Webhook] No email found in payment:', paymentId);
      return NextResponse.json({ received: true });
    }

    const supabase = getSupabaseAdmin();

    // Idempotency check - don't process same payment twice
    const { data: existing } = await supabase
      .from('purchases')
      .select('id')
      .eq('payment_id', paymentIdStr)
      .single();

    if (existing) {
      // Already processed - return 200 (idempotent)
      return NextResponse.json({ received: true, message: 'Already processed' });
    }

    // Generate access token (expires in 30 minutes)
    const accessToken = generateAccessToken();
    const tokenExpiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();

    // Save purchase record
    const { error: insertError } = await supabase
      .from('purchases')
      .insert({
        email,
        payment_id: paymentIdStr,
        product_id: 'livro-nao-ore-fale-com-o-pai',
        status: 'approved',
        access_released: true,
        access_token: accessToken,
        token_expires_at: tokenExpiresAt,
      });

    if (insertError) {
      console.error('[Webhook] Error saving purchase:', insertError);
      // Still return 200 to avoid retries for DB errors we need to fix
      return NextResponse.json({ received: true, error: 'db_error' });
    }

    console.log(`[Webhook] Payment approved for ${email}. Access token generated.`);

    // Return 200 within 22 seconds (as documentation requires)
    return NextResponse.json({ received: true, status: 'processed' });
  } catch (error) {
    console.error('[Webhook] Unexpected error:', error);
    // Return 500 - Mercado Pago will retry
    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
