import { Metadata } from 'next';
import LoginForm from '@/components/auth/LoginForm';

export const metadata: Metadata = {
  title: 'Entrar | Livro Interativo Espiritual',
  description: 'Entre para continuar sua jornada espiritual',
};

/**
 * Login Page
 * 
 * Displays login form with session expiration messaging.
 * Handles redirect after successful login.
 * 
 * Requirements: 9.1, 9.2, 14.4
 */
export default function LoginPage({
  searchParams,
}: {
  searchParams: { reason?: string; redirect?: string };
}) {
  // Determine message based on reason
  let message: string | null = null;
  let messageType: 'info' | 'warning' = 'info';
  
  if (searchParams.reason === 'session_expired') {
    message = 'Sua sessão expirou. Por favor, faça login novamente.';
    messageType = 'warning';
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-8 sm:px-6 sm:py-12 lg:px-8">
      <main className="w-full max-w-md" role="main" aria-labelledby="login-heading">
        <header className="text-center mb-6 sm:mb-8">
          <h1 id="login-heading" className="text-2xl sm:text-3xl font-bold mb-2">Bem-vindo de volta</h1>
          <p className="text-sm sm:text-base text-gray-400">Continue sua jornada espiritual</p>
        </header>
        
        {/* Session expiration message */}
        {message && (
          <div 
            className={`mb-4 p-3 sm:p-4 rounded-lg text-sm ${
              messageType === 'warning' 
                ? 'bg-yellow-900/20 border border-yellow-700/50 text-yellow-200' 
                : 'bg-blue-900/20 border border-blue-700/50 text-blue-200'
            }`}
            role="alert"
            aria-live="polite"
          >
            {message}
          </div>
        )}
        
        <LoginForm redirectTo={searchParams.redirect} />
        
        <nav className="text-center text-xs sm:text-sm text-gray-400 mt-4 sm:mt-6" aria-label="Navegação de autenticação">
          <p>
            Ainda não tem uma conta?{' '}
            <a 
              href="/signup" 
              className="text-indigo-400 hover:text-indigo-300 focus:text-indigo-300 transition-colors underline min-h-[44px] inline-flex items-center touch-manipulation focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-950 rounded"
              aria-label="Ir para página de criar conta"
            >
              Criar conta
            </a>
          </p>
        </nav>
      </main>
    </div>
  );
}
