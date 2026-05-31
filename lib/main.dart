import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme/app_colors.dart';
import 'core/localization/localization_cubit.dart';
import 'core/router/app_router.dart';
import 'injection_container.dart';
import 'features/auth/controllers/auth_cubit.dart';
import 'features/builder/controllers/builder_cubit.dart';
import 'features/dashboard/controllers/leads_analytics_cubit.dart';
import 'features/dashboard/controllers/landing_pages_cubit.dart';
import 'features/super_admin/controllers/super_admin_cubit.dart';
import 'features/public_viewer/controllers/public_page_cubit.dart';

import 'features/dashboard/controllers/active_website_cubit.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    // Initialize all dependencies via GetIt Service Locator
    await initDependencies();

    runApp(const LandyMakerApp());
  } catch (e) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your Supabase configuration.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class LandyMakerApp extends StatelessWidget {
  const LandyMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationCubit>(create: (_) => sl<LocalizationCubit>()),
        BlocProvider<ActiveWebsiteCubit>(create: (_) => sl<ActiveWebsiteCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<LandingPageBuilderCubit>(
          create: (_) => sl<LandingPageBuilderCubit>(),
        ),
        BlocProvider<LandingPagesCubit>(
          create: (_) => sl<LandingPagesCubit>(),
        ),
        BlocProvider<LeadsAnalyticsCubit>(
          create: (_) => sl<LeadsAnalyticsCubit>(),
        ),
        BlocProvider<SuperAdminCubit>(create: (_) => sl<SuperAdminCubit>()),
        BlocProvider<PublicPageCubit>(create: (_) => sl<PublicPageCubit>()),
      ],
      child: BlocBuilder<LocalizationCubit, Locale>(
        builder: (context, locale) {
          return ToastificationWrapper(
            child: MaterialApp.router(
              title: 'LandyMaker',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,

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
                cardTheme: CardThemeData(
                  color: AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  secondary: AppColors.secondary,
                  surface: AppColors.cardBg,
                  error: AppColors.dangerRed,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//* flutter run -d chrome --dart-define=SUPABASE_URL=رابط_مشروعك --dart-define=SUPABASE_ANON_KEY=مفتاحك

/**
 * 🚀 SPEC-KIT PROJECT GUIDELINES (github.com/github/spec-kit)
 * Use these commands to maintain consistency and prevent AI hallucinations:
 * 
 * 1. /speckit.specify   - Define human intent, user journeys, and "The What".
 * 2. /speckit.plan      - Generate technical blueprint, architecture, and "The How".
 * 3. /speckit.tasks     - Break down the plan into a granular, actionable checklist.
 * 4. /speckit.implement - Execute tasks one by one based on the approved spec/plan.
 * 
 * Rules for this project:
 * - NEVER build a widget from scratch if a custom widget already exists (check lib/core/widgets/ or lib/features/public_viewer/widgets/).
 * - ALWAYS maintain the "Source of Truth" in the Bloc/Cubit states.
 * - Mobile-first design for the Builder Workspace is mandatory.
 * - Always use SectionRenderer for any block-based preview to ensure 1:1 consistency.
 */
