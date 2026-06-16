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
import '../theme/app_colors.dart';
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
import '../../features/super_admin/screens/super_admin_panel_screen.dart';
import '../../features/super_admin/screens/platform_seo_screen.dart';
import '../../features/blog_admin/screens/blog_management_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) {
    final loc = context.read<LocalizationCubit>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link_off_rounded, size: 72, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                '404',
                style: AppTypography.h1.copyWith(color: AppColors.primary, fontSize: 72),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('page_not_found'),
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                loc.translate('page_not_found_desc'),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => context.go('/'),
                  );
                },
                icon: const Icon(Icons.home_rounded),
                label: Text(loc.translate('back_to_home')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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

        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              // Wait for a frame to go to dashboard to avoid build-phase navigation errors
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/dashboard');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return const LandyMakerHomeScreen();
          },
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return DashboardShell(
                navigationShell: navigationShell,
                onLogout: () {
                  context.read<AuthCubit>().logout();
                },
              );
            }
            // If somehow unauthenticated here, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => DashboardHomeScreen(
                onOpenBuilder: (pageId) => context.push('/builder/$pageId'),
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
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  return BuilderWorkspaceScreen(
                    pageId: pageId,
                    onBackToDashboard: () {
                      context.go('/');
                    },
                  );
                }
                return const LoginScreen();
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
