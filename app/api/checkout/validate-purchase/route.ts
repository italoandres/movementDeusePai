import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

/**
 * POST /api/checkout/validate-purchase
 *
 * Validates that a purchase exists for the given email before allowing
 * account creation with book access. Called by the Flutter app's
 * ProfileService.validatePurchaseByEmail(email).
 *
 * Server-side only — uses service role key.
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

    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('[ValidatePurchase] Missing Supabase environment variables');
      return NextResponse.json(
        { error: 'Server configuration error' },
        { status: 500 }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data, error } = await supabase
      .from('purchases')
      .select('id, product_id')
      .eq('email', email.toLowerCase().trim())
      .eq('access_released', true)
      .limit(1)
      .single();

    if (error && error.code !== 'PGRST116') {
      // PGRST116 = "no rows found" — that's a valid "not found" case
      console.error('[ValidatePurchase] Database error:', error.message);
      return NextResponse.json(
        { error: 'Erro ao verificar compra' },
        { status: 500 }
      );
    }

    if (data) {
      return NextResponse.json({ valid: true, product_id: data.product_id });
    }

    return NextResponse.json({ valid: false });
  } catch (error) {
    console.error('[ValidatePurchase] Unexpected error:', error);
    return NextResponse.json(
      { error: 'Erro interno do servidor' },
      { status: 500 }
    );
  }
}
