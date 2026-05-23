'use client';

/**
 * Error Toast Notification Component
 * 
 * Displays user-facing error messages as toast notifications.
 * Supports different error types with appropriate styling and icons.
 * 
 * Requirements: 15.1, 15.2, 15.3, 15.5
 */

import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import type { ErrorCategory } from '@/lib/utils/errorHandling';

// ============================================================================
// Toast Types
// ============================================================================

export type ToastType = 'error' | 'warning' | 'success' | 'info';

export interface Toast {
  id: string;
  type: ToastType;
  message: string;
  category?: ErrorCategory;
  duration?: number;
}

interface ToastContextValue {
  toasts: Toast[];
  showToast: (message: string, type?: ToastType, category?: ErrorCategory, duration?: number) => void;
  showError: (message: string, category?: ErrorCategory) => void;
  showSuccess: (message: string) => void;
  showWarning: (message: string) => void;
  showInfo: (message: string) => void;
  removeToast: (id: string) => void;
}

// ============================================================================
// Toast Context
// ============================================================================

const ToastContext = createContext<ToastContextValue | undefined>(undefined);

export function useToast(): ToastContextValue {
  const context = useContext(ToastContext);
  if (!context) {
    throw new Error('useToast must be used within ToastProvider');
  }
  return context;
}

// ============================================================================
// Toast Provider
// ============================================================================

interface ToastProviderProps {
  children: React.ReactNode;
  maxToasts?: number;
}

export function ToastProvider({ children, maxToasts = 3 }: ToastProviderProps): JSX.Element {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const removeToast = useCallback((id: string) => {
    setToasts(prev => prev.filter(toast => toast.id !== id));
  }, []);

  const showToast = useCallback(
    (
      message: string, 
      type: ToastType = 'info', 
      category?: ErrorCategory,
      duration: number = 5000
    ) => {
      const id = `toast-${Date.now()}-${Math.random()}`;
      const newToast: Toast = { id, type, message, category, duration };

      setToasts(prev => {
        // Limit number of toasts
        const updated = [...prev, newToast];
        if (updated.length > maxToasts) {
          return updated.slice(-maxToasts);
        }
        return updated;
      });

      // Auto-remove after duration
      if (duration > 0) {
        setTimeout(() => {
          removeToast(id);
        }, duration);
      }
    },
    [maxToasts, removeToast]
  );

  const showError = useCallback(
    (message: string, category?: ErrorCategory) => {
      showToast(message, 'error', category, 6000);
    },
    [showToast]
  );

  const showSuccess = useCallback(
    (message: string) => {
      showToast(message, 'success', undefined, 4000);
    },
    [showToast]
  );

  const showWarning = useCallback(
    (message: string) => {
      showToast(message, 'warning', undefined, 5000);
    },
    [showToast]
  );

  const showInfo = useCallback(
    (message: string) => {
      showToast(message, 'info', undefined, 4000);
    },
    [showToast]
  );

  const value: ToastContextValue = {
    toasts,
    showToast,
    showError,
    showSuccess,
    showWarning,
    showInfo,
    removeToast,
  };

  return (
    <ToastContext.Provider value={value}>
      {children}
      <ToastContainer toasts={toasts} onRemove={removeToast} />
    </ToastContext.Provider>
  );
}

// ============================================================================
// Toast Container
// ============================================================================

interface ToastContainerProps {
  toasts: Toast[];
  onRemove: (id: string) => void;
}

function ToastContainer({ toasts, onRemove }: ToastContainerProps): JSX.Element {
  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2 max-w-md">
      {toasts.map(toast => (
        <ToastItem key={toast.id} toast={toast} onRemove={onRemove} />
      ))}
    </div>
  );
}

// ============================================================================
// Toast Item
// ============================================================================

interface ToastItemProps {
  toast: Toast;
  onRemove: (id: string) => void;
}

function ToastItem({ toast, onRemove }: ToastItemProps): JSX.Element {
  const [isExiting, setIsExiting] = useState(false);

  const handleClose = () => {
    setIsExiting(true);
    setTimeout(() => {
      onRemove(toast.id);
    }, 300); // Match animation duration
  };

  useEffect(() => {
    // Trigger entrance animation
    const timer = setTimeout(() => {
      setIsExiting(false);
    }, 10);
    return () => clearTimeout(timer);
  }, []);

  const getToastStyles = (): string => {
    const baseStyles = 'flex items-start gap-3 p-4 rounded-lg shadow-lg border backdrop-blur-sm';
    
    switch (toast.type) {
      case 'error':
        return `${baseStyles} bg-red-900/90 border-red-500/50 text-red-100`;
      case 'warning':
        return `${baseStyles} bg-yellow-900/90 border-yellow-500/50 text-yellow-100`;
      case 'success':
        return `${baseStyles} bg-green-900/90 border-green-500/50 text-green-100`;
      case 'info':
      default:
        return `${baseStyles} bg-blue-900/90 border-blue-500/50 text-blue-100`;
    }
  };

  const getIcon = (): JSX.Element => {
    const iconClass = 'w-5 h-5 flex-shrink-0 mt-0.5';
    
    switch (toast.type) {
      case 'error':
        return (
          <svg className={iconClass} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
      case 'warning':
        return (
          <svg className={iconClass} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        );
      case 'success':
        return (
          <svg className={iconClass} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
      case 'info':
      default:
        return (
          <svg className={iconClass} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
    }
  };

  return (
    <div
      className={`${getToastStyles()} transition-all duration-300 ${
        isExiting ? 'opacity-0 translate-x-full' : 'opacity-100 translate-x-0'
      }`}
      role="alert"
    >
      {getIcon()}
      
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium break-words">
          {toast.message}
        </p>
        {toast.category && process.env.NODE_ENV === 'development' && (
          <p className="text-xs opacity-75 mt-1">
            Categoria: {toast.category}
          </p>
        )}
      </div>

      <button
        onClick={handleClose}
        className="flex-shrink-0 text-current opacity-70 hover:opacity-100 transition-opacity"
        aria-label="Fechar notificação"
      >
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
  );
}

// ============================================================================
// Convenience Hook for Error Display
// ============================================================================

/**
 * Hook for displaying errors with automatic categorization
 * 
 * **Validates: Requirements 15.1, 15.2, 15.3, 15.5**
 */
export function useErrorDisplay() {
  const { showError, showWarning, showInfo } = useToast();

  const displayError = useCallback(
    (error: unknown) => {
      // Import error handling utilities dynamically
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const { getUserErrorMessage, categorizeError } = require('@/lib/utils/errorHandling');
      
      const message = getUserErrorMessage(error);
      const category = categorizeError(error);
      
      showError(message, category);
    },
    [showError]
  );

  const displayStorageError = useCallback(() => {
    showError('Erro ao salvar dados. Tente novamente.', 'data_operation');
  }, [showError]);

  const displayRetrievalError = useCallback(() => {
    showError('Erro ao carregar dados. Tente novamente.', 'data_operation');
  }, [showError]);

  const displayAuthError = useCallback(() => {
    showError('Erro de autenticação. Por favor, faça login novamente.', 'authentication');
  }, [showError]);

  const displayNetworkError = useCallback(() => {
    showError('Problema de conexão. Verifique sua internet e tente novamente.', 'network');
  }, [showError]);

  return {
    displayError,
    displayStorageError,
    displayRetrievalError,
    displayAuthError,
    displayNetworkError,
    showWarning,
    showInfo,
  };
}
