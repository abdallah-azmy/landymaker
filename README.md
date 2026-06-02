<div align="center">
  <img src="assets/images/logo.webp" alt="LandyMaker Logo" width="120" />
  <h1>LandyMaker 🚀</h1>
  <p><strong>Professional, High-Performance SaaS Landing Page Builder</strong></p>

  [![Flutter Web](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
  [![Vercel](https://img.shields.io/badge/Vercel-Edge_SEO-000000?logo=vercel&logoColor=white)](https://vercel.com/)
  [![SPEC-KIT](https://img.shields.io/badge/Architecture-SPEC--KIT-FF6B6B)](https://github.com/github/spec-kit)
</div>

<br />

> **LandyMaker** is engineered for speed, conversion, and effortless customization. It transforms the complex process of web design into a simple, visually driven, block-based experience. Built on a robust Clean Architecture, it serves as a multi-tenant SaaS platform right out of the box.

---

## 📑 Table of Contents
- [🌟 Core Features](#-core-features)
- [🛠 Technical Stack](#-technical-stack)
- [🌍 Localization & RTL](#-localization--rtl)
- [📁 Project Structure](#-project-structure)
- [🚀 Getting Started](#-getting-started)
- [💻 Environment Variables](#-environment-variables)

---

## 🌟 Core Features

### 🎨 Professional Builder Engine (Flex-Editor)
- **Modular Block System**: 15+ industry-specific sections including `Hero`, `Products`, `Lead Forms`, and `Basic Layouts`.
- **Atomic Styling**: Precise control over individual text, image, and button elements via **Long-Press** contextual menus.
- **Dynamic Typography**: Real-time integration with **Google Fonts** for infinite font choices without app bloat.
- **Responsive-First**: Every design is automatically optimized for Mobile, Tablet, and Desktop views.

### 🏢 Multi-Page SaaS Infrastructure
- **Tier-Based Limits**: Automated quotas and page limits for Free (1), Pro (5), and Enterprise (Unlimited) users.
- **Unified Dashboard**: Manage multiple projects from a single workspace with aggregated performance metrics.
- **Automated Lifecycle**: Inactive or expired pages are automatically suspended with a professional redirect UI.

### 📊 Deep Analytics & SEO
- **High-Performance Telemetry**: Non-blocking **Postgres RPCs** track views and conversions in real-time.
- **Edge SEO Middleware**: Vercel Edge functions serve static HTML metadata to search engine bots (Google/AI Bots) for 100% indexability.
- **Advanced SEO Controls**: Built-in editor fields for custom Meta Titles and Descriptions with built-in educational guidance.

### 👑 Super Admin & Operations
- **Full Platform Visibility**: Real-time monitoring of all users, landing pages, and growth statistics.
- **WhatsApp Payment Flow**: Direct user-to-admin payment confirmation via WhatsApp to eliminate complex gateway overhead.
- **Affiliate Marketing**: Double-sided commission engine with coupon code tracking and automated balance updates.

---

## 🛠 Technical Stack

### Frontend
- **Framework**: Flutter Web
- **State Management**: flutter_bloc (Cubit)
- **Routing**: go_router (with path URL strategy)
- **Dependency Injection**: get_it
- **Networking**: dio & http

### Backend (BaaS)
- **Database**: PostgreSQL (via Supabase)
- **Features**: Authentication, Storage, Edge Functions, Real-time RPCs, Triggers.

### Hosting & Edge
- **Provider**: Vercel
- **Middleware**: Custom `seo-middleware.js` for handling dynamic metadata injection for web crawlers.

---

## 🌍 Localization & RTL

LandyMaker is designed to be **Arabic-First**:
- **Native RTL Support**: Comprehensive translations and mirrored UI components built natively for Right-to-Left languages.
- **Multilingual**: Full English (LTR) support with a seamless one-tap language toggle.

---

## 📁 Project Structure

The project follows a scalable **Feature-Driven Architecture**:

```text
lib/
├── core/                # Shared utilities, themes, routing, and generic widgets
├── features/            # Isolated business domains
│   ├── auth/            # Login, Signup, OTP
│   ├── builder/         # The core drag-and-drop landing page editor
│   ├── dashboard/       # User project management & analytics
│   ├── home/            # The main landing page of the SaaS
│   ├── public_viewer/   # The high-performance renderer for published pages
│   ├── subscription/    # SaaS tiers and limits
│   └── super_admin/     # Admin platform management
├── injection_container.dart # Service Locator (get_it) setup
└── main.dart            # Application entry point
```

---

## 🚀 Getting Started

Follow these steps to set up the project locally:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/mylandy.git
   cd mylandy
   ```

2. **Install dependencies:**
   Fetch all necessary Flutter packages and fonts.
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   Launch the app on Chrome by providing your Supabase credentials.
   ```bash
   flutter run -d chrome \
     --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
     --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

---

## 💻 Environment Variables

For production or CI/CD deployments, ensure the following arguments are passed during the build process:

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase public anonymous key |

Example Build Command:
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---
<div align="center">
  <i>Built with ❤️ for creators by the LandyMaker Team.</i>
</div>
