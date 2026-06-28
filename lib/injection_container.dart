/// Dependency injection root for the entire application.
///
/// **Responsibility**: Registers all services, cubits, and repositories with
/// `GetIt` before the app runs. Must be called once at startup.
/// **Used by**: `main.dart`
/// **Key state**: `sl` (the `GetIt` singleton) holds every registered dependency.
/// **⚠️ AI Warning**: Do NOT change registration order (supabase → services → cubits).
/// Do NOT add `BuildContext`-dependent registrations here — use `context.read()` or
/// `BlocProvider` in the widget tree instead.
import 'package:get_it/get_it.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/database_service.dart';
import 'services/subscription_service.dart';
import 'services/image_media_service.dart';
import 'core/localization/localization_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/particles/cube_mode_cubit.dart';
import 'core/http_client.dart';
import 'features/auth/controllers/auth_cubit.dart';
import 'features/builder/controllers/builder_cubit.dart';
import 'features/builder/controllers/builder_theme_cubit.dart';
import 'features/dashboard/controllers/leads_analytics_cubit.dart';
import 'features/dashboard/controllers/landing_pages_cubit.dart';
import 'features/dashboard/controllers/active_website_cubit.dart';
import 'features/dashboard/controllers/media_gallery_cubit.dart';
import 'features/super_admin/controllers/super_admin_cubit.dart';
import 'features/public_viewer/controllers/public_page_cubit.dart';
import 'features/blog_admin/data/repositories/blog_repository.dart';
import 'features/blog_admin/controllers/blog_cubit.dart';

import 'features/builder/controllers/ai_generation_cubit.dart';
import 'features/builder/controllers/pixabay_selector_cubit.dart';
import 'features/builder/controllers/upload_manager_cubit.dart';

/// The global service locator instance.
///
/// **Used by**: Every file that needs DI access via `sl<T>()`
/// **⚠️ AI Warning**: Prefer `context.read()` in widgets; use `sl` only in
/// non-widget code (services, repositories, cubit constructors).
final sl = GetIt.instance;

/// Initializes all application dependencies.
///
/// Called once from `main.dart` before `runApp()`. Registers:
/// 1. HTTP client (Dio)
/// 2. Supabase service (singleton, initialized first)
/// 3. Child services (Auth, Storage, Database, Subscription, ImageMedia)
/// 4. Global cubits (Theme, CubeMode, Localization, ActiveWebsite)
/// 5. Feature cubits (Auth, Builder, Dashboard, SuperAdmin, Blog, PublicPage)
///
/// Side effects: HTTP calls to Supabase, Dio initialization, service initialization.
///
/// **⚠️ AI Warning**: Do NOT call this more than once. Order matters — supabase
/// must be registered before dependent services.
Future<void> initDependencies() async {
  // 1. Initialize HTTP Client with Dio + PrettyDioLogger
  await DioFactory.getDio();

  // 2. Core Services / External
  final supabaseService = SupabaseService.instance;
  await supabaseService.initialize();
  sl.registerSingleton<SupabaseService>(supabaseService);

  // 3. Child Supabase Services (Registered as Singletons)
  sl.registerSingleton<AuthService>(AuthService(sl<SupabaseService>()));
  sl.registerSingleton<StorageService>(StorageService(sl<SupabaseService>()));
  sl.registerSingleton<DatabaseService>(DatabaseService(sl<SupabaseService>()));
  sl.registerSingleton<SubscriptionService>(SubscriptionService(sl<DatabaseService>()));
  sl.registerSingleton<ImageMediaService>(ImageMediaService());

  sl.registerLazySingleton<UploadManagerCubit>(() => UploadManagerCubit(mediaService: sl<ImageMediaService>()));
  sl.registerFactory<PixabaySelectorCubit>(() => PixabaySelectorCubit(sl<ImageMediaService>()));
  sl.registerFactory<AIGenerationCubit>(() => AIGenerationCubit(sl<SupabaseService>(), sl<LandingPageBuilderCubit>()));

  // 4. Global Cubits / State Managers (Registered as Singletons / Factories)
  sl.registerSingleton<ThemeCubit>(ThemeCubit());
  sl.registerSingleton<CubeModeCubit>(CubeModeCubit());
  sl.registerSingleton<LocalizationCubit>(LocalizationCubit());
  sl.registerSingleton<ActiveWebsiteCubit>(ActiveWebsiteCubit());
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthService>()));
  sl.registerFactory<BuilderThemeCubit>(() => BuilderThemeCubit());
  sl.registerFactory<LandingPageBuilderCubit>(
    () => LandingPageBuilderCubit(
      authService: sl<AuthService>(),
      databaseService: sl<DatabaseService>(),
      storageService: sl<StorageService>(),
      subscriptionService: sl<SubscriptionService>(),
      themeCubit: sl<BuilderThemeCubit>(),
    ),
  );
  sl.registerFactory<LandingPagesCubit>(
    () => LandingPagesCubit(
      databaseService: sl<DatabaseService>(),
      authService: sl<AuthService>(),
      subscriptionService: sl<SubscriptionService>(),
    ),
  );
  sl.registerFactory<LeadsAnalyticsCubit>(
    () => LeadsAnalyticsCubit(
      authService: sl<AuthService>(),
      databaseService: sl<DatabaseService>(),
    ),
  );
  sl.registerFactory<MediaGalleryCubit>(
    () => MediaGalleryCubit(storageService: sl<StorageService>()),
  );
  sl.registerFactory<SuperAdminCubit>(
    () => SuperAdminCubit(databaseService: sl<DatabaseService>()),
  );
  sl.registerSingleton<BlogRepository>(BlogRepository(sl<SupabaseService>().client));
  sl.registerFactory<BlogCubit>(() => BlogCubit(sl<BlogRepository>()));
  sl.registerFactory<PublicPageCubit>(
    () => PublicPageCubit(
      databaseService: sl<DatabaseService>(),
      leadsAnalyticsCubit: sl<LeadsAnalyticsCubit>(),
    ),
  );
}
