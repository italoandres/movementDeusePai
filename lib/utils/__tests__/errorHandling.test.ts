/**
 * Unit Tests for Error Handling Utilities
 * 
 * Tests error detection functions, categorization, user messages,
 * and the safeDataOperation wrapper.
 * 
 * Requirements: 15.1, 15.2, 15.3, 15.4, 15.5
 */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  isNetworkError,
  isAuthError,
  isValidationError,
  isDatabaseError,
  categorizeError,
  getUserErrorMessage,
  Logger,
  logger,
  safeDataOperation,
  fetchWithRetry,
  handleAuthError,
} from '../errorHandling';

describe('Error Detection Functions', () => {
  describe('isNetworkError', () => {
    it('should detect network errors by message', () => {
      const error = new Error('Network request failed');
      expect(isNetworkError(error)).toBe(true);
    });

    it('should detect fetch errors', () => {
      const error = new Error('Failed to fetch');
      expect(isNetworkError(error)).toBe(true);
    });

    it('should detect timeout errors', () => {
      const error = new Error('Request timeout');
      expect(isNetworkError(error)).toBe(true);
    });

    it('should detect connection errors', () => {
      const error = new Error('Connection refused');
      expect(isNetworkError(error)).toBe(true);
    });

    it('should return false for non-network errors', () => {
      const error = new Error('Invalid input');
      expect(isNetworkError(error)).toBe(false);
    });

    it('should return false for non-Error objects', () => {
      expect(isNetworkError('string error')).toBe(false);
      expect(isNetworkError(null)).toBe(false);
      expect(isNetworkError(undefined)).toBe(false);
    });
  });

  describe('isAuthError', () => {
    it('should detect auth errors by message', () => {
      const error = new Error('Authentication failed');
      expect(isAuthError(error)).toBe(true);
    });

    it('should detect unauthorized errors', () => {
      const error = new Error('Unauthorized access');
      expect(isAuthError(error)).toBe(true);
    });

    it('should detect session errors', () => {
      const error = new Error('Session expired');
      expect(isAuthError(error)).toBe(true);
    });

    it('should detect Supabase auth errors by status code', () => {
      const error = { status: 401, message: 'Unauthorized' };
      expect(isAuthError(error)).toBe(true);
    });

    it('should detect Supabase JWT errors', () => {
      const error = { code: 'PGRST301', message: 'JWT expired' };
      expect(isAuthError(error)).toBe(true);
    });

    it('should return false for non-auth errors', () => {
      const error = new Error('Database error');
      expect(isAuthError(error)).toBe(false);
    });
  });

  describe('isValidationError', () => {
    it('should detect validation errors by message', () => {
      const error = new Error('Validation failed');
      expect(isValidationError(error)).toBe(true);
    });

    it('should detect invalid input errors', () => {
      const error = new Error('Invalid email format');
      expect(isValidationError(error)).toBe(true);
    });

    it('should detect required field errors', () => {
      const error = new Error('Field is required');
      expect(isValidationError(error)).toBe(true);
    });

    it('should detect PostgreSQL constraint violations', () => {
      const error = { code: '23514', message: 'Check constraint violation' };
      expect(isValidationError(error)).toBe(true);
    });

    it('should return false for non-validation errors', () => {
      const error = new Error('Network timeout');
      expect(isValidationError(error)).toBe(false);
    });
  });

  describe('isDatabaseError', () => {
    it('should detect PostgreSQL error codes', () => {
      const error = { code: '23505', message: 'Unique violation' };
      expect(isDatabaseError(error)).toBe(true);
    });

    it('should detect 5-character error codes', () => {
      const error = { code: 'ABCDE', message: 'Database error' };
      expect(isDatabaseError(error)).toBe(true);
    });

    it('should return false for non-database errors', () => {
      const error = new Error('Network error');
      expect(isDatabaseError(error)).toBe(false);
    });

    it('should return false for invalid code formats', () => {
      const error = { code: '123', message: 'Short code' };
      expect(isDatabaseError(error)).toBe(false);
    });
  });

  describe('categorizeError', () => {
    it('should categorize auth errors', () => {
      const error = new Error('Unauthorized');
      expect(categorizeError(error)).toBe('authentication');
    });

    it('should categorize network errors', () => {
      const error = new Error('Network timeout');
      expect(categorizeError(error)).toBe('network');
    });

    it('should categorize validation errors', () => {
      const error = new Error('Invalid input');
      expect(categorizeError(error)).toBe('validation');
    });

    it('should categorize database errors', () => {
      const error = { code: '23505', message: 'Unique violation' };
      expect(categorizeError(error)).toBe('data_operation');
    });

    it('should return unknown for unrecognized errors', () => {
      const error = new Error('Something went wrong');
      expect(categorizeError(error)).toBe('unknown');
    });
  });
});

