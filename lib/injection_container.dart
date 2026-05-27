import 'package:get_it/get_it.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/database_service.dart';
import 'core/localization/localization_cubit.dart';
import 'core/http_client.dart';
import 'features/auth/controllers/auth_cubit.dart';
import 'features/builder/controllers/builder_cubit.dart';
import 'features/dashboard/controllers/leads_analytics_cubit.dart';
import 'features/super_admin/controllers/super_admin_cubit.dart';
import 'features/public_viewer/controllers/public_page_cubit.dart';

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

  // 4. Global Cubits / State Managers (Registered as Singletons / Factories)
  // Localization: App-wide language toggle persists globally
  sl.registerSingleton<LocalizationCubit>(LocalizationCubit());

  // Auth: Governs user profile status
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthService>()));

  // Builder: Section layout configuration sessions
  sl.registerFactory<LandingPageBuilderCubit>(
    () => LandingPageBuilderCubit(
      authService: sl<AuthService>(),
      databaseService: sl<DatabaseService>(),
      storageService: sl<StorageService>(),
    ),
  );

  // Leads & Analytics Tracker
  sl.registerFactory<LeadsAnalyticsCubit>(
    () => LeadsAnalyticsCubit(
      authService: sl<AuthService>(),
      databaseService: sl<DatabaseService>(),
    ),
  );

  // Super Admin panel cubit
  sl.registerFactory<SuperAdminCubit>(
    () => SuperAdminCubit(databaseService: sl<DatabaseService>()),
  );

  // Public Landing Page cubit
  sl.registerFactory<PublicPageCubit>(
    () => PublicPageCubit(
      databaseService: sl<DatabaseService>(),
      leadsAnalyticsCubit: sl<LeadsAnalyticsCubit>(),
    ),
  );
}
