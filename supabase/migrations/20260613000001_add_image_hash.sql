-- Add hash column to prevent redundant ImgBB uploads
ALTER TABLE public.user_assets ADD COLUMN IF NOT EXISTS image_hash TEXT;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_assets_hash ON public.user_assets(image_hash);
