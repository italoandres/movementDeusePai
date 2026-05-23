import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { getSealInfo } from '@/lib/services/sealService';

/**
 * Seal Status API Route
 * 
 * Retrieves the user's seal information including award status, date, and reason.
 * 
 * Requirements: 7.3, 7.5
 */
export async function GET() {
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

    // Get seal information
    const sealResult = await getSealInfo(user.id);

    if (sealResult.error) {
      return NextResponse.json(
        { error: sealResult.error },
        { status: 500 }
      );
    }

    if (!sealResult.data) {
      return NextResponse.json(
        { error: 'Erro ao buscar informações do selo.' },
        { status: 500 }
      );
    }

    return NextResponse.json(sealResult.data);
  } catch (error) {
    console.error('Seal status error:', error);
    return NextResponse.json(
      { error: 'Erro inesperado ao buscar selo.' },
      { status: 500 }
    );
  }
}
