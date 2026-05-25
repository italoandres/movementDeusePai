import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

/**
 * POST /api/checkout/check-access
 * 
 * Diagnostic endpoint: checks and fixes access for an email.
 * If a purchase exists with access_released=true but profile doesn't have
 * has_book_access=true, it fixes the profile.
 * 
 * Body: { "email": "user@email.com" }
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email } = body;

    if (!email || typeof email !== 'string') {
      return NextResponse.json({ error: 'Email required' }, { status: 400 });
    }

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
    );

    // Check purchases
    const { data: purchase } = await supabase
      .from('purchases')
      .select('*')
      .eq('email', email)
      .eq('access_released', true)
      .maybeSingle();

    // Check profile
    const { data: profile } = await supabase
      .from('profiles')
      .select('id, email, access_type, has_book_access')
      .eq('email', email)
      .maybeSingle();

    const result: Record<string, unknown> = {
      email,
      purchase: purchase ? { id: purchase.id, status: purchase.status, access_released: purchase.access_released } : null,
      profile: profile || null,
    };

    // If purchase exists but profile doesn't have book access, fix it
    if (purchase && profile && !profile.has_book_access) {
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ access_type: 'book', has_book_access: true })
        .eq('id', profile.id);

      if (updateError) {
        result.fixAttempt = 'failed';
        result.fixError = updateError.message;
      } else {
        result.fixAttempt = 'success — profile updated to book access';
      }
    } else if (purchase && !profile) {
      result.note = 'Purchase exists but no profile found with this email. User may need to create account first.';
    } else if (!purchase) {
      result.note = 'No purchase found for this email with access_released=true.';
    } else if (profile?.has_book_access) {
      result.note = 'Profile already has book access. Everything is correct.';
    }

    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 });
  }
}
