/// ======================================================
/// CORE: App Router
/// PURPOSE: Centralized navigation and route guard logic
/// USED BY: lib/main.dart
/// DEPENDENCIES:
/// - go_router
/// - AuthCubit (for role-based redirects)
/// - TenantRoutingService (for domain resolution)
/// ======================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_typography.dart';
import '../localization/localization_cubit.dart';
import '../../features/auth/controllers/auth_cubit.dart';
import '../../features/auth/controllers/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/dashboard/screens/dashboard_shell.dart';
import '../../features/home/screens/landymaker_home_screen.dart';
import '../../features/home/screens/template_picker_screen.dart';
import '../../features/home/screens/legal_page.dart';
import '../../features/public_viewer/screens/public_landing_page.dart';
import '../../features/builder/screens/builder_workspace_screen.dart';
import '../../features/builder/screens/guest_preview_screen.dart';
import '../../services/tenant_routing_service.dart';
import '../../features/dashboard/screens/dashboard_home_screen.dart';
import '../../features/dashboard/screens/leads_tracker_screen.dart';
import '../../features/dashboard/screens/analytics_screen.dart';
import '../../features/dashboard/screens/product_feed_screen.dart';
import '../../features/dashboard/screens/domain_settings_screen.dart';
import '../../features/dashboard/screens/media_gallery_screen.dart';
import '../../features/dashboard/screens/settings_screen.dart';
import '../../features/dashboard/screens/notifications_screen.dart';
import '../../features/super_admin/screens/super_admin_panel_screen.dart';
import '../../features/super_admin/screens/platform_seo_screen.dart';
import '../../features/super_admin/screens/homepage_editor_screen.dart';
import '../../features/super_admin/screens/user_profile_screen.dart';
import '../../features/blog_admin/screens/blog_management_screen.dart';
import '../../services/supabase_service.dart';
import '../../services/database_service.dart';
import '../../injection_container.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: sl<SupabaseService>(),
  redirect: (context, state) {
    final path = state.uri.path;

    // 1. Blog redirection
    if (path == '/blog' || path.startsWith('/blog/')) {
      final String url;
      if (kIsWeb) {
        final origin = Uri.base.origin;
        if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
          url = 'https://landymaker.com$path';
        } else {
          url = '$origin$path';
        }
      } else {
        url = 'https://landymaker.com$path';
      }
      launchUrl(
        Uri.parse(url),
        webOnlyWindowName: '_self',
      );
      return '/';
    }

    // 2. Auth Guards (Dashboard & Builder protection)
    final routeMode = TenantRoutingService.getRouteMode();
    if (routeMode == RouteMode.publicViewer) {
      return null;
    }

    final supabase = sl<SupabaseService>();
    final isLoggedIn = supabase.isAuthenticated;

    final isGoingToAuth = path == '/login' ||
        path == '/register' ||
        path == '/forgot-password' ||
        path == '/reset-password';
    final isGoingToDashboard = path.startsWith('/dashboard') || path.startsWith('/builder');

    if (isLoggedIn) {
      if (isGoingToAuth || path == '/') {
        return '/dashboard';
      }
    } else {
      if (isGoingToDashboard) {
        return '/login';
      }
    }

    return null;
  },
  errorBuilder: (context, state) {
    final loc = context.read<LocalizationCubit>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 24),
              Text(
                '404',
                style: AppTypography.h1.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 72),
              ),
              SizedBox(height: 8),
              Text(
                loc.translate('page_not_found'),
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                loc.translate('page_not_found_desc'),
                style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => context.go('/'),
                  );
                },
                icon: Icon(Icons.home_rounded),
                label: Text(loc.translate('back_to_home')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final routeMode = TenantRoutingService.getRouteMode();

        if (routeMode == RouteMode.publicViewer) {
          final identifier = TenantRoutingService.getTenantIdentifier();
          return PublicLandingPage(identifier: identifier);
        }

        return const LandyMakerHomeScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardShell(
          navigationShell: navigationShell,
          onLogout: () {
            context.read<AuthCubit>().logout();
          },
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => DashboardHomeScreen(
                onOpenBuilder: (pageId) => context.go('/builder/$pageId'),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/products',
              builder: (context, state) => const ProductFeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/leads',
              builder: (context, state) => const LeadsTrackerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/gallery',
              builder: (context, state) => const MediaGalleryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/feed',
              builder: (context, state) => const ProductFeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/domain',
              builder: (context, state) => const DomainSettingsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/super-admin',
              builder: (context, state) => const SuperAdminPanelScreen(),
              redirect: (context, state) {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated &&
                    authState.role == 'super_admin') {
                  return null; // allow
                }
                return '/dashboard'; // redirect
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/blog-admin',
              builder: (context, state) => const BlogManagementScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/platform-seo',
              builder: (context, state) => const PlatformSeoScreen(),
              redirect: (context, state) {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated &&
                    authState.role == 'super_admin') {
                  return null; // allow
                }
                return '/dashboard'; // redirect
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/homepage-editor',
              builder: (context, state) => BlocProvider(
                create: (_) => HomepageEditorCubit(sl<DatabaseService>()),
                child: const HomepageEditorScreen(),
              ),
              redirect: (context, state) {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated &&
                    authState.role == 'super_admin') {
                  return null; // allow
                }
                return '/dashboard'; // redirect
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard/super-admin/users/:userId',
              builder: (context, state) {
                final userId = state.pathParameters['userId'] ?? '';
                return UserProfileScreen(userId: userId);
              },
              redirect: (context, state) {
                final authState = context.read<AuthCubit>().state;
                if (authState is Authenticated &&
                    authState.role == 'super_admin') {
                  return null;
                }
                return '/dashboard';
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/templates',
      builder: (context, state) => const TemplatePickerScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const LegalPage(
        titleKey: 'about_us',
        contentKey: 'about_content',
        path: '/about',
      ),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const LegalPage(
        titleKey: 'privacy_policy',
        contentKey: 'privacy_policy_content',
        path: '/privacy-policy',
      ),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const LegalPage(
        titleKey: 'terms_of_service',
        contentKey: 'terms_content',
        path: '/terms',
      ),
    ),
    GoRoute(
      path: '/guest-preview',
      builder: (context, state) => const GuestPreviewScreen(),
    ),
    GoRoute(
      path: '/builder',
      redirect: (context, state) {
        // /builder without a pageId shows an empty workspace — redirect to dashboard instead
        if (state.uri.path == '/builder') return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: ':pageId',
          builder: (context, state) {
            final pageId = state.pathParameters['pageId'];
            return BuilderWorkspaceScreen(
              pageId: pageId,
              onBackToDashboard: () {
                context.go('/dashboard');
              },
            );
          },
        ),
      ],
    ),
    // Dynamic Landing Page Route (Catch-all)
    GoRoute(
      path: '/:pageName',
      builder: (context, state) {
        final pageName = state.pathParameters['pageName'];
        return PublicLandingPage(identifier: pageName);
      },
    ),
  ],
);
