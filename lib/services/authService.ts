import { createClient } from '@/lib/supabase/client';
import type { AuthError, User, Session } from '@supabase/supabase-js';

/**
 * Authentication Service
 * 
 * Provides authentication operations using Supabase Auth:
 * - User registration (signUp)
 * - User login (signIn)
 * - User logout (signOut)
 * - Session management
 * - Error handling for authentication failures
 * 
 * Requirements: 9.4, 9.5, 14.1
 */

export interface AuthResult {
  success: boolean;
  user?: User;
  session?: Session;
  error?: string;
}

export interface SignUpData {
  email: string;
  password: string;
}

export interface SignInData {
  email: string;
  password: string;
}

/**
 * Sign up a new user
 * 
 * Creates a new user account in Supabase Auth and establishes a session.
 * 
 * @param data - User email and password
 * @returns AuthResult with user, session, or error message
 * 
 * **Validates: Requirements 9.3, 9.4, 14.1**
 */
export async function signUp(data: SignUpData): Promise<AuthResult> {
  try {
    const supabase = createClient();
    
    const { data: authData, error } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
    });

    if (error) {
      return {
        success: false,
        error: mapAuthError(error),
      };
    }

    if (!authData.user) {
      return {
        success: false,
        error: 'Erro ao criar conta. Tente novamente.',
      };
    }

    return {
      success: true,
      user: authData.user,
      session: authData.session ?? undefined,
    };
  } catch (error) {
    console.error('Sign up error:', error);
    return {
      success: false,
      error: 'Erro inesperado ao criar conta. Tente novamente.',
    };
  }
}

/**
 * Sign in an existing user
 * 
 * Authenticates user credentials and creates a session with HTTP-only cookie.
 * 
 * @param data - User email and password
 * @returns AuthResult with user, session, or error message
 * 
 * **Validates: Requirements 9.4, 9.5, 14.1**
 */
export async function signIn(data: SignInData): Promise<AuthResult> {
  try {
    const supabase = createClient();
    
    const { data: authData, error } = await supabase.auth.signInWithPassword({
      email: data.email,
      password: data.password,
    });

    if (error) {
      return {
        success: false,
        error: mapAuthError(error),
      };
    }

    if (!authData.user || !authData.session) {
      return {
        success: false,
        error: 'Erro ao fazer login. Tente novamente.',
      };
    }

    return {
      success: true,
      user: authData.user,
      session: authData.session,
    };
  } catch (error) {
    console.error('Sign in error:', error);
    return {
      success: false,
      error: 'Erro inesperado ao fazer login. Tente novamente.',
    };
  }
}

/**
 * Sign out the current user
 * 
 * Terminates the user's session and clears the session cookie.
 * 
 * @returns AuthResult indicating success or failure
 * 
 * **Validates: Requirements 14.5**
 */
export async function signOut(): Promise<AuthResult> {
  try {
    const supabase = createClient();
    
    const { error } = await supabase.auth.signOut();

    if (error) {
      return {
        success: false,
        error: 'Erro ao sair. Tente novamente.',
      };
    }

    return {
      success: true,
    };
  } catch (error) {
    console.error('Sign out error:', error);
    return {
      success: false,
      error: 'Erro inesperado ao sair. Tente novamente.',
    };
  }
}

/**
 * Get the current user session
 * 
 * Retrieves the active session if one exists.
 * 
 * @returns Session object or null if no active session
 * 
 * **Validates: Requirements 9.5, 14.3**
 */
export async function getSession(): Promise<Session | null> {
  try {
    const supabase = createClient();
    const { data: { session }, error } = await supabase.auth.getSession();

    if (error) {
      console.error('Get session error:', error);
      return null;
    }

    return session;
  } catch (error) {
    console.error('Get session error:', error);
    return null;
  }
}

/**
 * Get the current authenticated user
 * 
 * Retrieves the current user from the active session.
 * 
 * @returns User object or null if not authenticated
 * 
 * **Validates: Requirements 9.5**
 */
export async function getCurrentUser(): Promise<User | null> {
  try {
    const supabase = createClient();
    const { data: { user }, error } = await supabase.auth.getUser();

    if (error) {
      console.error('Get user error:', error);
      return null;
    }

    return user;
  } catch (error) {
    console.error('Get user error:', error);
    return null;
  }
}

/**
 * Map Supabase auth errors to user-friendly Portuguese messages
 * 
 * Provides specific error messages for different authentication failure scenarios.
 * 
 * @param error - Supabase AuthError
 * @returns User-friendly error message in Portuguese
 * 
 * **Validates: Requirements 9.6, 15.3**
 */
function mapAuthError(error: AuthError): string {
  // Map common Supabase auth error messages to Portuguese
  const errorMessage = error.message.toLowerCase();

  if (errorMessage.includes('invalid login credentials') || 
      errorMessage.includes('invalid email or password')) {
    return 'Email ou senha incorretos. Tente novamente.';
  }

  if (errorMessage.includes('email not confirmed')) {
    return 'Por favor, confirme seu email antes de continuar.';
  }

  if (errorMessage.includes('user already registered')) {
    return 'Este email já está cadastrado. Tente fazer login.';
  }

  if (errorMessage.includes('password should be at least')) {
    return 'A senha deve ter pelo menos 6 caracteres.';
  }

  if (errorMessage.includes('rate limit')) {
    return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
  }

  if (errorMessage.includes('network') || errorMessage.includes('fetch')) {
    return 'Problema de conexão. Verifique sua internet e tente novamente.';
  }

  // Generic fallback
  return 'Erro ao autenticar. Tente novamente.';
}

/**
 * Check if an error is an authentication error
 * 
 * @param error - Error object
 * @returns true if error is authentication-related
 */
export function isAuthError(error: unknown): boolean {
  if (error && typeof error === 'object' && 'status' in error) {
    const status = (error as { status: number }).status;
    return status === 401 || status === 403;
  }
  return false;
}
