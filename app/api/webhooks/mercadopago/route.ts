import { NextRequest, NextResponse } from 'next/server';
import { paymentClient } from '@/lib/mercadopago/client';
import { createClient } from '@supabase/supabase-js';
import crypto from 'crypto';
import { sendAccessEmail } from '@/lib/email/send-access-email';

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
      console.log('[Webhook] Type check: not a payment notification, ignoring');
      return NextResponse.json({ received: true });
    }

    if (!paymentId) {
      console.log('[Webhook] Type check: payment type but no payment ID found');
      return NextResponse.json({ received: true });
    }

    console.log('[Webhook] Payment detected, fetching details for ID:', paymentId);

    // Fetch payment details from Mercado Pago API
    let payment;
    try {
      payment = await paymentClient.get({ id: Number(paymentId) });
      console.log('[Webhook] Payment fetch result:', JSON.stringify({
        status: payment?.status,
        email: payment?.payer?.email,
        externalReference: payment?.external_reference,
      }));
    } catch (mpError) {
      console.error('[Webhook] Payment fetch error:', mpError);
      return NextResponse.json({ received: true, error: 'mp_fetch_error' });
    }

    if (!payment || payment.status !== 'approved') {
      console.log('[Webhook] Approval check: payment not approved, status:', payment?.status);
      return NextResponse.json({ received: true, status: payment?.status });
    }

    const email = payment.external_reference || payment.payer?.email;
    const paymentIdStr = String(payment.id);

    if (!email) {
      console.error('[Webhook] Email extraction: no email found in payment (external_reference or payer.email)');
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
      console.log('[Webhook] Idempotency: already processed payment', paymentIdStr, '— skipping');
      return NextResponse.json({ received: true, message: 'Already processed' });
    }

    console.log('[Webhook] Idempotency: new payment, proceeding with processing');

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
        book_purchased_at: new Date().toISOString(),
      });

    if (insertError) {
      console.error('[Webhook] Purchase insert error:', insertError);
    } else {
      console.log('[Webhook] Purchase insert: saved successfully for', email);
    }

    // Update profile access if profile exists (only guaranteed columns)
    const { data: updateData, error: updateError } = await supabase
      .from('profiles')
      .update({
        access_type: 'book',
        has_book_access: true,
      })
      .eq('email', email)
      .select('id');

    if (updateError) {
      console.error('[Webhook] Profile update error:', updateError);
    } else if (!updateData || updateData.length === 0) {
      console.log(`[Webhook] Profile not found for ${email} — access will be picked up on account creation via purchases table`);
    } else {
      console.log(`[Webhook] ✓ Profile updated to book access for: ${email}`);
    }

    // Send access email to buyer
    await sendAccessEmail(email);

    return NextResponse.json({ received: true, status: 'processed' });
  } catch (error) {
    console.error('[Webhook] Unexpected error:', error);
    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
