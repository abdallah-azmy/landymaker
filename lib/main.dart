import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';
import 'core/localization/localization_cubit.dart';
import 'injection_container.dart';
import 'services/tenant_routing_service.dart';
import 'features/auth/controllers/auth_cubit.dart';
import 'features/auth/controllers/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_shell.dart';
import 'features/public_viewer/screens/public_landing_page.dart';
import 'features/builder/controllers/builder_cubit.dart';
import 'features/dashboard/controllers/leads_analytics_cubit.dart';
import 'features/super_admin/controllers/super_admin_cubit.dart';
import 'features/public_viewer/controllers/public_page_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies via GetIt Service Locator
  // (Supabase init is handled inside initDependencies)
  await initDependencies();

  runApp(const MyLandyApp());
}

class MyLandyApp extends StatelessWidget {
  const MyLandyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Singleton — shared app-wide locale instance
        BlocProvider<LocalizationCubit>(create: (_) => sl<LocalizationCubit>()),
        // Factory — fresh cubit per session, constructor-injected AuthService
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        // Factory — constructor-injected DatabaseService + StorageService
        BlocProvider<LandingPageBuilderCubit>(
          create: (_) => sl<LandingPageBuilderCubit>(),
        ),
        // Factory — constructor-injected DatabaseService
        BlocProvider<LeadsAnalyticsCubit>(
          create: (_) => sl<LeadsAnalyticsCubit>(),
        ),
        // Factory — constructor-injected DatabaseService for Super Admin
        BlocProvider<SuperAdminCubit>(create: (_) => sl<SuperAdminCubit>()),
        // Factory — constructor-injected DatabaseService and LeadsAnalyticsCubit for Public viewer
        BlocProvider<PublicPageCubit>(create: (_) => sl<PublicPageCubit>()),
      ],
      child: BlocBuilder<LocalizationCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'MyLandy',
            debugShowCheckedModeBanner: false,

            // Locale Configurations
            locale: locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Theme specifications
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.cardBg,
                error: AppColors.dangerRed,
              ),
            ),

            // Dynamic Routing entry
            home: const RootTenantRouter(),
          );
        },
      ),
    );
  }
}

class RootTenantRouter extends StatelessWidget {
  const RootTenantRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final routeMode = TenantRoutingService.getRouteMode();

    if (routeMode == RouteMode.publicViewer) {
      return const PublicLandingPage();
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

        return LoginScreen(
          onLoginSuccess: () {
            // State automatically changes to Authenticated, rebuilding routing
          },
        );
      },
    );
  }
}

//* flutter run -d chrome --dart-define=SUPABASE_URL=رابط_مشروعك --dart-define=SUPABASE_ANON_KEY=مفتاحك
