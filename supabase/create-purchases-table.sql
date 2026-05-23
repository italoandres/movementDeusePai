-- Create purchases table for payment tracking
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  payment_id TEXT UNIQUE NOT NULL,
  product_id TEXT NOT NULL DEFAULT 'livro-nao-ore-fale-com-o-pai',
  status TEXT NOT NULL DEFAULT 'pending',
  access_released BOOLEAN DEFAULT FALSE,
  access_token TEXT,
  token_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_purchases_email ON purchases(email);
CREATE INDEX IF NOT EXISTS idx_purchases_payment_id ON purchases(payment_id);
CREATE INDEX IF NOT EXISTS idx_purchases_access_token ON purchases(access_token);

-- RLS policies
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;

-- Only service role can insert/update (via webhook)
CREATE POLICY "Service role full access" ON purchases
  FOR ALL
  USING (auth.role() = 'service_role');

-- Users can read their own purchases
CREATE POLICY "Users can read own purchases" ON purchases
  FOR SELECT
  USING (auth.email() = email);
