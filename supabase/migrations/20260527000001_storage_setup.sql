-- Create the landing-assets bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('landing-assets', 'landing-assets', true)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- ROW LEVEL SECURITY POLICIES FOR STORAGE
-- -----------------------------------------------------------------------------

-- Drop existing policies if they exist to avoid "already exists" errors
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;

-- 1. Allow public access to view images (as bucket is marked public, this is often default but good to be explicit)
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'landing-assets' );

-- 2. Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'landing-assets'
);

-- 3. Allow users to update their own images
-- This assumes the path structure is 'userId/filename.ext'
CREATE POLICY "Users can update own images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'landing-assets'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 4. Allow users to delete their own images
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'landing-assets'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
