# Features Module

The `features` folder contains isolated, domain-driven modules. Each subdirectory represents a distinct functional area of LandyMaker.

## 📦 Features Overview

- **auth/**: Handles user lifecycle (Register, Login, Password Reset).
- **builder/**: The drag-and-drop editor. Contains `registries` for blocks and `editors` for properties.
- **dashboard/**: The post-login panel for users to manage pages, leads, and analytics.
- **public_viewer/**: The public-facing renderer for published landing pages. Optimized for speed and SEO.
- **blog_admin/**: Tools for creating and managing blog content.
- **super_admin/**: High-level platform monitoring and global SEO settings.
- **subscription/**: Tier-based limit enforcement and payment UI.
- **home/**: The main landing page of LandyMaker itself and template pickers.

## 🛠 Feature Pattern

Each feature typically includes:
- `controllers/`: BLoC/Cubit for state management.
- `screens/`: Top-level UI containers.
- `widgets/`: Feature-specific components.
- `models/`: Domain-specific data objects.

## 🛡️ Boundary Rules

- Features should be as decoupled as possible.
- Shared logic should be moved to `lib/core/` or `lib/services/`.
- Features communicate primarily through the `AppRouter` or global services.
