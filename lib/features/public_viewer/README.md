# Public Viewer Feature

This module is responsible for rendering the final, published landing pages for site visitors.

## 🚀 Performance & SEO

- **Optimization**: Minimal overhead, high-speed rendering of the JSON `designMap`.
- **Bot Support**: `middleware.js` intercepts crawlers and provides them with a raw HTML version of this module's output.
- **Tracking**: Automatically handles Facebook/TikTok/Snapchat pixels and anonymous fingerprinting for analytics.

## 🧱 Key Components

- `screens/public_landing_page.dart`: Resolves the tenant and loads the design.
- `widgets/section_renderer.dart`: Iterates through the JSON array and builds the UI.
- `widgets/custom_*_widget.dart`: Highly optimized section widgets.
- `widgets/global/sticky_cta_bar.dart`: An overlay that appears on scroll to boost conversions.

## 🔗 Unidirectional Data Flow

**JSON design_json** → **SectionRenderer** → **Individual Block Widgets** → **ActionHandlerService** (on click)
