-- Create Table for FCM Tokens
CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    fcm_token TEXT UNIQUE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can manage own tokens"
    ON public.user_fcm_tokens FOR ALL
    USING (auth.uid() = user_id);
