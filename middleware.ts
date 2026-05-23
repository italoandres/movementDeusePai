import { type NextRequest } from 'next/server';
import { createClient } from '@/lib/supabase/middleware';

/**
 * Next.js Middleware for Authentication
 * 
 * Protects routes that require authentication by validating the user's session.
 * Redirects unauthenticated users to the login page with appropriate messaging.
 * Handles session expiration detection and refresh.
 * 
 * Protected routes:
 * - /journey - Main chat interface
 * - /profile - User profile page
 * 
 * Requirements: 9.5, 14.2, 14.4
 */
export async function middleware(request: NextRequest) {
  const { supabase, response } = await createClient(request);

  // Refresh session if expired - required for Server Components
  const { data: { user }, error } = await supabase.auth.getUser();

  // If no user or error, redirect to login
  if (error || !user) {
    const loginUrl = new URL('/login', request.url);
    
    // Add redirect parameter to return user to intended destination after login
    loginUrl.searchParams.set('redirect', request.nextUrl.pathname);
    
    // Add reason parameter to show appropriate message
    // Check if error indicates session expiration
    if (error && (
      error.message.includes('expired') ||
      error.message.includes('invalid') ||
      error.message.includes('JWT')
    )) {
      loginUrl.searchParams.set('reason', 'session_expired');
    }
    
    return Response.redirect(loginUrl);
  }

  // User is authenticated, allow request to proceed
  return response;
}

/**
 * Middleware Configuration
 * 
 * Specifies which routes should be protected by authentication.
 * Uses Next.js matcher to apply middleware only to specific paths.
 */
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     * - auth routes (login, signup)
     * - landing page (/)
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$|login|signup|$).*)',
  ],
};
