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
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';
import '../widgets/notification_inbox_modal.dart';
import '../../../../services/supabase_service.dart';

/// ======================================================
/// FEATURE: Dashboard Shell
/// PURPOSE: Main layout wrapper for the dashboard with responsive sidebar and top bar.
/// ARCHITECTURE: State is hoisted to [DashboardShell] wrapper.
/// Renders [_DesktopDashboardShell] or [_MobileDashboardShell] based on screen size.
/// ======================================================
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
  NotificationCubit? _notificationCubit;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initNotificationCubit();
  }

  void _initNotificationCubit() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _notificationCubit = NotificationCubit(
        supabase: SupabaseService.instance,
        userId: authState.userId,
      )..fetchNotifications();
    }
  }

  @override
  void dispose() {
    _notificationCubit?.close();
    super.dispose();
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
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) return const Scaffold();

    final isSuperAdmin = authState.role == 'super_admin';
    final userEmail = authState.email;

    return BlocProvider.value(
      value: _notificationCubit!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          final sidebar = SidebarNavigation(
            currentIndex: widget.navigationShell.currentIndex,
            isAdmin: isSuperAdmin,
            userEmail: userEmail,
            onLogout: () {
              context.read<AuthCubit>().logout();
            },
            onTabSelected: (index) {
              // Navigation handled via GoRouter
            },
          );

          if (isDesktop) {
            return _DesktopDashboardShell(
              navigationShell: widget.navigationShell,
              sidebar: sidebar,
              notificationCubit: _notificationCubit!,
            );
          }

          return _MobileDashboardShell(
            scaffoldKey: _scaffoldKey,
            navigationShell: widget.navigationShell,
            sidebar: sidebar,
            notificationCubit: _notificationCubit!,
          );
        },
      ),
    );
  }
}

/// Desktop version of the Dashboard Shell with fixed sidebar.
class _DesktopDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Widget sidebar;
  final NotificationCubit notificationCubit;

  const _DesktopDashboardShell({
    required this.navigationShell,
    required this.sidebar,
    required this.notificationCubit,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          sidebar,
          Expanded(
            child: Container(
              color: const Color(0xFF0A0E1A),
              child: SafeArea(
                child: Column(
                  children: [
                    _DashboardTopBar(
                      notificationCubit: notificationCubit,
                      loc: loc,
                    ),
                    Expanded(
                      key: ValueKey(navigationShell.currentIndex),
                      child: navigationShell,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile version of the Dashboard Shell with drawer and app bar.
class _MobileDashboardShell extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final StatefulNavigationShell navigationShell;
  final Widget sidebar;
  final NotificationCubit notificationCubit;

  const _MobileDashboardShell({
    required this.scaffoldKey,
    required this.navigationShell,
    required this.sidebar,
    required this.notificationCubit,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Text(loc.translate('app_title'), style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          _NotificationBell(notificationCubit: notificationCubit),
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.secondary),
            onPressed: () => loc.toggleLanguage(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: AppColors.border, height: 1.5),
        ),
      ),
      drawer: Drawer(child: sidebar),
      body: Container(
        color: const Color(0xFF0A0E1A),
        child: SafeArea(
          child: navigationShell,
        ),
      ),
    );
  }
}

/// Shared top bar for desktop view.
class _DashboardTopBar extends StatelessWidget {
  final NotificationCubit notificationCubit;
  final LocalizationCubit loc;

  const _DashboardTopBar({
    required this.notificationCubit,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _NotificationBell(notificationCubit: notificationCubit),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.secondary),
            onPressed: () => loc.toggleLanguage(),
          ),
        ],
      ),
    );
  }
}

/// Shared notification bell widget.
class _NotificationBell extends StatelessWidget {
  final NotificationCubit notificationCubit;

  const _NotificationBell({required this.notificationCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      bloc: notificationCubit,
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {
                NotificationInboxModal.show(
                  context: context,
                  cubit: notificationCubit,
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
