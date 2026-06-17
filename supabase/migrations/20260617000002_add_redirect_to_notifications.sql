-- =============================================================================
-- MIGRATION: Update lead notification trigger to populate redirect_to
-- Date: 2026-06-17
-- Description:
--   1. Update lead notification trigger function to set redirect_to.
-- =============================================================================

-- Drop and Re-create handle_new_lead_notification to populate redirect_to
CREATE OR REPLACE FUNCTION public.handle_new_lead_notification()
RETURNS TRIGGER AS $$
DECLARE
    owner_id UUID;
    page_subdomain TEXT;
BEGIN
    -- Get the owner of the landing page
    SELECT user_id, subdomain INTO owner_id, page_subdomain
    FROM public.landing_pages
    WHERE id = NEW.landing_page_id;

    -- Insert notification with redirect_to path
    IF owner_id IS NOT NULL THEN
        INSERT INTO public.notifications (user_id, title, message, type, redirect_to)
        VALUES (
            owner_id,
            'عميل جديد مهتم! 🎉',
            'لقد تلقيت طلباً جديداً من خلال صفحة (' || page_subdomain || '). تحقق من قائمة العملاء لمعرفة التفاصيل.',
            'lead',
            '/dashboard/leads'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
