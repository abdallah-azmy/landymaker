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

## 📦 Active Block Types (29 Total)

| Block Type | Category | Layout Control | Key Properties |
|-----------|----------|---------------|----------------|
| `hero` | Content | `layout_style` ("split"|"centered"|"glass"|"fullWidthBg"|"reverse"|"gradientOnly"|"fullWidthImage"|"minimal") | title, subtitle, button_text, button_url, image_url, badge_text |
| `hero_saas` | Content | `layout_style` ("dashboardSplit"|"launchCenter"|"darkSaas") | title, subtitle, badge_text, tech_logos, button_text |
| `features` | Content | `layout_style` ("grid"\|"bento") | items[{title, description, image_url, link_url}] |
| `pricing` | Commerce | `variant` (0:Grid, 1:Row, 2:Table) | items[{name, prices{monthly,yearly}, currency, features[], button_text, is_popular}] |
| `products` | Commerce | `layout_style` ("grid_2"\|"grid_3"\|"list"\|"carousel") | items[{id, name, price, description, image_url, button_text}], mobile_columns, card_style, hover_effect |
| `featured_product` | Commerce | `layout_style` ("split"\|"centered"\|"reversed") | name, price, description, image_url, button_text, badge_text |
| `bento_store` | Commerce | `layout_style` ("modern"\|"tight"\|"glass") | items[{name, price, image_url}], stagger_animations |
| `testimonials` | Content | `variant` (0:Carousel, 1:Grid, 2:Masonry) | items[{name, role, text, avatar_url, rating}] |
| `faq` | Content | `variant` (0:Accordion, 1:List) | items[{question, answer}] |
| `gallery` | Media | `layout_style` ("grid"\|"masonry"\|"carousel") | items[{image_url, caption}] |
| `contact_info` | Content | `variant` (0:Grid, 1:Row) | items[{icon, label, value, url}] |
| `video_embed` | Media | — | url, autoplay, aspect_ratio |
| `logo_header` | Content | — | logo_url, alt_text |
| `lead_form` | Forms | — | fields[{type, label, placeholder, required}], submit_button_text |
| `lead_magnet` | Forms | `layout_style` ("split"\|"centered") | image_url, title, subtitle, fields[], submit_button_text, magnet_title |
| `multi_step_lead_form` | Forms | — | steps[{title, fields[]}], submit_button_text |
| `working_hours` | Content | `variant` (0:List, 1:Table) | days[{day, open, close, is_closed}] |
| `location_map` | Media | — | address, lat, lng, zoom, embed_type |
| `trust_logos` | Media | `layout_style` ("row"\|"grid") | items[{name, logo_url}] |
| `animated_counter` | Content | `variant` (0:Row, 1:Grid) | items[{value, suffix, label, icon}] |
| `social_qr` | Media | — | facebook_url, instagram_url, twitter_url, whatsapp_url, qr_text |
| `whatsapp` | Content | — | phone_number, message, button_text, position, animation |
| `basic_section` | Content | — | html_content (rich text), text_align |
| `cta_banner` | Content | `layout_style` ("simple"\|"split"\|"centered") | title, subtitle, button_text, button_url, image_url |
| `comparison_table` | Commerce | `layout_style` ("table"\|"cards") | items[{name, features[{label, included}], price, button_text, is_popular}] |
| `qr_code` | Media | — | url, size, foreground_color, background_color |
| `service_steps` | Content | `layout_style` ("vertical"\|"horizontal") | steps[{number, title, description, icon}] |
| `statistics_grid` | Content | `layout_style` ("grid"\|"row") | stats[{label, value, prefix, suffix}] |
| `team_members` | Content | `variant` (0:Grid, 1:Carousel) | members[{name, role, bio, photo_url, social_links[]}] |

---
**Rule for AI Agents**: 
1. Always prioritize contrast and variety. Use `pixabay_search` for dynamic image fulfillment.
2. The complete exact schema definition for the AI prompt is now dynamically loaded from `supabase/functions/shared/schema_registry.json`. Whenever a new block is added to the Flutter `BlockRegistry`, its schema MUST also be appended to `schema_registry.json` so the edge function can read it.
