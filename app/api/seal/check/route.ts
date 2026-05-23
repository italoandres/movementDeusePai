import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { checkSealConditions, awardSeal } from '@/lib/services/sealService';

/**
 * Seal Check API Route
 * 
 * Checks seal unlock conditions and awards seal if conditions are met.
 * This endpoint is called after chapter completion or message submission.
 * 
 * Requirements: 7.1, 8.1, 8.2
 */
export async function POST() {
  try {
    const supabase = await createClient();
    
    // Get authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json(
        { error: 'Não autenticado.' },
        { status: 401 }
      );
    }

    // Check seal conditions
    const conditionsResult = await checkSealConditions(user.id);

    if (conditionsResult.error) {
      return NextResponse.json(
        { error: conditionsResult.error },
        { status: 500 }
      );
    }

    if (!conditionsResult.data) {
      return NextResponse.json(
        { error: 'Erro ao verificar condições do selo.' },
        { status: 500 }
      );
    }

    const { shouldAward, journeyComplete } = conditionsResult.data;

    // If seal should be awarded, award it
    if (shouldAward) {
      const reason = journeyComplete ? 'journey_complete' : 'first_message';
      const awardResult = await awardSeal(user.id, reason);

      if (awardResult.error) {
        return NextResponse.json(
          { error: awardResult.error },
          { status: 500 }
        );
      }

      return NextResponse.json({
        awarded: true,
        reason,
        conditions: conditionsResult.data,
      });
    }

    return NextResponse.json({
      awarded: false,
      conditions: conditionsResult.data,
    });
  } catch (error) {
    console.error('Seal check error:', error);
    return NextResponse.json(
      { error: 'Erro inesperado ao verificar selo.' },
      { status: 500 }
    );
  }
}
