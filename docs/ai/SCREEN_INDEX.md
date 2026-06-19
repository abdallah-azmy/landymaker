# Screen Index - LandyMaker

Find screens based on their business description or path.

| Screen Purpose | File Path | Route | Feature |
| :--- | :--- | :--- | :--- |
| **Main Landing Page** | `lib/features/home/screens/landymaker_home_screen.dart` | `/` | Home |
| **Login Page** | `lib/features/auth/screens/login_screen.dart` | `/login` | Auth |
| **Register Page** | `lib/features/auth/screens/register_screen.dart` | `/register` | Auth |
| **Password Recovery** | `lib/features/auth/screens/forgot_password_screen.dart` | `/forgot-password` | Auth |
| **Reset Password** | `lib/features/auth/screens/reset_password_screen.dart` | `/reset-password` | Auth |
| **Main Editor Workspace** | `lib/features/builder/screens/builder_workspace_screen.dart` | `/builder/:pageId` | Builder |
| **User Dashboard Home** | `lib/features/dashboard/screens/dashboard_home_screen.dart` | `/dashboard` | Dashboard |
| **Analytics Dashboard** | `lib/features/dashboard/screens/analytics_screen.dart` | `/dashboard/analytics` | Dashboard |
| **Leads Management** | `lib/features/dashboard/screens/leads_tracker_screen.dart` | `/dashboard/leads` | Dashboard |
| **Media Library** | `lib/features/dashboard/screens/media_gallery_screen.dart` | `/dashboard/gallery` | Dashboard |
| **Domain Configuration** | `lib/features/dashboard/screens/domain_settings_screen.dart` | `/dashboard/domain` | Dashboard |
| **Product Feed Sync** | `lib/features/dashboard/screens/product_feed_screen.dart` | `/dashboard/feed` | Dashboard |
| **Template Library** | `lib/features/home/screens/template_picker_screen.dart` | `/templates` | Home |
| **Legal / Policy Page** | `lib/features/home/screens/legal_page.dart` | `/about`, `/privacy-policy`, `/terms` | Home |
| **Published Site View** | `lib/features/public_viewer/screens/public_landing_page.dart` | `/:pageName` (Catch-all) | Public Viewer |
| **Super Admin Panel** | `lib/features/super_admin/screens/super_admin_panel_screen.dart` | `/dashboard/super-admin` | Super Admin |
| **User Profile (Super Admin)** | `lib/features/super_admin/screens/user_profile_screen.dart` | `/dashboard/super-admin/users/:userId` | Super Admin |
| **Homepage Editor (Super Admin)** | `lib/features/super_admin/screens/homepage_editor_screen.dart` | `/dashboard/homepage-editor` | Super Admin |
| **Platform SEO Editor** | `lib/features/super_admin/screens/platform_seo_screen.dart` | `/dashboard/platform-seo` | Super Admin |
| **Notifications** | `lib/features/dashboard/screens/notifications_screen.dart` | `/dashboard/notifications` | Dashboard |
| **Blog Management** | `lib/features/blog_admin/screens/blog_management_screen.dart` | `/dashboard/blog-admin` | Blog Admin |
| **Blog Post Editor** | `lib/features/blog_admin/screens/blog_editor_screen.dart` | N/A (Modal/Push) | Blog Admin |

## 🧭 Navigation Shell

The Dashboard uses `StatefulShellRoute.indexedStack` defined in `lib/core/router/app_router.dart`. This ensures the sidebar navigation state is preserved between tabs.
