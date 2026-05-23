import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import ChapterList from '../ChapterList';
import type { ChapterProgress } from '@/lib/types/domain.types';

describe('ChapterList Component', () => {
  const mockChapters: ChapterProgress[] = [
    {
      chapter: {
        id: 'ch-1',
        order_index: 1,
        title: 'Primeiro Capítulo',
        content: { messages: [] },
        created_at: '2024-01-01',
        updated_at: '2024-01-01',
      },
      completed: true,
      unlocked: true,
      completedAt: '2024-01-01',
    },
    {
      chapter: {
        id: 'ch-2',
        order_index: 2,
        title: 'Segundo Capítulo',
        content: { messages: [] },
        created_at: '2024-01-01',
        updated_at: '2024-01-01',
      },
      completed: false,
      unlocked: true,
      completedAt: null,
    },
    {
      chapter: {
        id: 'ch-3',
        order_index: 3,
        title: 'Terceiro Capítulo',
        content: { messages: [] },
        created_at: '2024-01-01',
        updated_at: '2024-01-01',
      },
      completed: false,
      unlocked: false,
      completedAt: null,
    },
  ];

  it('should render all chapters', () => {
    render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
      />
    );

    expect(screen.getByText('Capítulos')).toBeInTheDocument();
    expect(screen.getByText('Primeiro Capítulo')).toBeInTheDocument();
    expect(screen.getByText('Segundo Capítulo')).toBeInTheDocument();
    expect(screen.getByText('Terceiro Capítulo')).toBeInTheDocument();
  });

  it('should show checkmark for completed chapters', () => {
    const { container } = render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
      />
    );

    // Check for checkmark SVG in completed chapter
    const checkmarks = container.querySelectorAll('path[d*="M5 13l4 4L19 7"]');
    expect(checkmarks.length).toBeGreaterThan(0);
  });

  it('should show lock icon for locked chapters', () => {
    const { container } = render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
      />
    );

    // Check for lock SVG in locked chapter
    const locks = container.querySelectorAll('path[d*="M12 15v2m-6 4h12"]');
    expect(locks.length).toBeGreaterThan(0);
  });

  it('should highlight current chapter', () => {
    render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
      />
    );

    expect(screen.getByText('Atual')).toBeInTheDocument();
  });

  it('should call onChapterSelect when unlocked chapter is clicked', () => {
    const onChapterSelect = vi.fn();
    
    render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
        onChapterSelect={onChapterSelect}
      />
    );

    const unlockedChapter = screen.getByText('Segundo Capítulo').closest('button');
    fireEvent.click(unlockedChapter!);

    expect(onChapterSelect).toHaveBeenCalledWith('ch-2');
  });

  it('should not call onChapterSelect when locked chapter is clicked', () => {
    const onChapterSelect = vi.fn();
    
    render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
        onChapterSelect={onChapterSelect}
      />
    );

    const lockedChapter = screen.getByText('Terceiro Capítulo').closest('button');
    fireEvent.click(lockedChapter!);

    expect(onChapterSelect).not.toHaveBeenCalled();
  });

  it('should disable locked chapter buttons', () => {
    render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
      />
    );

    const lockedChapter = screen.getByText('Terceiro Capítulo').closest('button');
    expect(lockedChapter).toBeDisabled();
  });

  it('should not disable unlocked chapter buttons', () => {
    render(
      <ChapterList
        chapters={mockChapters}
        currentChapterIndex={1}
      />
    );

    const unlockedChapter = screen.getByText('Segundo Capítulo').closest('button');
    expect(unlockedChapter).not.toBeDisabled();
  });

  it('should render empty list when no chapters provided', () => {
    render(
      <ChapterList
        chapters={[]}
        currentChapterIndex={0}
      />
    );

    expect(screen.getByText('Capítulos')).toBeInTheDocument();
    expect(screen.queryByText('Capítulo 1')).not.toBeInTheDocument();
  });
});
