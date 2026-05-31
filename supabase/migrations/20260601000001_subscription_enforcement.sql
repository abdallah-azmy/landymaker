-- =============================================================================
-- MIGRATION: Subscription Page Limits Enforcement
-- Date: 2026-06-01
-- Description:
--   Enforce landing page count limits based on user tier.
--   Rule: Free tier users can only own 1 landing page.
--   Super Admins bypass all limits.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.check_page_limit_on_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_user_role TEXT;
    v_user_tier TEXT;
    v_current_count INTEGER;
    v_max_pages INTEGER;
BEGIN
    -- 1. Get user role and tier
    SELECT role, tier INTO v_user_role, v_user_tier
    FROM public.profiles
    WHERE id = NEW.user_id;

    -- 2. Bypass for Super Admins (Rule 1)
    IF v_user_role = 'super_admin' THEN
        RETURN NEW;
    END IF;

    -- 3. Calculate limit (Rule 2)
    -- Default to 1 for free, 5 for pro, 999 for enterprise
    v_max_pages := CASE
        WHEN v_user_tier = 'pro' THEN 5
        WHEN v_user_tier = 'enterprise' THEN 999
        ELSE 1 -- free tier
    END;

    -- 4. Count existing pages
    SELECT COUNT(*) INTO v_current_count
    FROM public.landing_pages
    WHERE user_id = NEW.user_id;

    -- 5. Enforce limit
    IF v_current_count >= v_max_pages THEN
        RAISE EXCEPTION 'You have reached the maximum number of landing pages allowed for your plan (%)', v_user_tier;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind the trigger
DROP TRIGGER IF EXISTS trigger_check_page_limit ON public.landing_pages;
CREATE TRIGGER trigger_check_page_limit
    BEFORE INSERT ON public.landing_pages
    FOR EACH ROW EXECUTE FUNCTION public.check_page_limit_on_insert();
