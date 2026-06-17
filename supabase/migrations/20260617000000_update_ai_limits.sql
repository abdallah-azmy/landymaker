-- =============================================================================
-- MIGRATION: Update AI Limits & Super Admin Daily Quota
-- Date: 2026-06-17
-- Description:
--   1. Update ai_generation_limit for default plans: Free=10, Pro=20, Business=30, Agency=40.
--   2. Update check_ai_quota function to support 1000 daily limit for Super Admin
--      and enforce tier limits for other registered users.
-- =============================================================================

-- 1. Update plan limits
UPDATE public.subscription_plans SET ai_generation_limit = 10 WHERE id = 'free';
UPDATE public.subscription_plans SET ai_generation_limit = 20 WHERE id = 'pro';
UPDATE public.subscription_plans SET ai_generation_limit = 30 WHERE id = 'business';
UPDATE public.subscription_plans SET ai_generation_limit = 40 WHERE id = 'agency';

-- 2. Update check_ai_quota function to handle Super Admin role (1000 daily) and plan limits
CREATE OR REPLACE FUNCTION public.check_ai_quota(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_role TEXT;
    v_tier TEXT;
    v_limit INTEGER;
    v_used INTEGER;
    v_month_start TIMESTAMP;
    v_day_start TIMESTAMP;
BEGIN
    -- 1. Get user role and tier
    SELECT role, tier INTO v_role, v_tier FROM public.profiles WHERE id = p_user_id;

    -- 2. If Super Admin, enforce 1000 daily limit
    IF v_role = 'super_admin' THEN
        v_day_start := date_trunc('day', now());
        SELECT COUNT(*) INTO v_used FROM public.ai_usage_log
        WHERE user_id = p_user_id AND created_at >= v_day_start;
        RETURN v_used < 1000;
    END IF;

    -- 3. Get limit for tier
    SELECT ai_generation_limit INTO v_limit FROM public.subscription_plans WHERE id = v_tier;
    IF v_limit IS NULL THEN v_limit := 10; END IF; -- Default to free limit (10)

    -- 4. Calculate usage this month
    v_month_start := date_trunc('month', now());
    SELECT COUNT(*) INTO v_used FROM public.ai_usage_log
    WHERE user_id = p_user_id AND created_at >= v_month_start;

    RETURN v_used < v_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
