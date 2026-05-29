-- =============================================================================
-- MIGRATION: Security Hardening
-- Date: 2026-05-28
-- Description:
--   1. Tighten analytics INSERT policy — only allow recording views for
--      pages that are actually published. Prevents unauthenticated flooding.
--   2. Grant super_admin full CRUD access on all landing pages.
--   3. Add index on analytics(created_at) for query performance.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Drop the overly permissive analytics INSERT policy
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "Anyone can record analytics" ON public.analytics;

-- Replacement: only allow INSERT if the landing_page_id exists AND is published
CREATE POLICY "Anyone can record analytics for published pages"
    ON public.analytics FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.landing_pages
            WHERE id = landing_page_id
              AND is_published = true
        )
    );

-- -----------------------------------------------------------------------------
-- 2. Super Admin — Full CRUD on all landing pages
-- -----------------------------------------------------------------------------
CREATE POLICY "Super admins can read all pages"
    ON public.landing_pages FOR SELECT
    USING (
        public.is_super_admin(auth.uid())
    );

CREATE POLICY "Super admins can update all pages"
    ON public.landing_pages FOR UPDATE
    USING (
        public.is_super_admin(auth.uid())
    );

CREATE POLICY "Super admins can delete all pages"
    ON public.landing_pages FOR DELETE
    USING (
        public.is_super_admin(auth.uid())
    );

-- Super admin can also INSERT pages (e.g. when seeding demo pages)
CREATE POLICY "Super admins can insert pages"
    ON public.landing_pages FOR INSERT
    WITH CHECK (
        public.is_super_admin(auth.uid())
    );

-- Super admin can view ALL leads (not just pages they own)
CREATE POLICY "Super admins can view all leads"
    ON public.leads FOR SELECT
    USING (
        public.is_super_admin(auth.uid())
    );

-- Super admin can view ALL analytics
CREATE POLICY "Super admins can view all analytics"
    ON public.analytics FOR SELECT
    USING (
        public.is_super_admin(auth.uid())
    );

-- Super admin can manage all profiles (update roles, etc.)
CREATE POLICY "Super admins can update profiles"
    ON public.profiles FOR UPDATE
    USING (
        public.is_super_admin(auth.uid())
    );

-- -----------------------------------------------------------------------------
-- 3. Performance index on analytics(created_at) for time-range queries
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_analytics_created_at
    ON public.analytics (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_analytics_page_event
    ON public.analytics (landing_page_id, event_type);
