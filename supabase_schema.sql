-- ========================================================
-- Sprinkle Supabase Database Schema & RLS Policies
-- Execute this script in your Supabase Project SQL Editor
-- ========================================================

-- 1. Create Users Table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  uid TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  avatar TEXT DEFAULT '📸',
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Create Memories Table
CREATE TABLE IF NOT EXISTS public.memories (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  notes TEXT,
  rating FLOAT8 DEFAULT 5.0,
  timestamp TIMESTAMPTZ DEFAULT now(),
  image_url TEXT,
  address TEXT,
  tags TEXT[]
);

-- 3. Create Follows Table
CREATE TABLE IF NOT EXISTS public.follows (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  follower_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  followee_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_follow UNIQUE (follower_id, followee_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

-- Users RLS Policies
CREATE POLICY "Public users read access" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users insert access" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users self update access" ON public.users FOR UPDATE USING (true);

-- Memories RLS Policies
CREATE POLICY "Public memories read access" ON public.memories FOR SELECT USING (true);
CREATE POLICY "Memories insert access" ON public.memories FOR INSERT WITH CHECK (true);
CREATE POLICY "Memories update access" ON public.memories FOR UPDATE USING (true);
CREATE POLICY "Memories delete access" ON public.memories FOR DELETE USING (true);

-- Follows RLS Policies
CREATE POLICY "Public follows read access" ON public.follows FOR SELECT USING (true);
CREATE POLICY "Follows insert access" ON public.follows FOR INSERT WITH CHECK (true);
CREATE POLICY "Follows delete access" ON public.follows FOR DELETE USING (true);

-- Create Public Storage Bucket for Memory Images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('memory-images', 'memory-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS Policies
CREATE POLICY "Public read memory images" ON storage.objects FOR SELECT USING (bucket_id = 'memory-images');
CREATE POLICY "Authenticated upload memory images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'memory-images');
