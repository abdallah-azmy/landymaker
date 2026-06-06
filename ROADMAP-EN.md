# 🗺️ LandyMaker — Ultimate Development Roadmap & Implementation Guide (v3)

> **Mandatory reference for any developer or AI assistant working on the project.**
> This roadmap integrates core platform context from `AI_CONTEXT.md` with deep security, privacy, and architectural enhancements.
>
> **Execution Rule for AI Assist:** Implement ONLY ONE PART at a time. Do NOT proceed to the next part until the current part is fully completed, verified, and its status is marked as `[Completed: true]`.

---

## ⚖️ Core Engineering Principles (Zero Toleration for Violations)

### 1. Zero-Duplication Rule
Before creating any new file, class, widget, or helper method, perform a project-wide scan. If a component exists that performs a similar function (70% or more overlap), **extend it** instead of rewriting or duplicating.
*Scan Command Example:*
```bash
grep -r "SeoSettings" lib/ --include="*.dart" -l
```

### 2. Extension Over Replacement
Always prioritize extending existing components. For instance, when adding `og_image_url` or pixel settings, add them to `SeoSettingsModal` instead of building a new panel.

### 3. Backward Compatibility & Null-Safety
Ensure every modification does not break the **Builder Workspace Preview** or the **Public Viewer**. All new JSON configuration schema fields in the `designMap` must be optional, nullable, and defaults provided via null-coalescing (`??`).

---

## 🔍 Codebase Inventory (Scan Results)

### Existing Infrastructure
* **SEO Modal:** `lib/features/builder/widgets/modals/seo_settings_modal.dart` (Title, description, and Google preview built; missing `og_image_url` input).
* **SEO Panel (Sidebar):** `lib/features/builder/widgets/organisms/advanced_settings_panel.dart` (Used in Builder sidebar).
* **Metadata Updater:** `LandingPageBuilderCubit.updateMetadata()` (Handles updating arbitrary keys in `designMap`).
* **SEO Middleware:** `middleware.js` (Extracts `meta_title`, `meta_description`, and `og_image_url` for crawlers/bots).
* **Leads Screen:** `lib/features/dashboard/screens/leads_tracker_screen.dart` (Uses `ResponsiveDataTable` to render contacts; missing CSV export and WhatsApp action).
* **Leads Analytics Cubit:** `lib/features/dashboard/controllers/leads_analytics_cubit.dart` (Fetches leads list).
* **Templates Registry:** `lib/features/builder/registries/template_registry.dart` (Contains 7 landing page templates).
* **Temporary Tenant Variable:** `TenantRoutingService.pendingTemplateId` (For capturing selected template before auth registration).

---

## 📦 Modular Implementation Phases

### 📍 PART 1: SEO, Data Export & WhatsApp Actions (Week 1)
* **Status:** `[Completed: true]`

- [x] **Task 1.1: SEO Image Upload (`og_image_url`)**
  - **Objective:** Expand the existing `SeoSettingsModal` to accept an Open Graph (social share) image URL.
  - **Target File:** `lib/features/builder/widgets/modals/seo_settings_modal.dart`
  - **Implementation:**
    1. Add a `TextEditingController` for `og_image_url` bound to `state.designMap['og_image_url'] ?? ''`.
    2. Implement an input field with a file/media picker option or text field.
    3. Render an image preview using the required custom widget: `CustomNetworkImage` (never `Image.network` or `CachedNetworkImage` directly to avoid memory leaks).
    4. Call `cubit.updateMetadata('og_image_url', value)` on changes.
  - **Task Verification:** Open the SEO dialog in Builder, upload/type a URL, verify the preview displays via `CustomNetworkImage`, check database to see `og_image_url` saved in `designMap`.

- [x] **Task 1.2: CSV Leads Export with Arabic Encoding**
  - **Objective:** Allow dashboard users to export their captured leads to CSV.
  - **Target File:** `lib/features/dashboard/screens/leads_tracker_screen.dart`
  - **Implementation:**
    1. Import `package:file_saver/file_saver.dart` (already listed in `pubspec.yaml`).
    2. Add an `_exportToCsv()` method that parses `loadedState.leads`.
    3. **CRITICAL FIX:** Prepend the UTF-8 Byte Order Mark (BOM) `\uFEFF` to the string bytes. This ensures Arabic characters render perfectly without corruption when opened in Microsoft Excel.
    4. Add an "Export CSV" button in the screen header row next to the refresh button.
  - **Task Verification:** Go to Leads screen, click "Export CSV", open file in Excel, verify Arabic names and messages display correctly.

