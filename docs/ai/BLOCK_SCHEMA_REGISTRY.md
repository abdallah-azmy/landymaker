# LandyMaker Master Block Schema Registry

This registry defines the "Readable Language" used between the Builder and the AI Agent. Every key here is editable by both humans and AI.

## 🎨 Global Theme (ThemeModel)
- `primary`: Hex color (e.g., #3B82F6)
- `secondary`: Hex color (Used for buttons and accents)
- `background`: Hex color
- `textPrimary`: Hex color
- `textSecondary`: Hex color
- `button_text_color`: Hex color (Critical for contrast on buttons)
- `font_family`: String (e.g., "Cairo", "Tajawal", "Almarai", "Roboto")

## 🧱 Universal Properties (Every Block Supports These)
- `type`: String (Block ID)
- `title`: String (Section Title)
- `variant`: Integer (0-9) - Controls Layout Shapes (e.g., 0:Standard, 1:Split, 2:Centered)
- `card_layout_mode`: String ("auto" | "equal") - Controls grid height behavior for items.
- `bg_image_url`: String (Image URL)
- `bg_overlay_opacity`: Double (0.0 to 1.0)
- `bg_overlay_color`: Hex Color String
- `bg_color`: Hex Color String (Base background color for the section)
- `theme_override`: String (Name of the theme palette to apply to this section)
- `vertical_padding`: Double (0.0 to 300.0)
- `bg_blur`: Double (0.0 to 20.0)
- `is_visible`: Boolean
- `animation`: Object `{type: "none" | "fadeIn" | "slideUp" | "zoomIn" | "bounceIn", duration: 800, delay: 0, intensity: 1.0}`

## 📦 Block-Specific Schemas

### `hero` / `hero_saas`
- `variant`: 0:Standard, 1:Split, 2:Centered
- `title`, `subtitle`, `button_text`, `button_url`, `image_url`

### `features`
- `layout_style`: "grid" | "bento"
- `variant`: 0:Grid, 1:Bento, 2:List
- `items`: List of `{title, description, image_url, link_url}`

### `products`
- `layout_style`: "grid_2" | "grid_3" | "list" | "carousel"
- `mobile_columns`: 1 | 2
- `card_style`: "classic" | "modern" | "minimal"
- `hover_effect`: "none" | "scale" | "elevate" | "glow"
- `stagger_animations`: Boolean
- `items`: List of `{id, name, price, description, image_url, button_text, purchase_url, category}`

### `featured_product`
- `layout_style`: "split" | "centered" | "reversed"
- `name`, `price`, `description`, `image_url`, `button_text`, `badge_text`

### `bento_store`
- `layout_style`: "modern" | "tight" | "glass"
- `stagger_animations`: Boolean
- `items`: List of `{name, price, image_url}`

### `pricing`
- `variant`: 0:Grid, 1:Row, 2:Table
- `items`: List of `{name, prices: {monthly, yearly}, currency, features: [], button_text, is_popular}`

... (Refer to individual editors for full details)

---
**Rule for AI Agents**: 
1. Always prioritize contrast and variety. Use `pixabay_search` for dynamic image fulfillment.
2. The complete exact schema definition for the AI prompt is now dynamically loaded from `supabase/functions/shared/schema_registry.json`. Whenever a new block is added to the Flutter `BlockRegistry`, its schema MUST also be appended to `schema_registry.json` so the edge function can read it.
