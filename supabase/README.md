# Supabase Database Schema

This directory contains the SQL schema for the Interactive Spiritual Book System database.

## Files

- **schema.sql** - Complete database schema including tables, indexes, RLS policies, and triggers

## Schema Overview

The database consists of four main tables:

### 1. profiles
Extended user profile information linked to Supabase Auth users.
- Stores display name
- Tracks digital seal award status and unlock reason
- Automatically created when a user signs up

### 2. chapters
Static spiritual content organized into sequential chapters.
- Each chapter has an order_index for sequential display
- Content stored as JSONB with messages array
- Read-only for authenticated users

### 3. user_progress
Tracks which chapters each user has completed.
- One record per user-chapter pair
- Stores completion status and timestamp
- Used for sequential chapter unlocking

### 4. messages
User-submitted messages during their spiritual journey.
- Associated with both user and chapter
- Immutable (no updates or deletes)
- Ordered by creation timestamp

## Performance Optimizations

The schema includes several indexes for optimal query performance:

- **User Progress**: Indexed by user_id, chapter_id, and completed status
- **Messages**: Indexed by user_id, chapter_id, and created_at
- **Chapters**: Indexed by order_index
- **Profiles**: Indexed by seal_awarded status

## Security (Row Level Security)

All tables have RLS enabled with the following policies:

- **profiles**: Users can only view and update their own profile
- **chapters**: All authenticated users can read chapters
- **user_progress**: Users can only access their own progress
- **messages**: Users can only view and create their own messages

## Automatic Features

### Timestamp Updates
The schema includes triggers that automatically update the `updated_at` column when records are modified in:
- profiles
- chapters
- user_progress

### Profile Creation
A trigger automatically creates a profile record when a new user signs up through Supabase Auth.

## How to Apply the Schema

### Option 1: Supabase Dashboard (Recommended for first-time setup)

1. Log in to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of `schema.sql`
4. Paste into the SQL Editor
5. Click "Run" to execute the schema

### Option 2: Supabase CLI

If you have the Supabase CLI installed:

```bash
# Make sure you're in the project root directory
supabase db reset

# Or apply the schema directly
supabase db push
```

### Option 3: psql Command Line

If you have direct database access:

```bash
psql -h <your-supabase-host> -U postgres -d postgres -f supabase/schema.sql
```

## Verification

After applying the schema, you can verify it was created correctly by running these queries in the SQL Editor:

### Check Tables
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

Expected tables: chapters, messages, profiles, user_progress

### Check Indexes
```sql
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname = 'public' 
ORDER BY tablename, indexname;
```

### Check RLS Policies
```sql
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, policyname;
```

## Schema Updates

If you need to modify the schema after initial creation:

1. Create a new migration file (e.g., `migration_001.sql`)
2. Include only the changes (ALTER TABLE, CREATE INDEX, etc.)
3. Apply the migration through the Supabase dashboard or CLI

## Troubleshooting

### "relation already exists" errors
If you see these errors, the tables already exist. You can either:
- Drop the existing tables first (⚠️ this will delete all data)
- Modify the schema to use `CREATE TABLE IF NOT EXISTS`

### RLS policy errors
If you get permission errors:
- Verify RLS is enabled on all tables
- Check that policies are created correctly
- Ensure you're authenticated when testing

### Trigger not firing
If the profile creation trigger doesn't work:
- Verify the trigger is created on `auth.users`
- Check that the function has `SECURITY DEFINER` set
- Ensure the `public.profiles` table exists

## Related Documentation

- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Indexes](https://www.postgresql.org/docs/current/indexes.html)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/triggers.html)

## Requirements Traceability

This schema satisfies the following requirements:
- **10.2**: Database tables for profiles, chapters, user_progress, messages
- **10.3**: Performance indexes on frequently queried columns
- **10.6**: Row Level Security for user data isolation
