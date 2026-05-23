'use client';

import { useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { SESSION_CONFIG, shouldRefreshSession } from '@/lib/config/session.config';

/**
 * Session Refresh Hook
 * 
 * Automatically refreshes the user session when it's about to expire.
 * Redirects to login if session cannot be refreshed.
 * 
 * This hook should be used in the root layout or main protected pages
 * to ensure continuous session management.
 * 
 * Requirements: 14.2, 14.3, 14.4
 */
export function useSessionRefresh() {
  const router = useRouter();
  const supabase = createClient();

  const checkAndRefreshSession = useCallback(async () => {
    try {
      // Get current session
      const { data: { session }, error } = await supabase.auth.getSession();

      if (error) {
        console.error('Error getting session:', error);
        return;
      }

      // No session - user is not authenticated
      if (!session) {
        return;
      }

      // Check if session needs refresh
      if (session.expires_at && shouldRefreshSession(session.expires_at)) {
        console.log('Session about to expire, refreshing...');
        
        // Attempt to refresh the session
        const { data: { session: newSession }, error: refreshError } = 
          await supabase.auth.refreshSession();

        if (refreshError) {
          console.error('Error refreshing session:', refreshError);
          
          // Session refresh failed - redirect to login
          const loginUrl = new URL('/login', window.location.origin);
          loginUrl.searchParams.set('redirect', window.location.pathname);
          loginUrl.searchParams.set('reason', 'session_expired');
          router.push(loginUrl.toString());
          return;
        }

        if (newSession) {
          console.log('Session refreshed successfully');
        }
      }
    } catch (error) {
      console.error('Error in session refresh check:', error);
    }
  }, [supabase, router]);

  useEffect(() => {
    // Check session immediately on mount
    checkAndRefreshSession();

    // Set up periodic session checks
    const intervalId = setInterval(
      checkAndRefreshSession,
      SESSION_CONFIG.SESSION_CHECK_INTERVAL_MS
    );

    // Set up auth state change listener
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event) => {
        if (event === 'SIGNED_OUT') {
          // User signed out - redirect to landing page
          router.push('/');
        } else if (event === 'TOKEN_REFRESHED') {
          console.log('Token refreshed by Supabase');
        } else if (event === 'USER_UPDATED') {
          console.log('User updated');
        }
      }
    );

    // Cleanup
    return () => {
      clearInterval(intervalId);
      subscription.unsubscribe();
    };
  }, [checkAndRefreshSession, supabase, router]);
}
