-- Create Notifications table
CREATE TABLE public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own notifications
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- Function to handle new lead and log notification
CREATE OR REPLACE FUNCTION public.handle_new_lead_notification()
RETURNS TRIGGER AS $$
DECLARE
    owner_id UUID;
    page_subdomain TEXT;
BEGIN
    -- 1. Get the owner of the landing page
    SELECT user_id, subdomain INTO owner_id, page_subdomain
    FROM public.landing_pages
    WHERE id = NEW.landing_page_id;

    -- 2. Insert notification
    IF owner_id IS NOT NULL THEN
        INSERT INTO public.notifications (user_id, title, message, type)
        VALUES (
            owner_id,
            'عميل جديد مهتم! 🎉',
            'لقد تلقيت طلباً جديداً من خلال صفحة (' || page_subdomain || '). تحقق من قائمة العملاء لمعرفة التفاصيل.',
            'lead'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to fire after lead insertion
CREATE TRIGGER on_lead_inserted_log_notification
    AFTER INSERT ON public.leads
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_lead_notification();
