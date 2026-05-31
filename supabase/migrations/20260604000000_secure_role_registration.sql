-- =============================================================================
-- MIGRATION: Secure Role Registration
-- Date: 2026-06-04
-- Description:
--   Update handle_new_user trigger to ALWAYS assign 'user' role on signup.
--   Prevents self-escalation to super_admin via auth metadata.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'full_name', 'User'),
        'user' -- Hardcoded to 'user' for security. Super Admin must be assigned manually.
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
