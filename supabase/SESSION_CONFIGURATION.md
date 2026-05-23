# Session Configuration Guide

This guide explains how to configure session duration and refresh settings in Supabase for the Interactive Spiritual Book System.

## Overview

The system uses Supabase Auth for session management with the following features:
- **JWT-based authentication** with configurable expiry
- **Automatic session refresh** when approaching expiration
- **Session expiration detection** with user-friendly messaging
- **Secure HTTP-only cookies** for token storage

## Supabase Dashboard Configuration

### Step 1: Access Auth Settings

1. Go to your Supabase project dashboard: https://app.supabase.com
2. Select your project
3. Click on **Authentication** in the left sidebar
4. Click on **Settings** tab

### Step 2: Configure JWT Expiry

**JWT Expiry** controls how long a user's access token remains valid.

**Recommended Setting**: `604800` seconds (7 days)

1. Find the **JWT Expiry** field
2. Enter `604800` (or your preferred duration in seconds)
3. Click **Save**

**Common Values**:
- 1 hour: `3600`
- 1 day: `86400`
- 7 days: `604800` (recommended)
- 30 days: `2592000`

### Step 3: Configure Refresh Token Expiry

**Refresh Token Expiry** controls how long a user can stay logged in without re-authenticating.

**Recommended Setting**: `2592000` seconds (30 days)

1. Find the **Refresh Token Expiry** field
2. Enter `2592000` (or your preferred duration in seconds)
3. Click **Save**

**Common Values**:
- 7 days: `604800`
- 30 days: `2592000` (recommended)
- 90 days: `7776000`

### Step 4: Enable Refresh Token Rotation (Optional)

**Refresh Token Rotation** enhances security by issuing a new refresh token each time it's used.

**Recommended Setting**: Enabled

1. Find the **Refresh Token Rotation** toggle
2. Enable it
3. Click **Save**

## Application Configuration

The application's session configuration is defined in `lib/config/session.config.ts`:

```typescript
export const SESSION_CONFIG = {
  // Should match Supabase JWT Expiry setting
  JWT_EXPIRY_SECONDS: 604800, // 7 days
  
  // Should match Supabase Refresh Token Expiry setting
  REFRESH_TOKEN_EXPIRY_SECONDS: 2592000, // 30 days
  
  // Refresh session when less than 5 minutes remaining
  AUTO_REFRESH_THRESHOLD_SECONDS: 300,
  
  // Check session every 1 minute
  SESSION_CHECK_INTERVAL_MS: 60000,
};
```

**Important**: Update these values in `session.config.ts` to match your Supabase settings.

## How Session Management Works

### 1. Session Creation
When a user logs in:
- Supabase creates a JWT access token (expires based on JWT Expiry setting)
- Supabase creates a refresh token (expires based on Refresh Token Expiry setting)
- Tokens are stored in HTTP-only cookies for security

### 2. Session Validation
On every request to protected routes:
- Middleware validates the JWT access token
- If token is valid, request proceeds
- If token is expired or invalid, user is redirected to login

### 3. Automatic Session Refresh
The `useSessionRefresh` hook runs in protected routes:
- Checks session status every 1 minute
- If session expires in less than 5 minutes, automatically refreshes it
- Uses the refresh token to obtain a new access token
- If refresh fails, redirects to login with "session expired" message

### 4. Session Expiration Handling
When a session expires:
- User is redirected to `/login?reason=session_expired`
- Login page displays: "Sua sessão expirou. Por favor, faça login novamente."
- After login, user is redirected back to their intended destination

### 5. Manual Logout
When a user clicks the logout button:
- `signOut()` function terminates the session
- All tokens are cleared
- User is redirected to the landing page

## Testing Session Management

### Test Session Refresh

1. Log in to the application
2. Open browser DevTools > Console
3. Wait for automatic refresh (you'll see: "Session about to expire, refreshing...")
4. Verify session continues without interruption

### Test Session Expiration

**Option 1: Reduce JWT Expiry (Development)**
1. In Supabase Dashboard, set JWT Expiry to `60` (1 minute)
2. Log in to the application
3. Wait 1 minute
4. Try to navigate or refresh the page
5. Verify redirect to login with expiration message

**Option 2: Clear Session Manually**
1. Log in to the application
2. Open browser DevTools > Application > Cookies
3. Delete all Supabase cookies (starting with `sb-`)
4. Try to navigate or refresh the page
5. Verify redirect to login

### Test Logout

1. Log in to the application
2. Click the "Sair" (Logout) button
3. Verify redirect to landing page
4. Try to access `/journey` directly
5. Verify redirect to login

## Security Considerations

### HTTP-Only Cookies
- Tokens are stored in HTTP-only cookies
- JavaScript cannot access tokens (prevents XSS attacks)
- Cookies are automatically sent with requests

### Secure Flag
- In production, cookies use the `Secure` flag
- Tokens only transmitted over HTTPS
- Prevents man-in-the-middle attacks

### SameSite Policy
- Cookies use `SameSite=Lax` policy
- Prevents CSRF attacks
- Allows cookies on same-site navigation

### Token Rotation
- Enable Refresh Token Rotation for enhanced security
- Each refresh issues a new refresh token
- Old refresh tokens are invalidated

## Troubleshooting

### Issue: Users logged out too frequently

**Cause**: JWT Expiry is too short

**Solution**: Increase JWT Expiry in Supabase Dashboard (recommended: 604800 seconds / 7 days)

### Issue: Session refresh not working

**Cause**: Mismatch between Supabase settings and application config

**Solution**: 
1. Check JWT Expiry in Supabase Dashboard
2. Update `JWT_EXPIRY_SECONDS` in `lib/config/session.config.ts` to match
3. Restart the application

### Issue: "Session expired" message appears immediately after login

**Cause**: System clock mismatch or JWT Expiry set to 0

**Solution**:
1. Verify JWT Expiry is set correctly in Supabase Dashboard
2. Check system clock is accurate
3. Clear browser cookies and try again

### Issue: Session persists after logout

**Cause**: Browser caching or multiple tabs

**Solution**:
1. Close all application tabs
2. Clear browser cookies
3. Open application in new tab

## Best Practices

1. **Production Settings**:
   - JWT Expiry: 604800 seconds (7 days)
   - Refresh Token Expiry: 2592000 seconds (30 days)
   - Enable Refresh Token Rotation

2. **Development Settings**:
   - Can use shorter durations for testing
   - Remember to update application config to match

3. **User Experience**:
   - Automatic refresh prevents interruptions
   - Clear messaging when session expires
   - Redirect back to intended page after login

4. **Security**:
   - Never store tokens in localStorage
   - Always use HTTP-only cookies
   - Enable Refresh Token Rotation
   - Use HTTPS in production

## Related Files

- `lib/config/session.config.ts` - Session configuration constants
- `lib/hooks/useSessionRefresh.ts` - Automatic session refresh hook
- `lib/supabase/middleware.ts` - Middleware session validation
- `middleware.ts` - Route protection and expiration detection
- `app/(auth)/login/page.tsx` - Login page with expiration messaging
- `components/auth/LogoutButton.tsx` - Logout functionality
- `components/providers/SessionProvider.tsx` - Session management provider

## Requirements Validation

This session management implementation validates:

- **Requirement 14.1**: Session creation on authentication ✓
- **Requirement 14.2**: Configurable session duration ✓
- **Requirement 14.3**: Session restoration across app reopens ✓
- **Requirement 14.4**: Session expiration detection and re-authentication ✓
- **Requirement 14.5**: Logout functionality that terminates session ✓

---

**Last Updated**: 2025
**Version**: 1.0
