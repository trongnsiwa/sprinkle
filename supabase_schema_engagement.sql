-- Sprinkle Engagement Phase Schema (Likes & Comments)
-- File: supabase_schema_engagement.sql

-- 1. Memory Likes Table
CREATE TABLE IF NOT EXISTS public.memory_likes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    memory_uuid TEXT NOT NULL REFERENCES public.memories(uuid) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(memory_uuid, user_id)
);

-- 2. Memory Comments Table
CREATE TABLE IF NOT EXISTS public.memory_comments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    memory_uuid TEXT NOT NULL REFERENCES public.memories(uuid) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.memory_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.memory_comments ENABLE ROW LEVEL SECURITY;

-- Policies for memory_likes
CREATE POLICY "Everyone can view memory likes"
    ON public.memory_likes FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can like memories"
    ON public.memory_likes FOR INSERT
    WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can remove their own likes"
    ON public.memory_likes FOR DELETE
    USING (auth.uid() = user_id::uuid);

-- Policies for memory_comments
CREATE POLICY "Everyone can view memory comments"
    ON public.memory_comments FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can post comments"
    ON public.memory_comments FOR INSERT
    WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can delete their own comments"
    ON public.memory_comments FOR DELETE
    USING (auth.uid() = user_id::uuid);

-- For INSERT on memory_likes
CREATE POLICY "Users can like" ON memory_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id::uuid);
