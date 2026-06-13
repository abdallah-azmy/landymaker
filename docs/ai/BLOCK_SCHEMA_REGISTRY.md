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
- `bg_blur`: Double (0.0 to 20.0)
- `is_visible`: Boolean
- `animation`: Object `{type: "none" | "fadeIn" | "slideUp" | "zoomIn" | "bounceIn", duration: 800, delay: 0}`

## 📦 Block-Specific Schemas

### `hero` / `hero_saas`
- `variant`: 0:Standard, 1:Split, 2:Centered
- `title`, `subtitle`, `button_text`, `button_url`, `image_url`

### `features`
- `variant`: 0:Grid, 1:Bento, 2:List
- `items`: List of `{title, description, image_url, link_url}`

### `pricing`
- `variant`: 0:Grid, 1:Row, 2:Table
- `items`: List of `{name, prices: {monthly, yearly}, currency, features: [], button_text, is_popular}`

... (Refer to individual editors for full details)

---
**Rule for AI Agents**: Always prioritize contrast and variety. Use `pixabay_search` for dynamic image fulfillment.