describe('User Error Messages', () => {
  describe('getUserErrorMessage', () => {
    it('should return auth message for auth errors', () => {
      const error = new Error('Unauthorized');
      const message = getUserErrorMessage(error);
      expect(message).toContain('autenticação');
    });

    it('should return network message for network errors', () => {
      const error = new Error('Network timeout');
      const message = getUserErrorMessage(error);
      expect(message).toContain('conexão');
    });

    it('should return validation message for validation errors', () => {
      const error = new Error('Invalid input');
      const message = getUserErrorMessage(error);
      expect(message).toContain('inválidos');
    });

    it('should return specific message for invalid credentials', () => {
      const error = new Error('Invalid credentials');
      const message = getUserErrorMessage(error);
      expect(message).toContain('Email ou senha incorretos');
    });

    it('should return specific message for expired session', () => {
      const error = new Error('Session expired');
      const message = getUserErrorMessage(error);
      expect(message).toContain('sessão expirou');
    });

    it('should return generic message for unknown errors', () => {
      const error = new Error('Unknown error');
      const message = getUserErrorMessage(error);
      expect(message).toContain('Algo deu errado');
    });
  });

  describe('handleAuthError', () => {
    it('should return invalid credentials message', () => {
      const error = new Error('Invalid password');
      const message = handleAuthError(error);
      expect(message).toContain('Email ou senha incorretos');
    });

    it('should return session expired message', () => {
      const error = new Error('Session expired');
      const message = handleAuthError(error);
      expect(message).toContain('sessão expirou');
    });

    it('should return unauthorized message', () => {
      const error = new Error('Unauthorized access');
      const message = handleAuthError(error);
      expect(message).toContain('não tem permissão');
    });

    it('should return rate limit message', () => {
      const error = new Error('Rate limit exceeded');
      const message = handleAuthError(error);
      expect(message).toContain('Muitas tentativas');
    });
  });
});

describe('Logger', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let consoleErrorSpy: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let consoleWarnSpy: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let consoleInfoSpy: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let consoleDebugSpy: any;
  let originalEnv: string | undefined;

  beforeEach(() => {
    // Save original NODE_ENV
    originalEnv = process.env.NODE_ENV;
    // Set to development for logging tests
    process.env.NODE_ENV = 'development';
    
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});
    consoleInfoSpy = vi.spyOn(console, 'info').mockImplementation(() => {});
    consoleDebugSpy = vi.spyOn(console, 'debug').mockImplementation(() => {});
  });
  
  afterEach(() => {
    // Restore original NODE_ENV
    if (originalEnv !== undefined) {
      process.env.NODE_ENV = originalEnv;
    } else {
      delete process.env.NODE_ENV;
    }
  });

  it('should be a singleton', () => {
    const instance1 = Logger.getInstance();
    const instance2 = Logger.getInstance();
    expect(instance1).toBe(instance2);
  });

  it('should log error messages', () => {
    logger.error('Test error', { detail: 'error detail' });
    expect(consoleErrorSpy).toHaveBeenCalled();
  });

  it('should log warning messages', () => {
    logger.warn('Test warning', { detail: 'warning detail' });
    expect(consoleWarnSpy).toHaveBeenCalled();
  });

  it('should log info messages', () => {
    logger.info('Test info', { detail: 'info detail' });
    expect(consoleInfoSpy).toHaveBeenCalled();
  });

  it('should log debug messages', () => {
    logger.debug('Test debug', { detail: 'debug detail' });
    expect(consoleDebugSpy).toHaveBeenCalled();
  });

  it('should include context in logs', () => {
    const context = { userId: '123', operation: 'test' };
    logger.error('Test with context', context);
    expect(consoleErrorSpy).toHaveBeenCalledWith(
      expect.stringContaining('[ERROR]'),
      'Test with context',
      context
    );
  });
});

