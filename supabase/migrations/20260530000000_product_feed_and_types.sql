-- =============================================================================
-- MIGRATION: Product Feed Sync & Website Types
-- Date: 2026-05-30
-- Description:
--   1. Add website_type to landing_pages (store, landing_page, cv).
--   2. Add feed_token for secure RSS access.
--   3. Add index on subdomain for faster lookups in Edge Functions.
-- =============================================================================

-- 1. Add columns to landing_pages
ALTER TABLE public.landing_pages
ADD COLUMN IF NOT EXISTS website_type TEXT NOT NULL DEFAULT 'landing_page' CHECK (website_type IN ('store', 'landing_page', 'cv')),
ADD COLUMN IF NOT EXISTS feed_token UUID DEFAULT gen_random_uuid();

-- 2. Performance & Search Indices
CREATE INDEX IF NOT EXISTS idx_landing_pages_website_type ON public.landing_pages(website_type);
CREATE INDEX IF NOT EXISTS idx_landing_pages_feed_token ON public.landing_pages(feed_token);

-- 3. Function to regenerate feed token (optional security feature)
CREATE OR REPLACE FUNCTION public.rotate_feed_token(page_id UUID)
RETURNS UUID AS $$
DECLARE
    new_token UUID;
BEGIN
    new_token := gen_random_uuid();
    UPDATE public.landing_pages
    SET feed_token = new_token
    WHERE id = page_id;
    RETURN new_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
