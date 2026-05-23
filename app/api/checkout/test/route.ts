import { NextResponse } from 'next/server';
import { preferenceClient } from '@/lib/mercadopago/client';

/**
 * GET /api/checkout/test
 * 
 * Test endpoint that creates a preference and returns the checkout link.
 * For local testing, back_urls and auto_return are omitted since
 * Mercado Pago does not accept localhost URLs.
 * 
 * Access: http://localhost:3000/api/checkout/test
 */
export async function GET() {
  try {
    const preference = await preferenceClient.create({
      body: {
        items: [
          {
            id: 'livro-nao-ore-fale-com-o-pai',
            title: 'Não Ore. Fale com o Pai.',
            description: 'Livro digital + acesso ao app O Secreto',
            quantity: 1,
            unit_price: 47.00,
            currency_id: 'BRL',
          },
        ],
        payer: {
          email: 'test_user_123@testuser.com',
        },
        external_reference: 'test_user_123@testuser.com',
        statement_descriptor: 'NAO ORE FALE PAI',
      },
    });

    return NextResponse.json({
      message: 'Preference created successfully!',
      preference_id: preference.id,
      checkout_url: preference.init_point,
      sandbox_url: preference.sandbox_init_point,
      instructions: {
        step1: 'Open the sandbox_url in an incognito browser window',
        step2: 'Login as your test buyer account',
        step3: 'Use test card: 5031 4332 1540 6351 (Mastercard)',
        step4: 'Security code: 123, Expiry: 11/30',
        step5: 'Name: APRO (for approved payment)',
        step6: 'CPF: 12345678909',
      },
    });
  } catch (error) {
    console.error('[Test Checkout] Error:', error);
    return NextResponse.json(
      { error: 'Failed to create preference', details: String(error) },
      { status: 500 }
    );
  }
}
