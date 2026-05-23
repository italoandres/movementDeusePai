/**
 * Error Handling Utilities
 * 
 * Provides comprehensive error handling utilities including:
 * - safeDataOperation wrapper for data operations
 * - Error type detection functions
 * - Structured logging with Logger class
 * - User-friendly error messages in Portuguese
 * 
 * Requirements: 15.1, 15.2, 15.3, 15.4, 15.5
 */

// ============================================================================
// Error Types
// ============================================================================

export type ErrorCategory = 
  | 'authentication'
  | 'data_operation'
  | 'content'
  | 'network'
  | 'validation'
  | 'unknown';

export type AuthErrorType = 
  | 'invalid_credentials'
  | 'session_expired'
  | 'unauthorized'
  | 'email_not_confirmed'
  | 'rate_limit_exceeded';

export interface ErrorContext {
  category: ErrorCategory;
  operation?: string;
  userId?: string;
  timestamp: Date;
  details?: Record<string, unknown>;
}

// ============================================================================
// Error Detection Functions
// ============================================================================

/**
 * Check if error is network-related
 */
export function isNetworkError(error: unknown): boolean {
  if (error instanceof Error) {
    const message = error.message.toLowerCase();
    return (
      message.includes('network') ||
      message.includes('fetch') ||
      message.includes('timeout') ||
      message.includes('connection') ||
      error.name === 'NetworkError' ||
      error.name === 'TypeError' && message.includes('failed to fetch')
    );
  }
  return false;
}

/**
 * Check if error is authentication-related
 */
export function isAuthError(error: unknown): boolean {
  if (error instanceof Error) {
    const message = error.message.toLowerCase();
    return (
      message.includes('auth') ||
      message.includes('unauthorized') ||
      message.includes('forbidden') ||
      message.includes('credentials') ||
      message.includes('session')
    );
  }
  
  // Check for Supabase auth errors
  if (typeof error === 'object' && error !== null) {
    const err = error as Record<string, unknown>;
    return (
      err.code === 'PGRST301' || // JWT expired
      err.code === 'PGRST302' || // JWT invalid
      err.status === 401 ||
      err.status === 403
    );
  }
  
  return false;
}

/**
 * Check if error is validation-related
 */
export function isValidationError(error: unknown): boolean {
  if (error instanceof Error) {
    const message = error.message.toLowerCase();
    return (
      message.includes('validation') ||
      message.includes('invalid') ||
      message.includes('required') ||
      message.includes('must be')
    );
  }
  
  // Check for Supabase validation errors
  if (typeof error === 'object' && error !== null) {
    const err = error as Record<string, unknown>;
    return err.code === '23514' || err.code === '23502'; // PostgreSQL constraint violations
  }
  
  return false;
}

/**
 * Check if error is database-related
 */
export function isDatabaseError(error: unknown): boolean {
  if (typeof error === 'object' && error !== null) {
    const err = error as Record<string, unknown>;
    // PostgreSQL error codes
    return typeof err.code === 'string' && /^[0-9A-Z]{5}$/.test(err.code);
  }
  return false;
}

/**
 * Categorize error type
 */
export function categorizeError(error: unknown): ErrorCategory {
  if (isAuthError(error)) return 'authentication';
  if (isNetworkError(error)) return 'network';
  if (isValidationError(error)) return 'validation';
  if (isDatabaseError(error)) return 'data_operation';
  return 'unknown';
}

// ============================================================================
// User-Facing Error Messages (Portuguese)
// ============================================================================

const ERROR_MESSAGES: Record<ErrorCategory, string> = {
  authentication: 'Erro de autenticação. Por favor, faça login novamente.',
  data_operation: 'Erro ao processar dados. Tente novamente em alguns instantes.',
  content: 'Erro ao carregar conteúdo. Por favor, recarregue a página.',
  network: 'Problema de conexão. Verifique sua internet e tente novamente.',
  validation: 'Dados inválidos. Por favor, verifique e tente novamente.',
  unknown: 'Algo deu errado. Tente novamente em alguns instantes.',
};

