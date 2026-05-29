# mylandy Constitution

## Core Principles

### I. User-Centric Fluidity
Every UI component must be responsive by default. Use `LayoutBuilder` and `AspectRatio` instead of hardcoded heights to ensure 100% overflow-free experience across all devices (Mobile to Ultra-wide).

### II. Real-Time Feedback
The Builder Workspace must reflect every change (color, layout, text) instantly. Use BLoC (Cubit) to sync state between the Sidebar Editor and the Live Canvas Preview.

### III. Section-Based Architecture
The application is built on modular "Sections". Each section is a self-contained Widget that accepts a `LandingPageTheme` to maintain visual consistency.

### IV. Visual Integrity
Maintain a strict vertical spacing rule: 80px for desktop and 40px for mobile to ensure a professional "breathable" design without excessive white space.

## Technical Constraints

- **Framework**: Flutter (Targeting Web & Mobile).
- **Backend**: Supabase (Auth, Database, Storage).
- **State Management**: flutter_bloc.
- **Design System**: Slate-based dark theme (default) with high-contrast accent colors.

## Development Workflow

1. **Research**: Analyze trending UI patterns for the target industry.
2. **Implementation**: Build responsive widgets first, then property editors.
3. **Verification**: Stress test with extreme content lengths and small screen widths.

**Version**: 1.0.0 | **Ratified**: 2024-05-28
