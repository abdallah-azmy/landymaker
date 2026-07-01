-- Add source_url column to map original external URLs (Pixabay/Templates) to ImgBB URLs
ALTER TABLE public.user_assets ADD COLUMN IF NOT EXISTS source_url TEXT;

-- Create index for faster lookups by source_url
CREATE INDEX IF NOT EXISTS idx_user_assets_source_url ON public.user_assets(source_url);
