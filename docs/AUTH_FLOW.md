# Authentication Flow Documentation

## Overview

This document describes the authentication flow implemented in Task 3.2 for the Interactive Spiritual Book System.

## Sign Up Flow

```
User                    SignupForm              authService             Supabase
  |                         |                        |                      |
  |--[Fill form]----------->|                        |                      |
  |                         |                        |                      |
  |--[Submit]-------------->|                        |                      |
  |                         |                        |                      |
  |                         |--[Validate form]------>|                      |
  |                         |                        |                      |
  |                         |--[signUp()]----------->|                      |
  |                         |                        |                      |
  |                         |                        |--[auth.signUp()]---->|
  |                         |                        |                      |
  |                         |                        |                      |--[Create user]
  |                         |                        |                      |
  |                         |                        |                      |--[Create session]
  |                         |                        |                      |
  |                         |                        |                      |--[Set HTTP-only cookie]
  |                         |                        |                      |
  |                         |                        |<--[User + Session]---|
  |                         |                        |                      |
  |                         |<--[AuthResult]---------|                      |
  |                         |                        |                      |
  |                         |--[router.push('/journey')]                    |
  |                         |                        |                      |
  |<--[Redirect to journey]-|                        |                      |
  |                         |                        |                      |
```

## Sign In Flow

```
User                    LoginForm               authService             Supabase
  |                         |                        |                      |
  |--[Fill form]----------->|                        |                      |
  |                         |                        |                      |
  |--[Submit]-------------->|                        |                      |
  |                         |                        |                      |
  |                         |--[Validate form]------>|                      |
  |                         |                        |                      |
  |                         |--[signIn()]----------->|                      |
  |                         |                        |                      |
  |                         |                        |--[auth.signInWithPassword()]->|
  |                         |                        |                      |
  |                         |                        |                      |--[Verify credentials]
  |                         |                        |                      |
  |                         |                        |                      |--[Create session]
  |                         |                        |                      |
  |                         |                        |                      |--[Set HTTP-only cookie]
  |                         |                        |                      |
  |                         |                        |<--[User + Session]---|
  |                         |                        |                      |
  |                         |<--[AuthResult]---------|                      |
  |                         |                        |                      |
  |                         |--[router.push('/journey')]                    |
  |                         |                        |                      |
  |<--[Redirect to journey]-|                        |                      |
  |                         |                        |                      |
```

## Sign Out Flow

```
User                  LogoutButton            authService             Supabase
  |                         |                        |                      |
  |--[Click logout]-------->|                        |                      |
  |                         |                        |                      |
  |                         |--[signOut()]---------->|                      |
  |                         |                        |                      |
  |                         |                        |--[auth.signOut()]---->|
  |                         |                        |                      |
  |                         |                        |                      |--[Terminate session]
  |                         |                        |                      |
  |                         |                        |                      |--[Clear cookie]
  |                         |                        |                      |
  |                         |                        |<--[Success]----------|
  |                         |                        |                      |
  |                         |<--[AuthResult]---------|                      |
  |                         |                        |                      |
  |                         |--[router.push('/')]                           |
  |                         |                        |                      |
  |<--[Redirect to landing]-|                        |                      |
  |                         |                        |                      |
```

## Protected Route Access Flow

```
User                  Browser                 Journey Page            Supabase
  |                         |                        |                      |
  |--[Navigate to /journey]>|                        |                      |
  |                         |                        |                      |
  |                         |--[Request page]------->|                      |
  |                         |                        |                      |
  |                         |                        |--[createClient()]---->|
  |                         |                        |                      |
  |                         |                        |--[auth.getUser()]---->|
  |                         |                        |                      |
  |                         |                        |                      |--[Validate session cookie]
  |                         |                        |                      |
  |                         |                        |<--[User data]--------|
  |                         |                        |                      |
  |                         |<--[Render page]--------|                      |
  |                         |                        |                      |
  |<--[Display journey]-----|                        |                      |
  |                         |                        |                      |

--- OR if not authenticated ---

User                  Browser                 Journey Page            Supabase
  |                         |                        |                      |
  |--[Navigate to /journey]>|                        |                      |
  |                         |                        |                      |
  |                         |--[Request page]------->|                      |
  |                         |                        |                      |
  |                         |                        |--[createClient()]---->|
  |                         |                        |                      |
  |                         |                        |--[auth.getUser()]---->|
  |                         |                        |                      |
  |                         |                        |                      |--[No valid session]
  |                         |                        |                      |
  |                         |                        |<--[Error/null]-------|
  |                         |                        |                      |
  |                         |                        |--[redirect('/login')]
  |                         |                        |                      |
  |                         |<--[Redirect]-----------|                      |
  |                         |                        |                      |
  |<--[Display login]-------|                        |                      |
  |                         |                        |                      |
```

