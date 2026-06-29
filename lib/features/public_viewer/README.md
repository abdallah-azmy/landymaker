# Public Viewer Feature

Renders published landing pages for site visitors. This is the public-facing output of the builder — all `design_json` → widget rendering happens here.

## File Map

| Path | Role |
|------|------|
| `controllers/public_page_cubit.dart` | `PublicPageCubit` — loads page by domain, decodes `design_json` via isolate, emits `PublicPageLoaded` with pre-parsed blocks |
| `controllers/public_page_state.dart` | `PublicPageState` — `PublicPageInitial`, `PublicPageLoading`, `PublicPageLoaded(pageData, blocks, designJson)`, `PublicPageNotFound`, `PublicPageFailure` |
| `controllers/cart_cubit.dart` | `CartCubit` — manages shopping cart state (items, total, fold/visibility) for ecommerce pages |
| `models/pricing_models.dart` | Pricing data models used by the pricing block widgets |
| `screens/public_landing_page.dart` | Main entry point — resolves tenant, applies SEO meta, renders full page including sticky CTA, cookie consent, floating cart |
| `utils/pricing_calculator.dart` | Pricing calculation utilities |
| `utils/pricing_parser.dart` | Pricing JSON parsing utilities |
| `widgets/section_renderer.dart` | Iterates the JSON block array and delegates to the correct `custom_*_widget` |
| `widgets/custom_hero_widget.dart` | Hero section block renderer |
| `widgets/custom_hero_saas_widget.dart` | SaaS-specific hero block renderer |
| `widgets/custom_features_widget.dart` | Features grid block renderer |
| `widgets/custom_pricing_widget.dart` | Pricing table block renderer |
| `widgets/custom_testimonials_widget.dart` | Testimonials carousel block renderer |
| `widgets/custom_faq_widget.dart` | FAQ accordion block renderer |
| `widgets/custom_cta_banner_widget.dart` | CTA banner block renderer |
| `widgets/custom_lead_form_widget.dart` | Lead generation form block renderer |
| `widgets/custom_gallery_widget.dart` | Image gallery block renderer |
| `widgets/custom_video_embed_widget.dart` | Video embed block renderer |
| `widgets/custom_team_members_widget.dart` | Team members grid block renderer |
| `widgets/custom_contact_info_widget.dart` | Contact info block renderer |
| `widgets/custom_logo_header_widget.dart` | Logo header block renderer |
| `widgets/custom_animated_counter_widget.dart` | Animated counter block renderer |
| `widgets/custom_comparison_table_widget.dart` | Comparison table block renderer |
| `widgets/custom_whatsapp_widget.dart` | WhatsApp button block renderer |
| `widgets/custom_multi_step_form_widget.dart` | Multi-step form block renderer |
| `widgets/custom_products_widget.dart` | Products grid block renderer |
| `widgets/custom_service_steps_widget.dart` | Service steps block renderer |
| `widgets/custom_statistics_grid_widget.dart` | Statistics grid block renderer |
| `widgets/custom_trust_logos_widget.dart` | Trust logos block renderer |
| `widgets/custom_working_hours_widget.dart` | Working hours block renderer |
| `widgets/custom_social_qr_widget.dart` | Social QR code block renderer |
| `widgets/custom_qr_widget.dart` | QR code block renderer |
| `widgets/custom_location_map_widget.dart` | Location map block renderer |
| `widgets/custom_lead_magnet_widget.dart` | Lead magnet block renderer |
| `widgets/featured_product_widget.dart` | Featured product block renderer |
| `widgets/bento_store_widget.dart` | Bento store layout block renderer |
| `widgets/floating_cart_widget.dart` | Floating cart overlay for ecommerce pages |
| `widgets/cookie_consent_banner.dart` | GDPR cookie consent banner |
| `widgets/basic_section_renderer.dart` | Fallback renderer for unknown block types |
| `widgets/global/` | Shared utility widgets (sticky CTA bar) |

## Rendering Pipeline

```
design_json (from cubit)
  → SectionRenderer (iterates blocks array)
    → custom_*_widget.dart (matches block['type'])
      → ActionHandlerService (on click / form submit)
```

## State Management

- `PublicPageCubit` — single cubit; loads page by identifier, decodes `design_json` via isolate, emits parsed state
- `CartCubit` — manages cart state for ecommerce pages (separate from page state since cart persists across page navigation)

## ⚠️ AI Warnings

- **`designJson` is decoded once in the cubit via isolate** and stored in state. The 4 `BlocConsumer`/`BlocBuilder` call sites in `public_landing_page.dart` read from `state.designJson` (NOT from `state.pageData['design_json']`). Never re-decode inline.
- **`SectionRenderer`** maps `block['type']` strings to widgets via a large `if/else if` chain. Each block type MUST have a corresponding handler. Adding a new block type in the builder requires adding a renderer here — the public viewer will crash on unknown types if no fallback is provided.
- **Cart cubit** is independent of page state. Do NOT merge it into `PublicPageCubit` — cart state must outlive page navigation.
- **Cookie consent banner** reads from `designJson['cookie_consent']` — do NOT hardcode consent logic. Banner visibility is controlled by the page design.
- **Sticky CTA bar** position is `bottomCenter` with a `ScrollController` listener. Changing the alignment or scroll behavior may overlap with the cookie consent banner.
- **Pixel tracking** (`PixelBootstrapService.initialize(designJson)`) runs in the cubit listener — do NOT move it to the builder as it depends on the full design being loaded.
