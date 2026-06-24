-- Create audit trigger function for homepage_sections
CREATE OR REPLACE FUNCTION public.audit_homepage_sections_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.system_audit_logs (user_id, action, table_name, old_data, new_data)
    VALUES (
        auth.uid(),
        TG_OP,
        'homepage_sections',
        CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE to_jsonb(OLD) END,
        CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE to_jsonb(NEW) END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach the trigger to the homepage_sections table
DROP TRIGGER IF EXISTS trigger_audit_homepage_sections ON public.homepage_sections;
CREATE TRIGGER trigger_audit_homepage_sections
    AFTER INSERT OR UPDATE OR DELETE ON public.homepage_sections
    FOR EACH ROW EXECUTE FUNCTION public.audit_homepage_sections_changes();
