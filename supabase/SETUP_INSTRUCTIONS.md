# Database Setup Instructions

Quick guide to set up the database schema for the Interactive Spiritual Book System.

## Prerequisites

- A Supabase project created (see main SUPABASE_SETUP.md if you haven't done this)
- Access to your Supabase dashboard
- Your Supabase project URL and anon key configured in `.env.local`

## Step-by-Step Setup

### Step 1: Access the SQL Editor

1. Go to your Supabase project dashboard: https://app.supabase.com
2. Select your project
3. Click on "SQL Editor" in the left sidebar

### Step 2: Execute the Schema

1. Click "New query" button
2. Open the `supabase/schema.sql` file in this project
3. Copy the entire contents
4. Paste into the SQL Editor
5. Click "Run" (or press Ctrl/Cmd + Enter)

You should see a success message indicating all tables, indexes, and policies were created.

### Step 3: Verify the Setup

Run this verification query in the SQL Editor:

```sql
-- Check that all tables exist
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_name IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY table_name;
```

Expected output:
```
table_name      | column_count
----------------|-------------
chapters        | 5
messages        | 4
profiles        | 6
user_progress   | 7
```

### Step 4: Test RLS Policies

Verify that Row Level Security is working:

```sql
-- Check RLS is enabled
SELECT 
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'chapters', 'user_progress', 'messages')
ORDER BY tablename;
```

All tables should show `rls_enabled = true`.

### Step 5: Test the Trigger

The schema includes a trigger that automatically creates a profile when a user signs up. To test:

1. Go to "Authentication" > "Users" in your Supabase dashboard
2. Click "Add user" > "Create new user"
3. Enter an email and password
4. Click "Create user"
5. Go back to SQL Editor and run:

```sql
SELECT id, display_name, seal_awarded, created_at 
FROM public.profiles 
ORDER BY created_at DESC 
LIMIT 1;
```

You should see the newly created profile with the email as display_name.

## What Gets Created

### Tables (4)
- ✅ `public.profiles` - User profile information
- ✅ `public.chapters` - Spiritual content chapters
- ✅ `public.user_progress` - Chapter completion tracking
- ✅ `public.messages` - User-submitted messages

### Indexes (10)
- ✅ Performance indexes on user_id, chapter_id, created_at, etc.

### RLS Policies (9)
- ✅ Profiles: view own, update own, insert own
- ✅ Chapters: authenticated users can read
- ✅ User Progress: view own, insert own, update own
- ✅ Messages: view own, insert own

### Triggers (4)
- ✅ Auto-update `updated_at` on profiles, chapters, user_progress
- ✅ Auto-create profile on user signup

### Functions (2)
- ✅ `update_updated_at_column()` - Updates timestamp
- ✅ `handle_new_user()` - Creates profile for new users

## Common Issues

### Issue: "permission denied for schema public"

**Solution**: Make sure you're using the correct database credentials. The schema should be run with the `postgres` role or a role with sufficient privileges.

### Issue: "relation already exists"

**Solution**: The tables already exist. If you want to recreate them:

```sql
-- ⚠️ WARNING: This will delete all data!
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.user_progress CASCADE;
DROP TABLE IF EXISTS public.chapters CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Then run the schema.sql again
```

### Issue: Trigger not creating profiles

**Solution**: Check that the trigger exists:

```sql
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'auth'
  AND event_object_table = 'users';
```

If it doesn't exist, run just the trigger creation part of the schema again.

## Next Steps

After the database schema is set up:

1. ✅ Seed initial chapter content (see Task 6.3 in tasks.md)
2. ✅ Test the Supabase client connection (run `npm run test:connection`)
3. ✅ Start implementing the application features

## Need Help?

- Check the main [SUPABASE_SETUP.md](../SUPABASE_SETUP.md) for general Supabase setup
- Review [supabase/README.md](./README.md) for detailed schema documentation
- Consult the [Supabase Documentation](https://supabase.com/docs)
