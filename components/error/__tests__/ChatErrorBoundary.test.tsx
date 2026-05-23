/**
 * Unit Tests for ChatErrorBoundary Component
 * 
 * Tests error boundary behavior, fallback UI rendering,
 * and error logging.
 * 
 * Requirements: 15.1, 15.2
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ChatErrorBoundary, CompactErrorBoundary } from '../ChatErrorBoundary';

// Component that throws an error
function ThrowError({ shouldThrow }: { shouldThrow: boolean }) {
  if (shouldThrow) {
    throw new Error('Test error');
  }
  return <div>No error</div>;
}

describe('ChatErrorBoundary', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let consoleErrorSpy: any;

  beforeEach(() => {
    // Suppress console.error in tests
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  it('should render children when no error occurs', () => {
    render(
      <ChatErrorBoundary>
        <div>Test content</div>
      </ChatErrorBoundary>
    );

    expect(screen.getByText('Test content')).toBeInTheDocument();
  });

  it('should render fallback UI when error occurs', () => {
    render(
      <ChatErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ChatErrorBoundary>
    );

    expect(screen.getByText('Algo deu errado')).toBeInTheDocument();
    expect(screen.getByText(/Ocorreu um erro inesperado/)).toBeInTheDocument();
  });

  it('should display reload button in fallback UI', () => {
    render(
      <ChatErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ChatErrorBoundary>
    );

    expect(screen.getByRole('button', { name: /Recarregar página/i })).toBeInTheDocument();
  });

  it('should display try again button in fallback UI', () => {
    render(
      <ChatErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ChatErrorBoundary>
    );

    expect(screen.getByRole('button', { name: /Tentar novamente/i })).toBeInTheDocument();
  });

  it('should log error when caught', () => {
    render(
      <ChatErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ChatErrorBoundary>
    );

    expect(consoleErrorSpy).toHaveBeenCalled();
  });

  it('should render custom fallback if provided', () => {
    const customFallback = <div>Custom error message</div>;

    render(
      <ChatErrorBoundary fallback={customFallback}>
        <ThrowError shouldThrow={true} />
      </ChatErrorBoundary>
    );

    expect(screen.getByText('Custom error message')).toBeInTheDocument();
    expect(screen.queryByText('Algo deu errado')).not.toBeInTheDocument();
  });

  it('should reload page when reload button is clicked', async () => {
    const user = userEvent.setup();
    const reloadMock = vi.fn();
    Object.defineProperty(window, 'location', {
      value: { reload: reloadMock },
      writable: true,
    });

    render(
      <ChatErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ChatErrorBoundary>
    );

    const reloadButton = screen.getByRole('button', { name: /Recarregar página/i });
    await user.click(reloadButton);

    expect(reloadMock).toHaveBeenCalled();
  });
});

describe('CompactErrorBoundary', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let consoleErrorSpy: any;

  beforeEach(() => {
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  it('should render children when no error occurs', () => {
    render(
      <CompactErrorBoundary>
        <div>Test content</div>
      </CompactErrorBoundary>
    );

    expect(screen.getByText('Test content')).toBeInTheDocument();
  });

  it('should render compact fallback UI when error occurs', () => {
    render(
      <CompactErrorBoundary>
        <ThrowError shouldThrow={true} />
      </CompactErrorBoundary>
    );

    expect(screen.getByText(/Erro ao carregar este componente/)).toBeInTheDocument();
  });

  it('should display try again link in compact fallback', () => {
    render(
      <CompactErrorBoundary>
        <ThrowError shouldThrow={true} />
      </CompactErrorBoundary>
    );

    expect(screen.getByRole('button', { name: /Tentar novamente/i })).toBeInTheDocument();
  });

  it('should log error when caught', () => {
    render(
      <CompactErrorBoundary>
        <ThrowError shouldThrow={true} />
      </CompactErrorBoundary>
    );

    expect(consoleErrorSpy).toHaveBeenCalled();
  });

  it('should render custom fallback if provided', () => {
    const customFallback = <div>Compact custom error</div>;

    render(
      <CompactErrorBoundary fallback={customFallback}>
        <ThrowError shouldThrow={true} />
      </CompactErrorBoundary>
    );

    expect(screen.getByText('Compact custom error')).toBeInTheDocument();
  });
});
