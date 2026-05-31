-- =============================================================================
-- MIGRATION: Slug Reserved Protection
-- Date: 2026-06-01
-- Description:
--   Add a database-level constraint to prevent users from creating landing pages
--   with slugs that conflict with core system routes.
-- =============================================================================

-- 1. Create a function to check if a slug is reserved
CREATE OR REPLACE FUNCTION public.is_slug_reserved(slug TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN slug IN (
        '', 'login', 'register', 'signup', 'signin', 'forgot-password',
        'reset-password', 'dashboard', 'admin', 'settings', 'profile',
        'pricing', 'plans', 'billing', 'checkout', 'success', 'cancel',
        'api', 'auth', 'app', 'editor', 'builder', 'pages', 'page',
        'store', 'products', 'orders', 'analytics', 'support', 'help',
        'about', 'contact', 'privacy', 'terms', 'sitemap', 'robots.txt',
        'favicon.ico', 'home', 'public_viewer', 'assets', 'images',
        'icons', 'web'
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 2. Add a CHECK constraint to the landing_pages table
ALTER TABLE public.landing_pages
ADD CONSTRAINT landing_pages_subdomain_reserved_check
CHECK (NOT public.is_slug_reserved(subdomain));
