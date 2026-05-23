import { type NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/middleware';

/**
 * Next.js Middleware for Authentication
 */
export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

  // NEVER touch /app routes - these are Flutter Web static files
  if (pathname.startsWith('/app')) {
    return NextResponse.next();
  }

  // Skip API routes for webhooks
  if (pathname.startsWith('/api/')) {
    return NextResponse.next();
  }

  // Skip public routes
  const publicRoutes = ['/login', '/signup', '/'];
  if (publicRoutes.includes(pathname)) {
    return NextResponse.next();
  }

  // For protected routes, check auth
  const { supabase, response } = await createClient(request);
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('redirect', pathname);
    return Response.redirect(loginUrl);
  }

  return response;
}

export const config = {
  matcher: [
    // Only match specific protected routes, NOT /app
    '/journey/:path*',
    '/profile/:path*',
  ],
};
