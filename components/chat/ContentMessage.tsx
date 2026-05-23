'use client';

import { ContentDisplayMessage } from '@/lib/types/domain.types';

interface ContentMessageProps {
  message: ContentDisplayMessage;
}

/**
 * ContentMessage Component
 * 
 * Displays content messages (from chapters) with left-aligned styling.
 * Uses dark theme with minimalist design for intimate reading experience.
 * Optimized for mobile with responsive sizing and touch-friendly spacing.
 * 
 * Requirements: 2.3, 2.5, 3.2, 3.4, 11.1, 11.2
 */
export function ContentMessage({ message }: ContentMessageProps) {
  return (
    <div className="flex justify-start mb-3 sm:mb-4 animate-fade-in" role="article">
      <div className="max-w-[90%] sm:max-w-[85%] md:max-w-[75%]">
        <div className="bg-gray-800 text-gray-100 rounded-2xl rounded-tl-sm px-3 py-2 sm:px-4 sm:py-3 shadow-md">
          <p className="text-sm sm:text-base leading-relaxed whitespace-pre-wrap break-words">
            {message.content}
          </p>
        </div>
      </div>
    </div>
  );
}
