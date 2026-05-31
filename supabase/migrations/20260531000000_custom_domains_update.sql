-- =============================================================================
-- MIGRATION: Premium Custom Domains
-- Date: 2026-05-31
-- Description:
--   1. Add domain_status to track verification lifecycle.
--   2. Add domain_verification_token for TXT record checks.
--   3. Ensure custom_domain uniqueness across the entire platform.
-- =============================================================================

-- 1. Create a type for domain status
DO $$ BEGIN
    CREATE TYPE domain_status_type AS ENUM ('pending', 'verifying', 'connected', 'failed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add columns to landing_pages
ALTER TABLE public.landing_pages
ADD COLUMN IF NOT EXISTS domain_status domain_status_type DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS domain_verification_token TEXT DEFAULT md5(random()::text);

-- 3. Ensure custom_domain has a unique index if it doesn't already
-- (Note: init.sql already had UNIQUE on custom_domain, but good to be explicit)
CREATE UNIQUE INDEX IF NOT EXISTS idx_landing_pages_custom_domain_unique
ON public.landing_pages (custom_domain)
WHERE custom_domain IS NOT NULL;

-- 4. Index for performance
CREATE INDEX IF NOT EXISTS idx_landing_pages_domain_status ON public.landing_pages(domain_status);

-- 5. Function to refresh verification token
CREATE OR REPLACE FUNCTION public.refresh_domain_verification_token(page_id UUID)
RETURNS TEXT AS $$
DECLARE
    new_token TEXT;
BEGIN
    new_token := md5(random()::text);
    UPDATE public.landing_pages
    SET domain_verification_token = new_token,
        domain_status = 'pending'
    WHERE id = page_id;
    RETURN new_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
