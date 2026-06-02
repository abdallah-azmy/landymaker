-- Create blog_categories table
CREATE TABLE IF NOT EXISTS public.blog_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create blog_posts table
CREATE TABLE IF NOT EXISTS public.blog_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  content TEXT NOT NULL,
  featured_image_url TEXT,
  author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  category_id UUID REFERENCES public.blog_categories(id) ON DELETE SET NULL,
  meta_title VARCHAR(255),
  meta_description TEXT,
  is_published BOOLEAN DEFAULT false,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.blog_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- Categories RLS: Public can read all categories
CREATE POLICY "Allow public read access for categories" 
ON public.blog_categories FOR SELECT USING (true);

-- Posts RLS: Public can read only published posts
CREATE POLICY "Allow public read access for published posts" 
ON public.blog_posts FOR SELECT USING (is_published = true);

-- Admin RLS: We assume only authenticated super admins can insert/update/delete.
-- Since determining super admin status depends on how you've set it up (e.g. auth.jwt()->>'role', or a separate users table),
-- For now, we will allow authenticated users to perform operations, but you should lock this down to 'admin' roles in production.
CREATE POLICY "Allow authenticated users to manage categories" 
ON public.blog_categories FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to manage posts" 
ON public.blog_posts FOR ALL USING (auth.role() = 'authenticated');
