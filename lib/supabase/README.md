# Supabase Client Utilities

This directory contains three Supabase client utilities for different contexts in the Next.js application.

## Files Overview

### `client.ts` - Browser Client
Use this in **Client Components** (components with `'use client'` directive).

**Example usage:**
```typescript
'use client'

import { createClient } from '@/lib/supabase/client'
import { useEffect, useState } from 'react'

export function MyClientComponent() {
  const [user, setUser] = useState(null)
  const supabase = createClient()

  useEffect(() => {
    const getUser = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      setUser(user)
    }
    getUser()
  }, [])

  return <div>User: {user?.email}</div>
}
```

### `server.ts` - Server Client
Use this in **Server Components**, **Server Actions**, and **Route Handlers**.

**Example usage in Server Component:**
```typescript
import { createClient } from '@/lib/supabase/server'

export default async function MyServerComponent() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  return <div>User: {user?.email}</div>
}
```

**Example usage in Route Handler:**
```typescript
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = await createClient()
  const { data, error } = await supabase.from('chapters').select('*')

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json(data)
}
```

### `middleware.ts` - Middleware Client
Use this in **Next.js Middleware** (`middleware.ts` in the root directory).

**Example usage:**
```typescript
import { createClient } from '@/lib/supabase/middleware'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  const { supabase, response } = await createClient(request)

  // Refresh session if expired
  const { data: { user } } = await supabase.auth.getUser()

  // Protect routes
  if (!user && request.nextUrl.pathname.startsWith('/journey')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return response
}

export const config = {
  matcher: ['/journey/:path*', '/profile/:path*']
}
```

## When to Use Each Client

| Context | Client to Use | File |
|---------|---------------|------|
| Client Component (`'use client'`) | Browser Client | `client.ts` |
| Server Component | Server Client | `server.ts` |
| Server Action | Server Client | `server.ts` |
| Route Handler (`app/api/*`) | Server Client | `server.ts` |
| Middleware (`middleware.ts`) | Middleware Client | `middleware.ts` |

## Key Differences

- **Browser Client**: Runs in the browser, has access to browser APIs, handles cookies automatically
- **Server Client**: Runs on the server, has access to server-side cookies via Next.js `cookies()` API
- **Middleware Client**: Runs in Next.js middleware, handles session refresh and cookie management for protected routes

## Authentication Flow

1. **User signs in** → Session stored in HTTP-only cookies
2. **Middleware** → Refreshes session on each request if needed
3. **Server Components** → Read session from cookies to fetch user-specific data
4. **Client Components** → Access session for client-side interactions

## Important Notes

- All clients use the same environment variables (`NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`)
- Sessions are stored in HTTP-only cookies for security
- The middleware client automatically refreshes expired sessions
- Always use `await` when calling `createClient()` for server and middleware clients
