'use client';

/**
 * DigitalSeal Component
 * 
 * Displays the digital seal with text "Faço parte do movimento Deus é Pai".
 * Supports full and compact variants.
 * Shows award date if available.
 * Optimized for mobile with responsive sizing.
 * 
 * Requirements: 7.2, 7.5, 11.1, 11.2
 */

interface DigitalSealProps {
  awarded: boolean;
  awardedAt?: string | null;
  variant?: 'full' | 'compact';
}

export default function DigitalSeal({
  awarded,
  awardedAt,
  variant = 'full',
}: DigitalSealProps) {
  if (!awarded) {
    return null;
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
    });
  };

  if (variant === 'compact') {
    return (
      <div 
        className="inline-flex items-center gap-1.5 sm:gap-2 px-2 py-1.5 sm:px-3 sm:py-2 bg-gradient-to-r from-indigo-600 to-purple-600 rounded-lg min-h-[44px] touch-manipulation"
        role="img"
        aria-label="Selo digital do movimento Deus é Pai"
      >
        <svg
          className="w-4 h-4 sm:w-5 sm:h-5 text-white flex-shrink-0"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
        >
          <path
            fillRule="evenodd"
            d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
            clipRule="evenodd"
          />
        </svg>
        <span className="text-xs sm:text-sm font-medium text-white">
          Movimento Deus é Pai
        </span>
      </div>
    );
  }

  return (
    <article 
      className="w-full max-w-md mx-auto"
      role="img"
      aria-label={`Selo digital do movimento Deus é Pai${awardedAt ? `, concedido em ${formatDate(awardedAt)}` : ''}`}
    >
      <div className="relative bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 rounded-2xl p-6 sm:p-8 shadow-2xl">
        {/* Decorative background pattern */}
        <div className="absolute inset-0 opacity-10" aria-hidden="true">
          <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <pattern
                id="seal-pattern"
                x="0"
                y="0"
                width="40"
                height="40"
                patternUnits="userSpaceOnUse"
              >
                <circle cx="20" cy="20" r="1" fill="white" />
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#seal-pattern)" />
          </svg>
        </div>

        {/* Content */}
        <div className="relative z-10 text-center">
          {/* Seal icon */}
          <div className="flex justify-center mb-4 sm:mb-6" aria-hidden="true">
            <div className="w-16 h-16 sm:w-20 sm:h-20 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm">
              <svg
                className="w-10 h-10 sm:w-12 sm:h-12 text-white"
                fill="currentColor"
                viewBox="0 0 20 20"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  fillRule="evenodd"
                  d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clipRule="evenodd"
                />
              </svg>
            </div>
          </div>

          {/* Seal text */}
          <h3 className="text-xl sm:text-2xl font-bold text-white mb-1 sm:mb-2">
            Faço parte do movimento
          </h3>
          <p className="text-2xl sm:text-3xl font-extrabold text-white mb-4 sm:mb-6">
            Deus é Pai
          </p>

          {/* Award date */}
          {awardedAt && (
            <footer className="pt-4 sm:pt-6 border-t border-white/20">
              <p className="text-xs sm:text-sm text-white/80">
                Concedido em {formatDate(awardedAt)}
              </p>
            </footer>
          )}
        </div>
      </div>
    </article>
  );
}
