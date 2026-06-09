-- =============================================================================
-- MIGRATION: Advanced Analytics Events
-- Date: 2026-06-11
-- Description:
--   1. Expand analytics event types.
--   2. Add metadata column for detailed event tracking.
--   3. Add a generic event recording function.
-- =============================================================================

-- 1. Remove old check constraint
ALTER TABLE public.analytics DROP CONSTRAINT IF EXISTS analytics_event_type_check;

-- 2. Add new event types and metadata column
ALTER TABLE public.analytics
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Re-apply expanded constraint
ALTER TABLE public.analytics
ADD CONSTRAINT analytics_event_type_check
CHECK (event_type IN ('view', 'conversion', 'cta_click', 'whatsapp_open', 'funnel_start', 'funnel_complete'));

-- 3. Create a generic event recording function
CREATE OR REPLACE FUNCTION public.record_page_event(
    p_page_id UUID,
    p_event_type TEXT,
    p_visitor_ip TEXT DEFAULT NULL,
    p_fingerprint TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID AS $$
BEGIN
    -- 1. Insert the event
    INSERT INTO public.analytics (landing_page_id, event_type, ip_address, visitor_fingerprint, metadata)
    VALUES (p_page_id, p_event_type, p_visitor_ip, p_fingerprint, p_metadata);

    -- 2. Handle aggregate counters for legacy support
    IF p_event_type = 'view' THEN
        UPDATE public.landing_pages SET views_count = views_count + 1, last_visited_at = now() WHERE id = p_page_id;
    ELSIF p_event_type = 'conversion' THEN
        UPDATE public.landing_pages SET purchases_count = purchases_count + 1 WHERE id = p_page_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Update the aggregate stats function to be aware of new events (Optional, can be done in DB later if needed)
-- For now, keep it simple for legacy dashboards.
