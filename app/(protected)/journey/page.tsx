import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import LogoutButton from '@/components/auth/LogoutButton';
import { ChatWrapper } from '@/components/chat/ChatWrapper';
import ProgressBar from '@/components/progress/ProgressBar';
import ChapterCompletionHandler from '@/components/progress/ChapterCompletionHandler';
import { ChatErrorBoundary } from '@/components/error';
// Lazy-loaded components for better performance
import DigitalSeal from '@/components/seal/DigitalSeal.lazy';
import ChapterList from '@/components/progress/ChapterList.lazy';
import { getChapterMessages, getChapterById } from '@/lib/services/chapterService';
import { getMessagesByChapter } from '@/lib/services/messageService';
import { isChapterUnlocked, getNextChapter, getProgress } from '@/lib/services/progressService';
import { getSealInfo } from '@/lib/services/sealService';
import type { DisplayMessage, UserDisplayMessage, Chapter } from '@/lib/types/domain.types';
import Link from 'next/link';

/**
 * Journey Page (Protected Route)
 * 
 * Main chat interface for the spiritual journey.
 * Implements sequential chapter unlocking with route guard.
 * Integrates ProgressBar and ChapterList for journey navigation.
 * Displays digital seal if awarded.
 * 
 * Requirements: 2.1, 2.2, 3.3, 4.1, 4.5, 5.4, 5.5, 7.5, 9.5, 10.1
 */
