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
    context.watch<ActiveWebsiteCubit>();

    String? currentUserId;
    bool isSuperAdmin = false;
    String userEmail = 'user@landymaker.com';

    if (authState is Authenticated) {
      currentUserId = authState.userId;
      isSuperAdmin = authState.role == 'super_admin';
      userEmail = authState.email;
    }

    if (currentUserId == null) return const Scaffold();

    return BlocProvider(
      create: (context) => NotificationCubit(
        supabase: SupabaseService.instance,
        userId: currentUserId!,
      )..fetchNotifications(),
      child: Builder(
        builder: (context) {
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
                      _buildNotificationBell(context),
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
                if (ResponsiveLayout.isDesktop(context)) ...[
                  sidebar,
                  // On Desktop, add a small header or floating button for notifications if sidebar doesn't have it
                ],
                Expanded(
                  child: Container(
                    color: const Color(0xFF0A0E1A),
                    child: SafeArea(
                      child: Column(
                        children: [
                          if (ResponsiveLayout.isDesktop(context))
                            _buildDesktopTopBar(context, loc),
                          Expanded(child: widget.navigationShell),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopTopBar(BuildContext context, LocalizationCubit loc) {
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
          _buildNotificationBell(context),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.secondary),
            onPressed: () => loc.toggleLanguage(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () => NotificationInboxModal.show(context),
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
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
