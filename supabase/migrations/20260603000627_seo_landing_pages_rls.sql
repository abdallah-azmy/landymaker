-- Enable RLS on the table if not already enabled
ALTER TABLE public.landing_pages ENABLE ROW LEVEL SECURITY;

-- Drop policy if it already exists to avoid conflict when running migrations
DROP POLICY IF EXISTS "Allow public read access for published landing pages" ON public.landing_pages;

-- Create policy to allow public (anonymous) read access ONLY for published pages
-- This is critical for the SEO Middleware and Sitemap Generator to fetch page data
CREATE POLICY "Allow public read access for published landing pages" 
ON public.landing_pages 
FOR SELECT 
USING (is_published = true);
