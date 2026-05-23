'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

/**
 * ChapterCompletionHandler Component
 * 
 * Client component that handles chapter completion logic.
 * Provides a button to mark chapter as complete and triggers seal checking.
 * Optimized for mobile with proper touch targets.
 * 
 * Requirements: 1.4, 4.2, 7.1, 11.3
 */

interface ChapterCompletionHandlerProps {
  userId: string;
  chapterId: string;
  isCompleted: boolean;
  onComplete?: () => void;
}

export default function ChapterCompletionHandler({
  chapterId,
  isCompleted,
  onComplete,
}: ChapterCompletionHandlerProps) {
  const [isCompleting, setIsCompleting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleCompleteChapter = async () => {
    if (isCompleting || isCompleted) return;

    setIsCompleting(true);
    setError(null);

    try {
      // Call API to complete chapter
      const response = await fetch('/api/progress/complete', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          chapterId,
        }),
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Erro ao completar capítulo.');
      }

      // Trigger seal check (non-blocking)
      fetch('/api/seal/check', {
        method: 'POST',
      }).catch(err => {
        console.error('Seal check failed:', err);
        // Don't block completion on seal check failure
      });

      // Refresh the page to update progress
      router.refresh();
      
      onComplete?.();
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro inesperado.';
      setError(errorMessage);
      console.error('Failed to complete chapter:', errorMessage);
    } finally {
      setIsCompleting(false);
    }
  };

  if (isCompleted) {
    return (
      <div className="text-center py-3 sm:py-4">
        <div 
          className="inline-flex items-center gap-2 px-3 py-2 sm:px-4 sm:py-2 bg-green-900/30 border border-green-700 text-green-400 rounded-lg text-sm sm:text-base"
          role="status"
          aria-label="Capítulo completado"
        >
          <svg
            className="w-4 h-4 sm:w-5 sm:h-5 flex-shrink-0"
            fill="currentColor"
            viewBox="0 0 20 20"
            aria-hidden="true"
          >
            <path
              fillRule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
              clipRule="evenodd"
            />
          </svg>
          <span className="font-medium">Capítulo completado</span>
        </div>
      </div>
    );
  }

  return (
    <div className="text-center py-3 sm:py-4 space-y-2">
      <button
        onClick={handleCompleteChapter}
        disabled={isCompleting}
        className="px-5 py-2.5 sm:px-6 sm:py-3 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 focus:bg-indigo-700 active:bg-indigo-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950 text-sm sm:text-base min-h-[44px] touch-manipulation"
        aria-label={isCompleting ? 'Completando capítulo' : 'Marcar capítulo como completado'}
      >
        {isCompleting ? 'Completando...' : 'Marcar como completado'}
      </button>
      
      {error && (
        <p className="text-xs sm:text-sm text-red-400 px-2" role="alert" aria-live="assertive">
          {error}
        </p>
      )}
    </div>
  );
}
