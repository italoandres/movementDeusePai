import { createClient } from '@/lib/supabase/server';
import type { 
  Chapter, 
  UserProgress,
  JourneyProgress,
  ChapterProgress
} from '@/lib/types/domain.types';

/**
 * Progress Service
 * 
 * Provides progress tracking operations:
 * - Initialize progress for new users
 * - Get user progress with chapter completion status
 * - Mark chapters as completed
 * - Check if chapters are unlocked
 * - Get next unlocked chapter
 * 
 * Requirements: 1.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.3, 5.4
 */

export interface ProgressServiceResult<T> {
  data: T | null;
  error: string | null;
}

/**
 * Initialize progress for a new user
 * 
 * Creates initial progress records for all chapters.
 * The first chapter is marked as unlocked by default.
 * 
 * @param userId - The UUID of the user
 * @returns ProgressServiceResult with success status
 * 
 * **Validates: Requirements 5.1**
 */
export async function initializeProgress(
  userId: string
): Promise<ProgressServiceResult<boolean>> {
  try {
    const supabase = await createClient();
    
    // Check if progress already exists
    const { data: existingProgress, error: checkError } = await supabase
      .from('user_progress')
      .select('id')
      .eq('user_id', userId)
      .limit(1);

    if (checkError) {
      console.error('Error checking existing progress:', checkError);
      return {
        data: null,
        error: 'Erro ao verificar progresso existente.',
      };
    }

    // If progress already exists, don't reinitialize
    if (existingProgress && existingProgress.length > 0) {
      return {
        data: true,
        error: null,
      };
    }

    // Get all chapters
    const { data: chapters, error: chaptersError } = await supabase
      .from('chapters')
      .select('id, chapter_number')
      .order('chapter_number', { ascending: true });

    if (chaptersError) {
      console.error('Error fetching chapters:', chaptersError);
      return {
        data: null,
        error: 'Erro ao carregar capítulos.',
      };
    }

    if (!chapters || chapters.length === 0) {
      return {
        data: null,
        error: 'Nenhum capítulo encontrado.',
      };
    }

    // Create progress records for all chapters
    const progressRecords = chapters.map(chapter => ({
      user_id: userId,
      chapter_id: chapter.id,
      status: 'locked' as const,
    }));

    const { error: insertError } = await supabase
      .from('user_progress')
      .insert(progressRecords);

    if (insertError) {
      console.error('Error initializing progress:', insertError);
      return {
        data: null,
        error: 'Erro ao inicializar progresso.',
      };
    }

    return {
      data: true,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error initializing progress:', error);
    return {
      data: null,
      error: 'Erro inesperado ao inicializar progresso.',
    };
  }
}

/**
 * Get user's journey progress with chapter completion status
 * 
 * Retrieves comprehensive progress information including:
 * - Total chapters
 * - Completed chapters count
 * - Current chapter index
 * - Completion percentage
 * - Detailed chapter progress with unlock status
 * 
 * Optimized to reduce N+1 queries by fetching chapters and progress together.
 * 
 * @param userId - The UUID of the user
 * @returns ProgressServiceResult with JourneyProgress or error
 * 
 * **Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**
 */
export async function getProgress(
  userId: string
): Promise<ProgressServiceResult<JourneyProgress>> {
  try {
    const supabase = await createClient();
    
    // Get all chapters
    const { data: chapters, error: chaptersError } = await supabase
      .from('chapters')
      .select('*')
      .order('chapter_number', { ascending: true });

    if (chaptersError) {
      console.error('Error fetching chapters:', chaptersError);
      return {
        data: null,
        error: 'Erro ao carregar capítulos.',
      };
    }

    if (!chapters || chapters.length === 0) {
      return {
        data: null,
        error: 'Nenhum capítulo encontrado.',
      };
    }

    // Get user progress for all chapters in a single query
    const { data: userProgress, error: progressError } = await supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId);

    if (progressError) {
      console.error('Error fetching user progress:', progressError);
      return {
        data: null,
        error: 'Erro ao carregar progresso do usuário.',
      };
    }

    // Create a map of chapter_id to progress for O(1) lookup
    const progressMap = new Map<string, UserProgress>();
    (userProgress || []).forEach(progress => {
      progressMap.set(progress.chapter_id, progress as UserProgress);
    });

    // Build chapter progress array
    const chapterProgressList: ChapterProgress[] = [];
    let completedCount = 0;
    let currentChapterIndex = 0;
    let foundIncomplete = false;

    for (const chapter of chapters) {
      const progress = progressMap.get(chapter.id);
      const completed = progress?.status === 'completed';
      
      if (completed) {
        completedCount++;
      } else if (!foundIncomplete) {
        // First incomplete chapter is the current chapter
        currentChapterIndex = chapter.chapter_number - 1; // 0-indexed
        foundIncomplete = true;
      }

      // Determine if chapter is unlocked
      // First chapter is always unlocked
      // Other chapters are unlocked if all previous chapters are completed
      let unlocked = false;
      if (chapter.chapter_number === 1) {
        unlocked = true;
      } else {
        // Check if all previous chapters are completed
        const previousChapters = chapters.filter(
          c => c.chapter_number < chapter.chapter_number
        );
        unlocked = previousChapters.every(prevChapter => {
          const prevProgress = progressMap.get(prevChapter.id);
          return prevProgress?.status === 'completed';
        });
      }

      chapterProgressList.push({
        chapter: chapter as Chapter,
        completed,
        unlocked,
        completedAt: progress?.completed_at || null,
      });
    }

    // If all chapters are completed, current chapter is the last one
    if (!foundIncomplete) {
      currentChapterIndex = chapters.length - 1;
    }

    const totalChapters = chapters.length;
    const percentComplete = totalChapters > 0 
      ? Math.round((completedCount / totalChapters) * 100) 
      : 0;

    const journeyProgress: JourneyProgress = {
      totalChapters,
      completedChapters: completedCount,
      currentChapterIndex,
      percentComplete,
      chapters: chapterProgressList,
    };

    return {
      data: journeyProgress,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching progress:', error);
    return {
      data: null,
      error: 'Erro inesperado ao carregar progresso.',
    };
  }
}

/**
 * Mark a chapter as completed
 * 
 * Updates the user's progress to mark a specific chapter as completed.
 * Sets the completed_at timestamp to the current time.
 * 
 * @param userId - The UUID of the user
 * @param chapterId - The UUID of the chapter to mark as completed
 * @returns ProgressServiceResult with updated progress or error
 * 
 * **Validates: Requirements 1.4, 4.2**
 */
export async function completeChapter(
  userId: string,
  chapterId: string
): Promise<ProgressServiceResult<UserProgress>> {
  try {
    const supabase = await createClient();
    
    // Check if progress record exists
    const { data: existingProgress, error: checkError } = await supabase
      .from('user_progress')
      .select('*')
      .eq('user_id', userId)
      .eq('chapter_id', chapterId)
      .single();

    if (checkError && checkError.code !== 'PGRST116') {
      // PGRST116 is "not found" error, which is expected if no record exists
      console.error('Error checking progress:', checkError);
      return {
        data: null,
        error: 'Erro ao verificar progresso.',
      };
    }

    if (existingProgress) {
      // Update existing progress
      const { data, error } = await supabase
        .from('user_progress')
        .update({
          status: 'completed',
          completed_at: new Date().toISOString(),
          progress_percentage: 100,
        })
        .eq('user_id', userId)
        .eq('chapter_id', chapterId)
        .select()
        .single();

      if (error) {
        console.error('Error updating progress:', error);
        return {
          data: null,
          error: 'Erro ao atualizar progresso.',
        };
      }

      return {
        data: data as UserProgress,
        error: null,
      };
    } else {
      // Create new progress record
      const { data, error } = await supabase
        .from('user_progress')
        .insert({
          user_id: userId,
          chapter_id: chapterId,
          status: 'completed',
          completed_at: new Date().toISOString(),
          progress_percentage: 100,
        })
        .select()
        .single();

      if (error) {
        console.error('Error creating progress:', error);
        return {
          data: null,
          error: 'Erro ao criar progresso.',
        };
      }

      return {
        data: data as UserProgress,
        error: null,
      };
    }
  } catch (error) {
    console.error('Unexpected error completing chapter:', error);
    return {
      data: null,
      error: 'Erro inesperado ao completar capítulo.',
    };
  }
}

/**
 * Check if a chapter is unlocked for a user
 * 
 * Determines if a user has access to a specific chapter based on sequential unlocking.
 * The first chapter is always unlocked.
 * Other chapters are unlocked only if all previous chapters are completed.
 * 
 * @param userId - The UUID of the user
 * @param chapterId - The UUID of the chapter to check
 * @returns ProgressServiceResult with boolean indicating unlock status
 * 
 * **Validates: Requirements 1.5, 5.1, 5.2, 5.3, 5.4**
 */
export async function isChapterUnlocked(
  userId: string,
  chapterId: string
): Promise<ProgressServiceResult<boolean>> {
  try {
    const supabase = await createClient();
    
    // Get the target chapter
    const { data: chapter, error: chapterError } = await supabase
      .from('chapters')
      .select('id, chapter_number')
      .eq('id', chapterId)
      .single();

    if (chapterError) {
      console.error('Error fetching chapter:', chapterError);
      return {
        data: null,
        error: 'Erro ao carregar capítulo.',
      };
    }

    if (!chapter) {
      return {
        data: null,
        error: 'Capítulo não encontrado.',
      };
    }

    // First chapter is always unlocked
    if (chapter.chapter_number === 1) {
      return {
        data: true,
        error: null,
      };
    }

    // Get all chapters with chapter_number less than target chapter
    const { data: precedingChapters, error: precedingError } = await supabase
      .from('chapters')
      .select('id, chapter_number')
      .lt('chapter_number', chapter.chapter_number);

    if (precedingError) {
      console.error('Error fetching preceding chapters:', precedingError);
      return {
        data: null,
        error: 'Erro ao verificar capítulos anteriores.',
      };
    }

    if (!precedingChapters || precedingChapters.length === 0) {
      // No preceding chapters, chapter is unlocked
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
        data: null,
        error: 'Erro ao verificar progresso.',
      };
    }

    // Check if all preceding chapters are completed
    const completedChapterIds = new Set(
      (userProgress || [])
        .filter(p => p.status === 'completed')
        .map(p => p.chapter_id)
    );

    const allPrecedingCompleted = precedingChapters.every(
      prevChapter => completedChapterIds.has(prevChapter.id)
    );

    return {
      data: allPrecedingCompleted,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error checking chapter unlock:', error);
    return {
      data: null,
      error: 'Erro inesperado ao verificar acesso ao capítulo.',
    };
  }
}

/**
 * Get the next unlocked chapter for a user
 * 
 * Finds the next chapter that the user should read based on their progress.
 * Returns the first incomplete chapter that is unlocked.
 * If all chapters are completed, returns null.
 * 
 * @param userId - The UUID of the user
 * @returns ProgressServiceResult with next chapter or null if journey complete
 * 
 * **Validates: Requirements 5.2**
 */
export async function getNextChapter(
  userId: string
): Promise<ProgressServiceResult<Chapter | null>> {
  try {
    const supabase = await createClient();
    
    // Get all chapters in order
    const { data: chapters, error: chaptersError } = await supabase
      .from('chapters')
      .select('*')
      .order('chapter_number', { ascending: true });

    if (chaptersError) {
      console.error('Error fetching chapters:', chaptersError);
      return {
        data: null,
        error: 'Erro ao carregar capítulos.',
      };
    }

    if (!chapters || chapters.length === 0) {
      return {
        data: null,
        error: 'Nenhum capítulo encontrado.',
      };
    }

    // Get user progress
    const { data: userProgress, error: progressError } = await supabase
      .from('user_progress')
      .select('chapter_id, status')
      .eq('user_id', userId);

    if (progressError) {
      console.error('Error fetching user progress:', progressError);
      return {
        data: null,
        error: 'Erro ao carregar progresso.',
      };
    }

    // Create a map of completed chapters
    const completedChapterIds = new Set(
      (userProgress || [])
        .filter(p => p.status === 'completed')
        .map(p => p.chapter_id)
    );

    // Find the first incomplete chapter
    for (const chapter of chapters) {
      if (!completedChapterIds.has(chapter.id)) {
        // Check if this chapter is unlocked
        const unlockResult = await isChapterUnlocked(userId, chapter.id);
        
        if (unlockResult.error) {
          return {
            data: null,
            error: unlockResult.error,
          };
        }

        if (unlockResult.data) {
          return {
            data: chapter as Chapter,
            error: null,
          };
        }
      }
    }

    // All chapters completed
    return {
      data: null,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error getting next chapter:', error);
    return {
      data: null,
      error: 'Erro inesperado ao buscar próximo capítulo.',
    };
  }
}
