-- Create homepage_sections table
CREATE TABLE IF NOT EXISTS public.homepage_sections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  section_key TEXT NOT NULL UNIQUE,
  is_visible BOOLEAN DEFAULT TRUE,
  sort_order INT NOT NULL DEFAULT 0,
  display_name TEXT NOT NULL,
  config JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.homepage_sections ENABLE ROW LEVEL SECURITY;

-- Public can read visible sections
CREATE POLICY "Allow public read access for visible sections"
ON public.homepage_sections FOR SELECT USING (is_visible = true);

-- Only super_admin can manage sections
CREATE POLICY "Allow super_admin full access"
ON public.homepage_sections
FOR ALL
USING (
  auth.jwt() ->> 'role' = 'super_admin'
)
WITH CHECK (
  auth.jwt() ->> 'role' = 'super_admin'
);

-- Seed default sections
INSERT INTO public.homepage_sections (section_key, is_visible, sort_order, display_name, config) VALUES
  ('hero', true, 1, 'Hero Section', '{"title": "ابنِ صفحة هبوط احترافية متكاملة لخدماتك", "subtitle": "بدون الحاجة لخبرة برمجية", "layout": "split", "show_phone_preview": true, "show_ai_button": true}'::jsonb),
  ('features', true, 2, 'المميزات (Bento)', '{"layout": "bentoGrid"}'::jsonb),
  ('templates', true, 3, 'السلايدر', '{"max_to_show": 6}'::jsonb),
  ('desktop_preview', true, 4, 'معاينة الديسكتوب', '{}'::jsonb),
  ('cta', true, 5, 'CTA السفلي', '{"title": "جاهز تطلق موقعك الآن؟", "button_text": "ابدأ الآن مجاناً"}'::jsonb),
  ('footer', true, 6, 'الـ Footer', '{"copyright_text": "© 2026 LandyMaker. جميع الحقوق محفوظة."}'::jsonb)
ON CONFLICT (section_key) DO NOTHING;

-- Add is_blocked and subscription_end_date to profiles if not present
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMPTZ;
