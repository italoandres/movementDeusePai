'use client';

import { UserDisplayMessage } from '@/lib/types/domain.types';

interface UserMessageProps {
  message: UserDisplayMessage;
}

/**
 * UserMessage Component
 * 
 * Displays user-submitted messages with right-aligned styling.
 * Uses distinct visual styling from content messages with dark theme.
 * Optimized for mobile with responsive sizing and touch-friendly spacing.
 * 
 * Requirements: 2.3, 2.5, 3.2, 3.4, 11.1, 11.2
 */
export function UserMessage({ message }: UserMessageProps) {
  const formattedTime = new Date(message.created_at).toLocaleTimeString('pt-BR', {
    hour: '2-digit',
    minute: '2-digit'
  });
  
  return (
    <div className="flex justify-end mb-3 sm:mb-4 animate-fade-in" role="article">
      <div className="max-w-[90%] sm:max-w-[85%] md:max-w-[75%]">
        <div className="bg-indigo-600 text-white rounded-2xl rounded-tr-sm px-3 py-2 sm:px-4 sm:py-3 shadow-md">
          <p className="text-sm sm:text-base leading-relaxed whitespace-pre-wrap break-words">
            {message.content}
          </p>
        </div>
        <div className="text-xs text-gray-500 mt-1 text-right" aria-label={`Enviado às ${formattedTime}`}>
          <time dateTime={message.created_at}>
            {formattedTime}
          </time>
        </div>
      </div>
    </div>
  );
}
