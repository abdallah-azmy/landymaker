# Home Feature

The public-facing SaaS marketing website — landing page with hero section, feature showcases, template picker, and the full CubeLoader ecosystem. Entry point for unauthenticated visitors.

## File Map

| Path | Role |
|------|------|
| `screens/landymaker_home_screen.dart` | **Main entry** (698 lines) — home page with cross-fade transition from HTML loading screen, dynamic sections (hero, features, templates, cta, footer), cube showcase gallery, `FloatingCubeBackground` integration, logo compare FAB (debug only) |
| `screens/template_picker_screen.dart` | Template gallery — category filter sidebar (desktop) / bottom sheet (mobile), template cards with dual mini-preview, image pre-cache, bilingual display, telemetry events |
| `screens/legal_page.dart` | Static legal pages — `/about`, `/privacy-policy`, `/terms` |
| `models/home_layouts.dart` | Layout enums — `HeroLayout`, `FeatureLayout`, `StatsLayout`, `CtaLayout`, `TemplateSliderLayout` |
| `widgets/home_navbar.dart` | Factory navbar (470 lines) — desktop/mobile responsive, `DesktopSideMenu`, `MobileMenuPopup`, `UserAvatarMenu` |
| `widgets/navbar/desktop_side_menu.dart` | Animated overlay side menu for desktop |
| `widgets/navbar/mobile_menu_popup.dart` | Popup menu for mobile with auth actions |
| `widgets/navbar/user_avatar_menu.dart` | Avatar dropdown — dashboard link, account switch, logout |
| `widgets/home_hero_section.dart` | Factory hero (870 lines) — layout-style dispatch, `TypewriterText`, `PhonePreview`, 4 layout methods, badge, CTA |
| `widgets/hero/typewriter_text.dart` | Animated typewriter with cursor blink effect |
| `widgets/hero/phone_preview.dart` | Scrolling phone mockup with template cycling |
| `widgets/home_feature_bento.dart` | Feature showcase — bento grid layout with icons |
| `widgets/home_cta_section.dart` | Call-to-action banner section |
| `widgets/home_footer.dart` | Site footer with links and branding |
| `widgets/logo_test_dialog.dart` | Debug dialog (kDebugMode only) — compares CubeLoader variants side-by-side for visual QA |

## State & Services

- **No dedicated cubit** for the home screen — it uses `StatefulWidget` local state for section visibility and layout selection.
- Section data loaded via `DatabaseService.getHomepageSections()` at startup (dynamic sections from DB).
- `CubeModeCubit` — singleton; manages `FloatingCubeBackground` animation mode (logo, idle, burst, attract).
- `LocalizationCubit` — singleton; drives RTL/LTR switching (`context.translate`, `context.isRtl`).
- Template data sourced from `TemplateRegistry.availableTemplates` + DB.

## Cross-Fade Transition Architecture

```
index.html (pre-Flutter)
  └─ #loading-indicator (100dvh, logo.webp, SVG cubes)
       └─ 1.5s cross-fade →
            landymaker_home_screen.dart (Flutter)
              └─ FloatingCubeBackground (logo→attract→idle)
              └─ Dynamic sections loaded from DB
```

Key sync parameters (both HTML and Flutter must match):
- `gap = 24.7` — spacing between cube parts
- `renderSize = 19.5` — base cube unit size
- Corner radius formula: `h * 0.25`
- Stroke width formula: `h * 0.10`

## ⚠️ AI Warnings

- **Do NOT modify first-load transition** — the HTML→Flutter cross-fade (1.5s, `100dvh`, keyframe max scale 1.35, aspect-ratio correction 1.0266×1.0347) is precisely tuned. Changing any parameter breaks the visual handoff.
- **`FloatingCubeBackground`** is a 60fps particle system wrapped in `RepaintBoundary`. Do NOT add widgets inside it or wrap it with `Opacity`/`Transform` that would trigger repaints.
- **`CubeLoader` is the ONLY loading indicator** — do NOT use `CircularProgressIndicator`, `LinearProgressIndicator`, or custom spinners anywhere in the home module.
- **`logo_test_dialog.dart`** is guarded by `kDebugMode`. Do NOT remove the guard — it must never render in production builds.
- **Navbar/hero subfolders** are extracted widget clusters. Do NOT merge `navbar/*.dart` back into `home_navbar.dart` or `hero/*.dart` back into `home_hero_section.dart` — they were split for AI readability.
- **Template picker** uses `DraggableScrollableSheet` for mobile filter (initialChildSize: 0.5). Do NOT replace with a fixed `Container` — it must support 320px screens.
- **Home section widgets** use `LayoutBuilder` + `HomeBreakpoint.isMobile(constraints.maxWidth)` for responsive decisions. Do NOT use `MediaQuery.of(context).size` for layout decisions inside section widgets.
- **`EdgeInsetsDirectional`** must be used instead of `EdgeInsets.only(left/right)` for all home module widgets to support RTL.