const AUTH_ERROR_MESSAGES: Record<AuthErrorType, string> = {
  invalid_credentials: 'Email ou senha incorretos. Tente novamente.',
  session_expired: 'Sua sessão expirou. Por favor, faça login novamente.',
  unauthorized: 'Você não tem permissão para acessar este recurso.',
  email_not_confirmed: 'Por favor, confirme seu email antes de continuar.',
  rate_limit_exceeded: 'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
};

/**
 * Get user-friendly error message
 */
export function getUserErrorMessage(error: unknown): string {
  const category = categorizeError(error);
  
  // Check for specific auth error types
  if (category === 'authentication' && error instanceof Error) {
    const message = error.message.toLowerCase();
    if (message.includes('invalid') && message.includes('credentials')) {
      return AUTH_ERROR_MESSAGES.invalid_credentials;
    }
    if (message.includes('expired')) {
      return AUTH_ERROR_MESSAGES.session_expired;
    }
    if (message.includes('rate limit')) {
      return AUTH_ERROR_MESSAGES.rate_limit_exceeded;
    }
  }
  
  // Return category-specific message
  return ERROR_MESSAGES[category];
}

// ============================================================================
// Structured Logger
// ============================================================================

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface LogEntry {
  level: LogLevel;
  message: string;
  context?: Record<string, unknown>;
  timestamp: Date;
  userId?: string;
  sessionId?: string;
  category?: ErrorCategory;
}

/**
 * Structured Logger Class
 * 
 * Provides structured logging with different levels and context.
 * In development: logs to console
 * In production: can be extended to send to external logging service
 * 
 * **Validates: Requirements 15.4**
 */
export class Logger {
  private static instance: Logger;
  
  private constructor() {}
  
  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }
  
  private send(entry: LogEntry): void {
    // In development: console logging
    if (process.env.NODE_ENV === 'development') {
      const timestamp = entry.timestamp.toISOString();
      const prefix = `[${timestamp}] [${entry.level.toUpperCase()}]`;
      
      switch (entry.level) {
        case 'error':
          console.error(prefix, entry.message, entry.context || '');
          break;
        case 'warn':
          console.warn(prefix, entry.message, entry.context || '');
          break;
        case 'info':
          console.info(prefix, entry.message, entry.context || '');
          break;
        case 'debug':
          console.debug(prefix, entry.message, entry.context || '');
          break;
      }
    }
    
    // In production: send to external logging service (async, fire and forget)
    if (process.env.NODE_ENV === 'production' && entry.level === 'error') {
      // Fire and forget - don't block on logging
      void (async () => {
        try {
          // Example: Send to logging endpoint
          // await fetch('/api/logs', {
          //   method: 'POST',
          //   headers: { 'Content-Type': 'application/json' },
          //   body: JSON.stringify(entry),
          // });
        } catch {
          // Silently fail - don't break app if logging fails
        }
      })();
    }
  }
  
  error(message: string, context?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level: 'error',
      message,
      context,
      timestamp: new Date(),
      category: context?.error ? categorizeError(context.error) : undefined,
    };
    this.send(entry);
  }
  
  warn(message: string, context?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level: 'warn',
      message,
      context,
      timestamp: new Date(),
    };
    this.send(entry);
  }
  
  info(message: string, context?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level: 'info',
      message,
      context,
      timestamp: new Date(),
    };
    this.send(entry);
  }
  
  debug(message: string, context?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level: 'debug',
      message,
      context,
      timestamp: new Date(),
    };
    this.send(entry);
  }
}

// Export singleton instance
export const logger = Logger.getInstance();

// ============================================================================
// Safe Data Operation Wrapper
// ============================================================================

export interface SafeOperationResult<T> {
  data: T | null;
  error: string | null;
  errorCategory?: ErrorCategory;
}

