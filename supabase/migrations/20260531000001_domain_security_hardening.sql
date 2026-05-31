-- =============================================================================
-- MIGRATION: Custom Domain Security Hardening
-- Date: 2026-05-31
-- Description:
--   Enforce Pro tier requirement for custom domains at the database level.
--   Prevents manual API manipulation by non-premium users.
-- =============================================================================

-- 1. Create a function to check if a user is eligible for custom domains
CREATE OR REPLACE FUNCTION public.is_eligible_for_custom_domain(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = p_user_id AND tier IN ('pro', 'enterprise')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Add a CHECK constraint to the landing_pages table
-- (Note: Using a trigger for more complex logic if constraints are too rigid)
CREATE OR REPLACE FUNCTION public.enforce_domain_tier_limit()
RETURNS TRIGGER AS $$
BEGIN
    -- If the user is trying to set a custom domain
    IF NEW.custom_domain IS NOT NULL AND (OLD.custom_domain IS NULL OR NEW.custom_domain <> OLD.custom_domain) THEN
        -- Check if they are pro/enterprise
        IF NOT public.is_eligible_for_custom_domain(NEW.user_id) THEN
            RAISE EXCEPTION 'Custom domains are only available for Pro or Enterprise users.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Bind the trigger
DROP TRIGGER IF EXISTS trigger_enforce_domain_tier_limit ON public.landing_pages;
CREATE TRIGGER trigger_enforce_domain_tier_limit
    BEFORE UPDATE ON public.landing_pages
    FOR EACH ROW EXECUTE FUNCTION public.enforce_domain_tier_limit();
