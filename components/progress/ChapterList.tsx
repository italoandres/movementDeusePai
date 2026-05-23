'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import type { ChapterProgress } from '@/lib/types/domain.types';

/**
 * ChapterList Component
 * 
 * Displays all chapters with:
 * - Completion status (checkmark for completed)
 * - Lock indicators for locked chapters
 * - Current chapter highlight
 * - Prevention of navigation to locked chapters
 * - Client-side navigation to unlocked chapters
 * 
 * Optimized for mobile with touch-friendly targets and responsive text.
 * 
 * Requirements: 4.4, 5.3, 5.4, 11.1, 11.3
 */

interface ChapterListProps {
  chapters: ChapterProgress[];
  currentChapterIndex: number;
  onChapterSelect?: (chapterId: string) => void;
}

export default function ChapterList({
  chapters,
  currentChapterIndex,
  onChapterSelect,
}: ChapterListProps) {
  // Only use router if onChapterSelect is not provided
  let router;
  try {
    // eslint-disable-next-line react-hooks/rules-of-hooks
    router = !onChapterSelect ? useRouter() : undefined;
  } catch {
    // Router not available (e.g., in tests)
    router = undefined;
  }
  
  const [attemptedLockedChapter, setAttemptedLockedChapter] = useState<string | null>(null);

  const handleChapterClick = (chapterProgress: ChapterProgress) => {
    if (!chapterProgress.unlocked) {
      // Show locked message
      setAttemptedLockedChapter(chapterProgress.chapter.id);
      setTimeout(() => setAttemptedLockedChapter(null), 3000);
      return;
    }

    // Navigate to unlocked chapter
    if (onChapterSelect) {
      onChapterSelect(chapterProgress.chapter.id);
    } else if (router) {
      // Default navigation behavior
      router.push(`/journey?chapterId=${chapterProgress.chapter.id}`);
    }
  };

  return (
    <nav className="w-full bg-zinc-900 border-b border-zinc-800" aria-label="Lista de capítulos">
      <div className="max-w-4xl mx-auto p-3 sm:p-4">
        <h2 id="chapters-heading" className="text-base sm:text-lg font-semibold text-zinc-200 mb-3 sm:mb-4">
          Capítulos
        </h2>

        <ul className="space-y-2" role="list" aria-labelledby="chapters-heading">
          {chapters.map((chapterProgress, index) => {
            const isCurrentChapter = index === currentChapterIndex;
            const isLocked = !chapterProgress.unlocked;
            const isCompleted = chapterProgress.completed;
            const showLockedMessage = attemptedLockedChapter === chapterProgress.chapter.id;

            return (
              <li key={chapterProgress.chapter.id}>
                <button
                  onClick={() => handleChapterClick(chapterProgress)}
                  disabled={isLocked}
                  className={`
                    w-full text-left p-3 sm:p-4 rounded-lg border transition-all min-h-[44px] touch-manipulation
                    ${isCurrentChapter 
                      ? 'bg-zinc-800 border-blue-600 shadow-lg shadow-blue-900/20' 
                      : 'bg-zinc-800/50 border-zinc-700 hover:border-zinc-600 focus:border-zinc-600'
                    }
                    ${isLocked 
                      ? 'opacity-60 cursor-not-allowed' 
                      : 'cursor-pointer hover:bg-zinc-800 focus:bg-zinc-800 active:bg-zinc-700'
                    }
                    focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:ring-offset-zinc-900
                  `}
                  aria-label={`Capítulo ${(chapterProgress.chapter as any).order_index || ''}: ${chapterProgress.chapter.title}${isCompleted ? ', completado' : ''}${isLocked ? ', bloqueado' : ''}${isCurrentChapter ? ', atual' : ''}`}
                  aria-current={isCurrentChapter ? 'page' : undefined}
                  aria-disabled={isLocked}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2 sm:gap-3 flex-1 min-w-0">
                      {/* Status icon */}
                      <div className="flex-shrink-0 w-5 h-5 sm:w-6 sm:h-6 flex items-center justify-center" aria-hidden="true">
                        {isCompleted && (
                          <svg
                            className="w-4 h-4 sm:w-5 sm:h-5 text-green-500"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M5 13l4 4L19 7"
                            />
                          </svg>
                        )}
                        {isLocked && !isCompleted && (
                          <svg
                            className="w-4 h-4 sm:w-5 sm:h-5 text-zinc-500"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                            />
                          </svg>
                        )}
                        {!isCompleted && !isLocked && (
                          <div className="w-4 h-4 sm:w-5 sm:h-5 rounded-full border-2 border-zinc-600" />
                        )}
                      </div>

                      {/* Chapter info */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="text-xs sm:text-sm font-medium text-zinc-400">
                            Capítulo {chapterProgress.chapter.order_index}
                          </span>
                          {isCurrentChapter && (
                            <span className="text-xs px-2 py-0.5 bg-blue-600/20 text-blue-400 rounded-full whitespace-nowrap">
                              Atual
                            </span>
                          )}
                        </div>
                        <h3 className={`
                          text-sm sm:text-base font-medium mt-1 truncate
                          ${isLocked ? 'text-zinc-500' : 'text-zinc-200'}
                        `}>
                          {chapterProgress.chapter.title}
                        </h3>
                      </div>
                    </div>

                    {/* Arrow indicator for unlocked chapters */}
                    {!isLocked && (
                      <svg
                        className="w-4 h-4 sm:w-5 sm:h-5 text-zinc-600 flex-shrink-0"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 5l7 7-7 7"
                        />
                      </svg>
                    )}
                  </div>
                </button>

                {/* Locked chapter message */}
                {showLockedMessage && (
                  <div 
                    className="mt-2 p-2 sm:p-3 bg-amber-900/20 border border-amber-800/50 rounded-lg"
                    role="alert"
                    aria-live="polite"
                  >
                    <p className="text-xs sm:text-sm text-amber-400">
                      Complete os capítulos anteriores para desbloquear este capítulo.
                    </p>
                  </div>
                )}
              </li>
            );
          })}
        </ul>
      </div>
    </nav>
  );
}
