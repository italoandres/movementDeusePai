import { createClient } from '@/lib/supabase/server';
import type { Message } from '@/lib/types/domain.types';

/**
 * Message Service
 * 
 * Provides message data operations:
 * - Create user messages
 * - Retrieve messages by chapter
 * - Get all user messages
 * - Count user messages
 * 
 * Requirements: 3.3, 10.1, 15.1
 */

export interface MessageServiceResult<T> {
  data: T | null;
  error: string | null;
}

/**
 * Create a new user message
 * 
 * Stores a user message in the database associated with the user's ID
 * and the current chapter ID.
 * 
 * @param userId - The UUID of the user
 * @param chapterId - The UUID of the chapter
 * @param content - The message content
 * @returns MessageServiceResult with created message or error
 * 
 * **Validates: Requirements 3.3, 10.1**
 */
export async function createMessage(
  userId: string,
  chapterId: string,
  content: string
): Promise<MessageServiceResult<Message>> {
  try {
    // Validate input
    const trimmedContent = content.trim();
    if (!trimmedContent) {
      return {
        data: null,
        error: 'Mensagem não pode estar vazia.',
      };
    }

    if (!userId || !chapterId) {
      return {
        data: null,
        error: 'Dados inválidos para criar mensagem.',
      };
    }

    const supabase = await createClient();
    
    const { data, error } = await supabase
      .from('messages')
      .insert({
        user_id: userId,
        chapter_id: chapterId,
        content: trimmedContent,
      })
      .select()
      .single();

    if (error) {
      console.error('Error creating message:', error);
      return {
        data: null,
        error: 'Erro ao salvar mensagem. Tente novamente.',
      };
    }

    if (!data) {
      return {
        data: null,
        error: 'Erro ao criar mensagem.',
      };
    }

    return {
      data: data as Message,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error creating message:', error);
    return {
      data: null,
      error: 'Erro inesperado ao salvar mensagem.',
    };
  }
}

/**
 * Get all messages for a user in a specific chapter
 * 
 * Retrieves all messages submitted by a user within a specific chapter,
 * ordered by creation time (oldest first).
 * 
 * @param userId - The UUID of the user
 * @param chapterId - The UUID of the chapter
 * @returns MessageServiceResult with array of messages or error
 * 
 * **Validates: Requirements 3.3, 10.1**
 */
export async function getMessagesByChapter(
  userId: string,
  chapterId: string
): Promise<MessageServiceResult<Message[]>> {
  try {
    if (!userId || !chapterId) {
      return {
        data: null,
        error: 'Dados inválidos para buscar mensagens.',
      };
    }

    const supabase = await createClient();
    
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('user_id', userId)
      .eq('chapter_id', chapterId)
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Error fetching messages by chapter:', error);
      return {
        data: null,
        error: 'Erro ao carregar mensagens. Tente novamente.',
      };
    }

    return {
      data: (data as Message[]) || [],
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching messages by chapter:', error);
    return {
      data: null,
      error: 'Erro inesperado ao carregar mensagens.',
    };
  }
}

/**
 * Get all messages for a user across all chapters
 * 
 * Retrieves all messages submitted by a user throughout their journey,
 * ordered by creation time (oldest first).
 * 
 * @param userId - The UUID of the user
 * @returns MessageServiceResult with array of messages or error
 * 
 * **Validates: Requirements 10.1, 10.4**
 */
export async function getAllUserMessages(
  userId: string
): Promise<MessageServiceResult<Message[]>> {
  try {
    if (!userId) {
      return {
        data: null,
        error: 'ID de usuário inválido.',
      };
    }

    const supabase = await createClient();
    
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Error fetching all user messages:', error);
      return {
        data: null,
        error: 'Erro ao carregar mensagens. Tente novamente.',
      };
    }

    return {
      data: (data as Message[]) || [],
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching all user messages:', error);
    return {
      data: null,
      error: 'Erro inesperado ao carregar mensagens.',
    };
  }
}

/**
 * Get the count of messages submitted by a user
 * 
 * Returns the total number of messages a user has submitted across all chapters.
 * This is used for seal unlock conditions and progress tracking.
 * 
 * @param userId - The UUID of the user
 * @returns MessageServiceResult with message count or error
 * 
 * **Validates: Requirements 8.1, 10.1**
 */
export async function getUserMessageCount(
  userId: string
): Promise<MessageServiceResult<number>> {
  try {
    if (!userId) {
      return {
        data: null,
        error: 'ID de usuário inválido.',
      };
    }

    const supabase = await createClient();
    
    const { count, error } = await supabase
      .from('messages')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId);

    if (error) {
      console.error('Error counting user messages:', error);
      return {
        data: null,
        error: 'Erro ao contar mensagens.',
      };
    }

    return {
      data: count ?? 0,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error counting user messages:', error);
    return {
      data: null,
      error: 'Erro inesperado ao contar mensagens.',
    };
  }
}
