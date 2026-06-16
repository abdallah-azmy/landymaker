/// Layout variant enums for the LandyMaker home page sections.
///
/// Each section widget accepts its corresponding layout enum to determine
/// how it structures content on Desktop vs Mobile screens.
///
/// **Usage:**
/// ```dart
/// HomeHeroSection(layout: HeroLayout.centered, ...)
/// HomeFeatureBento(layout: FeatureLayout.threeCols, ...)
/// ```
///
/// **Rules:**
/// - Every layout MUST support both Desktop (≥ 900px) and Mobile (< 900px).
/// - Every layout MUST respect RTL/LTR via `EdgeInsetsDirectional`.
/// - Do NOT use `MediaQuery.of(context).size` — use `LayoutBuilder` instead.

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section Layouts
// ─────────────────────────────────────────────────────────────────────────────
enum HeroLayout {
  /// Default: text left (RTL: right) + decorative phone mockup right (RTL: left).
  /// Mobile: text stack above, mockup below.
  split,

  /// Full-width background image with centered text overlay and dark overlay.
  /// Text color is always white in this layout regardless of theme.
  centered,

  /// Animated gradient background only — no image.
  /// Text centered on both desktop and mobile.
  gradientOnly,

  /// Edge-to-edge background image with dark overlay and centered text.
  /// Outer container has zero padding; image spans full width/height.
  /// Content is constrained to 1200px max-width with 24px horizontal padding.
  fullWidthImage,
}

// ─────────────────────────────────────────────────────────────────────────────
// Features / Bento Section Layouts
// ─────────────────────────────────────────────────────────────────────────────
enum FeatureLayout {
  /// Irregular bento grid (current default).
  /// Desktop: two rows of unequal columns. Mobile: single column stack.
  bentoGrid,

  /// Three equal columns with icon + title + description.
  /// Desktop: 3 cols. Mobile: 1 col stack.
  threeCols,

  /// Icon on the leading side, text on the trailing side (list style).
  /// Desktop: 2 cols of rows. Mobile: single column.
  iconLeft,
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Section Layouts
// ─────────────────────────────────────────────────────────────────────────────
enum StatsLayout {
  /// Horizontal row of 4 numbers (current default).
  /// Mobile: 2×2 grid.
  horizontal,

  /// Each stat has a colored icon above the number.
  /// Mobile: 2×2 grid.
  withIcons,
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA Section Layouts
// ─────────────────────────────────────────────────────────────────────────────
enum CtaLayout {
  /// Centered text + single large button on animated gradient (current default).
  centeredGradient,

  /// Text on the leading side, button on the trailing side.
  /// Mobile: stacked vertically.
  split,

  /// Edge-to-edge background image with dark overlay and centered CTA content.
  /// Outer container has zero padding; image spans full width/height.
  /// Content is constrained to 1100px max-width with 24px horizontal padding.
  fullWidthImage,
}

// ─────────────────────────────────────────────────────────────────────────────
// Template Slider Section Layouts
// ─────────────────────────────────────────────────────────────────────────────
enum TemplateSliderLayout {
  /// Horizontal auto-cycling slider (current default).
  horizontalSlider,

  /// Responsive masonry-style grid.
  masonryGrid,

  /// Two-column responsive grid.
  /// Desktop: 2 cols, Mobile: 1 col.
  twoColsGrid,
}
