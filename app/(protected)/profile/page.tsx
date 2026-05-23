import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import LogoutButton from '@/components/auth/LogoutButton';
import { DigitalSeal } from '@/components/seal';
import { getSealInfo } from '@/lib/services/sealService';
import { getProgress } from '@/lib/services/progressService';
import Link from 'next/link';

/**
 * Profile Page (Protected Route)
 * 
 * Displays user profile information including:
 * - Journey progress summary
 * - Digital seal (if awarded)
 * - Navigation back to journey
 * 
 * Requirements: 7.5, 10.5
 */
export default async function ProfilePage() {
  const supabase = await createClient();
  
  // Check authentication
  const { data: { user }, error } = await supabase.auth.getUser();

  if (error || !user) {
    redirect('/login');
  }

  // Fetch user profile
  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (profileError) {
    console.error('Error fetching profile:', profileError);
  }

  // Fetch seal information
  const sealResult = await getSealInfo(user.id);
  const sealInfo = sealResult.data || {
    awarded: false,
    awardedAt: null,
    unlockReason: null,
  };

  // Fetch journey progress
  const progressResult = await getProgress(user.id);
  const journeyProgress = progressResult.data;

  return (
    <div className="min-h-screen bg-gray-950">
      {/* Header */}
      <header className="border-b border-gray-800 p-3 sm:p-4" role="banner">
        <nav className="max-w-4xl mx-auto flex justify-between items-center gap-2" aria-label="Navegação do perfil">
          <Link
            href="/journey"
            className="text-gray-400 hover:text-white focus:text-white transition-colors flex items-center gap-1 sm:gap-2 text-sm sm:text-base min-h-[44px] touch-manipulation focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950 rounded px-2"
            aria-label="Voltar para jornada"
          >
            <svg
              className="w-4 h-4 sm:w-5 sm:h-5 flex-shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
            <span className="hidden xs:inline">Voltar para jornada</span>
            <span className="xs:hidden">Voltar</span>
          </Link>
          <LogoutButton />
        </nav>
      </header>

      {/* Main content */}
      <main className="max-w-4xl mx-auto p-4 sm:p-6 space-y-6 sm:space-y-8" role="main">
        {/* Profile header */}
        <header className="text-center">
          <h1 className="text-2xl sm:text-3xl font-bold text-white mb-2">Meu Perfil</h1>
          <p className="text-sm sm:text-base text-gray-400 break-words px-2">
            {profile?.display_name || user.email}
          </p>
        </header>

        {/* Journey progress summary */}
        {journeyProgress && (
          <section className="bg-gray-900 rounded-2xl p-4 sm:p-6 border border-gray-800" aria-labelledby="progress-heading">
            <h2 id="progress-heading" className="text-lg sm:text-xl font-semibold text-white mb-4">
              Progresso da Jornada
            </h2>
            <div className="grid grid-cols-2 gap-3 sm:gap-4" role="list">
              <div className="text-center" role="listitem">
                <div className="text-2xl sm:text-3xl font-bold text-indigo-400" aria-label={`${journeyProgress.completedChapters} capítulos completados`}>
                  {journeyProgress.completedChapters}
                </div>
                <div className="text-xs sm:text-sm text-gray-400 mt-1">
                  Capítulos completados
                </div>
              </div>
              <div className="text-center" role="listitem">
                <div className="text-2xl sm:text-3xl font-bold text-purple-400" aria-label={`${journeyProgress.percentComplete} por cento de progresso`}>
                  {journeyProgress.percentComplete}%
                </div>
                <div className="text-xs sm:text-sm text-gray-400 mt-1">
                  Progresso total
                </div>
              </div>
            </div>
          </section>
        )}

        {/* Digital seal section */}
        <section className="bg-gray-900 rounded-2xl p-4 sm:p-6 border border-gray-800" aria-labelledby="seal-heading">
          <h2 id="seal-heading" className="text-lg sm:text-xl font-semibold text-white mb-4 sm:mb-6 text-center">
            Selo Digital
          </h2>
          
          {sealInfo.awarded ? (
            <div className="space-y-4">
              <DigitalSeal
                awarded={sealInfo.awarded}
                awardedAt={sealInfo.awardedAt}
                variant="full"
              />
              
              {sealInfo.unlockReason && (
                <p className="text-center text-xs sm:text-sm text-gray-400">
                  {sealInfo.unlockReason === 'journey_complete'
                    ? 'Concedido por completar toda a jornada'
                    : 'Concedido por enviar sua primeira mensagem'}
                </p>
              )}
            </div>
          ) : (
            <div className="text-center py-6 sm:py-8">
              <div className="w-16 h-16 sm:w-20 sm:h-20 mx-auto mb-4 bg-gray-800 rounded-full flex items-center justify-center" aria-hidden="true">
                <svg
                  className="w-8 h-8 sm:w-10 sm:h-10 text-gray-600"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fillRule="evenodd"
                    d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
                    clipRule="evenodd"
                  />
                </svg>
              </div>
              <h3 className="text-base sm:text-lg font-semibold text-white mb-2">
                Selo ainda não conquistado
              </h3>
              <p className="text-sm sm:text-base text-gray-400 max-w-md mx-auto px-4">
                Complete todos os capítulos da jornada para receber seu selo
                digital e fazer parte do movimento Deus é Pai.
              </p>
            </div>
          )}
        </section>

        {/* Action button */}
        <nav className="text-center" aria-label="Ações do perfil">
          <Link
            href="/journey"
            className="inline-block px-6 py-3 sm:px-8 sm:py-3 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 focus:bg-indigo-700 active:bg-indigo-800 transition-colors text-sm sm:text-base min-h-[44px] touch-manipulation focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950"
            aria-label="Continuar jornada espiritual"
          >
            Continuar jornada
          </Link>
        </nav>
      </main>
    </div>
  );
}
