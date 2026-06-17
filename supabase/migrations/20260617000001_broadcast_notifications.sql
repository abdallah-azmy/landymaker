-- =============================================================================
-- MIGRATION: Broadcast Notifications Support
-- Date: 2026-06-17
-- Description:
--   1. Create broadcast_notification function to allow Super Admins to send
--      notifications to all registered users simultaneously.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.broadcast_notification(
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'info'
)
RETURNS VOID AS $$
BEGIN
    -- Insert a notification for all users in the profiles table
    INSERT INTO public.notifications (user_id, title, message, type)
    SELECT id, p_title, p_message, p_type FROM public.profiles;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
