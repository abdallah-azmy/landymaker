-- =============================================================================
-- MIGRATION: Broadcast Notifications Support
-- Date: 2026-06-17
-- Description:
--   1. Create broadcast_notification function to allow Super Admins to send
--      notifications to all registered users simultaneously.
-- =============================================================================

ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS redirect_to TEXT DEFAULT NULL;

CREATE OR REPLACE FUNCTION public.broadcast_notification(
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'info',
    p_redirect_to TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.notifications (user_id, title, message, type, redirect_to)
    SELECT id, p_title, p_message, p_type, p_redirect_to FROM public.profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
