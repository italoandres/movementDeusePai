-- ============================================================================
-- Interactive Spiritual Book System - Database Schema
-- ============================================================================
-- This schema creates the database structure for the livro-interativo-espiritual
-- application, including tables for user profiles, chapters, progress tracking,
-- and user messages.
--
-- Requirements: 10.2, 10.3
-- ============================================================================

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Profiles Table
-- ----------------------------------------------------------------------------
-- Extended user profile information beyond Supabase Auth
-- Links to auth.users via foreign key
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  display_name TEXT,
  seal_awarded BOOLEAN DEFAULT FALSE NOT NULL,
  seal_awarded_at TIMESTAMPTZ,
  seal_unlock_reason TEXT CHECK (seal_unlock_reason IN ('journey_complete', 'first_message'))
);

-- Add comment for documentation
COMMENT ON TABLE public.profiles IS 'Extended user profile information with digital seal award tracking';
COMMENT ON COLUMN public.profiles.seal_awarded IS 'Whether the user has been awarded the digital seal';
COMMENT ON COLUMN public.profiles.seal_unlock_reason IS 'The condition that triggered the seal award: journey_complete or first_message';

-- ----------------------------------------------------------------------------
-- Chapters Table
-- ----------------------------------------------------------------------------
-- Static spiritual content organized into sequential chapters
CREATE TABLE IF NOT EXISTS public.chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_index INTEGER NOT NULL UNIQUE,
  title TEXT NOT NULL,
  content JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Add comment for documentation
COMMENT ON TABLE public.chapters IS 'Spiritual content chapters displayed in sequential order';
COMMENT ON COLUMN public.chapters.order_index IS 'Sequential order of chapters (1, 2, 3, ...)';
COMMENT ON COLUMN public.chapters.content IS 'JSONB structure containing messages array and metadata';

-- ----------------------------------------------------------------------------
-- User Progress Table
-- ----------------------------------------------------------------------------
-- Tracks which chapters each user has completed
CREATE TABLE IF NOT EXISTS public.user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
  completed BOOLEAN DEFAULT FALSE NOT NULL,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, chapter_id)
);

-- Add comment for documentation
COMMENT ON TABLE public.user_progress IS 'Tracks user progress through chapters';
COMMENT ON COLUMN public.user_progress.completed IS 'Whether the user has completed this chapter';
COMMENT ON COLUMN public.user_progress.completed_at IS 'Timestamp when the chapter was completed';

-- ----------------------------------------------------------------------------
-- Messages Table
-- ----------------------------------------------------------------------------
-- User-submitted messages during their spiritual journey
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Add comment for documentation
COMMENT ON TABLE public.messages IS 'User-submitted messages associated with chapters';
COMMENT ON COLUMN public.messages.content IS 'The text content of the user message';

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- User Progress Indexes
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id 
  ON public.user_progress(user_id);

CREATE INDEX IF NOT EXISTS idx_user_progress_chapter_id 
  ON public.user_progress(chapter_id);

CREATE INDEX IF NOT EXISTS idx_user_progress_completed 
  ON public.user_progress(user_id, completed) 
  WHERE completed = true;

-- Messages Indexes
CREATE INDEX IF NOT EXISTS idx_messages_user_id 
  ON public.messages(user_id);

CREATE INDEX IF NOT EXISTS idx_messages_chapter_id 
  ON public.messages(chapter_id);

CREATE INDEX IF NOT EXISTS idx_messages_created_at 
  ON public.messages(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_user_chapter 
  ON public.messages(user_id, chapter_id);

-- Chapters Indexes
CREATE INDEX IF NOT EXISTS idx_chapters_order 
  ON public.chapters(order_index);

-- Profiles Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_seal_awarded 
  ON public.profiles(seal_awarded) 
  WHERE seal_awarded = true;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- Profiles Policies
-- ----------------------------------------------------------------------------

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own profile (for initial profile creation)
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ----------------------------------------------------------------------------
-- Chapters Policies
-- ----------------------------------------------------------------------------

-- All authenticated users can read chapters
CREATE POLICY "Authenticated users can read chapters"
  ON public.chapters FOR SELECT
  TO authenticated
  USING (true);

-- ----------------------------------------------------------------------------
-- User Progress Policies
-- ----------------------------------------------------------------------------

-- Users can view their own progress
CREATE POLICY "Users can view own progress"
  ON public.user_progress FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own progress
CREATE POLICY "Users can insert own progress"
  ON public.user_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own progress
CREATE POLICY "Users can update own progress"
  ON public.user_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- ----------------------------------------------------------------------------
-- Messages Policies
-- ----------------------------------------------------------------------------

-- Users can view their own messages
CREATE POLICY "Users can view own messages"
  ON public.messages FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own messages
CREATE POLICY "Users can insert own messages"
  ON public.messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Note: No update or delete policies for messages (immutable by design)

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for chapters table
DROP TRIGGER IF EXISTS update_chapters_updated_at ON public.chapters;
CREATE TRIGGER update_chapters_updated_at
  BEFORE UPDATE ON public.chapters
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for user_progress table
DROP TRIGGER IF EXISTS update_user_progress_updated_at ON public.user_progress;
CREATE TRIGGER update_user_progress_updated_at
  BEFORE UPDATE ON public.user_progress
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- FUNCTION TO AUTOMATICALLY CREATE PROFILE ON USER SIGNUP
-- ============================================================================

-- Function to create profile when new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, NEW.email);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- GRANTS (Optional - for additional security configuration)
-- ============================================================================

-- Grant usage on schema to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Grant access to tables for authenticated users
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT ON public.chapters TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_progress TO authenticated;
GRANT SELECT, INSERT ON public.messages TO authenticated;

-- ============================================================================
-- SCHEMA VALIDATION QUERIES (Optional - for testing)
-- ============================================================================

-- Uncomment these queries to validate the schema after creation:

-- List all tables
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- ORDER BY table_name;

-- List all indexes
-- SELECT indexname, tablename FROM pg_indexes 
-- WHERE schemaname = 'public' 
-- ORDER BY tablename, indexname;

-- List all RLS policies
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
-- FROM pg_policies 
-- WHERE schemaname = 'public' 
-- ORDER BY tablename, policyname;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
