'use client';

import { useState } from 'react';
import { ChatContainer } from './ChatContainer';
import { DisplayMessage } from '@/lib/types/domain.types';
import { createMessage } from '@/lib/services/messageService.client';
import SealChecker from '@/components/seal/SealChecker';

interface ChatWrapperProps {
  initialMessages: DisplayMessage[];
  currentChapterId: string;
  userId: string;
  canSendMessage?: boolean;
}

/**
 * ChatWrapper Component
 * 
 * Client-side wrapper for ChatContainer that handles message submission
 * to the database using the client-side message service.
 * 
 * Implements optimistic UI updates and error handling for failed submissions.
 * Triggers seal checking after message submission.
 * 
 * Requirements: 3.3, 8.1, 8.4, 15.1
 */
export function ChatWrapper({
  initialMessages,
  currentChapterId,
  userId,
  canSendMessage = true,
}: ChatWrapperProps) {
  const [error, setError] = useState<string | null>(null);
  const [triggerSealCheck, setTriggerSealCheck] = useState(false);

  const handleSendMessage = async (
    content: string,
    chapterId: string,
    userId: string
  ): Promise<void> => {
    try {
      setError(null);

      // Call client-side message service to persist message
      const result = await createMessage(userId, chapterId, content);

      if (!result.success) {
        throw new Error(result.error || 'Erro ao salvar mensagem.');
      }

      // Success - trigger seal check after message submission
      setTriggerSealCheck(true);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado ao salvar mensagem.';
      setError(errorMessage);
      
      // Log error and re-throw so ChatContainer can handle it
      console.error('Failed to send message:', errorMessage);
      throw err;
    }
  };

  const handleSealCheckComplete = () => {
    setTriggerSealCheck(false);
  };

  return (
    <div className="flex flex-col h-full">
      {/* Error notification */}
      {error && (
        <div className="bg-red-900/50 border border-red-700 text-red-200 px-4 py-3 text-sm">
          <div className="max-w-4xl mx-auto flex items-center justify-between">
            <span>{error}</span>
            <button
              onClick={() => setError(null)}
              className="text-red-200 hover:text-white ml-4"
              aria-label="Fechar"
            >
              ✕
            </button>
          </div>
        </div>
      )}

      {/* Chat interface */}
      <ChatContainer
        initialMessages={initialMessages}
        currentChapterId={currentChapterId}
        userId={userId}
        canSendMessage={canSendMessage}
        onSendMessage={handleSendMessage}
      />

      {/* Seal checker */}
      <SealChecker
        userId={userId}
        triggerCheck={triggerSealCheck}
        onCheckComplete={handleSealCheckComplete}
      />
    </div>
  );
}
