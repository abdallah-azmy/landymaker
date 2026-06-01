import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/controllers/auth_cubit.dart';
import '../../features/auth/controllers/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_shell.dart';
import '../../features/home/screens/landymaker_home_screen.dart';
import '../../features/public_viewer/screens/public_landing_page.dart';
import '../../features/builder/screens/builder_workspace_screen.dart';
import '../../services/tenant_routing_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
              return DashboardShell(
                onLogout: () {
                  context.read<AuthCubit>().logout();
                },
              );
            }
            return const LandyMakerHomeScreen();
          },
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/builder',
      builder: (context, state) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BuilderWorkspaceScreen(
                onBackToDashboard: () {
                  context.go('/');
                },
              );
            }
            return const LoginScreen();
          },
        );
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
