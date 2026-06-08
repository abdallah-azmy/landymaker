# Dashboard Feature

The dashboard is the central hub for users who have logged in to LandyMaker.

## 📊 Capabilities

- **Site Management**: Create, delete, and list websites.
- **Analytics**: High-fidelity conversion tracking and visitor stats.
- **Leads**: View and export form submissions received from landing pages.
- **Media Gallery**: Centralized storage for user-uploaded images.
- **Domain Settings**: Configure custom domains and subdomains.
- **Product Feeds**: (Future) Syncing with Facebook/Google catalogs.

## 🧭 Navigation

The dashboard uses a `StatefulShellRoute` with a side navigation menu (`SidebarNavigation`).

## 🧱 Key Components

- `controllers/active_website_cubit.dart`: Tracks which site the user is currently focused on.
- `screens/dashboard_shell.dart`: The layout container for all dashboard tabs.
- `widgets/responsive_data_table.dart`: A specialized table that adapts to mobile screens for leads and site lists.
