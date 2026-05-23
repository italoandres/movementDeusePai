import { createClient } from '@/lib/supabase/server';
import type { SealConditions, SealUnlockReason } from '@/lib/types/domain.types';
import { getUserMessageCount } from './messageService';
import { getProgress } from './progressService';

/**
 * Seal Service
 * 
 * Provides digital seal award operations:
 * - Check if user has earned seal
 * - Award seal to user with reason
 * - Check seal unlock conditions
 * 
 * Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.4, 8.5
 */

export interface SealServiceResult<T> {
  data: T | null;
  error: string | null;
}

/**
 * Check if user has earned the digital seal
 * 
 * Retrieves the user's profile and checks if the seal has been awarded.
 * 
 * @param userId - The UUID of the user
 * @returns SealServiceResult with boolean indicating seal status
 * 
 * **Validates: Requirements 7.3, 7.5**
 */
export async function hasSeal(
  userId: string
): Promise<SealServiceResult<boolean>> {
  try {
    if (!userId) {
      return {
        data: null,
        error: 'ID de usuário inválido.',
      };
    }

    const supabase = await createClient();
    
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('seal_awarded')
      .eq('id', userId)
      .single();

    if (error) {
      console.error('Error checking seal status:', error);
      return {
        data: null,
        error: 'Erro ao verificar selo.',
      };
    }

    if (!profile) {
      return {
        data: null,
        error: 'Perfil não encontrado.',
      };
    }

    return {
      data: profile.seal_awarded || false,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error checking seal status:', error);
    return {
      data: null,
      error: 'Erro inesperado ao verificar selo.',
    };
  }
}

/**
 * Award the digital seal to a user
 * 
 * Updates the user's profile to mark the seal as awarded with the specified reason.
 * The seal can only be awarded once per user.
 * 
 * @param userId - The UUID of the user
 * @param reason - The unlock condition that triggered the award
 * @returns SealServiceResult with success status
 * 
 * **Validates: Requirements 7.1, 7.3, 8.1, 8.2**
 */
export async function awardSeal(
  userId: string,
  reason: SealUnlockReason
): Promise<SealServiceResult<boolean>> {
  try {
    if (!userId) {
      return {
        data: null,
        error: 'ID de usuário inválido.',
      };
    }

    if (!reason || (reason !== 'journey_complete' && reason !== 'first_message')) {
      return {
        data: null,
        error: 'Motivo de desbloqueio inválido.',
      };
    }

    const supabase = await createClient();
    
    // Check if seal is already awarded
    const { data: profile, error: checkError } = await supabase
      .from('profiles')
      .select('seal_awarded')
      .eq('id', userId)
      .single();

    if (checkError) {
      console.error('Error checking seal status:', checkError);
      return {
        data: null,
        error: 'Erro ao verificar selo.',
      };
    }

    if (!profile) {
      return {
        data: null,
        error: 'Perfil não encontrado.',
      };
    }

    // If seal is already awarded, don't award again
    if (profile.seal_awarded) {
      return {
        data: true,
        error: null,
      };
    }

    // Award the seal
    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        seal_awarded: true,
        seal_awarded_at: new Date().toISOString(),
        seal_unlock_reason: reason,
      })
      .eq('id', userId);

    if (updateError) {
      console.error('Error awarding seal:', updateError);
      return {
        data: null,
        error: 'Erro ao conceder selo.',
      };
    }

    return {
      data: true,
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error awarding seal:', error);
    return {
      data: null,
      error: 'Erro inesperado ao conceder selo.',
    };
  }
}

/**
 * Check seal unlock conditions for a user
 * 
 * Evaluates whether the user meets the conditions to receive the digital seal:
 * - Journey complete: All chapters completed
 * - First message: User has sent at least one message
 * 
 * Returns detailed condition status and whether the seal should be awarded.
 * 
 * @param userId - The UUID of the user
 * @returns SealServiceResult with SealConditions object
 * 
 * **Validates: Requirements 7.1, 8.1, 8.2**
 */
export async function checkSealConditions(
  userId: string
): Promise<SealServiceResult<SealConditions>> {
  try {
    if (!userId) {
      return {
        data: null,
        error: 'ID de usuário inválido.',
      };
    }

    // Check if seal is already awarded
    const sealResult = await hasSeal(userId);
    
    if (sealResult.error) {
      return {
        data: null,
        error: sealResult.error,
      };
    }

    // If seal is already awarded, no need to check conditions
    if (sealResult.data) {
      return {
        data: {
          journeyComplete: false,
          firstMessageSent: false,
          shouldAward: false,
        },
        error: null,
      };
    }

    // Check journey completion
    const progressResult = await getProgress(userId);
    
    if (progressResult.error) {
      return {
        data: null,
        error: progressResult.error,
      };
    }

    const journeyComplete = progressResult.data
      ? progressResult.data.completedChapters === progressResult.data.totalChapters
      : false;

    // Check if user has sent at least one message
    const messageCountResult = await getUserMessageCount(userId);
    
    if (messageCountResult.error) {
      return {
        data: null,
        error: messageCountResult.error,
      };
    }

    const firstMessageSent = (messageCountResult.data ?? 0) > 0;

    // Determine if seal should be awarded
    // For now, we use journey completion as the default unlock condition
    // Alternative unlock (first message) can be configured later
    const shouldAward = journeyComplete;

    return {
      data: {
        journeyComplete,
        firstMessageSent,
        shouldAward,
      },
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error checking seal conditions:', error);
    return {
      data: null,
      error: 'Erro inesperado ao verificar condições do selo.',
    };
  }
}

/**
 * Get seal information for a user
 * 
 * Retrieves complete seal information including award status, date, and reason.
 * 
 * @param userId - The UUID of the user
 * @returns SealServiceResult with seal information
 */
export async function getSealInfo(
  userId: string
): Promise<SealServiceResult<{
  awarded: boolean;
  awardedAt: string | null;
  unlockReason: SealUnlockReason | null;
}>> {
  try {
    if (!userId) {
      return {
        data: null,
        error: 'ID de usuário inválido.',
      };
    }

    const supabase = await createClient();
    
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('seal_awarded, seal_awarded_at, seal_unlock_reason')
      .eq('id', userId)
      .single();

    if (error) {
      console.error('Error fetching seal info:', error);
      return {
        data: null,
        error: 'Erro ao buscar informações do selo.',
      };
    }

    if (!profile) {
      return {
        data: null,
        error: 'Perfil não encontrado.',
      };
    }

    return {
      data: {
        awarded: profile.seal_awarded || false,
        awardedAt: profile.seal_awarded_at || null,
        unlockReason: profile.seal_unlock_reason as SealUnlockReason | null,
      },
      error: null,
    };
  } catch (error) {
    console.error('Unexpected error fetching seal info:', error);
    return {
      data: null,
      error: 'Erro inesperado ao buscar informações do selo.',
    };
  }
}
