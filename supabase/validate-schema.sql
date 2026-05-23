-- ============================================================================
-- Schema Validation Queries
-- ============================================================================
-- Run these queries after applying schema.sql to verify everything was
-- created correctly.
-- ============================================================================

-- ============================================================================
-- 1. VERIFY TABLES EXIST
-- ============================================================================

SELECT 
  'Tables Check' as check_type,
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'public') as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_name IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY table_name;

-- Expected: 4 tables (chapters, messages, profiles, user_progress)

-- ============================================================================
-- 2. VERIFY INDEXES EXIST
-- ============================================================================

SELECT 
  'Indexes Check' as check_type,
  tablename,
  indexname
FROM pg_indexes 
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY tablename, indexname;

-- Expected: At least 10 indexes

-- ============================================================================
-- 3. VERIFY ROW LEVEL SECURITY IS ENABLED
-- ============================================================================

SELECT 
  'RLS Check' as check_type,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY tablename;

-- Expected: All tables should have rls_enabled = true

-- ============================================================================
-- 4. VERIFY RLS POLICIES EXIST
-- ============================================================================

SELECT 
  'RLS Policies Check' as check_type,
  tablename,
  policyname,
  cmd as operation,
  roles
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Expected: At least 9 policies across all tables

-- ============================================================================
-- 5. VERIFY TRIGGERS EXIST
-- ============================================================================

SELECT 
  'Triggers Check' as check_type,
  trigger_name,
  event_object_table as table_name,
  event_manipulation as event_type
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
  AND (
    event_object_table IN ('profiles', 'chapters', 'user_progress')
    OR (trigger_schema = 'auth' AND event_object_table = 'users')
  )
ORDER BY event_object_table, trigger_name;

-- Expected: 4 triggers (3 for updated_at, 1 for new user)

-- ============================================================================
-- 6. VERIFY FUNCTIONS EXIST
-- ============================================================================

SELECT 
  'Functions Check' as check_type,
  routine_name as function_name,
  routine_type as type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('update_updated_at_column', 'handle_new_user')
ORDER BY routine_name;

-- Expected: 2 functions

-- ============================================================================
-- 7. VERIFY FOREIGN KEY CONSTRAINTS
-- ============================================================================

SELECT 
  'Foreign Keys Check' as check_type,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY tc.table_name, kcu.column_name;

-- Expected: 5 foreign keys
-- - profiles.id -> auth.users.id
-- - user_progress.user_id -> profiles.id
-- - user_progress.chapter_id -> chapters.id
-- - messages.user_id -> profiles.id
-- - messages.chapter_id -> chapters.id

-- ============================================================================
-- 8. VERIFY CHECK CONSTRAINTS
-- ============================================================================

SELECT 
  'Check Constraints' as check_type,
  tc.table_name,
  tc.constraint_name,
  cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'CHECK'
  AND tc.table_name IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY tc.table_name;

-- Expected: 1 check constraint on profiles.seal_unlock_reason

-- ============================================================================
-- 9. VERIFY UNIQUE CONSTRAINTS
-- ============================================================================

SELECT 
  'Unique Constraints' as check_type,
  tc.table_name,
  kcu.column_name,
  tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'UNIQUE'
  AND tc.table_name IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY tc.table_name, kcu.column_name;

-- Expected: 2 unique constraints
-- - chapters.order_index
-- - user_progress(user_id, chapter_id)

-- ============================================================================
-- 10. SUMMARY COUNT
-- ============================================================================

SELECT 
  'Summary' as check_type,
  'Tables' as object_type,
  COUNT(*) as count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('profiles', 'chapters', 'user_progress', 'messages')

UNION ALL

SELECT 
  'Summary' as check_type,
  'Indexes' as object_type,
  COUNT(*) as count
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'chapters', 'user_progress', 'messages')

UNION ALL

SELECT 
  'Summary' as check_type,
  'RLS Policies' as object_type,
  COUNT(*) as count
FROM pg_policies
WHERE schemaname = 'public'

UNION ALL

SELECT 
  'Summary' as check_type,
  'Triggers' as object_type,
  COUNT(*) as count
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'auth')
  AND (
    event_object_table IN ('profiles', 'chapters', 'user_progress')
    OR (trigger_schema = 'auth' AND event_object_table = 'users')
  )

UNION ALL

SELECT 
  'Summary' as check_type,
  'Functions' as object_type,
  COUNT(*) as count
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('update_updated_at_column', 'handle_new_user');

-- Expected Summary:
-- Tables: 4
-- Indexes: 10+
-- RLS Policies: 9
-- Triggers: 4
-- Functions: 2

-- ============================================================================
-- END OF VALIDATION QUERIES
-- ============================================================================
