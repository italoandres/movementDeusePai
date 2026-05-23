'use client';

import { useState, useEffect, useRef } from 'react';
import { DisplayMessage } from '@/lib/types/domain.types';
import { ContentMessage } from './ContentMessage';
import { UserMessage } from './UserMessage';
import { MessageInput } from './MessageInput';

interface ChatContainerProps {
  initialMessages: DisplayMessage[];
  currentChapterId: string;
  userId: string;
  canSendMessage?: boolean;
  onSendMessage: (content: string, chapterId: string, userId: string) => Promise<void>;
}

/**
 * ChatContainer Component
 * 
 * Main chat wrapper with state management, message list rendering,
 * and auto-scroll behavior. Optimized for mobile with smooth scrolling
 * and proper spacing.
 * 
 * Requirements: 2.1, 2.2, 11.1, 11.4
 */
export function ChatContainer({
  initialMessages,
  currentChapterId,
  userId,
  canSendMessage = true,
  onSendMessage
}: ChatContainerProps) {
  const [messages, setMessages] = useState<DisplayMessage[]>(initialMessages);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const messagesContainerRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when messages change
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // Update messages when initialMessages prop changes (e.g., chapter navigation)
  useEffect(() => {
    setMessages(initialMessages);
  }, [initialMessages]);

  const handleSendMessage = async (content: string) => {
    setIsSubmitting(true);
    
    try {
      // Optimistic UI update
      const optimisticMessage: DisplayMessage = {
        type: 'user',
        id: `temp-${Date.now()}`,
        content,
        created_at: new Date().toISOString()
      };
      
      setMessages(prev => [...prev, optimisticMessage]);
      
      // Call parent handler to persist message
      await onSendMessage(content, currentChapterId, userId);
      
      // Note: In a real implementation, we might want to replace the optimistic
      // message with the actual message from the server, but for now we keep it
      // since the server response would be identical
      
    } catch (error) {
      // Remove optimistic message on error
      setMessages(prev => prev.filter(m => !m.id.startsWith('temp-')));
      throw error; // Re-throw so MessageInput can handle it
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="flex flex-col h-full bg-black">
      {/* Messages Area */}
      <div 
        ref={messagesContainerRef}
        className="flex-1 overflow-y-auto px-3 py-4 sm:px-4 sm:py-6 space-y-1 overscroll-behavior-contain"
        style={{ WebkitOverflowScrolling: 'touch' }}
        role="log"
        aria-live="polite"
        aria-label="Mensagens do capítulo"
      >
        <div className="max-w-4xl mx-auto">
          {messages.map((message) => {
            if (message.type === 'content') {
              return <ContentMessage key={message.id} message={message} />;
            } else {
              return <UserMessage key={message.id} message={message} />;
            }
          })}
          {/* Scroll anchor */}
          <div ref={messagesEndRef} aria-hidden="true" />
        </div>
      </div>

      {/* Message Input */}
      {canSendMessage && (
        <MessageInput 
          onSendMessage={handleSendMessage}
          disabled={isSubmitting}
        />
      )}
    </div>
  );
}
