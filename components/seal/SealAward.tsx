'use client';

import { useEffect, useState } from 'react';

/**
 * SealAward Component
 * 
 * Award notification/animation component.
 * Displays when seal is awarded with celebratory styling.
 * Optimized for mobile with responsive sizing and touch-friendly buttons.
 * 
 * Requirements: 7.4, 8.4, 11.1, 11.3
 */

interface SealAwardProps {
  show: boolean;
  onClose?: () => void;
  reason?: 'journey_complete' | 'first_message';
}

export default function SealAward({
  show,
  onClose,
  reason = 'journey_complete',
}: SealAwardProps) {
  const [isVisible, setIsVisible] = useState(false);
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    if (show) {
      setIsVisible(true);
      // Trigger animation after mount
      setTimeout(() => setIsAnimating(true), 50);
    } else {
      setIsAnimating(false);
      // Wait for animation to complete before hiding
      setTimeout(() => setIsVisible(false), 300);
    }
  }, [show]);

  if (!isVisible) {
    return null;
  }

  const getMessage = () => {
    if (reason === 'first_message') {
      return 'Você deu o primeiro passo! Bem-vindo ao movimento.';
    }
    return 'Parabéns! Você completou sua jornada.';
  };

  return (
    <div
      className={`fixed inset-0 z-50 flex items-center justify-center p-4 transition-all duration-300 ${
        isAnimating ? 'bg-black/60 backdrop-blur-sm' : 'bg-black/0'
      }`}
      onClick={onClose}
    >
      <div
        className={`relative max-w-md w-full transition-all duration-500 transform ${
          isAnimating
            ? 'scale-100 opacity-100 translate-y-0'
            : 'scale-75 opacity-0 translate-y-8'
        }`}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Celebration particles */}
        <div className="absolute inset-0 pointer-events-none">
          {[...Array(12)].map((_, i) => (
            <div
              key={i}
              className={`absolute w-2 h-2 bg-gradient-to-r from-yellow-400 to-pink-500 rounded-full animate-float-${
                (i % 4) + 1
              }`}
              style={{
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`,
                animationDelay: `${Math.random() * 2}s`,
              }}
            />
          ))}
        </div>

        {/* Award card */}
        <div className="relative bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 rounded-3xl p-6 sm:p-8 shadow-2xl">
          {/* Close button */}
          {onClose && (
            <button
              onClick={onClose}
              className="absolute top-3 right-3 sm:top-4 sm:right-4 w-10 h-10 flex items-center justify-center rounded-full bg-white/20 hover:bg-white/30 active:bg-white/40 transition-colors min-h-[44px] min-w-[44px] touch-manipulation"
              aria-label="Fechar"
            >
              <svg
                className="w-5 h-5 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          )}

          {/* Content */}
          <div className="text-center">
            {/* Animated seal icon */}
            <div className="flex justify-center mb-4 sm:mb-6">
              <div
                className={`w-20 h-20 sm:w-24 sm:h-24 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm transition-transform duration-700 ${
                  isAnimating ? 'scale-100 rotate-0' : 'scale-0 rotate-180'
                }`}
              >
                <svg
                  className="w-12 h-12 sm:w-16 sm:h-16 text-white"
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

            {/* Title */}
            <h2 className="text-2xl sm:text-3xl font-bold text-white mb-2 sm:mb-3">
              Selo Conquistado!
            </h2>

            {/* Message */}
            <p className="text-base sm:text-lg text-white/90 mb-4 sm:mb-6">{getMessage()}</p>

            {/* Seal text */}
            <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-4 sm:p-6 mb-4 sm:mb-6">
              <p className="text-lg sm:text-xl font-semibold text-white mb-1">
                Faço parte do movimento
              </p>
              <p className="text-xl sm:text-2xl font-bold text-white">Deus é Pai</p>
            </div>

            {/* Action button */}
            {onClose && (
              <button
                onClick={onClose}
                className="w-full px-6 py-3 bg-white text-purple-600 font-semibold rounded-xl hover:bg-gray-100 active:bg-gray-200 transition-colors shadow-lg text-sm sm:text-base min-h-[44px] touch-manipulation"
              >
                Continuar
              </button>
            )}
          </div>
        </div>
      </div>

      <style jsx>{`
        @keyframes float-1 {
          0%,
          100% {
            transform: translateY(0) translateX(0);
            opacity: 0;
          }
          50% {
            transform: translateY(-100px) translateX(20px);
            opacity: 1;
          }
        }
        @keyframes float-2 {
          0%,
          100% {
            transform: translateY(0) translateX(0);
            opacity: 0;
          }
          50% {
            transform: translateY(-120px) translateX(-20px);
            opacity: 1;
          }
        }
        @keyframes float-3 {
          0%,
          100% {
            transform: translateY(0) translateX(0);
            opacity: 0;
          }
          50% {
            transform: translateY(-90px) translateX(30px);
            opacity: 1;
          }
        }
        @keyframes float-4 {
          0%,
          100% {
            transform: translateY(0) translateX(0);
            opacity: 0;
          }
          50% {
            transform: translateY(-110px) translateX(-30px);
            opacity: 1;
          }
        }
        .animate-float-1 {
          animation: float-1 3s ease-in-out infinite;
        }
        .animate-float-2 {
          animation: float-2 3s ease-in-out infinite;
        }
        .animate-float-3 {
          animation: float-3 3s ease-in-out infinite;
        }
        .animate-float-4 {
          animation: float-4 3s ease-in-out infinite;
        }
      `}</style>
    </div>
  );
}
