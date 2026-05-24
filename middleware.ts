import { type NextRequest, NextResponse } from 'next/server';

/**
 * Next.js Middleware
 * 
 * The entire frontend is the Flutter Web app at /app/.
 * All non-API, non-static routes redirect to the Flutter app.
 */
export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;

  // NEVER touch /app routes - these are Flutter Web static files
  if (pathname.startsWith('/app')) {
    return NextResponse.next();
  }

  // Allow API routes
  if (pathname.startsWith('/api/')) {
    return NextResponse.next();
  }

  // Allow static files and Next.js internals
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/favicon') ||
    pathname.includes('.')
  ) {
    return NextResponse.next();
  }

  // REDIRECT everything else to the Flutter app
  // The Flutter app handles all routing via hash: /app/#/route
  const url = request.nextUrl.clone();
  url.pathname = '/app/';
  return NextResponse.redirect(url);
}

export const config = {
  matcher: [
    // Match all routes except /app, /api, and static files
    '/((?!app|api|_next/static|_next/image|favicon.ico).*)',
  ],
};
