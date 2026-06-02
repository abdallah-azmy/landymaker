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
  final VoidCallback onLogout;

  const DashboardShell({super.key, required this.onLogout});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToTabByTitle(String titleKey, List<Map<String, dynamic>> navigationItems, List<Map<String, dynamic>> adminItems) {
    int targetIdx = 0;
    bool found = false;

    for (var item in navigationItems) {
      if (item['title_key'] == titleKey) {
        found = true;
        break;
      }
      targetIdx++;
    }

    if (!found) {
      for (var item in adminItems) {
        if (item['title_key'] == titleKey) {
          found = true;
          break;
        }
        targetIdx++;
      }
    }

    if (found) {
      setState(() => _currentTabIndex = targetIdx);
    }
  }

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
      'screen': DashboardHomeScreen(
        onOpenBuilder: (pageId) {
          context.push('/builder/$pageId');
        },
      ),
    });

    if (activeSiteType == 'store') {
      navigationItems.add({
        'title_key': 'Products',
        'icon': Icons.inventory_2_rounded,
        'is_store_only': true,
        'is_builder': true,
      });
    }

    navigationItems.addAll([
      {'title_key': 'leads', 'icon': Icons.contacts_rounded, 'screen': const LeadsTrackerScreen()},
      {'title_key': 'analytics', 'icon': Icons.analytics_rounded, 'screen': const AnalyticsScreen()},
    ]);

    if (activeSiteType == 'store') {
      navigationItems.add({
        'title_key': 'Product Feed',
        'icon': Icons.rss_feed_rounded,
        'is_store_only': true,
        'screen': const ProductFeedScreen(),
      });
    }

    navigationItems.addAll([
      {
        'title_key': 'hero',
        'icon': Icons.construction_rounded,
        'is_builder': true,
      },
      {'title_key': 'custom_domain_menu', 'icon': Icons.language_rounded, 'screen': const DomainSettingsScreen()},
    ]);

    // 2. Admin Items
    final List<Map<String, dynamic>> adminItems = [];
    if (isSuperAdmin) {
      adminItems.add({
        'title_key': 'super_admin',
        'icon': Icons.admin_panel_settings_rounded,
        'screen': const SuperAdminPanelScreen(),
      });
      adminItems.add({
        'title_key': 'blog_management',
        'icon': Icons.article_rounded,
        'screen': const BlogManagementScreen(),
      });
    }


    // 4. Final lists
    final List<Map<String, dynamic>> sidebarMenu = [...navigationItems, ...adminItems];
    final List<Widget> screens = [
      ...navigationItems.where((e) => e.containsKey('screen')).map((e) => e['screen'] as Widget),
      ...adminItems.where((e) => e.containsKey('screen')).map((e) => e['screen'] as Widget),
    ];

    final sidebar = SidebarNavigation(
      currentIndex: _currentTabIndex,
      isAdmin: isSuperAdmin,
      userEmail: userEmail,
      menuItemsOverride: sidebarMenu,
      onLogout: () {
        context.read<AuthCubit>().logout();
      },
      onTabSelected: (index) {
        final selectedItem = sidebarMenu[index];
        if (selectedItem['is_locked'] == true) return;

        if (selectedItem['is_builder'] == true) {
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
          context.push('/builder');
          return;
        }

        int screenIdx = 0;
        for (int i = 0; i < index; i++) {
          if (sidebarMenu[i]['is_locked'] != true && sidebarMenu[i]['is_builder'] != true) screenIdx++;
        }

        setState(() => _currentTabIndex = screenIdx);
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }
      },
    );

    return BlocListener<ActiveWebsiteCubit, ActiveWebsiteState>(
      listener: (context, state) {
        setState(() => _currentTabIndex = 0);
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
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: screens,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