- [x] **Task 1.3: WhatsApp Communication Trigger with Number Normalization**
  - **Objective:** Provide a fast "Chat on WhatsApp" action for every lead row.
  - **Target File:** `lib/features/dashboard/screens/leads_tracker_screen.dart`
  - **Implementation:**
    1. Append a "WhatsApp" column header and matching action button to the `ResponsiveDataTable` rows.
    2. Extract the phone number from `lead['form_data']`.
    3. **CRITICAL FIX:** Normalize the phone number using a helper function: strip all non-digit characters (like spaces, `-`, `+`), and strip leading `00` or `+`. Ensure it contains only the digits required by the `wa.me` API.
    4. Use `dart:html` `window.open('https://wa.me/<normalized_phone>?text=<encoded_msg>', '_blank')` to open the chat window.
  - **Task Verification:** Submit a lead with number `+966 50-123-4567`, click WhatsApp button, verify browser opens `wa.me/966501234567` correctly.

---

### 📍 PART 2: Pixel Tracking Infrastructure & Consent (Week 2)
* **Status:** `[Completed: false]`

- [ ] **Task 2.1: Pixel Settings UI**
  - **Objective:** Allow landing page builders to configure tracking IDs.
  - **Target Files:**
    - `lib/features/builder/widgets/modals/seo_settings_modal.dart` (Add a tab/section for "Tracking & Pixels").
    - `lib/features/builder/widgets/organisms/builder_app_bar.dart` (Ensure the SEO/Settings button links correctly).
  - **Implementation:**
    1. Add input fields for `fb_pixel_id`, `tiktok_pixel_id`, and `snap_pixel_id`.
    2. Save inputs utilizing the existing `cubit.updateMetadata()`.
  - **Task Verification:** Verify inputs are rendered, saving updates `designMap` correctly with matching keys.

- [ ] **Task 2.2: Dual-Layer Pixel Bootstrap & Injection**
  - **Objective:** Inject scripts correctly for BOTH crawler bots (SEO indexing) and real human visitors (conversion logging).
  - **Architectural Boundaries:**
    - **Bots/Crawlers (Middleware Layer):** `middleware.js` will intercept bot traffic and return semantic HTML containing the tracking pixel tags.
    - **Real Human Visitors (Flutter Runtime Layer):** Real visitors bypass the middleware's bot check and load the Flutter Web single-page app. We must inject the tracking scripts dynamically client-side.
  - **Target Files:**
    - `middleware.js` (Under the `isBot` check, inject pixel scripts into `<head>`).
    - `lib/core/services/pixel_bootstrap_service.dart` [NEW]
  - **Implementation:**
    1. Create `PixelBootstrapService` to dynamically compile and append tracking scripts into the browser DOM `<head>` inside the Flutter Runtime.
    2. When the public page loads, read the configuration from `designMap` and inject script tags for configured pixels.
  - **Task Verification:** Open page as bot (verify scripts in HTML), open page as human, inspect DOM to verify `<script>` tags are present.

- [ ] **Task 2.3: Client-Side Pixel Events & Consent Blocker**
  - **Objective:** Trigger standard conversion events (`PageView`, `Lead`, `Purchase`) safely.
  - **Target Files:**
    - `lib/core/services/pixel_event_service.dart` [NEW]
    - `lib/features/public_viewer/widgets/custom_lead_form_widget.dart`
    - `lib/features/public_viewer/widgets/custom_lead_magnet_widget.dart`
    - `lib/features/public_viewer/widgets/custom_products_widget.dart`
  - **Implementation:**
    1. Create `PixelEventService` communicating with the injected scripts via JS Interop.
    2. **CRITICAL PRIVACY CHECK:** Before triggering any event, verify if the user has consented to tracking cookies (Cookie Consent Banner state). If rejected, block the scripts and events.
  - **Task Verification:** Submit a lead and check browser console/network logs to confirm the pixel calls (`fbq('track', 'Lead')`, etc.) are fired.

- [ ] **Task 2.4: Cookie Consent Banner**
  - **Objective:** Display a GDPR/regional privacy compliance banner.
  - **Target File:** `lib/features/public_viewer/widgets/cookie_consent_banner.dart` [NEW]
  - **Implementation:**
    1. Build a sleek banner with "Accept", "Reject", and "Customize" choices.
    2. Save choices locally to `window.localStorage` and toggle tracking parameters in `PixelBootstrapService` and `PixelEventService` reactively.
  - **Task Verification:** Load page, verify banner appears, click "Reject", confirm no scripts are injected, click "Accept", confirm scripts initialize.

