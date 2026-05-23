# Supabase Setup Instructions

This document provides step-by-step instructions for setting up your Supabase project for the Interactive Spiritual Book application.

## Step 1: Create a Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in or create a new account
3. Click "New Project"
4. Fill in the project details:
   - **Name**: Choose a name (e.g., "livro-interativo-espiritual")
   - **Database Password**: Create a strong password (save this securely!)
   - **Region**: Choose the region closest to your users
   - **Pricing Plan**: Select "Free" for development
5. Click "Create new project"
6. Wait for the project to be provisioned (this may take a few minutes)

## Step 2: Get Your API Credentials

1. Once your project is ready, go to **Settings** (gear icon in the sidebar)
2. Navigate to **API** section
3. You'll see two important values:
   - **Project URL**: This is your `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public**: This is your `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## Step 3: Configure Environment Variables

1. Open the `.env.local` file in the root of this project
2. Replace the placeholder values with your actual credentials:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-actual-anon-key-here
```

3. Save the file

## Step 4: Verify the Setup

After configuring your environment variables, you can verify the setup by running:

```bash
npm run dev
```

The application should now be able to connect to your Supabase project.

## Next Steps

After completing this setup, you'll need to:

1. **Create the database schema** (Task 2.2) - Set up the tables for profiles, chapters, user_progress, and messages
2. **Configure Row Level Security** (Task 2.3) - Set up security policies to protect user data
3. **Enable Email Authentication** - Configure authentication providers in Supabase

## Important Security Notes

- ✅ The `.env.local` file is already in `.gitignore` and will NOT be committed to version control
- ✅ The `NEXT_PUBLIC_SUPABASE_ANON_KEY` is safe to expose in the browser (it's designed for client-side use)
- ⚠️ NEVER commit your `.env.local` file or share your credentials publicly
- ⚠️ The database password you created should be stored securely (you'll need it for direct database access)

## Troubleshooting

### "Invalid API key" error
- Double-check that you copied the correct anon key from the Supabase dashboard
- Make sure there are no extra spaces or quotes in your `.env.local` file
- Restart your development server after changing environment variables

### "Failed to fetch" error
- Verify your Project URL is correct
- Check that your internet connection is working
- Ensure your Supabase project is active (not paused)

### Environment variables not loading
- Make sure the file is named exactly `.env.local` (not `.env` or `.env.local.txt`)
- Restart your Next.js development server (`npm run dev`)
- Clear your browser cache and reload

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Auth with Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs)
- [Next.js Environment Variables](https://nextjs.org/docs/basic-features/environment-variables)
