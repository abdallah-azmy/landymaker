# Feature Index - LandyMaker

Locate platform functionality by business purpose rather than exact filename.

| Feature Name | Business Purpose | Main Entry / Screen | Main Controller | Main Widgets |
| :--- | :--- | :--- | :--- | :--- |
| **Builder** | Drag-and-drop editor workspace | `BuilderWorkspaceScreen` | `LandingPageBuilderCubit` | `BuilderCanvas`, `BuilderSidebar` |
| **Public Viewer** | Rendering live landing pages | `PublicLandingPage` | `PublicPageCubit` | `SectionRenderer` |
| **Analytics** | High-fidelity visitor metrics | `AnalyticsScreen` | `LeadsAnalyticsCubit` | `DataCard`, `PageStatCard` |
| **Leads** | Lead management and submission | `LeadsTrackerScreen` | N/A (Direct DB fetch) | `ResponsiveDataTable` |
| **Auth** | User identity and access | `LoginScreen`, `RegisterScreen` | `AuthCubit` | `SocialSignInButton` |
| **Media Gallery** | Asset storage and management | `MediaGalleryScreen` | `MediaGalleryCubit` | `ImagePickerModal` |
| **SEO Settings** | Site-specific SEO configuration | `SeoSettingsModal` | N/A (Builder context) | `CustomTextField` |
| **Domains** | Custom domain configuration | `DomainSettingsScreen` | `ActiveWebsiteCubit` | `DomainSetupWidget` |
| **Super Admin** | Platform-level monitoring | `SuperAdminPanelScreen` | `SuperAdminCubit` | `ResponsiveDataTable` |
| **Blog Admin** | Headless blog management | `BlogManagementScreen` | `BlogCubit` | `BlogEditorScreen` |
| **Subscription** | Tier limits and payments | `UpgradeLimitModal` | N/A (Service layer) | `ManualPaymentModal` |
| **Sticky CTA** | High-conversion scroll overlay | N/A (Internal) | N/A (Local state) | `StickyCtaBar` |
| **Product Feed** | Merchant catalog sync | `ProductFeedScreen` | N/A (Future work) | `GlassContainer` |

## 🔗 System Relationships

- **Builder** ➡️ **JSON Schema** ➡️ **Public Viewer**
- **Public Viewer** ➡️ **ActionHandler** ➡️ **Leads**
- **Dashboard** ➡️ **ActiveWebsiteCubit** ➡️ **All Sub-Screens**
- **Middleware** ➡️ **Supabase API** ➡️ **SEO / Robots / Blog Proxy**
