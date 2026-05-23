import { createClient } from '@/lib/supabase/client';
import type { Message } from '@/lib/types/domain.types';

/**
 * Client-Side Message Service
 * 
 * Provides message operations for client components:
 * - Create user messages from the browser
 * - Error handling for failed submissions
 * 
 * This service uses the client-side Supabase client and is designed
 * for use in React client components.
 * 
 * Requirements: 3.3, 15.1
 */

export interface MessageResult {
  success: boolean;
  message?: Message;
  error?: string;
}

/**
 * Create a new user message (client-side)
 * 
 * Stores a user message in the database from a client component.
 * Implements validation and error handling for failed submissions.
 * 
 * @param userId - The UUID of the user
 * @param chapterId - The UUID of the chapter
 * @param content - The message content
 * @returns MessageResult with created message or error
 * 
 * **Validates: Requirements 3.3, 15.1**
 */
export async function createMessage(
  userId: string,
  chapterId: string,
  content: string
): Promise<MessageResult> {
  try {
    // Validate input
    const trimmedContent = content.trim();
    if (!trimmedContent) {
      return {
        success: false,
        error: 'Mensagem não pode estar vazia.',
      };
    }

    if (!userId || !chapterId) {
      return {
        success: false,
        error: 'Dados inválidos para enviar mensagem.',
      };
    }

    // Create client-side Supabase client
    const supabase = createClient();

    // Insert message into database
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
      
      // Check for network errors
      if (error.message?.includes('fetch') || error.message?.includes('network')) {
        return {
          success: false,
          error: 'Problema de conexão. Verifique sua internet e tente novamente.',
        };
      }
      
      return {
        success: false,
        error: 'Erro ao salvar mensagem. Tente novamente.',
      };
    }

    if (!data) {
      return {
        success: false,
        error: 'Erro ao criar mensagem.',
      };
    }

    return {
      success: true,
      message: data as Message,
    };
  } catch (error) {
    console.error('Unexpected error creating message:', error);
    
    // Check if it's a network error
    if (error instanceof Error && 
        (error.message.includes('fetch') || 
         error.message.includes('network') || 
         error.message.includes('Failed to fetch'))) {
      return {
        success: false,
        error: 'Problema de conexão. Verifique sua internet e tente novamente.',
      };
    }
    
    return {
      success: false,
      error: 'Erro inesperado ao salvar mensagem.',
    };
  }
}
