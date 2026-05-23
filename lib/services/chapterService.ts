import { createClient } from '@/lib/supabase/server';
import { parseChapter, extractMessages } from '@/lib/parsers/contentParser';
import type { 
  Chapter, 
  ChapterMessage, 
  ContentDisplayMessage 
} from '@/lib/types/domain.types';

/**
 * Chapter Service
 * 
 * Provides chapter data operations:
 * - Fetch all chapters in sequential order
 * - Get specific chapter by ID
 * - Parse chapter content into message blocks
 * - Validate chapter access based on user progress
 * 
 * Requirements: 1.3, 5.1
 */

export interface ChapterServiceResult<T> {
  data: T | null;
  error: string | null;
}

/**
 * Get all chapters ordered by chapter_number
 * 
 * Retrieves all chapters from the database in sequential order.
 * 
 * @returns ChapterServiceResult with array of chapters or error
 * 
 * **Validates: Requirements 1.3**
 */
export async function getAllChapters(): Promise<ChapterServiceResult<Chapter[]>> {
  try {
    const supabase = await createClient();
    
    const { data, error } = await supabase
      .from('chapters')
      .select('*')
      .order('chapter_number', { ascending: true });

    if (error) {
      console.error('Error fetching chapters:', error);
      return {
        data: null,
        error: 'Erro ao carregar capítulos. Tente novamente.',
      };
    }

    if (!data) {
      return {
        data: [],
        error: null,
      };
    }

    return {
      data: data as Chapter[],
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching chapters:', error);
    return {
      data: null,
      error: 'Erro inesperado ao carregar capítulos.',
    };
  }
}

/**
 * Get a specific chapter by ID
 * 
 * Retrieves a single chapter from the database.
 * 
 * @param chapterId - The UUID of the chapter to retrieve
 * @returns ChapterServiceResult with chapter or error
 * 
 * **Validates: Requirements 1.1, 1.3**
 */
export async function getChapterById(
  chapterId: string
): Promise<ChapterServiceResult<Chapter>> {
  try {
    const supabase = await createClient();
    
    const { data, error } = await supabase
      .from('chapters')
      .select('*')
      .eq('id', chapterId)
      .single();

    if (error) {
      console.error('Error fetching chapter:', error);
      return {
        data: null,
        error: 'Erro ao carregar capítulo. Tente novamente.',
      };
    }

    if (!data) {
      return {
        data: null,
        error: 'Capítulo não encontrado.',
      };
    }

    return {
      data: data as Chapter,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching chapter:', error);
    return {
      data: null,
      error: 'Erro inesperado ao carregar capítulo.',
    };
  }
}

/**
 * Get chapter messages parsed for display
 * 
 * Extracts and formats chapter content into display-ready message blocks.
 * Messages are returned in order specified by the content.
 * 
 * @param chapterId - The UUID of the chapter
 * @returns ChapterServiceResult with array of content messages or error
 * 
 * **Validates: Requirements 1.2, 2.1**
 */
export async function getChapterMessages(
  chapterId: string
): Promise<ChapterServiceResult<ContentDisplayMessage[]>> {
  try {
    const result = await getChapterById(chapterId);
    
    if (result.error || !result.data) {
      return {
        data: null,
        error: result.error || 'Capítulo não encontrado.',
      };
    }

    const chapter = result.data;
    
    // Parse and validate chapter content using content parser
    try {
      const parsedContent = parseChapter(chapter.content);
      const messages = extractMessages(parsedContent);

      // Convert to display format
      const displayMessages: ContentDisplayMessage[] = messages.map((msg: ChapterMessage) => ({
        type: 'content' as const,
        id: msg.id,
        content: msg.content,
        order: msg.order,
      }));

      return {
        data: displayMessages,
        error: null,
      };
    } catch (parseError) {
      // Content parser throws descriptive errors in Portuguese
      const errorMessage = parseError instanceof Error 
        ? parseError.message 
        : 'Conteúdo do capítulo inválido.';
      
      console.error('Error parsing chapter content:', parseError);
      return {
        data: null,
        error: errorMessage,
      };
    }
  } catch (error) {
    console.error('Unexpected error parsing chapter messages:', error);
    return {
      data: null,
      error: 'Erro ao processar mensagens do capítulo.',
    };
  }
}

/**
 * Validate chapter access for sequential unlocking
 * 
 * Checks if a user has access to a specific chapter based on their progress.
 * Users can only access chapters if all preceding chapters are completed.
 * The first chapter (chapter_number = 1) is always accessible.
 * 
 * @param chapterId - The UUID of the chapter to validate access for
 * @param userId - The UUID of the user
 * @returns ChapterServiceResult with boolean indicating access permission
 * 
 * **Validates: Requirements 1.5, 5.1**
 */
export async function validateChapterAccess(
  chapterId: string,
  userId: string
): Promise<ChapterServiceResult<boolean>> {
  try {
    const supabase = await createClient();
    
    // Get the target chapter
    const chapterResult = await getChapterById(chapterId);
    if (chapterResult.error || !chapterResult.data) {
      return {
        data: false,
        error: chapterResult.error || 'Capítulo não encontrado.',
      };
    }

    const targetChapter = chapterResult.data;

    // First chapter is always accessible
    if (targetChapter.chapter_number === 1) {
      return {
        data: true,
        error: null,
      };
    }

    // Get all chapters with chapter_number less than target chapter
    const { data: precedingChapters, error: chaptersError } = await supabase
      .from('chapters')
      .select('id, chapter_number')
      .lt('chapter_number', targetChapter.chapter_number);

    if (chaptersError) {
      console.error('Error fetching preceding chapters:', chaptersError);
      return {
        data: false,
        error: 'Erro ao verificar acesso ao capítulo.',
      };
    }

    if (!precedingChapters || precedingChapters.length === 0) {
      // No preceding chapters, access granted
      return {
        data: true,
        error: null,
      };
    }

    // Get user's progress for preceding chapters
    const { data: userProgress, error: progressError } = await supabase
      .from('user_progress')
      .select('chapter_id, status')
      .eq('user_id', userId)
      .in('chapter_id', precedingChapters.map(c => c.id));

    if (progressError) {
      console.error('Error fetching user progress:', progressError);
      return {
        data: false,
        error: 'Erro ao verificar progresso do usuário.',
      };
    }

    // Check if all preceding chapters are completed
    const completedChapterIds = new Set(
      (userProgress || [])
        .filter(p => p.status === 'completed')
        .map(p => p.chapter_id)
    );

    const allPrecedingCompleted = precedingChapters.every(
      chapter => completedChapterIds.has(chapter.id)
    );

    if (!allPrecedingCompleted) {
      return {
        data: false,
        error: 'Complete os capítulos anteriores para acessar este capítulo.',
      };
    }

    return {
      data: true,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error validating chapter access:', error);
    return {
      data: false,
      error: 'Erro inesperado ao verificar acesso ao capítulo.',
    };
  }
}

/**
 * Check if a chapter is the first chapter
 * 
 * Helper function to determine if a chapter is the first in the sequence.
 * 
 * @param chapterId - The UUID of the chapter
 * @returns ChapterServiceResult with boolean indicating if it's the first chapter
 */
export async function isFirstChapter(
  chapterId: string
): Promise<ChapterServiceResult<boolean>> {
  try {
    const result = await getChapterById(chapterId);
    
    if (result.error || !result.data) {
      return {
        data: false,
        error: result.error || 'Capítulo não encontrado.',
      };
    }

    return {
      data: result.data.chapter_number === 1,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error checking first chapter:', error);
    return {
      data: false,
      error: 'Erro ao verificar capítulo.',
    };
  }
}

/**
 * Get the first chapter
 * 
 * Retrieves the first chapter in the sequence (chapter_number = 1).
 * 
 * @returns ChapterServiceResult with the first chapter or error
 * 
 * **Validates: Requirements 5.1**
 */
export async function getFirstChapter(): Promise<ChapterServiceResult<Chapter>> {
  try {
    const supabase = await createClient();
    
    const { data, error } = await supabase
      .from('chapters')
      .select('*')
      .eq('chapter_number', 1)
      .single();

    if (error) {
      console.error('Error fetching first chapter:', error);
      return {
        data: null,
        error: 'Erro ao carregar primeiro capítulo.',
      };
    }

    if (!data) {
      return {
        data: null,
        error: 'Primeiro capítulo não encontrado.',
      };
    }

    return {
      data: data as Chapter,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching first chapter:', error);
    return {
      data: null,
      error: 'Erro inesperado ao carregar primeiro capítulo.',
    };
  }
}
