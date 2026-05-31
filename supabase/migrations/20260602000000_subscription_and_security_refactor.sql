-- =============================================================================
-- MIGRATION: Subscription & Security Limits Refactor
-- Date: 2026-06-02
-- Description:
--   1. Create system_security_limits (Immutable by API).
--   2. Create subscription_plans (Configurable by Admin).
--   3. Create audit logs.
--   4. Implement database-level enforcement (Triggers).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Security Limits (Infrastructure Layer)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.system_security_limits (
    key TEXT PRIMARY KEY,
    value_int INTEGER NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Seed static security boundaries
INSERT INTO public.system_security_limits (key, value_int, description)
VALUES
    ('MAX_PLAN_PAGE_LIMIT', 50, 'Absolute maximum any subscription plan can allow.'),
    ('SUPER_ADMIN_PAGE_LIMIT', 500, 'Absolute maximum pages for a Super Admin account.')
ON CONFLICT (key) DO NOTHING;

-- Revoke all API access to this table (Safe from any mistake in RLS or Edge Functions)
REVOKE ALL ON public.system_security_limits FROM anon, authenticated;
-- Allow authenticated users (Admins) to READ only for UI display
GRANT SELECT ON public.system_security_limits TO authenticated;

-- -----------------------------------------------------------------------------
-- 2. Subscription Plans (Business Layer)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id TEXT PRIMARY KEY, -- 'free', 'pro', 'enterprise', etc.
    display_name TEXT NOT NULL,
    monthly_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    page_limit INTEGER NOT NULL DEFAULT 1,
    custom_domain_access BOOLEAN NOT NULL DEFAULT false,
    advanced_seo_access BOOLEAN NOT NULL DEFAULT false,
    features JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Seed initial plans
INSERT INTO public.subscription_plans (id, display_name, monthly_price, page_limit, custom_domain_access, advanced_seo_access)
VALUES
    ('free', 'المجانية', 0.00, 1, false, false),
    ('pro', 'برو', 299.00, 5, true, true),
    ('enterprise', 'المؤسسات', 999.00, 20, true, true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view plans" ON public.subscription_plans FOR SELECT USING (true);
CREATE POLICY "Super admins can manage plans" ON public.subscription_plans FOR ALL
USING (public.is_super_admin(auth.uid()));

-- -----------------------------------------------------------------------------
-- 3. Audit Logging
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.system_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id),
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.system_audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Super admins can view audit logs" ON public.system_audit_logs FOR SELECT
USING (public.is_super_admin(auth.uid()));

-- -----------------------------------------------------------------------------
-- 4. Enforcement Logic (Triggers)
-- -----------------------------------------------------------------------------

-- A. Prevent Business Plans from exceeding Security Boundaries
CREATE OR REPLACE FUNCTION public.validate_plan_limit()
RETURNS TRIGGER AS $$
DECLARE
    v_max_allowed INTEGER;
BEGIN
    SELECT value_int INTO v_max_allowed FROM public.system_security_limits WHERE key = 'MAX_PLAN_PAGE_LIMIT';

    IF NEW.page_limit > v_max_allowed THEN
        RAISE EXCEPTION 'Plan limit (%) exceeds global security boundary (%)', NEW.page_limit, v_max_allowed;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_plan_limit
    BEFORE INSERT OR UPDATE ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION public.validate_plan_limit();

-- B. Audit Log Trigger
CREATE OR REPLACE FUNCTION public.audit_plan_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.system_audit_logs (user_id, action, table_name, old_data, new_data)
    VALUES (auth.uid(), TG_OP, 'subscription_plans', to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_audit_plan_changes
    AFTER UPDATE ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION public.audit_plan_changes();

-- C. Unified Page Creation Guard
CREATE OR REPLACE FUNCTION public.check_page_limit_unified()
RETURNS TRIGGER AS $$
DECLARE
    v_user_role TEXT;
    v_user_tier TEXT;
    v_current_count INTEGER;
    v_limit INTEGER;
BEGIN
    -- 1. Get identity details
    SELECT role, tier INTO v_user_role, v_user_tier FROM public.profiles WHERE id = NEW.user_id;

    -- 2. Calculate Limit
    IF v_user_role = 'super_admin' THEN
        -- Read from Security Limits
        SELECT value_int INTO v_limit FROM public.system_security_limits WHERE key = 'SUPER_ADMIN_PAGE_LIMIT';
    ELSE
        -- Read from Business Configuration
        SELECT page_limit INTO v_limit FROM public.subscription_plans WHERE id = v_user_tier;
        -- Fallback to free if plan missing
        IF v_limit IS NULL THEN v_limit := 1; END IF;
    END IF;

    -- 3. Count existing pages (excluding the one being inserted)
    SELECT COUNT(*) INTO v_current_count FROM public.landing_pages WHERE user_id = NEW.user_id;

    -- 4. Enforcement
    IF v_current_count >= v_limit THEN
        RAISE EXCEPTION 'Limit reached: You have % pages. Max allowed is %.', v_current_count, v_limit;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Replace old trigger
DROP TRIGGER IF EXISTS trigger_check_page_limit ON public.landing_pages;
CREATE TRIGGER trigger_check_page_limit_v2
    BEFORE INSERT ON public.landing_pages
    FOR EACH ROW EXECUTE FUNCTION public.check_page_limit_unified();
