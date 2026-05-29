-- ==========================================
-- 1. SUBSCRIPTIONS & PAYMENT PROOFS
-- ==========================================

-- Extend profiles with subscription data
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS tier TEXT DEFAULT 'free',
ADD COLUMN IF NOT EXISTS tier_expires_at TIMESTAMP WITH TIME ZONE;

-- Table for manual payment verification
CREATE TABLE IF NOT EXISTS public.subscription_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    plan_name TEXT NOT NULL,
    price_paid NUMERIC(10, 2) NOT NULL,
    payment_method TEXT NOT NULL, -- e.g. 'vodafone_cash', 'we_cash', 'instapay'
    proof_screenshot_url TEXT NOT NULL,
    promo_code_used TEXT, -- tracking if an affiliate code was used
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT -- for rejection reasons
);

-- Enable RLS
ALTER TABLE public.subscription_requests ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own subscription requests"
    ON public.subscription_requests FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own subscription requests"
    ON public.subscription_requests FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Super admins can manage all subscription requests"
    ON public.subscription_requests FOR ALL
    USING (public.is_super_admin(auth.uid()));

-- Indices
CREATE INDEX IF NOT EXISTS idx_subscription_requests_user_id ON public.subscription_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_requests_status ON public.subscription_requests(status);
CREATE INDEX IF NOT EXISTS idx_subscription_requests_created_at ON public.subscription_requests(created_at);


-- ==========================================
-- 2. AFFILIATE MARKETING SYSTEM
-- ==========================================

-- Affiliate user profiles
CREATE TABLE IF NOT EXISTS public.affiliate_profiles (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    promo_code TEXT UNIQUE NOT NULL CHECK (promo_code ~* '^[a-zA-Z0-9]+$'), -- alphanumeric, no special chars
    discount_percent NUMERIC(5, 2) DEFAULT 10.0 NOT NULL,
    commission_percent NUMERIC(5, 2) DEFAULT 15.0 NOT NULL,
    balance NUMERIC(12, 2) DEFAULT 0.0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Referral history
CREATE TABLE IF NOT EXISTS public.affiliate_referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    affiliate_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    referred_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    subscription_request_id UUID REFERENCES public.subscription_requests(id) ON DELETE CASCADE NOT NULL,
    commission_earned NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Payout tracking
CREATE TABLE IF NOT EXISTS public.affiliate_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    affiliate_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payment_details TEXT NOT NULL, -- wallet number or bank details
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.affiliate_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliate_referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.affiliate_payouts ENABLE ROW LEVEL SECURITY;

-- Policies for affiliate_profiles
CREATE POLICY "Users can view own affiliate profile"
    ON public.affiliate_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Super admins can manage all affiliate profiles"
    ON public.affiliate_profiles FOR ALL
    USING (public.is_super_admin(auth.uid()));

-- Policies for affiliate_referrals
CREATE POLICY "Affiliates can view own referrals"
    ON public.affiliate_referrals FOR SELECT
    USING (auth.uid() = affiliate_id);

CREATE POLICY "Super admins can manage all affiliate referrals"
    ON public.affiliate_referrals FOR ALL
    USING (public.is_super_admin(auth.uid()));

-- Policies for affiliate_payouts
CREATE POLICY "Affiliates can view own payouts"
    ON public.affiliate_payouts FOR SELECT
    USING (auth.uid() = affiliate_id);

CREATE POLICY "Affiliates can request payouts"
    ON public.affiliate_payouts FOR INSERT
    WITH CHECK (auth.uid() = affiliate_id);

CREATE POLICY "Super admins can manage all affiliate payouts"
    ON public.affiliate_payouts FOR ALL
    USING (public.is_super_admin(auth.uid()));

-- Indices
CREATE INDEX IF NOT EXISTS idx_affiliate_referrals_affiliate_id ON public.affiliate_referrals(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_referrals_subscription_request_id ON public.affiliate_referrals(subscription_request_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_payouts_affiliate_id ON public.affiliate_payouts(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_payouts_status ON public.affiliate_payouts(status);

-- Trigger for Commission logic
CREATE OR REPLACE FUNCTION public.handle_subscription_approval()
RETURNS TRIGGER AS $$
DECLARE
    v_affiliate_id UUID;
    v_commission_earned NUMERIC;
BEGIN
    -- Check if status changed to approved
    IF (OLD.status = 'pending' AND NEW.status = 'approved') THEN

        -- Update user tier
        UPDATE public.profiles
        SET tier = NEW.plan_name,
            tier_expires_at = now() + INTERVAL '1 month'
        WHERE id = NEW.user_id;

        -- Update reviewed_at
        NEW.reviewed_at = now();

        -- Check if an affiliate promo code was used
        IF (NEW.promo_code_used IS NOT NULL) THEN

            -- Find the affiliate
            SELECT user_id INTO v_affiliate_id
            FROM public.affiliate_profiles
            WHERE promo_code = NEW.promo_code_used;

            IF (v_affiliate_id IS NOT NULL) THEN
                -- Calculate commission
                SELECT (NEW.price_paid * (commission_percent / 100.0)) INTO v_commission_earned
                FROM public.affiliate_profiles
                WHERE user_id = v_affiliate_id;

                -- 1. Create referral record
                INSERT INTO public.affiliate_referrals (
                    affiliate_id,
                    referred_user_id,
                    subscription_request_id,
                    commission_earned
                ) VALUES (
                    v_affiliate_id,
                    NEW.user_id,
                    NEW.id,
                    v_commission_earned
                );

                -- 2. Increase affiliate balance
                UPDATE public.affiliate_profiles
                SET balance = balance + v_commission_earned
                WHERE user_id = v_affiliate_id;
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-create trigger if it exists (or just drop and create)
DROP TRIGGER IF EXISTS on_subscription_request_approved ON public.subscription_requests;
CREATE TRIGGER on_subscription_request_approved
    BEFORE UPDATE ON public.subscription_requests
    FOR EACH ROW EXECUTE FUNCTION public.handle_subscription_approval();


-- ==========================================
-- 3. LANDING PAGE BARBER BOOKING SCHEMA
-- ==========================================

CREATE TABLE IF NOT EXISTS public.barber_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    landing_page_id UUID REFERENCES public.landing_pages(id) ON DELETE CASCADE NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    queue_number INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'serving', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.barber_bookings ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can book online"
    ON public.barber_bookings FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Anyone can view current wait queue"
    ON public.barber_bookings FOR SELECT
    USING (true);

CREATE POLICY "Page owners can manage bookings"
    ON public.barber_bookings FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.landing_pages
            WHERE id = landing_page_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Page owners can delete bookings"
    ON public.barber_bookings FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.landing_pages
            WHERE id = landing_page_id AND user_id = auth.uid()
        )
    );

-- Indices
CREATE INDEX IF NOT EXISTS idx_barber_bookings_landing_page_id ON public.barber_bookings(landing_page_id);
CREATE INDEX IF NOT EXISTS idx_barber_bookings_status ON public.barber_bookings(status);
CREATE INDEX IF NOT EXISTS idx_barber_bookings_created_at ON public.barber_bookings(created_at);

-- وظيفة لتسجيل عمليات الشراء وزيادة العداد (SPEC 3)
CREATE OR REPLACE FUNCTION public.record_page_purchase(page_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.landing_pages 
    SET purchases_count = purchases_count + 1 
    WHERE id = page_id;
    INSERT INTO public.page_analytics_logs (landing_page_id, event_type) VALUES (page_id, 'purchase');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
