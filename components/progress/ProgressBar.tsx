'use client';

/**
 * ProgressBar Component
 * 
 * Displays visual progress indicator showing:
 * - Completion percentage bar
 * - Completed vs total chapters count
 * - Current chapter highlight
 * 
 * Optimized for mobile with responsive text sizing.
 * 
 * Requirements: 4.1, 4.2, 4.4, 11.1, 11.2
 */

interface ProgressBarProps {
  totalChapters: number;
  completedChapters: number;
  currentChapterIndex: number;
  percentComplete: number;
}

export default function ProgressBar({
  totalChapters,
  completedChapters,
  currentChapterIndex,
  percentComplete,
}: ProgressBarProps) {
  return (
    <section 
      className="w-full bg-zinc-900 border-b border-zinc-800 p-3 sm:p-4"
      aria-label="Progresso da jornada"
    >
      <div className="max-w-4xl mx-auto space-y-2 sm:space-y-3">
        {/* Progress text */}
        <div className="flex items-center justify-between text-xs sm:text-sm">
          <span className="text-zinc-400">
            Sua jornada
          </span>
          <span className="text-zinc-300 font-medium" aria-label={`${completedChapters} de ${totalChapters} capítulos completados`}>
            {completedChapters} de {totalChapters} capítulos
          </span>
        </div>

        {/* Progress bar */}
        <div 
          className="relative w-full h-2 bg-zinc-800 rounded-full overflow-hidden"
          role="progressbar"
          aria-valuenow={percentComplete}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-label={`Progresso da jornada: ${percentComplete}%`}
        >
          <div
            className="absolute top-0 left-0 h-full bg-gradient-to-r from-blue-600 to-blue-500 transition-all duration-500 ease-out"
            style={{ width: `${percentComplete}%` }}
          />
        </div>

        {/* Current chapter indicator */}
        {completedChapters < totalChapters && (
          <div className="text-xs text-zinc-500" aria-live="polite">
            Capítulo atual: {currentChapterIndex + 1}
          </div>
        )}

        {/* Journey complete message */}
        {completedChapters === totalChapters && totalChapters > 0 && (
          <div className="text-xs text-blue-400 font-medium" role="status" aria-live="polite">
            ✓ Jornada completa
          </div>
        )}
      </div>
    </section>
  );
}
