# Comprehensive Fix and Feature Plan for LandyMaker

This document outlines the step-by-step plan to resolve existing bugs, enhance the guest user flow, upgrade the AI Agent capabilities, and improve the overall UI/UX and animation system of the LandyMaker platform. 

## Phase 1: Core Bug Fixes
1. **Builder Page Multiple Initialization Fix:**
   - Investigate the routing and state initialization in the Builder workspace. Ensure `LandingPageBuilderCubit` and the GoRouter navigation do not cause repeated page loads or duplicate state instantiations.
   - Check for unwanted multiple `addPostFrameCallback` or listener triggers.
2. **Text Rendering/Encoding Fix (Symbols Issue):**
   - Identify pages where text appears as symbols. This is likely a font loading issue (e.g., missing Google Fonts fallback) or a UTF-8 encoding issue. Ensure proper Arabic font families (like Cairo, Tajawal, or Almarai) are correctly loaded and applied globally in the Flutter theme.
3. **Builder Preview Visual Glitches:**
   - Diagnose the `Builder` preview section. Look for constraints violations (`RenderFlex overflow`), incorrect layout bounds in `ResponsiveUtils`, or `IntrinsicHeight` issues. Apply `FittedBox` or proper `LayoutBuilder` constraints as per the project's strict guidelines.

## Phase 2: Guest Onboarding & Auth Flow Optimization
1. **Guest AI Generation Restriction (1 Prompt Limit):**
   - Implement logic in `ai_usage_log` or local storage (if guest) to track AI prompt usage.
   - Allow an unregistered user to send exactly ONE prompt to generate a landing page.
2. **Post-Generation Auth Gate:**
   - After the first successful generation, render the generated page in the builder, but disable further editing or additional prompts.
   - Show a persistent, professional "Sign Up/Login to continue editing and save your site" modal or overlay.
3. **Seamless Account Claiming & Random Slug Generation:**
   - Upon successful registration, assign a random unique string (e.g., `site-1a2b3c`) as the `subdomain` slug for the generated page.
   - Save the guest's generated design to the database under their new user ID so they can access it in their dashboard and continue editing freely.

## Phase 3: AI Chat Agent Capabilities
1. **Logo & Asset Upload Integration:**
   - Add image upload UI elements to the AI chat interface (e.g., "Upload Logo", "Upload Assets").
   - **Logo Analysis:** Pass the uploaded logo to the multimodal AI model (e.g., Gemini Pro Vision) to analyze its color palette, style, and industry. Automatically apply a generated `LandingPageTheme` inspired by the logo to the page.
   - **Asset Gallery:** Store uploaded images via the existing "Double-Upload" ImgBB/Supabase system so they appear in the user's gallery and can be placed in the landing page by the AI.
2. **Advanced AI Page Controls:**
   - **Full Page Background:** Update the schema and `LandingPageBuilderCubit` to allow the AI to set a global background image for the entire landing page.
   - **Section Backgrounds:** Allow the AI to surgically assign background images to individual sections (updating the JSON `designMap`).
   - **Animation Control:** Enable the AI to select and configure section-level entrance animations (e.g., fade-in, slide-up) utilized by `BlockAnimationWrapper`.
3. **Professional Prompt Suggestions:**
   - Replace the generic AI prompt suggestions with highly professional, SaaS/E-commerce tailored suggestions (e.g., "Generate a high-converting landing page for a real estate agency focusing on luxury villas with a dark premium theme").

## Phase 4: UI/UX Enhancements
1. **Mobile Image Column Control:**
   - Update the section editors (e.g., for Gallery or Products) to allow users to explicitly choose between 1 or 2 columns on mobile devices. Ensure `ResponsiveUtils` respects this setting instead of forcing a default layout.
2. **Template Carousel Upgrade:**
   - Replace the outdated "Barber" template with modern, high-quality SaaS and E-commerce templates.
   - Improve the template carousel (`TemplateRegistry`) UI on mobile by adding clear Left/Right navigation arrows to make swiping between landing page templates intuitive and smooth.

## Phase 5: Animation System & Anime.js Analysis
1. **Anime.js Integration Assessment:**
   - *Context:* Anime.js (`https://github.com/juliangarnier/anime`) is a lightweight JavaScript animation library for the web DOM. Since LandyMaker is a Flutter application rendering on CanvasKit, DOM-based JS libraries cannot directly animate Flutter widgets.
   - *Recommendation:* Do NOT attempt to integrate Anime.js into the core Flutter UI, as it will break the rendering pipeline and degrade performance.
   - *Alternative for Flutter:* Continue using and expanding `BlockAnimationWrapper` with Flutter's native `AnimationController` and `Tween` sequences. To achieve Anime.js-like staggered, complex, and smooth micro-animations, implement `flutter_staggered_animations` or `Rive` for vector animations. Ensure all animations are wrapped in `RepaintBoundary` to maintain 60FPS.
   - *HTML Export Consideration:* If Anime.js is strictly required for the SEO/Semantic HTML5 Vercel Edge proxy export, it can be injected into the generated HTML string in `middleware.js` to animate the static HTML elements for web crawlers or non-JS environments, though its primary value is for the live frontend.

## Execution Rules for AI Agent:
- Follow the strict architecture rules defined in `docs/ai/AI_CONTEXT.md`.
- Ensure all new strings are bilingual (Arabic & English).
- Do not introduce `RenderFlex` overflow errors. Always test responsive breakpoints.
- Maintain the state management cleanliness (no mutating state outside Cubits).
