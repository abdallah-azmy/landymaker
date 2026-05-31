-- =============================================================================
-- MIGRATION: Fix Page Defaults & Missing Columns
-- Date: 2026-06-03
-- Description:
--   1. Add is_active, views_count, purchases_count, last_visited_at to landing_pages.
--   2. Ensure correct default values for existing and new rows.
--   3. Add a smart view/function for page status.
-- =============================================================================

-- 1. Add missing columns with safe defaults
ALTER TABLE public.landing_pages
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS views_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS purchases_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_visited_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 2. Update existing rows to have non-null defaults if they were null
UPDATE public.landing_pages SET is_active = true WHERE is_active IS NULL;
UPDATE public.landing_pages SET views_count = 0 WHERE views_count IS NULL;
UPDATE public.landing_pages SET purchases_count = 0 WHERE purchases_count IS NULL;
UPDATE public.landing_pages SET last_visited_at = created_at WHERE last_visited_at IS NULL;

-- 3. Create a helper function to record page views securely
CREATE OR REPLACE FUNCTION public.increment_page_view(page_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.landing_pages
    SET views_count = views_count + 1,
        last_visited_at = now()
    WHERE id = page_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
