/**
 * Test utility to verify Supabase connection
 * Run this after configuring your .env.local file
 * 
 * Usage:
 * 1. Configure your .env.local with actual Supabase credentials
 * 2. Run: npx tsx lib/supabase/test-connection.ts
 */

import { createClient } from './client'

async function testConnection() {
  console.log('Testing Supabase connection...\n')

  // Check environment variables
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!url || url === 'your-project-url-here') {
    console.error('❌ NEXT_PUBLIC_SUPABASE_URL is not configured')
    console.log('Please update your .env.local file with your actual Supabase URL')
    process.exit(1)
  }

  if (!key || key === 'your-anon-key-here') {
    console.error('❌ NEXT_PUBLIC_SUPABASE_ANON_KEY is not configured')
    console.log('Please update your .env.local file with your actual Supabase anon key')
    process.exit(1)
  }

  console.log('✅ Environment variables are configured')
  console.log(`   URL: ${url}`)
  console.log(`   Key: ${key.substring(0, 20)}...`)
  console.log()

  // Test connection
  try {
    const supabase = createClient()
    const { data, error } = await supabase.auth.getSession()

    if (error) {
      console.error('❌ Connection test failed:', error.message)
      process.exit(1)
    }

    console.log('✅ Successfully connected to Supabase!')
    console.log('   Session:', data.session ? 'Active' : 'No active session (this is normal)')
    console.log()
    console.log('🎉 Your Supabase setup is complete!')
    console.log()
    console.log('Next steps:')
    console.log('1. Create database tables (Task 2.2)')
    console.log('2. Configure Row Level Security (Task 2.3)')
    console.log('3. Set up authentication in your Supabase dashboard')
  } catch (err) {
    console.error('❌ Unexpected error:', err)
    process.exit(1)
  }
}

testConnection()