## Error Handling Flow

```
User                    Component               authService             Supabase
  |                         |                        |                      |
  |--[Submit invalid data]->|                        |                      |
  |                         |                        |                      |
  |                         |--[signIn/signUp()]---->|                      |
  |                         |                        |                      |
  |                         |                        |--[auth operation]---->|
  |                         |                        |                      |
  |                         |                        |                      |--[Validation fails]
  |                         |                        |                      |
  |                         |                        |<--[AuthError]--------|
  |                         |                        |                      |
  |                         |                        |--[mapAuthError()]
  |                         |                        |   (Convert to Portuguese)
  |                         |                        |                      |
  |                         |<--[AuthResult with error]                     |
  |                         |                        |                      |
  |                         |--[Display error message]                      |
  |                         |                        |                      |
  |<--[Show error]----------|                        |                      |
  |                         |                        |                      |
```

## Session Management

### Session Creation
- **When**: User signs up or signs in successfully
- **How**: Supabase creates a session and stores the token in an HTTP-only cookie
- **Duration**: Configurable in Supabase (default: 7 days)
- **Storage**: HTTP-only cookie (secure, not accessible to JavaScript)

### Session Validation
- **When**: User accesses protected routes
- **How**: Server component calls `auth.getUser()` which validates the session cookie
- **Result**: User data if valid, null/error if invalid

### Session Refresh
- **When**: Session token approaches expiration
- **How**: Supabase automatically refreshes the token
- **Transparent**: Happens automatically without user interaction

### Session Termination
- **When**: User clicks logout or session expires
- **How**: `auth.signOut()` terminates session and clears cookie
- **Result**: User redirected to landing page

## Security Features

### HTTP-Only Cookies
- Session tokens stored in HTTP-only cookies
- Not accessible to JavaScript (prevents XSS attacks)
- Automatically sent with requests to Supabase

### Server-Side Validation
- Protected routes validate session on server
- No client-side session checks (prevents tampering)
- Redirect to login if session invalid

### Error Message Security
- Generic error messages don't leak information
- "Email ou senha incorretos" for invalid credentials
- No indication whether email exists in system

### Password Security
- Passwords never stored in plain text
- Hashed by Supabase using bcrypt
- Minimum 6 characters enforced

## API Reference

### authService Functions

#### `signUp(data: SignUpData): Promise<AuthResult>`
Creates a new user account.

**Parameters:**
- `data.email` - User email address
- `data.password` - User password (min 6 characters)

**Returns:**
- `success: true` with `user` and `session` on success
- `success: false` with `error` message on failure

#### `signIn(data: SignInData): Promise<AuthResult>`
Authenticates an existing user.

**Parameters:**
- `data.email` - User email address
- `data.password` - User password

**Returns:**
- `success: true` with `user` and `session` on success
- `success: false` with `error` message on failure

#### `signOut(): Promise<AuthResult>`
Signs out the current user.

**Returns:**
- `success: true` on successful logout
- `success: false` with `error` message on failure

#### `getSession(): Promise<Session | null>`
Retrieves the current session.

**Returns:**
- `Session` object if authenticated
- `null` if not authenticated

#### `getCurrentUser(): Promise<User | null>`
Retrieves the current user.

**Returns:**
- `User` object if authenticated
- `null` if not authenticated

## Error Messages

### Portuguese Error Messages

| Supabase Error | Portuguese Message |
|----------------|-------------------|
| Invalid login credentials | Email ou senha incorretos. Tente novamente. |
| Email not confirmed | Por favor, confirme seu email antes de continuar. |
| User already registered | Este email já está cadastrado. Tente fazer login. |
| Password too short | A senha deve ter pelo menos 6 caracteres. |
| Rate limit exceeded | Muitas tentativas. Aguarde alguns minutos e tente novamente. |
| Network error | Problema de conexão. Verifique sua internet e tente novamente. |
| Generic error | Erro ao autenticar. Tente novamente. |

## Testing Scenarios

### Happy Path
1. User signs up with valid email and password
2. Session created automatically
3. User redirected to journey page
4. User can navigate within app (session persists)
5. User logs out
6. Session terminated, redirected to landing

### Error Scenarios
1. Sign up with existing email → Show error
2. Sign in with wrong password → Show error
3. Sign in with non-existent email → Show error
4. Access protected route without auth → Redirect to login
5. Network failure during auth → Show connectivity error

## Future Enhancements

### Not Yet Implemented
- Email confirmation flow
- Password reset functionality
- "Remember me" option
- Multi-factor authentication
- Social login (Google, Facebook, etc.)
- Account deletion

### Planned in Later Tasks
- **Task 3.3**: Authentication middleware for route protection
- **Task 3.4**: Property test for session creation
- **Task 3.5**: Property test for session restoration
- **Task 3.6**: Unit tests for error handling