---

### 📍 PART 3: Antispam & Security Safeguards (Week 2.5)
* **Status:** `[Completed: false]`

- [ ] **Task 3.1: Cloudflare Turnstile Integration**
  - **Objective:** Embed Turnstile captcha widgets in lead forms.
  - **Target Files:**
    - `lib/core/services/turnstile_service.dart` [NEW]
    - `lib/features/public_viewer/widgets/custom_lead_form_widget.dart`
    - `lib/features/public_viewer/widgets/custom_lead_magnet_widget.dart`
  - **Implementation:**
    1. Integrate a client-side Turnstile Widget into both form blocks.
    2. Force validation and extract the Turnstile token prior to allowing a form submission.
  - **Task Verification:** Render the form, confirm Turnstile widget appears and triggers token generation on submission.

- [ ] **Task 3.2: Edge Server Verification**
  - **Objective:** Validate Turnstile tokens before processing database inserts.
  - **Target Path:** `supabase/functions/verify-turnstile/index.ts` [NEW]
  - **Implementation:**
    1. Write a Supabase Edge Function to receive the Turnstile token and query the Cloudflare API.
    2. Reject insertion attempts if the token is invalid or expired.
  - **Task Verification:** Attempt calling the function with fake token, verify rejection (400 Bad Request).

- [ ] **Task 3.3: API Rate Limiting**
  - **Objective:** Limit submissions to prevent database bloat and webhook spam.
  - **Target Path:** `supabase/functions/lead-submit/index.ts` [NEW]
  - **Implementation:**
    1. Route all lead submissions through this Edge Function (instead of direct client-to-table writes).
    2. Enforce limits: Max **10 submissions per hour** per IP address, and max **5 submissions per 10 minutes** per device fingerprint hash.
  - **Task Verification:** Script multiple submissions, verify receiving `Too many requests` response.

- [ ] **Task 3.4: Device Fingerprinting**
  - **Objective:** Identify repeat spammers anonymously.
  - **Implementation:**
    1. Generate a SHA-256 fingerprint hash client-side based on `User-Agent`, `Screen Resolution`, `Timezone`, and `Language`.
    2. Submit the hash alongside the lead and record it in the submission log for rate limit comparisons. Do not store raw user-identifying info.
  - **Task Verification:** Verify the hash is computed and stored correctly under `leads` table payload metadata.

---

### 📍 PART 4: Onboarding Flows & Sign-in Options (Week 3)
* **Status:** `[Completed: false]`

- [ ] **Task 4.1: Template Picker Screen**
  - **Objective:** Show landing page templates to users before registration.
  - **Target File:** `lib/features/home/screens/template_picker_screen.dart` [NEW]
  - **Implementation:**
    1. Create a beautiful gallery displaying the 7 pre-made templates from `TemplateRegistry`.
    2. If the user is unauthenticated, store the selected template ID in `TenantRoutingService.pendingTemplateId` and redirect them to registration. If logged in, apply it immediately.
  - **Task Verification:** Open Picker, select template, confirm redirect to sign up and subsequent workspace creation using that template.

- [ ] **Task 4.2: Google Authentication OAuth Flow**
  - **Objective:** Allow rapid signup via Google OAuth.
  - **Target Files:**
    - `lib/services/supabase_service.dart`
    - `lib/features/auth/screens/login_screen.dart`
    - `lib/features/auth/screens/register_screen.dart`
  - **Implementation:**
    1. Implement `signInWithGoogle()` using Supabase OAuth provider (`OAuthProvider.google`).
    2. Add Google login buttons to the login and registration UI.
  - **Task Verification:** Click Google Login, verify redirect and successful profile creation in Supabase.

---

### 📍 PART 5: Analytics Dashboard V2 (Week 3.5)
* **Status:** `[Completed: false]`

- [ ] **Task 5.1: Performance Analytics**
  - **Objective:** Expand the dashboard metrics to calculate conversion metrics.
  - **Target Files:**
    - `lib/features/dashboard/controllers/leads_analytics_cubit.dart`
    - `lib/features/dashboard/screens/dashboard_home_screen.dart`
  - **Implementation:**
    1. Expand analytics tracking to query Page Views and Unique Visitors.
    2. Calculate and display: **Total Visitors**, **Unique Visitors**, **Total Leads**, and **Conversion Rate** (calculated as `(Leads / Visitors) * 100`).
  - **Task Verification:** Visit dashboard, verify stats calculations match lead table rows count.

