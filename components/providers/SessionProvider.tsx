'use client';

import { useSessionRefresh } from '@/lib/hooks/useSessionRefresh';

/**
 * Session Provider Component
 * 
 * Wraps protected routes to provide automatic session refresh functionality.
 * Should be used in layouts for protected routes.
 * 
 * Requirements: 14.2, 14.3, 14.4
 */
export function SessionProvider({ children }: { children: React.ReactNode }) {
  // Initialize session refresh hook
  useSessionRefresh();

  return <>{children}</>;
}
