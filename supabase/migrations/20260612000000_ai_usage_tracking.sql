-- =============================================================================
-- MIGRATION: AI Usage Tracking & Quota Enforcement
-- Date: 2026-06-12
-- Description:
--   1. Create ai_usage_log to track AI generations.
--   2. Add a function to check if a user has remaining AI credits.
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.ai_usage_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE, -- Nullable for guests
    ip_address TEXT, -- Tracked for guest rate limiting
    feature_type TEXT NOT NULL CHECK (feature_type IN ('page_generation', 'copywriting')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Index for fast quota calculation
CREATE INDEX idx_ai_usage_user_date ON public.ai_usage_log (user_id, created_at);

-- Function to check AI quota
CREATE OR REPLACE FUNCTION public.check_ai_quota(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_tier TEXT;
    v_limit INTEGER;
    v_used INTEGER;
    v_month_start TIMESTAMP;
BEGIN
    -- 1. Get user tier
    SELECT tier INTO v_tier FROM public.profiles WHERE id = p_user_id;

    -- 2. Get limit for tier
    SELECT ai_generation_limit INTO v_limit FROM public.subscription_plans WHERE id = v_tier;
    IF v_limit IS NULL THEN v_limit := 3; END IF; -- Default to free limit

    -- 3. Calculate usage this month
    v_month_start := date_trunc('month', now());
    SELECT COUNT(*) INTO v_used FROM public.ai_usage_log
    WHERE user_id = p_user_id AND created_at >= v_month_start;

    RETURN v_used < v_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
