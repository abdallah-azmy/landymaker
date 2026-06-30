# LandyMaker Master Block Schema Registry

This registry defines the "Readable Language" used between the Builder and the AI Agent. Every key here is editable by both humans and AI.

## 🎨 Global Theme (ThemeModel)
- `primary`: Hex color (e.g., #3B82F6)
- `secondary`: Hex color (Used for buttons and accents)
- `background`: Hex color
- `textPrimary`: Hex color
- `textSecondary`: Hex color
- `button_text_color`: Hex color (Critical for contrast on buttons)
- `font_family`: String (e.g., "Cairo", "Almarai", "Roboto")

## 🧱 Universal Properties (Every Block Supports These)
- `type`: String (Block ID) — must match one of the 29 registered types below
- `title`: String (Section Title)
- `layout_style` / `variant`: String/Integer — Controls layout shape (exact field name varies per block type)
- `card_layout_mode`: String ("auto" | "equal") - Controls grid height behavior for items
- `bg_image_url`: String (Image URL)
- `bg_overlay_opacity`: Double (0.0 to 1.0)
- `bg_overlay_color`: Hex Color String
- `bg_color`: Hex Color String (Base background color for the section)
- `theme_override`: String (Name of the theme palette to apply to this section)
- `vertical_padding`: Double (0.0 to 300.0)
- `bg_blur`: Double (0.0 to 20.0)
- `is_visible`: Boolean
- `animation`: Object `{type: "none" | "fadeIn" | "slideUp" | "zoomIn" | "bounceIn", duration: 800, delay: 0, intensity: 1.0}`

## 📦 Active Block Types (29 Total) — Full Reference

| Block Type | Category | Layout Control | Key Properties | Editor File | Renderer Widget |
|-----------|----------|---------------|----------------|------------|-----------------|
| `hero` | Content | `layout_style` ("split"\|"centered"\|"glass"\|"fullWidthBg"\|"reverse"\|"gradientOnly"\|"fullWidthImage"\|"minimal") | title, subtitle, button_text, button_url, image_url, badge_text | `hero_editor.dart` (96 lines) | `CustomHeroWidget` |
| `hero_saas` | Content | `layout_style` ("dashboardSplit"\|"launchCenter"\|"darkSaas") | title, subtitle, badge_text, tech_logos[{name, url}], button_text | `hero_saas_editor.dart` (135 lines) | `CustomHeroSaasWidget` |
| `features` | Content | `layout_style` ("grid"\|"bento") | items[{title, description, image_url, link_url}] | `features_editor.dart` | `CustomFeaturesWidget` |
| `pricing` | Commerce | `variant` (0:Grid, 1:Row, 2:Table) | items[{name, prices{monthly,yearly}, currency, features[], button_text, is_popular}] | `pricing_editor.dart` | `CustomPricingWidget` |
| `products` | Commerce | `layout_style` ("grid_2"\|"grid_3"\|"list"\|"carousel") | items[{id, name, price, description, image_url, button_text}], mobile_columns, card_style, hover_effect, stagger_animations | `products_editor.dart` | `CustomProductsWidget` |
| `featured_product` | Commerce | `layout_style` ("split"\|"centered"\|"reversed") | name, price, description, image_url, button_text, badge_text | `featured_product_editor.dart` | `FeaturedProductWidget` |
| `bento_store` | Commerce | `layout_style` ("modern"\|"tight"\|"glass") | items[{name, price, image_url}], stagger_animations | `bento_store_editor.dart` | `BentoStoreWidget` |
| `testimonials` | Content | `variant` (0:Carousel, 1:Grid, 2:Masonry) | items[{name, role, text, avatar_url, rating}] | `testimonials_editor.dart` | `CustomTestimonialsWidget` |
| `faq` | Content | `variant` (0:Accordion, 1:List) | items[{question, answer}] | `faq_editor.dart` | `CustomFaqWidget` |
| `gallery` | Media | `layout_style` ("grid"\|"masonry"\|"carousel") | items[{image_url, caption}] | `gallery_editor.dart` | `CustomGalleryWidget` |
| `contact_info` | Content | `variant` (0:Grid, 1:Row) | items[{icon, label, value, url}] | `contact_info_editor.dart` | `CustomContactInfoWidget` |
| `video_embed` | Media | — | url, autoplay, aspect_ratio | `video_embed_editor.dart` | `CustomVideoEmbedWidget` |
| `logo_header` | Content | — | logo_url, alt_text | `logo_header_editor.dart` | `CustomLogoHeaderWidget` |
| `lead_form` | Forms | — | fields[{type, label, placeholder, required}], submit_button_text | `lead_form_editor.dart` | `CustomLeadFormWidget` |
| `lead_magnet` | Forms | `layout_style` ("split"\|"centered") | image_url, title, subtitle, fields[], submit_button_text, magnet_title | `lead_magnet_editor.dart` | `CustomLeadMagnetWidget` |
| `multi_step_lead_form` | Forms | — | steps[{title, fields[]}], submit_button_text | `multi_step_form_editor.dart` | `CustomMultiStepFormWidget` |
| `working_hours` | Content | `variant` (0:List, 1:Table) | days[{day, open, close, is_closed}] | `working_hours_editor.dart` | `CustomWorkingHoursWidget` |
| `location_map` | Media | — | address, lat, lng, zoom, embed_type | `location_map_editor.dart` | `CustomLocationMapWidget` |
| `trust_logos` | Media | `layout_style` ("row"\|"grid") | items[{name, logo_url}] | `trust_logos_editor.dart` | `CustomTrustLogosWidget` |
| `animated_counter` | Content | `variant` (0:Row, 1:Grid) | items[{value, suffix, label, icon}] | `animated_counter_editor.dart` | `CustomAnimatedCounterWidget` |
| `social_qr` | Media | — | facebook_url, instagram_url, twitter_url, whatsapp_url, qr_text | `social_qr_editor.dart` | `CustomSocialQrWidget` |
| `whatsapp` | Content | — | phone_number, message, button_text, position, animation | `whatsapp_editor.dart` | `CustomWhatsAppWidget` |
| `basic_section` | Content | — | html_content (rich text), text_align | `basic_section_editor.dart` | `CustomBasicSectionWidget` |
| `cta_banner` | Content | `layout_style` ("simple"\|"split"\|"centered") | title, subtitle, button_text, button_url, image_url | `cta_banner_editor.dart` | `CustomCtaBannerWidget` |
| `comparison_table` | Commerce | `layout_style` ("table"\|"cards") | items[{name, features[{label, included}], price, button_text, is_popular}] | `comparison_table_editor.dart` | `CustomComparisonTableWidget` |
| `qr_code` | Media | — | url, size, foreground_color, background_color | `qr_code_editor.dart` | `CustomQRCodeWidget` |
| `service_steps` | Content | `layout_style` ("vertical"\|"horizontal") | steps[{number, title, description, icon}] | `service_steps_editor.dart` | `CustomServiceStepsWidget` |
| `statistics_grid` | Content | `layout_style` ("grid"\|"row") | stats[{label, value, prefix, suffix}] | `statistics_grid_editor.dart` | `CustomStatisticsGridWidget` |
| `team_members` | Content | `variant` (0:Grid, 1:Carousel) | members[{name, role, bio, photo_url, social_links[]}] | `team_members_editor.dart` | `CustomTeamMembersWidget` |
---

## 🔗 Editor Dispatch Architecture

All 29 block types are routed to their editors via `content_tab_dispatcher.dart` (220 lines) in `lib/features/builder/widgets/editors/`. The dispatcher uses a `switch` statement on `blockType`:
- **Shared editors**: `hero_editor.dart` serves BOTH `hero` and `hero_saas` (SaaS-specific properties like `tech_logos` and SaaS `layout_style` options are filtered via the block's `data` map)
- **Dedicated editors**: All other types have their own `*_editor.dart` in `lib/features/builder/widgets/editors/blocks/`
- **`whatsapp`** has its own `WhatsAppEditor` — was originally missing before Phase 4 fix (B4.2)

## 🔧 Layout Variant Mapping (Renderer Side)

The renderers use an `_effectiveVariant` mapping to convert `layout_style` strings to integer variants:

**Hero** (`custom_hero_widget.dart`):
| layout_style | Variant ID | Layout Rendered |
|---|---|---|
| `"split"` | 0 | `_HeroSplitLayout` — left text, right image |
| `"centered"` | 1 | `_HeroCenteredLayout` — centered text |
| `"glass"` | 2 | `_HeroGlassLayout` — glassmorphism card |
| `"fullWidthBg"` | 3 | `_HeroFullWidthBgLayout` — full-width background image |
| `"reverse"` | 4→5 (mapped) | `_HeroReverseLayout` — right text, left image (was identical to split before B5.2 fix) |
| `"gradientOnly"` | 6 | `_HeroGradientOnlyLayout` — gradient background, no image (was missing before B5.1 fix) |
| `"fullWidthImage"` | 7 | `_HeroFullWidthImageLayout` — image fills full width (was missing before B5.1 fix) |
| `"minimal"` | 8 | `_HeroMinimalLayout` — minimal text only |

**Hero SaaS** (`custom_hero_saas_widget.dart`):
| layout_style | Rendered Layout |
|---|---|
| `"dashboardSplit"` | Left dashboard mockup + right text |
| `"launchCenter"` | Centered launch/hero card |
| `"darkSaas"` | Dark card with platform preview |

## 📝 Schema Registry (Edge Function)

The complete exact schema definition for the AI prompt is dynamically loaded from `supabase/functions/shared/schema_registry.json` (198 lines). This file was restructured from flat strings (33 lines) to structured objects with per-block metadata: `schema` (JSON Schema), `allowedLayoutStyles`, `ai_intent`, `ai_when_to_use`, `ai_avoid_when`, and `category`.

**When adding a new block type**, the following files MUST all be updated:
1. `block_registry.dart` — renderer mapping
2. `block_schema.dart` — schema constants for the editor
3. Content tab dispatcher — editor routing
4. `*_editor.dart` — editor widget file
5. `section_data.dart` — section library entry + variants
6. `schema_registry.json` — AI generation metadata
7. `LandingPageBuilderCubit.addBlock()` — default preset

---

**Rule for AI Agents**: 
1. Always prioritize contrast and variety. Use `pixabay_search` for dynamic image fulfillment.
2. Never use `variant_style` key in section_data.dart for hero/hero_saas — use `layout_style` instead (see Rule 42).
3. Always ensure `DynamicFontService.loadFontsFromDesign()` is called after theme application (4 call sites in builder_cubit_persistence.dart).
4. The complete exact schema definition is in `supabase/functions/shared/schema_registry.json`. Whenever a new block is added to the Flutter `BlockRegistry`, its schema MUST also be appended to `schema_registry.json` so the edge function can read it.
