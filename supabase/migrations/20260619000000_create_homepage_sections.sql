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

-- Seed default sections (bilingual _ar/_en config keys)
INSERT INTO public.homepage_sections (section_key, is_visible, sort_order, display_name, config) VALUES
  ('hero', true, 1, 'Hero Section', '{"title_ar": "ابنِ صفحة هبوط احترافية متكاملة لخدماتك", "title_en": "Build a Professional Landing Page for Your Services", "subtitle_ar": "بدون الحاجة لخبرة برمجية", "subtitle_en": "Without any coding experience needed", "cta_text_ar": "ابدأ مجاناً", "cta_text_en": "Start Free", "typewriter_texts_ar": ["منيو مطعم إلكتروني تفاعلي", "معرض أعمال شخصي للمستقلين", "صفحة هبوط تسويقية لخدماتك", "متجر إلكتروني لمنتجاتك الخاصة"], "typewriter_texts_en": ["Interactive digital restaurant menu", "Personal portfolio for freelancers", "Marketing landing page for your services", "Online store for your products"], "layout": "split", "show_phone_preview": true, "show_ai_button": true}'::jsonb),
  ('features', true, 2, 'المميزات (Bento)', '{"title_ar": "مميزات لا حصر لها", "title_en": "Endless Features", "layout": "bentoGrid"}'::jsonb),
  ('templates', true, 3, 'السلايدر', '{"title_ar": "قوالب احترافية جاهزة", "title_en": "Ready Professional Templates", "subtitle_ar": "اختر من بين مئات القوالب المصممة خصيصاً لمجالك", "subtitle_en": "Choose from hundreds of templates designed for your field", "max_to_show": 6}'::jsonb),
  ('desktop_preview', true, 4, 'معاينة الديسكتوب', '{"title_ar": "شاهد كيف سيبدو موقعك", "title_en": "See How Your Site Will Look", "subtitle_ar": "معاينة حية لتصميم موقعك قبل النشر", "subtitle_en": "Live preview of your site design before publishing", "description_ar": "احصل على معاينة كاملة لصفحة الهبوط الخاصة بك قبل إطلاقها", "description_en": "Get a full preview of your landing page before launching"}'::jsonb),
  ('cta', true, 5, 'CTA السفلي', '{"title_ar": "جاهز تطلق موقعك الآن؟", "title_en": "Ready to Launch Your Site Now?", "button_text_ar": "ابدأ الآن مجاناً", "button_text_en": "Start Free Now", "layout": "centeredGradient"}'::jsonb),
  ('footer', true, 6, 'الـ Footer', '{"copyright_text_ar": "© 2026 LandyMaker. جميع الحقوق محفوظة.", "copyright_text_en": "© 2026 LandyMaker. All rights reserved."}'::jsonb),
  ('navbar', true, 0, 'الشريط العلوي', '{"logo_text_ar": "لاندي ميكر", "logo_text_en": "LandyMaker", "primary_links_ar": [{"label": "الرئيسية", "path": "/"}, {"label": "القوالب", "path": "/templates"}, {"label": "المدونة", "path": "/blog"}], "primary_links_en": [{"label": "Home", "path": "/"}, {"label": "Templates", "path": "/templates"}, {"label": "Blog", "path": "/blog"}], "cta_text_ar": "ابدأ مجاناً", "cta_text_en": "Start Free", "cta_path": "/templates", "show_login": true}'::jsonb),
  ('section_renderer', false, 7, 'قسم صفحة هبوط', '{"landing_page_id": "", "display_ar": "", "display_en": ""}'::jsonb)
ON CONFLICT (section_key) DO NOTHING;

-- Add is_blocked and subscription_end_date to profiles if not present
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMPTZ;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMPTZ;
