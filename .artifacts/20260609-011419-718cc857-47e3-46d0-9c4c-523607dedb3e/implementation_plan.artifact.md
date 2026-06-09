# Implementation Plan - Enhancing Templates, Sections, and Styles

This plan outlines the addition of new professional templates, high-end sections, and advanced style variants to LandyMaker, while preserving all existing functionality as requested.

## User Review Required

> [!NOTE]
> The new templates and sections will use existing schema patterns to ensure full compatibility with the current builder and parser. No database schema changes are required.

## Proposed Changes

### 🧱 New Sections (Public Viewer)
We will add 5 new professional-grade sections to the library.

#### [NEW] [custom_statistics_grid_widget.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/public_viewer/widgets/custom_statistics_grid_widget.dart)
- Displays metrics in a professional grid with icons and glassmorphism support.
- Supports 2x2, 3x1, and 4x1 layouts.

#### [NEW] [custom_team_members_widget.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/public_viewer/widgets/custom_team_members_widget.dart)
- Showcases the team behind the business.
- Includes name, role, bio, and social links.

#### [NEW] [custom_service_steps_widget.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/public_viewer/widgets/custom_service_steps_widget.dart)
- Visualizes "How it works" or "Process" flows.
- Supports horizontal (desktop) and vertical (mobile) timeline-style steps.

#### [NEW] [custom_cta_banner_widget.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/public_viewer/widgets/custom_cta_banner_widget.dart)
- A high-impact call-to-action banner for the bottom of pages.
- Supports gradient backgrounds and secondary CTAs.

#### [NEW] [custom_comparison_table_widget.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/public_viewer/widgets/custom_comparison_table_widget.dart)
- Compares features across different plans or products.
- Mobile-responsive (stacks vertically on small screens).

---

### 🎨 Style & Registry Enhancements

#### [block_registry.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/registries/block_registry.dart)
- Register the 5 new widgets.
- Implement **Variant 5** (Gradient Border): A modern aesthetic for tech/SaaS sections.
- Implement **Variant 7** (Soft Gradient Background): A premium feel for luxury/creative sections.
- Implement **Variant 8** (Dark Mode Contrast Card): High readability for information-dense blocks.

#### [template_registry.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/registries/template_registry.dart)
- Add 5 new professional templates:
  - **Solar Energy**: Clean, eco-friendly design.
  - **Luxury Resort**: Elegant, high-visual impact.
  - **Fintech / Crypto**: Dark mode, tech-first, neon accents.
  - **Architecture & Interior**: Minimalist, grid-focused.
  - **E-commerce V2 (Fashion)**: Editorial layout for apparel.

#### [section_library_modal.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/widgets/modals/section_library_modal.dart)
- Expose the new sections in the library.
- Add "Professional" variants (using the new global style indices) for existing sections like Hero, Features, and Pricing.

---

### 🛠 Builder Editors

#### [NEW] [statistics_grid_editor.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/widgets/editors/blocks/statistics_grid_editor.dart)
#### [NEW] [team_members_editor.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/widgets/editors/blocks/team_members_editor.dart)
#### [NEW] [service_steps_editor.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/widgets/editors/blocks/service_steps_editor.dart)
#### [NEW] [cta_banner_editor.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/widgets/editors/blocks/cta_banner_editor.dart)
#### [NEW] [comparison_table_editor.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/widgets/editors/blocks/comparison_table_editor.dart)

---

### 🌍 Localization

#### [translations_ar.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/localization/translations_ar.dart)
- Add Arabic strings for all new sections, fields, and templates.

#### [translations_en.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/localization/translations_en.dart)
- Add English strings for all new sections, fields, and templates.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no linting or type errors.
- Run `flutter test` (if applicable) to verify parser logic for new blocks.

### Manual Verification
1. Open the **Template Picker** and verify the 5 new templates are visible and load correct blocks.
2. Open the **Section Library** and verify the 5 new sections are visible.
3. Add each new section to the canvas and verify it renders correctly in both Desktop and Mobile views.
4. Test the **Design Tab** for each section and verify that changing "Variants" (0-9) correctly applies the new global styles (Glassmorphism, Gradient, etc.).
5. Verify that existing sections still function perfectly and can now also use the new global variants.
