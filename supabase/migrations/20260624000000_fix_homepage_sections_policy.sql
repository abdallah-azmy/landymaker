-- Drop old policies that are either broken or restrictive
DROP POLICY IF EXISTS "Allow public read access for visible sections" ON public.homepage_sections;
DROP POLICY IF EXISTS "Allow super_admin full access" ON public.homepage_sections;

-- Public can read all sections (visible and invisible) so the frontend can check the visibility flag
CREATE POLICY "Allow public read access for all sections"
ON public.homepage_sections FOR SELECT USING (true);

-- Only super_admin can manage sections (insert, update, delete, select) using the is_super_admin helper function
CREATE POLICY "Allow super_admin full access"
ON public.homepage_sections
FOR ALL
USING (
  public.is_super_admin(auth.uid())
)
WITH CHECK (
  public.is_super_admin(auth.uid())
);
