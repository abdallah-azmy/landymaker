# LandyMaker 🚀

LandyMaker is a professional, high-performance SaaS Landing Page Builder engineered for speed, conversion, and effortless customization. Built on the **SPEC-KIT** architecture using **Flutter Web** and **Supabase**, it transforms the complex process of web design into a simple, block-based experience.

## 🌟 Core Features

### 🎨 Professional Builder Engine (Flex-Editor)
- **Modular Block System**: 15+ industry-specific sections including `Hero`, `Products`, `Lead Forms`, and `Basic Sections`.
- **Atomic Styling**: Precise control over individual text and image elements via **Long-Press** contextual menus.
- **Dynamic Typography**: Real-time integration with **Google Fonts** for infinite font choices without app bloat.
- **Responsive-First**: Every design is automatically optimized for Mobile, Tablet, and Desktop.

### 🏢 Multi-Page SaaS Infrastructure
- **Tier-Based Limits**: Automated page limits for Free (1), Pro (5), and Enterprise (Unlimited) users.
- **Unified Dashboard**: Manage multiple projects from a single workspace with aggregated performance metrics.
- **Automated Lifecycle**: Inactive or expired pages are automatically suspended with a professional redirect UI.

### 📊 Deep Analytics & SEO
- **High-Performance Telemetry**: Non-blocking **Postgres RPCs** to track views and conversions in real-time.
- **Edge SEO Middleware**: Vercel Edge functions serve static HTML metadata to search engine bots (Google/AI Bots) for 100% indexability.
- **Advanced SEO Controls**: Built-in editor fields for custom Meta Titles and Descriptions with educational Arabic guidance.

### 👑 Super Admin & Operations
- **Full Platform Visibility**: Real-time monitoring of all users, landing pages, and growth stats.
- **WhatsApp Payment Flow**: Direct user-to-admin payment confirmation via WhatsApp to eliminate storage overhead.
- **Affiliate Marketing**: Double-sided commission engine with coupon code tracking and automated balance updates.

## 🛠 Technical Stack

- **Frontend**: Flutter Web (Clean Architecture, Atomic Design, Cubit State Management).
- **Backend**: Supabase (PostgreSQL, Storage, Real-time RPCs, Triggers).
- **Hosting**: Vercel (Edge Functions for SEO & Routing).
- **Methodology**: **SPEC-KIT** Framework for robust, scalable software engineering.

## 🌍 Localization

- **Arabic-First**: Native RTL support with comprehensive translations and mirrored UI components.
- **Multilingual**: Full English support with a one-tap language toggle.

## 🚀 Getting Started

1. Clone the repository.
2. Run `flutter pub get` to fetch dependencies (including Google Fonts).
3. Set up your environment variables:
   ```bash
   flutter run -d chrome \
     --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
     --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```

---
*Built with ❤️ for creators by LandyMaker Team.*
