-- Create Profiles Table (Linked to Auth Users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'super_admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create Landing Pages Table
CREATE TABLE public.landing_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    subdomain TEXT UNIQUE NOT NULL CHECK (subdomain ~* '^[a-z0-9-]+$'),
    custom_domain TEXT UNIQUE CHECK (custom_domain IS NULL OR custom_domain ~* '^[a-z0-9.-]+\.[a-z]{2,}$'),
    design_json JSONB NOT NULL DEFAULT '{"blocks": []}'::jsonb,
    is_published BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on Landing Pages
ALTER TABLE public.landing_pages ENABLE ROW LEVEL SECURITY;

-- Create Leads Table
CREATE TABLE public.leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    landing_page_id UUID REFERENCES public.landing_pages(id) ON DELETE CASCADE NOT NULL,
    form_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on Leads
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

-- Create Analytics Table
CREATE TABLE public.analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    landing_page_id UUID REFERENCES public.landing_pages(id) ON DELETE CASCADE NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('view', 'conversion')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on Analytics
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- TRIGGERS & FUNCTIONS
-- -----------------------------------------------------------------------------

-- Automatically create profiles record on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'full_name', 'User'),
        COALESCE(new.raw_user_meta_data->>'role', 'user')
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.is_super_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = user_id AND role = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Automatically update updated_at on Landing Page changes
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    new.updated_at = now();
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_landing_pages_updated_at
    BEFORE UPDATE ON public.landing_pages
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- -----------------------------------------------------------------------------
-- ROW LEVEL SECURITY POLICIES
-- -----------------------------------------------------------------------------

-- 1. Profiles Policies
CREATE POLICY "Users can view own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Super admins can view all profiles" 
    ON public.profiles FOR SELECT 
    USING (
        public.is_super_admin(auth.uid())
    );

-- 2. Landing Pages Policies
CREATE POLICY "Anyone can read published pages" 
    ON public.landing_pages FOR SELECT 
    USING (is_published = true);

CREATE POLICY "Users can read own pages" 
    ON public.landing_pages FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pages" 
    ON public.landing_pages FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pages" 
    ON public.landing_pages FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pages" 
    ON public.landing_pages FOR DELETE 
    USING (auth.uid() = user_id);

-- 3. Leads Policies
CREATE POLICY "Anyone can submit leads" 
    ON public.leads FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "Page owners can view leads" 
    ON public.leads FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.landing_pages 
            WHERE id = landing_page_id AND user_id = auth.uid()
        )
    );

-- 4. Analytics Policies
CREATE POLICY "Anyone can record analytics" 
    ON public.analytics FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "Page owners can view analytics" 
    ON public.analytics FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.landing_pages 
            WHERE id = landing_page_id AND user_id = auth.uid()
        )
    );
