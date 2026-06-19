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

final sl = GetIt.instance;

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
  // Theme: App-wide light/dark mode toggle
  sl.registerSingleton<ThemeCubit>(ThemeCubit());

  // Cube Mode: Standard floating cubes vs. merge/cluster mode
  sl.registerSingleton<CubeModeCubit>(CubeModeCubit());

  // Localization: App-wide language toggle persists globally
  sl.registerSingleton<LocalizationCubit>(LocalizationCubit());

  // Active Website: Tracks which site the user is currently managing
  sl.registerSingleton<ActiveWebsiteCubit>(ActiveWebsiteCubit());

  // Auth: Governs user profile status
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthService>()));

  // Builder Theme: Owns LandingPageTheme separately from the main builder cubit
  sl.registerFactory<BuilderThemeCubit>(() => BuilderThemeCubit());

  // Builder: Section layout configuration sessions
  sl.registerFactory<LandingPageBuilderCubit>(
    () => LandingPageBuilderCubit(
      authService: sl<AuthService>(),
      databaseService: sl<DatabaseService>(),
      storageService: sl<StorageService>(),
      subscriptionService: sl<SubscriptionService>(),
      themeCubit: sl<BuilderThemeCubit>(),
    ),
  );

  // Page Listing Manager
  sl.registerFactory<LandingPagesCubit>(
    () => LandingPagesCubit(
      databaseService: sl<DatabaseService>(),
      authService: sl<AuthService>(),
      subscriptionService: sl<SubscriptionService>(),
    ),
  );

  // Leads & Analytics Tracker
  sl.registerFactory<LeadsAnalyticsCubit>(
    () => LeadsAnalyticsCubit(
      authService: sl<AuthService>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  // Media Gallery Manager
  sl.registerFactory<MediaGalleryCubit>(
    () => MediaGalleryCubit(storageService: sl<StorageService>()),
  );

  // Super Admin panel cubit
  sl.registerFactory<SuperAdminCubit>(
    () => SuperAdminCubit(databaseService: sl<DatabaseService>()),
  );

  // Blog Admin
  sl.registerSingleton<BlogRepository>(BlogRepository(sl<SupabaseService>().client));
  sl.registerFactory<BlogCubit>(() => BlogCubit(sl<BlogRepository>()));

  // Public Landing Page cubit
  sl.registerFactory<PublicPageCubit>(
    () => PublicPageCubit(
      databaseService: sl<DatabaseService>(),
      leadsAnalyticsCubit: sl<LeadsAnalyticsCubit>(),
    ),
  );
}