export default async function JourneyPage({
  searchParams,
}: {
  searchParams: { chapterId?: string };
}) {
  const supabase = await createClient();
  
  // Check authentication
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    redirect('/login');
  }

  // Fetch user progress
  const progressResult = await getProgress(user.id);
  
  if (progressResult.error || !progressResult.data) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-white mb-4">Erro ao carregar progresso</h1>
          <p className="text-gray-400 mb-6">{progressResult.error || 'Progresso não encontrado.'}</p>
          <LogoutButton />
        </div>
      </div>
    );
  }

  const journeyProgress = progressResult.data;

  // Fetch seal information
  const sealResult = await getSealInfo(user.id);
  const sealInfo = sealResult.data || {
    awarded: false,
    awardedAt: null,
    unlockReason: null,
  };

  // Determine which chapter to display
  let chapter: Chapter;
  let currentChapterIndex = journeyProgress.currentChapterIndex;
  
  if (searchParams.chapterId) {
    // User is trying to access a specific chapter
    const chapterResult = await getChapterById(searchParams.chapterId);
    
    if (chapterResult.error || !chapterResult.data) {
      return (
        <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-white mb-4">Erro ao carregar capítulo</h1>
            <p className="text-gray-400 mb-6">{chapterResult.error || 'Capítulo não encontrado.'}</p>
            <LogoutButton />
          </div>
        </div>
      );
    }
    
    // Check if chapter is unlocked
    const unlockResult = await isChapterUnlocked(user.id, searchParams.chapterId);
    
    if (unlockResult.error) {
      return (
        <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-white mb-4">Erro ao verificar acesso</h1>
            <p className="text-gray-400 mb-6">{unlockResult.error}</p>
            <LogoutButton />
          </div>
        </div>
      );
    }
    
    // If chapter is locked, show "not yet available" message
    if (!unlockResult.data) {
      // Get the next unlocked chapter to redirect to
      const nextChapterResult = await getNextChapter(user.id);
      
      return (
        <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
          <div className="text-center max-w-md">
            <h1 className="text-2xl font-bold text-white mb-4">Capítulo ainda não disponível</h1>
            <p className="text-gray-400 mb-6">
              Complete os capítulos anteriores para desbloquear este capítulo.
            </p>
            {nextChapterResult.data && (
              <a
                href={`/journey?chapterId=${nextChapterResult.data.id}`}
                className="inline-block px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors mb-4"
              >
                Ir para capítulo atual
              </a>
            )}
            <div className="mt-4">
              <LogoutButton />
            </div>
          </div>
        </div>
      );
    }
    
    chapter = chapterResult.data;
    
    // Update current chapter index based on selected chapter
    const chapterProgressIndex = journeyProgress.chapters.findIndex(
      cp => cp.chapter.id === chapter.id
    );
    if (chapterProgressIndex !== -1) {
      currentChapterIndex = chapterProgressIndex;
    }
  } else {
    // No chapter specified, use current chapter from progress
    const currentChapterProgress = journeyProgress.chapters[currentChapterIndex];
    
    if (!currentChapterProgress) {
      return (
        <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-white mb-4">Erro ao carregar capítulo</h1>
            <p className="text-gray-400 mb-6">Capítulo atual não encontrado.</p>
            <LogoutButton />
          </div>
        </div>
      );
    }
    
    chapter = currentChapterProgress.chapter;
  }

  // Fetch chapter content messages
  const contentMessagesResult = await getChapterMessages(chapter.id);
  
  if (contentMessagesResult.error || !contentMessagesResult.data) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-white mb-4">Erro ao carregar conteúdo</h1>
          <p className="text-gray-400 mb-6">{contentMessagesResult.error || 'Conteúdo não encontrado.'}</p>
          <LogoutButton />
        </div>
      </div>
    );
  }

  // Fetch user messages for this chapter
  const userMessagesResult = await getMessagesByChapter(user.id, chapter.id);
  
  // Convert user messages to display format
  const userMessages: UserDisplayMessage[] = (userMessagesResult.data || []).map(msg => ({
    type: 'user' as const,
    id: msg.id,
    content: msg.content,
    created_at: msg.created_at,
  }));

  // Combine content messages and user messages
  // Content messages come first, then user messages in chronological order
  const allMessages: DisplayMessage[] = [
    ...contentMessagesResult.data,
    ...userMessages,
  ];

  // Check if current chapter is completed
  const currentChapterProgress = journeyProgress.chapters.find(
    cp => cp.chapter.id === chapter.id
  );
  const isChapterCompleted = currentChapterProgress?.completed || false;

  return (
    <div className="min-h-screen bg-gray-950 flex flex-col">
      {/* Header with logout and profile link */}
      <header className="border-b border-gray-800 p-3 sm:p-4 flex-shrink-0" role="banner">
        <div className="max-w-4xl mx-auto flex justify-between items-center gap-2">
          {/* Seal indicator (compact) */}
          <div className="flex items-center gap-2 sm:gap-4 min-w-0">
            {sealInfo.awarded && (
              <Link 
                href="/profile" 
                className="flex-shrink-0 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950 rounded"
                aria-label="Ver perfil e selo digital"
              >
                <DigitalSeal
                  awarded={sealInfo.awarded}
                  awardedAt={sealInfo.awardedAt}
                  variant="compact"
                />
              </Link>
            )}
          </div>
          
          <nav className="flex items-center gap-2 sm:gap-4 flex-shrink-0" aria-label="Navegação principal">
            <Link
              href="/profile"
              className="text-gray-400 hover:text-white focus:text-white transition-colors text-sm sm:text-base min-h-[44px] flex items-center touch-manipulation focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950 rounded px-2"
              aria-label="Ir para perfil"
            >
              Perfil
            </Link>
            <LogoutButton />
          </nav>
        </div>
      </header>

      {/* Progress Bar */}
      <ProgressBar
        totalChapters={journeyProgress.totalChapters}
        completedChapters={journeyProgress.completedChapters}
        currentChapterIndex={currentChapterIndex}
        percentComplete={journeyProgress.percentComplete}
      />

      {/* Chapter List */}
      <ChapterList
        chapters={journeyProgress.chapters}
        currentChapterIndex={currentChapterIndex}
        onChapterSelect={() => {
          // This will be handled client-side via navigation
        }}
      />

      {/* Chat interface - takes remaining height */}
      <main className="flex-1 overflow-hidden" role="main" aria-label="Interface de chat">
        <ChatErrorBoundary>
          <div className="h-full flex flex-col">
            {/* Chapter title */}
            <header className="border-b border-gray-800 p-3 sm:p-4 flex-shrink-0">
              <div className="max-w-4xl mx-auto">
                <h1 className="text-base sm:text-lg font-semibold text-white truncate">{chapter.title}</h1>
              </div>
            </header>
            
            {/* Chat wrapper */}
            <div className="flex-1 overflow-hidden">
              <ChatWrapper
                initialMessages={allMessages}
                currentChapterId={chapter.id}
                userId={user.id}
                canSendMessage={true}
              />
            </div>

            {/* Chapter completion handler */}
            <footer className="border-t border-gray-800 p-3 sm:p-4 flex-shrink-0">
              <div className="max-w-4xl mx-auto">
                <ChapterCompletionHandler
                  userId={user.id}
                  chapterId={chapter.id}
                  isCompleted={isChapterCompleted}
                />
              </div>
            </footer>
          </div>
        </ChatErrorBoundary>
      </main>
    </div>
  );
}
