import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/organisms/sidebar_navigation.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import 'dashboard_home_screen.dart';
import 'leads_tracker_screen.dart';
import 'analytics_screen.dart';
import 'package:go_router/go_router.dart';
import '../../super_admin/screens/super_admin_panel_screen.dart';
import '../../blog_admin/screens/blog_management_screen.dart';
import 'product_feed_screen.dart';
import 'domain_settings_screen.dart';
import '../controllers/active_website_cubit.dart';

class DashboardShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final VoidCallback onLogout;

  const DashboardShell({
    super.key,
    required this.navigationShell,
    required this.onLogout,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final authState = context.watch<AuthCubit>().state;
    final activeSiteType = context.watch<ActiveWebsiteCubit>().state.websiteType;

    bool isSuperAdmin = false;
    String userEmail = 'user@landymaker.com';

    if (authState is Authenticated) {
      isSuperAdmin = authState.role == 'super_admin';
      userEmail = authState.email;
    }

    // 1. Core Navigation Items
    final List<Map<String, dynamic>> navigationItems = [];
    
    navigationItems.add({
      'title_key': 'dashboard',
      'icon': Icons.dashboard_rounded,
      'route': '/dashboard',
    });

    if (activeSiteType == 'store') {
      navigationItems.add({
        'title_key': 'Products',
        'icon': Icons.inventory_2_rounded,
        'is_store_only': true,
        'route': '/dashboard/products',
      });
    }

    navigationItems.addAll([
      {'title_key': 'leads', 'icon': Icons.contacts_rounded, 'route': '/dashboard/leads'},
      {'title_key': 'analytics', 'icon': Icons.analytics_rounded, 'route': '/dashboard/analytics'},
    ]);

    if (activeSiteType == 'store') {
      navigationItems.add({
        'title_key': 'Product Feed',
        'icon': Icons.rss_feed_rounded,
        'is_store_only': true,
        'route': '/dashboard/feed',
      });
    }

    navigationItems.addAll([
      {
        'title_key': 'hero',
        'icon': Icons.construction_rounded,
        'is_builder': true,
        'route': '/builder',
      },
      {'title_key': 'custom_domain_menu', 'icon': Icons.language_rounded, 'route': '/dashboard/domain'},
    ]);

    // 2. Admin Items
    final List<Map<String, dynamic>> adminItems = [];
    if (isSuperAdmin) {
      adminItems.add({
        'title_key': 'super_admin',
        'icon': Icons.admin_panel_settings_rounded,
        'route': '/dashboard/super-admin',
      });
      adminItems.add({
        'title_key': 'blog_management',
        'icon': Icons.article_rounded,
        'route': '/dashboard/blog-admin',
      });
    }

    // 4. Final lists
    final List<Map<String, dynamic>> sidebarMenu = [...navigationItems, ...adminItems];

    final sidebar = SidebarNavigation(
      currentIndex: widget.navigationShell.currentIndex,
      isAdmin: isSuperAdmin,
      userEmail: userEmail,
      menuItemsOverride: sidebarMenu,
      onLogout: () {
        context.read<AuthCubit>().logout();
      },
      onTabSelected: (index) {
        // Handled directly inside SidebarNavigation now via GoRouter
      },
    );

    return BlocListener<ActiveWebsiteCubit, ActiveWebsiteState>(
      listener: (context, state) {
        context.go('/dashboard');
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: !ResponsiveLayout.isDesktop(context)
            ? AppBar(
                backgroundColor: AppColors.cardBg,
                title: Text(loc.translate('app_title'), style: AppTypography.h3),
                leading: IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.language_rounded, color: AppColors.secondary),
                    onPressed: () => loc.toggleLanguage(),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.5),
                  child: Container(color: AppColors.border, height: 1.5),
                ),
              )
            : null,
        drawer: !ResponsiveLayout.isDesktop(context) ? Drawer(child: sidebar) : null,
        body: Row(
          children: [
            if (ResponsiveLayout.isDesktop(context)) sidebar,
            Expanded(
              child: Container(
                color: const Color(0xFF0A0E1A),
                child: SafeArea(
                  child: widget.navigationShell,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
