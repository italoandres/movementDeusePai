import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { completeChapter } from '@/lib/services/progressService';

/**
 * Chapter Completion API Route
 * 
 * Marks a chapter as completed for the authenticated user.
 * 
 * Requirements: 1.4, 4.2
 */
export async function POST(request: NextRequest) {
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

    // Parse request body
    const body = await request.json();
    const { chapterId } = body;

    if (!chapterId) {
      return NextResponse.json(
        { error: 'ID do capítulo é obrigatório.' },
        { status: 400 }
      );
    }

    // Complete the chapter
    const result = await completeChapter(user.id, chapterId);

    if (result.error) {
      return NextResponse.json(
        { error: result.error },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      progress: result.data,
    });
  } catch (error) {
    console.error('Chapter completion error:', error);
    return NextResponse.json(
      { error: 'Erro inesperado ao completar capítulo.' },
      { status: 500 }
    );
  }
}
