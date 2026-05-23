import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import JourneyButton from '@/components/landing/JourneyButton';

/**
 * Landing Page
 * 
 * Displays emotional content based on "Carta de um Órfão" theme
 * with minimalist design and strong typography.
 * 
 * Handles authenticated vs unauthenticated states:
 * - Authenticated users are redirected to their journey
 * - Unauthenticated users see the landing page with CTA
 * 
 * **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 12.1, 12.3**
 */
export default async function Home() {
  // Check if user is already authenticated
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  // If authenticated, redirect to journey
  if (user) {
    redirect('/journey');
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-8 sm:px-6 sm:py-12 lg:px-8">
      <main className="max-w-3xl w-full space-y-8 sm:space-y-12 text-center" role="main" aria-label="Página inicial">
        {/* Hero Section - Carta de um Órfão */}
        <section className="space-y-6 sm:space-y-8" aria-labelledby="hero-heading">
          <h1 id="hero-heading" className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight leading-tight px-2">
            Carta de um Órfão
          </h1>
          
          <div className="space-y-4 sm:space-y-6 text-base sm:text-lg md:text-xl lg:text-2xl leading-relaxed text-gray-300 px-2" role="article" aria-label="Conteúdo emocional">
            <p>
              Você já se sentiu sozinho, mesmo cercado de pessoas?
            </p>
            
            <p>
              Como se ninguém realmente te conhecesse?
            </p>
            
            <p>
              Como se algo essencial estivesse faltando, mas você não consegue nomear o quê?
            </p>
            
            <p className="text-gray-400 text-sm sm:text-base md:text-lg lg:text-xl pt-2 sm:pt-4">
              Essa sensação tem um nome: <strong className="text-gray-200 font-semibold">orfandade espiritual</strong>.
            </p>
            
            <p className="text-gray-400 text-sm sm:text-base md:text-lg lg:text-xl">
              E há uma jornada que pode transformar isso.
            </p>
          </div>
        </section>

        {/* CTA Button */}
        <nav className="pt-4 sm:pt-8" aria-label="Ações principais">
          <JourneyButton />
        </nav>

        {/* Subtle footer text */}
        <footer className="text-xs sm:text-sm text-gray-500 pt-8 sm:pt-12 px-2">
          <p>Uma jornada de descoberta sobre paternidade divina</p>
        </footer>
      </main>
    </div>
  );
}
