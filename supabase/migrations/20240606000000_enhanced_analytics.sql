-- Enhance Analytics table to track unique visitors
ALTER TABLE public.analytics
ADD COLUMN IF NOT EXISTS visitor_fingerprint TEXT,
ADD COLUMN IF NOT EXISTS ip_address TEXT;

-- Update the increment_page_view function to track detailed logs
CREATE OR REPLACE FUNCTION public.increment_page_view(
    page_id UUID,
    visitor_ip TEXT DEFAULT NULL,
    fingerprint TEXT DEFAULT NULL,
    increment_purchase BOOLEAN DEFAULT false
)
RETURNS VOID AS $$
BEGIN
    -- 1. Log the event in analytics table
    INSERT INTO public.analytics (landing_page_id, event_type, ip_address, visitor_fingerprint)
    VALUES (page_id, CASE WHEN increment_purchase THEN 'conversion' ELSE 'view' END, visitor_ip, fingerprint);

    -- 2. Update aggregate counters in landing_pages
    UPDATE public.landing_pages
    SET
        views_count = CASE WHEN NOT increment_purchase THEN views_count + 1 ELSE views_count END,
        purchases_count = CASE WHEN increment_purchase THEN purchases_count + 1 ELSE purchases_count END,
        last_visited_at = now()
    WHERE id = page_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a helper function to get enhanced stats including unique visitors
CREATE OR REPLACE FUNCTION public.get_enhanced_page_stats(page_id UUID)
RETURNS JSON AS $$
DECLARE
    total_views INTEGER;
    unique_visitors INTEGER;
    total_conversions INTEGER;
    result JSON;
BEGIN
    SELECT views_count, purchases_count INTO total_views, total_conversions
    FROM public.landing_pages
    WHERE id = page_id;

    SELECT COUNT(DISTINCT visitor_fingerprint) INTO unique_visitors
    FROM public.analytics
    WHERE landing_page_id = page_id AND event_type = 'view' AND visitor_fingerprint IS NOT NULL;

    -- If no fingerprints (old data or bots), fallback to distinct IPs
    IF unique_visitors = 0 THEN
        SELECT COUNT(DISTINCT ip_address) INTO unique_visitors
        FROM public.analytics
        WHERE landing_page_id = page_id AND event_type = 'view' AND ip_address IS NOT NULL;
    END IF;

    result := json_build_object(
        'total_views', COALESCE(total_views, 0),
        'unique_visitors', COALESCE(unique_visitors, 0),
        'total_conversions', COALESCE(total_conversions, 0)
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
