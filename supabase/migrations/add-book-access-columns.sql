-- ============================================================================
-- MIGRATION: Add book access columns to profiles table
-- ============================================================================
-- This migration adds columns required for the post-purchase flow:
-- - Webhook updates: access_type, has_book_access, book_purchased_at
-- - Profile trigger: nome, email, perfil_is_complete, senha_is_seted
-- - ProfileService: app_source, language
--
-- Safe to run multiple times (uses IF NOT EXISTS).
-- Does NOT add payment_id or payment_provider — those stay in the purchases table.
--
-- Requirements: 1.1, 2.1
-- ============================================================================

-- Book access columns (used by webhook and ProfileService)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS access_type TEXT DEFAULT 'free';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS has_book_access BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS book_purchased_at TIMESTAMPTZ;

-- App metadata columns (used by ProfileService)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_source TEXT DEFAULT 'journey';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'pt';

-- Profile identity columns (used by trigger and ProfileService)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS nome TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Profile state columns (used by trigger and ProfileService)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS perfil_is_complete BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS senha_is_seted BOOLEAN DEFAULT true;

-- ============================================================================
-- INDEX: Fast email lookup for webhook processing
-- ============================================================================
-- The webhook looks up profiles by email to update access after payment approval.
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