---

### 📍 PART 6: Notification Center (Week 4)
* **Status:** `[Completed: false]`

- [ ] **Task 6.1: Database Notification Logging**
  - **Objective:** Ensure notifications are persistent even if FCM deliveries fail.
  - **Target SQL Schema:**
    ```sql
    CREATE TABLE notifications (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      is_read BOOLEAN DEFAULT false,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
    ```
  - **Implementation:**
    1. Create a DB trigger/webhook that creates a row in the `notifications` table whenever a new lead is generated.
    2. Build an in-app inbox to read and mark these notifications as read.
  - **Task Verification:** Create a lead, query `notifications` table, verify row was auto-created.

---

### 📍 PART 7: Progressive Web App & FCM Web Push (Week 5)
* **Status:** `[Completed: false]`

- [ ] **Task 7.1: PWA Dashboard Manifest**
  - **Objective:** Make the dashboard installable as a PWA.
  - **Target File:** `web/manifest.json`
  - **Implementation:**
    1. Configure application properties: `display: "standalone"`, `start_url: "/dashboard"`, and colors.
  - **Task Verification:** Check browser toolbar to verify "Install App" option appears.

- [ ] **Task 7.2: Web Push & FCM Integration**
  - **Objective:** Send instant browser notifications to page owners when they receive a lead.
  - **Target Files:**
    - `web/firebase-messaging-sw.js` [NEW]
    - `lib/core/services/fcm_service.dart` [NEW]
    - `supabase/functions/lead-notify/index.ts` [NEW]
  - **Implementation:**
    1. Implement Firebase Messaging Service Worker for background message listening.
    2. Ask for permission and register the client FCM token into the database `user_fcm_tokens` table.
    3. Deploy the `lead-notify` Edge Function triggered on lead insertions to send push notifications via Firebase API.
  - **Task Verification:** Grant notification permission, submit a lead from another tab, check for desktop push notification arrival.

---

## 🛡️ Security & Script Hardening (Epic F)

To prevent XSS (Cross-Site Scripting) and bypasses on the custom HTML script insertion feature (`custom_head_scripts`):
1. **Disallowed Javascript Functions:** The input field and backend validation must explicitly reject and strip statements containing:
   * `eval()`
   * `new Function()`
   * `document.write()`
2. **Allowed Tags:** Only allow standard safe tags: `<script src="...">`, `<meta>`, `<noscript>`, `<link>`.
3. **Database Security Rules (RLS):** Apply a Supabase row security policy validating that the user's `profiles.tier` is `'pro'` or `'enterprise'` before allowing any update containing a non-empty `custom_head_scripts` value in the `design_json`.

---

## ✋ Human Prerequisites & Configurations

### Prior to Week 1 (Immediate):
- [ ] Disable Vercel Git Auto-Deployment for the main `landymaker` project (to prevent deployment race conditions with GitHub Actions).

### Prior to Week 2.5 (Spam Protection):
- [ ] Create a Cloudflare account.
- [ ] Generate Cloudstile Turnstile Site Key & Secret Key.
- [ ] Save the Turnstile Secret Key securely as a environment secret in Supabase.

### Prior to Week 3 (Auth):
- [ ] Enable Google Auth Provider in Supabase.
- [ ] Configure OAuth Client ID and Secret in Google Cloud Console.

### Prior to Week 5 (FCM Push):
- [ ] Set up a Firebase project.
- [ ] Generate a Web VAPID key in Firebase Cloud Messaging.
- [ ] Enable Database Webhooks on Supabase for the `leads` table.

---

## ✅ Definition of Done (DoD) for Tasks

A task is only considered "Done" when:
1. It functions flawlessly on both Desktop and Mobile layouts.
2. It fully supports native RTL (Arabic-First) and LTR (English) alignments.
3. It does not break the Builder Workspace interactive canvas preview.
4. It does not introduce duplicate widgets or utility methods.
5. There are no console warnings, lint warnings, or null pointer exceptions.
6. Custom images are loaded using the memory-capped `CustomNetworkImage` wrapper.
7. Verification tests show success for:
   * Live lead generation.
   * Turnstile verification and rate-limiting blocks.
   * Correct pixel fired payloads client-side.
