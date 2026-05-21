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
import '../../builder/screens/builder_workspace_screen.dart';
import '../../super_admin/screens/super_admin_panel_screen.dart';

class DashboardShell extends StatefulWidget {
  final VoidCallback onLogout;

  const DashboardShell({super.key, required this.onLogout});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final authState = context.watch<AuthCubit>().state;

    bool isSuperAdmin = false;
    String userEmail = 'user@mylandy.com';

    if (authState is Authenticated) {
      isSuperAdmin = authState.role == 'super_admin';
      userEmail = authState.email;
    }

    // List of screens matching SidebarNavigation tabs
    final List<Widget> screens = [
      DashboardHomeScreen(onOpenBuilder: () => setState(() => _currentTabIndex = 3)),
      const LeadsTrackerScreen(),
      const AnalyticsScreen(),
      BuilderWorkspaceScreen(onBackToDashboard: () => setState(() => _currentTabIndex = 0)),
    ];

    if (isSuperAdmin) {
      screens.add(const SuperAdminPanelScreen());
    }

    final sidebar = SidebarNavigation(
      currentIndex: _currentTabIndex,
      isAdmin: isSuperAdmin,
      userEmail: userEmail,
      onLogout: () {
        context.read<AuthCubit>().logout();
      },
      onTabSelected: (index) {
        setState(() => _currentTabIndex = index);
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop(); // Close drawer on mobile
        }
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      // Render AppBar on Mobile/Tablet views only
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
          // Persistent Sidebar on Desktop
          if (ResponsiveLayout.isDesktop(context)) sidebar,

          // Main View Content Container
          Expanded(
            child: Container(
              color: const Color(0xFF0A0E1A), // Dark slate view background
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
    );
  }
}
