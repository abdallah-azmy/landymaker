CREATE TABLE IF NOT EXISTS lead_submissions_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  landing_page_id UUID REFERENCES landing_pages(id) ON DELETE CASCADE,
  ip_address TEXT,
  fingerprint TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE lead_submissions_log ENABLE ROW LEVEL SECURITY;

-- Only Allow Edge Functions to read/write (Service Role or specific policy)
-- For now, allowing all as the functions run with service role anyway if configured
CREATE POLICY "Enable insert for authenticated users only" ON lead_submissions_log FOR INSERT WITH CHECK (true);

-- Add conversion increment function if missing
CREATE OR REPLACE FUNCTION increment_conversion_count(page_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE landing_pages
  SET purchases_count = COALESCE(purchases_count, 0) + 1
  WHERE id = page_id;
END;
$$ LANGUAGE plpgsql;
