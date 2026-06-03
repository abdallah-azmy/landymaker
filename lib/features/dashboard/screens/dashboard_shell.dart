import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/organisms/sidebar_navigation.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../controllers/active_website_cubit.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';

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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cubit = context.read<LandingPagesCubit>();
    await cubit.loadPages();

    if (mounted) {
      final state = cubit.state;
      if (state is LandingPagesLoaded && state.pages.isNotEmpty) {
        final activeCubit = context.read<ActiveWebsiteCubit>();
        if (activeCubit.state.website == null) {
          activeCubit.selectWebsite(state.pages.first);
        }
      }
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

    final sidebar = SidebarNavigation(
      currentIndex: widget.navigationShell.currentIndex,
      isAdmin: isSuperAdmin,
      userEmail: userEmail,
      onLogout: () {
        context.read<AuthCubit>().logout();
      },
      onTabSelected: (index) {
        // Handled directly inside SidebarNavigation now via GoRouter
      },
    );

    return Scaffold(
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
      );
  }
}
