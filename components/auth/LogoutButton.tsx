'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { signOut } from '@/lib/services/authService';

/**
 * Logout Button Component
 * 
 * Provides a button to sign out the current user.
 * Terminates the session and redirects to the landing page.
 * Optimized for mobile with proper touch targets.
 * 
 * Requirements: 14.5, 11.3
 */
export default function LogoutButton() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  const handleLogout = async () => {
    setIsLoading(true);

    try {
      const result = await signOut();

      if (result.success) {
        // Redirect to landing page after successful logout
        router.push('/');
        router.refresh();
      } else {
        console.error('Logout failed:', result.error);
        alert(result.error || 'Erro ao sair. Tente novamente.');
      }
    } catch (error) {
      console.error('Logout error:', error);
      alert('Erro ao sair. Tente novamente.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <button
      onClick={handleLogout}
      disabled={isLoading}
      className="px-3 py-2 sm:px-4 sm:py-2 bg-gray-800 hover:bg-gray-700 focus:bg-gray-700 active:bg-gray-600 disabled:bg-gray-900 disabled:cursor-not-allowed text-white text-xs sm:text-sm font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-gray-600 focus:ring-offset-2 focus:ring-offset-gray-950 min-h-[44px] touch-manipulation"
      aria-label={isLoading ? 'Saindo da conta' : 'Sair da conta'}
    >
      {isLoading ? 'Saindo...' : 'Sair'}
    </button>
  );
}
