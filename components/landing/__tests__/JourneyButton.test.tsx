import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import JourneyButton from '../JourneyButton';

// Mock Next.js router
const mockPush = vi.fn();
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: mockPush,
  }),
}));

describe('JourneyButton Component', () => {
  it('should render button with correct text', () => {
    render(<JourneyButton />);
    
    const button = screen.getByRole('button', { name: /começar minha jornada/i });
    expect(button).toBeDefined();
    expect(button.textContent).toBe('Começar minha jornada');
  });

  it('should navigate to signup page when clicked', () => {
    render(<JourneyButton />);
    
    const button = screen.getByRole('button', { name: /começar minha jornada/i });
    fireEvent.click(button);
    
    expect(mockPush).toHaveBeenCalledWith('/signup');
  });

  it('should have minimum touch target size (44x44px)', () => {
    render(<JourneyButton />);
    
    const button = screen.getByRole('button', { name: /começar minha jornada/i });
    expect(button.className).toContain('min-h-[44px]');
    expect(button.className).toContain('min-w-[44px]');
  });

  it('should have proper accessibility attributes', () => {
    render(<JourneyButton />);
    
    const button = screen.getByRole('button', { name: /começar minha jornada/i });
    expect(button.getAttribute('aria-label')).toBe('Começar minha jornada espiritual');
  });
});
