-- =============================================================================
-- MIGRATION: New Plans and Feature Gating
-- Date: 2026-06-10
-- Description:
--   1. Add new feature gating columns to subscription_plans.
--   2. Define the new mission-aligned plans: Free, Pro, Business, Agency.
--   3. Update existing profiles to map to new tiers if necessary.
-- =============================================================================

-- 1. Add new columns for advanced gating
ALTER TABLE public.subscription_plans
ADD COLUMN IF NOT EXISTS ai_generation_limit INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS has_smart_whatsapp BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS has_white_label BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS lead_limit_monthly INTEGER NOT NULL DEFAULT 100,
ADD COLUMN IF NOT EXISTS team_member_limit INTEGER NOT NULL DEFAULT 1;

-- 2. Define the new mission-aligned plans
-- Using UPSERT logic to update existing tiers if they exist or insert new ones
INSERT INTO public.subscription_plans (
    id, display_name, monthly_price, page_limit,
    custom_domain_access, advanced_seo_access,
    ai_generation_limit, has_smart_whatsapp,
    has_white_label, lead_limit_monthly, team_member_limit
)
VALUES
    ('free', 'المجانية', 0.00, 3, false, false, 3, false, false, 100, 1),
    ('pro', 'الاحترافية', 29.00, 999, true, true, 50, false, false, 999999, 1),
    ('business', 'الأعمال', 79.00, 999, true, true, 150, true, false, 999999, 3),
    ('agency', 'الوكالات', 199.00, 999, true, true, 500, true, true, 999999, 10)
ON CONFLICT (id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    monthly_price = EXCLUDED.monthly_price,
    page_limit = EXCLUDED.page_limit,
    custom_domain_access = EXCLUDED.custom_domain_access,
    advanced_seo_access = EXCLUDED.advanced_seo_access,
    ai_generation_limit = EXCLUDED.ai_generation_limit,
    has_smart_whatsapp = EXCLUDED.has_smart_whatsapp,
    has_white_label = EXCLUDED.has_white_label,
    lead_limit_monthly = EXCLUDED.lead_limit_monthly,
    team_member_limit = EXCLUDED.team_member_limit,
    updated_at = now();

-- 3. Cleanup old tiers if they are no longer needed
-- For example, 'enterprise' was used before, we might want to map users from 'enterprise' to 'business' or 'agency'
UPDATE public.profiles SET tier = 'business' WHERE tier = 'enterprise';
DELETE FROM public.subscription_plans WHERE id = 'enterprise';

-- 4. Audit the change
INSERT INTO public.system_audit_logs (user_id, action, table_name, new_data)
VALUES (
    null, -- System level change
    'UPDATE_PLANS_MISSION_2026',
    'subscription_plans',
    '{"reason": "Aligning plans with AI & Growth mission"}'::jsonb
);
