-- =============================================================================
-- MIGRATION: Add redirect_to support for notifications
-- Date: 2026-06-17
-- Description:
--   1. Add redirect_to column to notifications table.
--   2. Update lead notification trigger function to set redirect_to.
--   3. Re-create broadcast_notification function to support dynamic redirect path.
-- =============================================================================

-- 1. Add redirect_to column if not exists
ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS redirect_to TEXT DEFAULT NULL;

-- 2. Drop and Re-create handle_new_lead_notification to populate redirect_to
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

-- 3. Drop and Re-create broadcast_notification to support custom redirect path
DROP FUNCTION IF EXISTS public.broadcast_notification(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.broadcast_notification(
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'info',
    p_redirect_to TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- Insert a notification for all users in the profiles table
    INSERT INTO public.notifications (user_id, title, message, type, redirect_to)
    SELECT id, p_title, p_message, p_type, p_redirect_to FROM public.profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
