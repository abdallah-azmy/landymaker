-- ======================================================
-- MIGRATION: templates_table
-- PURPOSE: Create templates table for dynamic template management
-- DEPENDENCIES: profiles table (exists from init migration)
-- ======================================================

CREATE TABLE templates (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    image_url TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    recommended_sections TEXT[] DEFAULT '{}',
    ai_prompt_hint TEXT DEFAULT '',
    design_json JSONB DEFAULT '{"blocks": []}',
    is_active BOOLEAN DEFAULT TRUE,
    is_draft BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

-- Allow public read access to active, non-draft templates
CREATE POLICY "Allow public read access to active templates"
ON templates FOR SELECT
USING (is_active = TRUE AND is_draft = FALSE);

-- Allow Super Admins full read/write access
CREATE POLICY "Allow super admins full access"
ON templates FOR ALL
USING (
    auth.uid() IN (
        SELECT id FROM profiles WHERE role = 'super_admin'
    )
);

-- Auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION update_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_templates_updated_at
    BEFORE UPDATE ON templates
    FOR EACH ROW
    EXECUTE FUNCTION update_templates_updated_at();
