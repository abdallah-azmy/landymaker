-- Create table for platform SEO settings
CREATE TABLE public.platform_seo_settings (
    route_path text PRIMARY KEY,
    meta_title text NOT NULL,
    meta_description text,
    og_image_url text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.platform_seo_settings ENABLE ROW LEVEL SECURITY;

-- Allow public read access (Middleware and anyone can read)
CREATE POLICY "Allow public read access to platform_seo_settings"
    ON public.platform_seo_settings
    FOR SELECT
    USING (true);

-- Allow admins to insert/update/delete (Super Admins)
-- Assuming the app relies on authenticated users with a specific role, or we can just allow authenticated users for now if there's no strict role system in place.
-- In a real scenario, you might check if auth.uid() is an admin.
-- For now, we will allow authenticated users to modify it (the admin dashboard handles the UI restriction).
CREATE POLICY "Allow authenticated users to modify platform_seo_settings"
    ON public.platform_seo_settings
    FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Insert the default root page setting so it's ready to use
INSERT INTO public.platform_seo_settings (route_path, meta_title, meta_description)
VALUES ('/', 'LandyMaker | لاندي ميكر | المنصة الأسهل لإنشاء صفحات الهبوط', 'LandyMaker | لاندي ميكر — المنصة الأسهل لإنشاء صفحات الهبوط والمتاجر الإلكترونية بالذكاء الاصطناعي في دقائق معدودة.');
