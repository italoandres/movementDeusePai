import { Metadata } from 'next';
import SignupForm from '@/components/auth/SignupForm';

export const metadata: Metadata = {
  title: 'Criar Conta | Livro Interativo Espiritual',
  description: 'Comece sua jornada espiritual',
};

export default function SignupPage() {
  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-8 sm:px-6 sm:py-12 lg:px-8">
      <main className="w-full max-w-md" role="main" aria-labelledby="signup-heading">
        <header className="text-center mb-6 sm:mb-8">
          <h1 id="signup-heading" className="text-2xl sm:text-3xl font-bold mb-2">Comece sua jornada</h1>
          <p className="text-sm sm:text-base text-gray-400">Crie sua conta para começar</p>
        </header>
        
        <SignupForm />
        
        <nav className="text-center text-xs sm:text-sm text-gray-400 mt-4 sm:mt-6" aria-label="Navegação de autenticação">
          <p>
            Já tem uma conta?{' '}
            <a 
              href="/login" 
              className="text-indigo-400 hover:text-indigo-300 focus:text-indigo-300 transition-colors underline min-h-[44px] inline-flex items-center touch-manipulation focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950 rounded"
              aria-label="Ir para página de login"
            >
              Entrar
            </a>
          </p>
        </nav>
      </main>
    </div>
  );
}
