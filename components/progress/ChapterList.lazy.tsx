'use client';

import dynamic from 'next/dynamic';
import type { ChapterProgress } from '@/lib/types/domain.types';

/**
 * Lazy-loaded ChapterList Component
 * 
 * Dynamically imports the ChapterList component to reduce initial bundle size.
 * The chapter list can be loaded after the main chat interface is visible.
 * 
 * Performance optimization for Task 24.1
 */

interface ChapterListProps {
  chapters: ChapterProgress[];
  currentChapterIndex: number;
  onChapterSelect?: (chapterId: string) => void;
}

const ChapterList = dynamic<ChapterListProps>(() => import('./ChapterList'), {
  loading: () => (
    <nav className="w-full bg-zinc-900 border-b border-zinc-800" aria-label="Carregando lista de capítulos">
      <div className="max-w-4xl mx-auto p-4">
        <div className="h-6 w-32 bg-zinc-800 rounded animate-pulse mb-4" />
        <div className="space-y-2">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-20 bg-zinc-800/50 rounded-lg animate-pulse" />
          ))}
        </div>
      </div>
    </nav>
  ),
  ssr: true,
});

export default ChapterList;
