'use client';

import { useRouter } from 'next/navigation';

/**
 * Journey Button Component
 * 
 * CTA button that navigates unauthenticated users to signup page.
 * This component is used on the landing page.
 * 
 * Navigation logic:
 * - Unauthenticated users → /signup
 * - (Authenticated users are already redirected to /journey by the landing page)
 * 
 * **Validates: Requirements 6.3, 6.4**
 */
export default function JourneyButton() {
  const router = useRouter();

  const handleClick = () => {
    console.log('Button clicked - navigating to signup');
    try {
      // Navigate to signup page for new users
      router.push('/signup');
    } catch (error) {
      console.error('Navigation error:', error);
    }
  };

  return (
    <button
      onClick={handleClick}
      className="inline-flex items-center justify-center px-6 py-3 sm:px-8 sm:py-4 text-base sm:text-lg font-semibold text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 focus:outline-none focus:ring-4 focus:ring-indigo-500 focus:ring-opacity-50 transition-all duration-200 transform hover:scale-105 active:scale-95 min-h-[44px] min-w-[120px] touch-manipulation"
      aria-label="Começar minha jornada espiritual"
    >
      Começar minha jornada
    </button>
  );
}
