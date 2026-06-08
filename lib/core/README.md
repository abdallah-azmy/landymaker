# Core Module

The `core` module contains shared infrastructure, utilities, and UI components used across all features of LandyMaker.

## 📂 Structure

- `forms/`: Centralized `ValidationEngine` and `FieldRenderer` for JSON-driven forms.
- `localization/`: Multi-language support (AR/EN) with RTL handling.
- `responsive/`: Layout utilities (`ResponsiveLayout`, `ResponsiveUtils`) for Mobile/Tablet/Desktop parity.
- `router/`: App-wide navigation configuration using `go_router`.
- `services/`: Low-level core services (Analytics, Analytics, Turnstile).
- `theme/`: Global style definitions (`AppColors`, `AppTypography`).
- `widgets/`: Reusable UI components following Atomic Design (Atoms, Molecules, Organisms).

## 🚀 Key Responsibilities

1.  **Uniformity**: Ensuring consistent styling and behavior across the entire platform.
2.  **Responsivity**: Providing the tools to build once and run on any screen size.
3.  **Localization**: Handling the Arabic-First (RTL) requirements.
4.  **Routing**: Managing the complex multi-tenant URL resolution.

## 🔗 Internal Dependencies

- Features depend on `core/widgets`, `core/theme`, and `core/localization`.
- `core/router` depends on feature screens to define the navigation tree.
