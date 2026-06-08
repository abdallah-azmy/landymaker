import 'package:flutter/foundation.dart';
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
import 'features/dashboard/controllers/media_gallery_cubit.dart';
import 'features/super_admin/controllers/super_admin_cubit.dart';
import 'features/public_viewer/controllers/public_page_cubit.dart';
import 'features/blog_admin/controllers/blog_cubit.dart';

import 'features/dashboard/controllers/active_website_cubit.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/seo/app_seo.dart';
import 'core/services/fcm_service.dart';
import 'services/tenant_routing_service.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    // Initialize SEO
    AppSEO.config();
    // Preload primary font to prevent FOUT/FOIT (Tofu effect) on web globally
    GoogleFonts.config.allowRuntimeFetching = true;
    GoogleFonts.cairo();
    await GoogleFonts.pendingFonts();

    // Initialize all dependencies via GetIt Service Locator
    await initDependencies();

    // Initialize FCM (Web Push) - ONLY if not in public viewer mode
    if (kIsWeb) {
      final routeMode = TenantRoutingService.getRouteMode();
      if (routeMode != RouteMode.publicViewer) {
        await FcmService.initialize();
      }
    }

    runApp(const LandyMakerApp());
  } catch (e) {
    runApp(
      MaterialApp(
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
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
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
      ),
    );
  }
}

class LandyMakerApp extends StatelessWidget {
  const LandyMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationCubit>(create: (_) => sl<LocalizationCubit>()),
        BlocProvider<ActiveWebsiteCubit>(
          create: (_) => sl<ActiveWebsiteCubit>(),
        ),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<LandingPageBuilderCubit>(
          create: (_) => sl<LandingPageBuilderCubit>(),
        ),
        BlocProvider<LandingPagesCubit>(create: (_) => sl<LandingPagesCubit>()),
        BlocProvider<LeadsAnalyticsCubit>(
          create: (_) => sl<LeadsAnalyticsCubit>(),
        ),
        BlocProvider<MediaGalleryCubit>(
          create: (_) => sl<MediaGalleryCubit>(),
        ),
        BlocProvider<SuperAdminCubit>(create: (_) => sl<SuperAdminCubit>()),
        BlocProvider<PublicPageCubit>(create: (_) => sl<PublicPageCubit>()),
        BlocProvider<BlogCubit>(create: (_) => sl<BlogCubit>()),
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
                quill.FlutterQuillLocalizations.delegate,
              ],

              // Theme specifications
              theme: ThemeData(
                fontFamily: GoogleFonts.cairo().fontFamily,
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

//* Debug
// flutter run -d chrome --dart-define-from-file=.env.local
//* Production Build
// flutter build web --release --dart-define-from-file=.env.local

//* locale host
// http://localhost:3000
