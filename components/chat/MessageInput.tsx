'use client';

import { useState, KeyboardEvent, FormEvent } from 'react';

interface MessageInputProps {
  onSendMessage: (content: string) => Promise<void>;
  disabled?: boolean;
  placeholder?: string;
}

/**
 * MessageInput Component
 * 
 * Text input with send button for user message submission.
 * Implements enter key submission, input validation, and disabled state.
 * Optimized for mobile keyboards with proper sizing and touch targets.
 * 
 * Requirements: 3.1, 11.1, 11.3
 */
export function MessageInput({ 
  onSendMessage, 
  disabled = false,
  placeholder = 'Escreva sua mensagem...'
}: MessageInputProps) {
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e?: FormEvent) => {
    e?.preventDefault();
    
    // Validate: no empty or whitespace-only messages
    const trimmedMessage = message.trim();
    if (!trimmedMessage || isSubmitting || disabled) {
      return;
    }

    setIsSubmitting(true);
    
    try {
      await onSendMessage(trimmedMessage);
      setMessage(''); // Clear input after successful send
    } catch (error) {
      console.error('Failed to send message:', error);
      // Error handling is done by parent component
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    // Submit on Enter (without Shift)
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  const isDisabled = disabled || isSubmitting;
  const canSend = message.trim().length > 0 && !isDisabled;

  return (
    <form onSubmit={handleSubmit} className="border-t border-gray-800 bg-black p-3 sm:p-4 safe-area-bottom" aria-label="Enviar mensagem">
      <div className="flex items-end gap-2 max-w-4xl mx-auto">
        <div className="flex-1">
          <label htmlFor="message-input" className="sr-only">
            Digite sua mensagem
          </label>
          <textarea
            id="message-input"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder={placeholder}
            disabled={isDisabled}
            rows={1}
            className="w-full bg-gray-900 text-gray-100 rounded-2xl px-3 py-2 sm:px-4 sm:py-3 
                     resize-none focus:outline-none focus:ring-2 focus:ring-indigo-500
                     disabled:opacity-50 disabled:cursor-not-allowed
                     placeholder:text-gray-500 text-sm sm:text-base leading-relaxed
                     min-h-[44px] max-h-[120px] touch-manipulation"
            style={{
              height: 'auto',
              overflowY: message.split('\n').length > 3 ? 'auto' : 'hidden'
            }}
            aria-label="Campo de mensagem"
            aria-describedby="message-hint"
          />
          <span id="message-hint" className="sr-only">
            Pressione Enter para enviar, Shift+Enter para nova linha
          </span>
        </div>
        <button
          type="submit"
          disabled={!canSend}
          className="bg-indigo-600 text-white rounded-full p-2 sm:p-3 
                   hover:bg-indigo-700 focus:bg-indigo-700 active:bg-indigo-800 transition-colors
                   disabled:opacity-50 disabled:cursor-not-allowed
                   focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-black
                   min-w-[44px] min-h-[44px] flex items-center justify-center flex-shrink-0 touch-manipulation"
          aria-label="Enviar mensagem"
        >
          <svg 
            xmlns="http://www.w3.org/2000/svg" 
            viewBox="0 0 24 24" 
            fill="currentColor" 
            className="w-5 h-5"
            aria-hidden="true"
          >
            <path d="M3.478 2.405a.75.75 0 00-.926.94l2.432 7.905H13.5a.75.75 0 010 1.5H4.984l-2.432 7.905a.75.75 0 00.926.94 60.519 60.519 0 0018.445-8.986.75.75 0 000-1.218A60.517 60.517 0 003.478 2.405z" />
          </svg>
        </button>
      </div>
    </form>
  );
}
