/**
 * Session Configuration
 * 
 * Centralized configuration for session management.
 * Session duration is controlled by Supabase Auth settings.
 * 
 * Requirements: 14.2
 */

/**
 * Session configuration constants
 * 
 * Note: The actual session duration is configured in Supabase Dashboard:
 * Authentication > Settings > JWT expiry
 * 
 * Default Supabase JWT expiry: 3600 seconds (1 hour)
 * Recommended for this application: 604800 seconds (7 days)
 */
export const SESSION_CONFIG = {
  /**
   * JWT expiry duration in seconds
   * This should match the value configured in Supabase Dashboard
   * Default: 604800 (7 days)
   */
  JWT_EXPIRY_SECONDS: 604800, // 7 days
  
  /**
   * Refresh token expiry duration in seconds
   * This should match the value configured in Supabase Dashboard
   * Default: 2592000 (30 days)
   */
  REFRESH_TOKEN_EXPIRY_SECONDS: 2592000, // 30 days
  
  /**
   * Auto-refresh threshold in seconds
   * Refresh the session when it has less than this many seconds remaining
   * Default: 300 (5 minutes)
   */
  AUTO_REFRESH_THRESHOLD_SECONDS: 300, // 5 minutes
  
  /**
   * Session check interval in milliseconds
   * How often to check if session needs refresh
   * Default: 60000 (1 minute)
   */
  SESSION_CHECK_INTERVAL_MS: 60000, // 1 minute
} as const;

/**
 * Get human-readable session duration
 */
export function getSessionDurationDisplay(): string {
  const days = Math.floor(SESSION_CONFIG.JWT_EXPIRY_SECONDS / 86400);
  const hours = Math.floor((SESSION_CONFIG.JWT_EXPIRY_SECONDS % 86400) / 3600);
  
  if (days > 0) {
    return `${days} ${days === 1 ? 'dia' : 'dias'}`;
  }
  if (hours > 0) {
    return `${hours} ${hours === 1 ? 'hora' : 'horas'}`;
  }
  return 'menos de 1 hora';
}

/**
 * Check if session is about to expire
 * @param expiresAt - Session expiration timestamp in seconds
 * @returns true if session should be refreshed
 */
export function shouldRefreshSession(expiresAt: number): boolean {
  const now = Math.floor(Date.now() / 1000);
  const timeRemaining = expiresAt - now;
  return timeRemaining < SESSION_CONFIG.AUTO_REFRESH_THRESHOLD_SECONDS;
}