describe('safeDataOperation', () => {
  let originalEnv: string | undefined;

  beforeEach(() => {
    originalEnv = process.env.NODE_ENV;
    process.env.NODE_ENV = 'development';
  });

  afterEach(() => {
    if (originalEnv !== undefined) {
      process.env.NODE_ENV = originalEnv;
    } else {
      delete process.env.NODE_ENV;
    }
  });
  
  it('should return data on successful operation', async () => {
    const operation = async () => ({ result: 'success' });
    const result = await safeDataOperation(operation, 'test operation');
    
    expect(result.data).toEqual({ result: 'success' });
    expect(result.error).toBeNull();
  });

  it('should return error on failed operation', async () => {
    const operation = async () => {
      throw new Error('Operation failed');
    };
    const result = await safeDataOperation(operation, 'test operation');
    
    expect(result.data).toBeNull();
    expect(result.error).toBeTruthy();
    expect(typeof result.error).toBe('string');
  });

  it('should categorize errors', async () => {
    const operation = async () => {
      throw new Error('Network timeout');
    };
    const result = await safeDataOperation(operation, 'test operation');
    
    expect(result.errorCategory).toBe('network');
  });

  it('should log errors with context', async () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    
    const operation = async () => {
      throw new Error('Test error');
    };
    await safeDataOperation(operation, 'test operation', 'user-123');
    
    expect(consoleErrorSpy).toHaveBeenCalled();
  });

  it('should return user-friendly error messages', async () => {
    const operation = async () => {
      throw new Error('Network failed');
    };
    const result = await safeDataOperation(operation, 'test operation');
    
    expect(result.error).toContain('conexão');
  });
});

describe('fetchWithRetry', () => {
  it('should return data on successful fetch', async () => {
    const fetcher = vi.fn().mockResolvedValue({ data: 'success' });
    const result = await fetchWithRetry(fetcher);
    
    expect(result).toEqual({ data: 'success' });
    expect(fetcher).toHaveBeenCalledTimes(1);
  });

  it('should retry on network errors', async () => {
    const fetcher = vi.fn()
      .mockRejectedValueOnce(new Error('Network timeout'))
      .mockRejectedValueOnce(new Error('Network timeout'))
      .mockResolvedValue({ data: 'success' });
    
    const result = await fetchWithRetry(fetcher, 3, 10);
    
    expect(result).toEqual({ data: 'success' });
    expect(fetcher).toHaveBeenCalledTimes(3);
  });

  it('should not retry on non-network errors', async () => {
    const fetcher = vi.fn().mockRejectedValue(new Error('Validation error'));
    
    await expect(fetchWithRetry(fetcher, 3, 10)).rejects.toThrow('Validation error');
    expect(fetcher).toHaveBeenCalledTimes(1);
  });

  it('should throw after max retries', async () => {
    const fetcher = vi.fn().mockRejectedValue(new Error('Network timeout'));
    
    await expect(fetchWithRetry(fetcher, 3, 10)).rejects.toThrow('Network timeout');
    expect(fetcher).toHaveBeenCalledTimes(3);
  });

  it('should use exponential backoff', async () => {
    const fetcher = vi.fn()
      .mockRejectedValueOnce(new Error('Network timeout'))
      .mockRejectedValueOnce(new Error('Network timeout'))
      .mockResolvedValue({ data: 'success' });
    
    const startTime = Date.now();
    await fetchWithRetry(fetcher, 3, 10);
    const duration = Date.now() - startTime;
    
    // Should have delays: 10ms + 20ms = 30ms minimum
    expect(duration).toBeGreaterThanOrEqual(20);
  });
});