/**
 * Safe Data Operation Wrapper
 * 
 * Wraps data operations with comprehensive error handling:
 * - Catches and categorizes errors
 * - Logs errors with context
 * - Returns user-friendly error messages
 * - Provides consistent error handling across the application
 * 
 * @param operation - The async operation to execute
 * @param context - Context string describing the operation
 * @param userId - Optional user ID for logging
 * @returns SafeOperationResult with data or error
 * 
 * **Validates: Requirements 15.1, 15.2, 15.4**
 */
export async function safeDataOperation<T>(
  operation: () => Promise<T>,
  context: string,
  userId?: string
): Promise<SafeOperationResult<T>> {
  try {
    const data = await operation();
    return {
      data,
      error: null,
    };
  } catch (error) {
    // Categorize error
    const category = categorizeError(error);
    
    // Log detailed error for debugging
    logger.error(`Data operation failed: ${context}`, {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
      category,
      context,
      userId,
      timestamp: new Date(),
    });
    
    // Get user-friendly message
    const userMessage = getUserErrorMessage(error);
    
    return {
      data: null,
      error: userMessage,
      errorCategory: category,
    };
  }
}

// ============================================================================
// Network Retry Utility
// ============================================================================

/**
 * Fetch with automatic retry for network errors
 * 
 * Retries failed network requests with exponential backoff.
 * Only retries network-related errors, not validation or auth errors.
 * 
 * @param fetcher - The async fetch operation
 * @param maxRetries - Maximum number of retry attempts (default: 3)
 * @param delayMs - Initial delay in milliseconds (default: 1000)
 * @returns Result of the fetch operation
 * 
 * **Validates: Requirements 15.5**
 */
export async function fetchWithRetry<T>(
  fetcher: () => Promise<T>,
  maxRetries: number = 3,
  delayMs: number = 1000
): Promise<T> {
  let lastError: Error | unknown;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fetcher();
    } catch (error) {
      lastError = error;
      
      // Check if error is network-related
      if (isNetworkError(error)) {
        logger.warn(`Network error, attempt ${attempt + 1}/${maxRetries}`, {
          error: error instanceof Error ? error.message : 'Unknown error',
          attempt: attempt + 1,
          maxRetries,
        });
        
        // Wait before retrying (exponential backoff)
        if (attempt < maxRetries - 1) {
          await delay(delayMs * Math.pow(2, attempt));
        }
      } else {
        // Non-network error, don't retry
        throw error;
      }
    }
  }
  
  // All retries failed
  logger.error('All retry attempts failed', {
    error: lastError instanceof Error ? lastError.message : 'Unknown error',
    maxRetries,
  });
  
  throw lastError;
}

/**
 * Delay utility for retry logic
 */
function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ============================================================================
// Error Handling for Authentication
// ============================================================================

/**
 * Handle authentication errors with appropriate user messages and actions
 * 
 * @param error - The authentication error
 * @returns User-friendly error message
 * 
 * **Validates: Requirements 15.3**
 */
export function handleAuthError(error: unknown): string {
  logger.error('Authentication error', {
    error: error instanceof Error ? error.message : 'Unknown error',
    category: 'authentication',
  });
  
  if (error instanceof Error) {
    const message = error.message.toLowerCase();
    
    if (message.includes('invalid') && (message.includes('credentials') || message.includes('password'))) {
      return AUTH_ERROR_MESSAGES.invalid_credentials;
    }
    
    if (message.includes('expired') || message.includes('session')) {
      return AUTH_ERROR_MESSAGES.session_expired;
    }
    
    if (message.includes('unauthorized') || message.includes('forbidden')) {
      return AUTH_ERROR_MESSAGES.unauthorized;
    }
    
    if (message.includes('email') && message.includes('confirm')) {
      return AUTH_ERROR_MESSAGES.email_not_confirmed;
    }
    
    if (message.includes('rate limit') || message.includes('too many')) {
      return AUTH_ERROR_MESSAGES.rate_limit_exceeded;
    }
  }
  
  return AUTH_ERROR_MESSAGES.invalid_credentials;
}
