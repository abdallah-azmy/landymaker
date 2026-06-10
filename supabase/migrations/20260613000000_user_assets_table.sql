-- Create User Assets Table to track external image links (ImgBB)
CREATE TABLE public.user_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    url TEXT NOT NULL,
    name TEXT,
    source TEXT DEFAULT 'imgbb',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.user_assets ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own assets"
    ON public.user_assets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own assets"
    ON public.user_assets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own assets"
    ON public.user_assets FOR DELETE
    USING (auth.uid() = user_id);
