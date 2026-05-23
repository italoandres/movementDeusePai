/**
 * Error Handling Components
 * 
 * Exports all error handling components and utilities for easy import.
 */

export { 
  ChatErrorBoundary, 
  CompactErrorBoundary 
} from './ChatErrorBoundary';

export { 
  ToastProvider, 
  useToast, 
  useErrorDisplay 
} from './ErrorToast';

export type { Toast, ToastType } from './ErrorToast';
