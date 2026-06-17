-- =============================================================================
-- MIGRATION: Targeted Notifications & Super Admin Registration Alerts
-- Date: 2026-06-17
-- Description:
--   1. Create send_targeted_notification to notify specific user(s) privately.
--   2. Create handle_new_user_registration_notification to alert Super Admins.
-- =============================================================================

-- 1. Create send_targeted_notification function
CREATE OR REPLACE FUNCTION public.send_targeted_notification(
    p_user_ids UUID[],
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'info',
    p_redirect_to TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.notifications (user_id, title, message, type, redirect_to)
    SELECT unnest(p_user_ids), p_title, p_message, p_type, p_redirect_to;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create user registration trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user_registration_notification()
RETURNS TRIGGER AS $$
DECLARE
    super_admin_id UUID;
    v_pages_count INT;
BEGIN
    -- Count landing pages of the new user (should be 0 initially)
    SELECT COUNT(*) INTO v_pages_count
    FROM public.landing_pages
    WHERE user_id = NEW.id;

    -- Insert notifications for all super admins
    FOR super_admin_id IN 
        SELECT id FROM public.profiles WHERE role = 'super_admin'
    LOOP
        INSERT INTO public.notifications (user_id, title, message, type, redirect_to)
        VALUES (
            super_admin_id,
            'عضو جديد انضم للمنصة! 👤',
            'البريد: ' || NEW.email || ' | الباقة: ' || COALESCE(NEW.tier, 'free') || ' | الصفحات: ' || v_pages_count,
            'info',
            '/dashboard/super-admin'
        );
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Bind trigger to public.profiles AFTER INSERT
DROP TRIGGER IF EXISTS on_user_profile_created_alert_admin ON public.profiles;

CREATE TRIGGER on_user_profile_created_alert_admin
    AFTER INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_registration_notification();
