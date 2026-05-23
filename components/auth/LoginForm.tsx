'use client';

import { useState, FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import { signIn } from '@/lib/services/authService';

interface LoginFormProps {
  redirectTo?: string;
}

export default function LoginForm({ redirectTo }: LoginFormProps) {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Form validation
  const validateForm = (): boolean => {
    setError('');

    if (!email.trim()) {
      setError('Por favor, insira seu email');
      return false;
    }

    if (!email.includes('@')) {
      setError('Por favor, insira um email válido');
      return false;
    }

    if (!password) {
      setError('Por favor, insira sua senha');
      return false;
    }

    if (password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres');
      return false;
    }

    return true;
  };

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const result = await signIn({ email, password });

      if (!result.success) {
        setError(result.error || 'Erro ao fazer login. Tente novamente.');
        return;
      }

      // Successful login - redirect to intended destination or journey page
      const destination = redirectTo && redirectTo !== '/' ? redirectTo : '/journey';
      router.push(destination);
      router.refresh();
    } catch (err) {
      setError('Erro ao fazer login. Tente novamente.');
      console.error('Login error:', err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 sm:space-y-6" aria-label="Formulário de login">
      {/* Error display */}
      {error && (
        <div 
          className="bg-red-900/20 border border-red-500/50 text-red-400 px-3 py-2 sm:px-4 sm:py-3 rounded-lg text-xs sm:text-sm"
          role="alert"
          aria-live="assertive"
          aria-atomic="true"
        >
          {error}
        </div>
      )}

      {/* Email field */}
      <div>
        <label 
          htmlFor="email" 
          className="block text-xs sm:text-sm font-medium text-gray-300 mb-1 sm:mb-2"
        >
          Email
        </label>
        <input
          id="email"
          name="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full px-3 py-2 sm:px-4 sm:py-3 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all text-white placeholder-gray-500 text-sm sm:text-base min-h-[44px] touch-manipulation"
          placeholder="seu@email.com"
          disabled={isLoading}
          autoComplete="email"
          required
          aria-required="true"
          aria-invalid={error ? 'true' : 'false'}
          aria-describedby={error ? 'login-error' : undefined}
        />
      </div>

      {/* Password field */}
      <div>
        <label 
          htmlFor="password" 
          className="block text-xs sm:text-sm font-medium text-gray-300 mb-1 sm:mb-2"
        >
          Senha
        </label>
        <input
          id="password"
          name="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full px-3 py-2 sm:px-4 sm:py-3 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all text-white placeholder-gray-500 text-sm sm:text-base min-h-[44px] touch-manipulation"
          placeholder="••••••••"
          disabled={isLoading}
          autoComplete="current-password"
          required
          aria-required="true"
          aria-invalid={error ? 'true' : 'false'}
          aria-describedby={error ? 'login-error' : undefined}
        />
      </div>

      {/* Submit button */}
      <button
        type="submit"
        disabled={isLoading}
        className="w-full py-3 px-4 bg-indigo-600 hover:bg-indigo-700 focus:bg-indigo-700 disabled:bg-gray-700 disabled:cursor-not-allowed text-white font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-900 text-sm sm:text-base min-h-[44px] touch-manipulation"
        aria-label={isLoading ? 'Entrando na conta' : 'Entrar na conta'}
      >
        {isLoading ? 'Entrando...' : 'Entrar'}
      </button>
    </form>
  );
}
