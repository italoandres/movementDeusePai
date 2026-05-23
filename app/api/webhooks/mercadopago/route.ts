import { NextRequest, NextResponse } from 'next/server';
import { paymentClient } from '@/lib/mercadopago/client';
import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';

function getSupabaseAdmin() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  );
}

function generateAccessToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

export async function POST(request: NextRequest) {
  try {
    const url = new URL(request.url);
    const dataIdFromQuery = url.searchParams.get('data.id');
    const typeFromQuery = url.searchParams.get('type');
    
    const body = await request.json();

    console.log('[Webhook] Received:', JSON.stringify({
      type: body.type,
      action: body.action,
      dataId: body.data?.id,
      queryDataId: dataIdFromQuery,
      queryType: typeFromQuery,
    }));

    // Determine payment ID from body or query params
    const paymentId = body.data?.id || dataIdFromQuery;
    
    // Only process if it's payment-related
    const isPayment = body.type === 'payment' || typeFromQuery === 'payment' || body.action?.includes('payment');
    
    if (!isPayment) {
      console.log('[Webhook] Not a payment notification, ignoring');
      return NextResponse.json({ received: true });
    }

    if (!paymentId) {
      console.log('[Webhook] No payment ID found');
      return NextResponse.json({ received: true });
    }

    console.log('[Webhook] Processing payment:', paymentId);

    // Fetch payment details from Mercado Pago API
    let payment;
    try {
      payment = await paymentClient.get({ id: Number(paymentId) });
      console.log('[Webhook] Payment status:', payment?.status, 'Email:', payment?.payer?.email, 'ExtRef:', payment?.external_reference);
    } catch (mpError) {
      console.error('[Webhook] Error fetching payment from MP:', mpError);
      return NextResponse.json({ received: true, error: 'mp_fetch_error' });
    }

    if (!payment || payment.status !== 'approved') {
      console.log('[Webhook] Payment not approved yet:', payment?.status);
      return NextResponse.json({ received: true, status: payment?.status });
    }

    const email = payment.external_reference || payment.payer?.email;
    const paymentIdStr = String(payment.id);

    if (!email) {
      console.error('[Webhook] No email found in payment');
      return NextResponse.json({ received: true });
    }

    console.log('[Webhook] Payment APPROVED for:', email);

    const supabase = getSupabaseAdmin();

    // Idempotency check
    const { data: existing } = await supabase
      .from('purchases')
      .select('id')
      .eq('payment_id', paymentIdStr)
      .maybeSingle();

    if (existing) {
      console.log('[Webhook] Already processed, skipping');
      return NextResponse.json({ received: true, message: 'Already processed' });
    }

    // Generate access token
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
    } else {
      console.log('[Webhook] Purchase saved successfully');
    }

    // Update profile access if profile exists
    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        access_type: 'book',
        has_book_access: true,
        book_purchased_at: new Date().toISOString(),
        payment_id: paymentIdStr,
        payment_provider: 'mercadopago',
      })
      .eq('email', email);

    if (updateError) {
      console.error('[Webhook] Error updating profile:', updateError);
    } else {
      console.log('[Webhook] Profile updated to book access for:', email);
    }

    return NextResponse.json({ received: true, status: 'processed' });
  } catch (error) {
    console.error('[Webhook] Unexpected error:', error);
    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
