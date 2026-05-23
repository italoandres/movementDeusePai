import { NextRequest, NextResponse } from 'next/server';
import { preferenceClient } from '@/lib/mercadopago/client';

/**
 * POST /api/checkout/create-preference
 * 
 * Creates a Mercado Pago Checkout Pro preference.
 * Called when user clicks "quero começar essa caminhada" on the sales page.
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email } = body;

    if (!email || typeof email !== 'string') {
      return NextResponse.json(
        { error: 'Email é obrigatório' },
        { status: 400 }
      );
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';

    const preference = await preferenceClient.create({
      body: {
        items: [
          {
            id: 'livro-nao-ore-fale-com-o-pai',
            title: 'Não Ore. Fale com o Pai.',
            description: 'Livro digital + acesso ao app O Secreto',
            quantity: 1,
            unit_price: 57.00,
            currency_id: 'BRL',
          },
        ],
        payer: {
          email,
        },
        back_urls: {
          success: `${appUrl}/app/#/obrigado`,
          failure: `${appUrl}/app/#/journey/sales`,
          pending: `${appUrl}/app/#/obrigado`,
        },
        auto_return: 'approved',
        notification_url: `${appUrl}/api/webhooks/mercadopago`,
        external_reference: email,
        statement_descriptor: 'NAO ORE FALE PAI',
      },
    });

    return NextResponse.json({
      id: preference.id,
      init_point: preference.init_point,
    });
  } catch (error) {
    console.error('[Checkout] Error creating preference:', error);
    return NextResponse.json(
      { error: 'Erro ao criar preferência de pagamento' },
      { status: 500 }
    );
  }
}
