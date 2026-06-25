import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/organisms/sidebar_navigation.dart';
import '../../../core/widgets/atoms/animated_theme_toggle.dart';
import '../../../core/utils/toast_service.dart';
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
import '../../home/screens/landymaker_home_screen.dart';

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
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    LandyMakerHomeScreen.resetScrollPosition();
    _loadData();
    _initFCMListener();
  }

  void _initNotificationCubit(String userId) {
    if (_notificationCubit == null) {
      _notificationCubit = NotificationCubit(
        supabase: SupabaseService.instance,
        userId: userId,
      )..fetchNotifications();
    }
  }

  void _initFCMListener() {
    _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      final notification = message.notification;
      if (notification != null) {
        final title = notification.title ?? '';
        final body = notification.body ?? '';

        final String? redirectTo = message.data['redirect_to'] ?? message.data['click_action'];
        final String type = message.data['type'] ?? 'info';

        String targetRoute = '/dashboard/notifications';
        if (redirectTo != null && redirectTo.isNotEmpty) {
          targetRoute = redirectTo;
        } else {
          if (type == 'lead') {
            targetRoute = '/dashboard/leads';
          } else if (type == 'product') {
            targetRoute = '/dashboard/products';
          } else if (type == 'domain') {
            targetRoute = '/dashboard/domain';
          }
        }

        // Play sound alert in foreground
        FcmService.playNotificationSound();

        ToastService.showInfo(
          context,
          title: title,
          message: body,
          onTap: () {
            if (mounted) {
              context.go(targetRoute);
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
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

    _initNotificationCubit(authState.userId);

    final isSuperAdmin = authState.role == 'super_admin';
    final userEmail = authState.email;
    final userPhotoUrl = authState.photoURL;

    return BlocProvider.value(
      value: _notificationCubit!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          final sidebar = SidebarNavigation(
            currentIndex: widget.navigationShell.currentIndex,
            isAdmin: isSuperAdmin,
            userEmail: userEmail,
            userPhotoUrl: userPhotoUrl,
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
              userPhotoUrl: userPhotoUrl,
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
  final String? userPhotoUrl;

  const _DesktopDashboardShell({
    required this.navigationShell,
    required this.sidebar,
    required this.notificationCubit,
    this.userPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          sidebar,
          Expanded(
              child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Column(
                  children: [
                    _DashboardTopBar(
                      notificationCubit: notificationCubit,
                      loc: loc,
                      userPhotoUrl: userPhotoUrl,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        title: Text(loc.translate('app_title'), style: AppTypography.h3),
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          const AnimatedThemeToggle(size: 36),
          const SizedBox(width: 8),
          _NotificationBell(notificationCubit: notificationCubit),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: Theme.of(context).colorScheme.outlineVariant, height: 1.5),
        ),
      ),
      drawer: Drawer(child: sidebar),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
  final String? userPhotoUrl;

  const _DashboardTopBar({
    required this.notificationCubit,
    required this.loc,
    this.userPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const AnimatedThemeToggle(size: 40),
          const SizedBox(width: 16),
          _NotificationBell(notificationCubit: notificationCubit),
          const SizedBox(width: 16),
          _UserAvatarChip(
            userEmail: context.read<AuthCubit>().state is Authenticated ? (context.read<AuthCubit>().state as Authenticated).email : '',
            userPhotoUrl: userPhotoUrl,
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
              icon: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface),
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
                    color: Theme.of(context).colorScheme.error,
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

class _UserAvatarChip extends StatelessWidget {
  final String userEmail;
  final String? userPhotoUrl;
  const _UserAvatarChip({required this.userEmail, this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      onSelected: (value) {
        if (value == 'settings') {
          context.go('/dashboard/settings');
        } else if (value == 'logout') {
          context.read<AuthCubit>().logout();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                child: userPhotoUrl == null
                    ? Text(
                        userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                userEmail.split('@').first,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          enabled: false,
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 18),
              const SizedBox(width: 12),
              Text(loc.translate('profile')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 18),
              const SizedBox(width: 12),
              Text(loc.translate('settings')),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.power_settings_new_rounded, size: 18, color: AppColors.dangerRed),
              const SizedBox(width: 12),
              Text(
                loc.translate('logout'),
                style: const TextStyle(color: AppColors.dangerRed),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
