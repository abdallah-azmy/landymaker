-- Drop the unique constraint limiting users to a single landing page
ALTER TABLE public.landing_pages DROP CONSTRAINT IF EXISTS landing_pages_user_id_key;

-- Create an index to keep page lookups by user fast
CREATE INDEX IF NOT EXISTS landing_pages_user_id_idx ON public.landing_pages(user_id);

-- Drop the overly permissive insert policies for leads and analytics
DROP POLICY IF EXISTS "Anyone can submit leads" ON public.leads;
DROP POLICY IF EXISTS "Anyone can record analytics" ON public.analytics;

-- Re-create leads insertion policy with a security check verifying the landing page is valid and published
CREATE POLICY "Anyone can submit leads to published pages" 
    ON public.leads FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.landing_pages 
            WHERE id = landing_page_id AND is_published = true
        )
    );

-- Re-create analytics insertion policy verifying the landing page is valid and published
CREATE POLICY "Anyone can record analytics for published pages" 
    ON public.analytics FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.landing_pages 
            WHERE id = landing_page_id AND is_published = true
        )
    );
