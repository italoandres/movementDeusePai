import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import ProgressBar from '../ProgressBar';

describe('ProgressBar Component', () => {
  it('should render progress information correctly', () => {
    render(
      <ProgressBar
        totalChapters={10}
        completedChapters={3}
        currentChapterIndex={3}
        percentComplete={30}
      />
    );

    expect(screen.getByText('Sua jornada')).toBeInTheDocument();
    expect(screen.getByText('3 de 10 capítulos concluídos')).toBeInTheDocument();
    expect(screen.getByText('Capítulo atual: 4')).toBeInTheDocument();
  });

  it('should display correct completion percentage', () => {
    const { container } = render(
      <ProgressBar
        totalChapters={5}
        completedChapters={2}
        currentChapterIndex={2}
        percentComplete={40}
      />
    );

    const progressBar = container.querySelector('[style*="width: 40%"]');
    expect(progressBar).toBeInTheDocument();
  });

  it('should show journey complete message when all chapters are done', () => {
    render(
      <ProgressBar
        totalChapters={5}
        completedChapters={5}
        currentChapterIndex={4}
        percentComplete={100}
      />
    );

    expect(screen.getByText('✓ Jornada completa')).toBeInTheDocument();
    expect(screen.queryByText(/Capítulo atual:/)).not.toBeInTheDocument();
  });

  it('should not show current chapter when journey is complete', () => {
    render(
      <ProgressBar
        totalChapters={3}
        completedChapters={3}
        currentChapterIndex={2}
        percentComplete={100}
      />
    );

    expect(screen.queryByText(/Capítulo atual:/)).not.toBeInTheDocument();
  });

  it('should handle zero chapters gracefully', () => {
    render(
      <ProgressBar
        totalChapters={0}
        completedChapters={0}
        currentChapterIndex={0}
        percentComplete={0}
      />
    );

    expect(screen.getByText('0 de 0 capítulos concluídos')).toBeInTheDocument();
  });

  it('should display 0% progress bar when no chapters completed', () => {
    const { container } = render(
      <ProgressBar
        totalChapters={10}
        completedChapters={0}
        currentChapterIndex={0}
        percentComplete={0}
      />
    );

    const progressBar = container.querySelector('[style*="width: 0%"]');
    expect(progressBar).toBeInTheDocument();
  });

  it('should display 100% progress bar when all chapters completed', () => {
    const { container } = render(
      <ProgressBar
        totalChapters={10}
        completedChapters={10}
        currentChapterIndex={9}
        percentComplete={100}
      />
    );

    const progressBar = container.querySelector('[style*="width: 100%"]');
    expect(progressBar).toBeInTheDocument();
  });
});
