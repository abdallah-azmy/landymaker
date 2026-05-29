import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../core/constants/db_constants.dart';
import '../core/error_handler.dart';
import '../core/logger.dart';
import '../core/dio_http_client_adapter.dart';
import '../core/http_client.dart';

/// Singleton service wrapping Supabase with Supabase SDK
class SupabaseService extends ChangeNotifier {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _client;

  // Track currently authenticated user info
  String? _currentUserEmail;
  String? _currentUserId;
  String _currentUserRole = 'user'; // 'user' or 'super_admin'

  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserId => _currentUserId;
  String get currentUserRole => _currentUserRole;
  bool get isAuthenticated => _currentUserId != null;

  // ─────────────────────────────────────────────────────────────────────────
  // ⚠️  SECURITY NOTE — READ BEFORE SHIPPING
  //
  // The credentials below use `kDebugMode` fallbacks so that local `flutter
  // run` works without extra flags during development. These defaults are
  // intentionally NEVER compiled into release builds:
  //
  //   • `flutter run --release` ignores kDebugMode defaults → credentials
  //     MUST be supplied via --dart-define or CI environment variables.
  //   • `flutter build web --release` likewise requires --dart-define.
  //
  // 🔒 FUTURE TODO: Move these to a secrets manager (e.g. GitHub Secrets,
  //    Vercel environment variables) and rotate the anon key if it has been
  //    committed to a public repo previously.
  //
  // Run command (development):
  //   flutter run -d chrome \
  //     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  //     --dart-define=SUPABASE_ANON_KEY=eyJ...
  // ─────────────────────────────────────────────────────────────────────────

  static final String supabaseUrl = const String.fromEnvironment('SUPABASE_URL').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_URL')
      : kDebugMode
          ? 'https://zajcnkpcdsvswfmsmqpt.supabase.co' // ⚠️ DEBUG ONLY — not compiled into release
          : '';

  static final String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
      ? const String.fromEnvironment('SUPABASE_ANON_KEY')
      : kDebugMode
          ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphamNua3BjZHN2c3dmbXNtcXB0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzNTgzMDMsImV4cCI6MjA5NDkzNDMwM30.oreTJAHB33FcTkJutIlLxgiPj-rERVFfB7n2pnzPj4w' // ⚠️ DEBUG ONLY
          : '';

  /// Initialize Supabase Flutter Client
  Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        "Supabase credentials are missing. Please provide SUPABASE_URL and SUPABASE_ANON_KEY.",
      );
    }

    try {
      // Get the configured Dio instance (with PrettyDioLogger)
      final dio = await DioFactory.getDio();

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
        // Wrap Dio into the adapter to be used as Supabase's client
        httpClient: DioHttpClientAdapter(dio),
      );
      _client = Supabase.instance.client;

      Logger.info('Supabase initialized successfully');

      // Check current session
      final session = _client!.auth.currentSession;
      if (session != null) {
        _currentUserId = session.user.id;
        _currentUserEmail = session.user.email;
        await _fetchUserRole(session.user.id);
      }

      // Listen to auth state updates to handle updates reactively
      _client!.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null) {
          _currentUserId = session.user.id;
          _currentUserEmail = session.user.email;
          await _fetchUserRole(session.user.id);
        } else {
          _currentUserId = null;
          _currentUserEmail = null;
          _currentUserRole = 'user';
        }
        notifyListeners();
      });
    } catch (e) {
      Logger.error(
        "Failed to initialize Supabase.",
        e,
        StackTrace.current,
      );
      rethrow;
    }
  }

  // Fetch the role of authenticated user from profiles table
  Future<void> _fetchUserRole(String userId) async {
    try {
      final response = await _client!
          .from(DbConstants.profilesTable)
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (response != null) {
        _currentUserRole = response['role'] as String;
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
  }

  // ----------------------------------------------------
  // AUTHENTICATION OPERATIONS
  // ----------------------------------------------------

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );
      if (response.user != null) {
        _currentUserId = response.user!.id;
        _currentUserEmail = response.user!.email;
        _currentUserRole = role;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register exception: $e');
      rethrow;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _currentUserId = response.user!.id;
        _currentUserEmail = response.user!.email;
        await _fetchUserRole(response.user!.id);
        notifyListeners();
        return true;
      }
      debugPrint('Login failed: no user returned');
      return false;
    } catch (e) {
      debugPrint('Login exception: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _client!.auth.signOut();
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserRole = 'user';
    notifyListeners();
  }

  // ----------------------------------------------------
  // LANDING PAGES OPERATIONS
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> getLandingPagesByUserId(String userId) async {
    try {
      final response = await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching landing pages for user ID: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLandingPageByUserId(String userId) async {
    try {
      final pages = await getLandingPagesByUserId(userId);
      return pages.isNotEmpty ? pages.first : null;
    } catch (e) {
      debugPrint("Error fetching default landing page: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLandingPageById(String pageId) async {
    try {
      return await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .eq('id', pageId)
          .maybeSingle();
    } catch (e) {
      debugPrint("Error fetching landing page by ID: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLandingPageByDomain(
    String domain, {
    bool isCustom = false,
  }) async {
    try {
      final column = isCustom ? 'custom_domain' : 'subdomain';
      return await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .eq(column, domain)
          .eq('is_published', true)
          .maybeSingle();
    } catch (e) {
      debugPrint("Error fetching landing page by domain/subdomain: $e");
      return null;
    }
  }

  /// Saves the landing page and returns the page ID (whether existing or newly created).
  /// On INSERT, the ID is returned directly from Supabase (no second round-trip needed).
  Future<String?> saveLandingPage({
    required String userId,
    required String subdomain,
    String? customDomain,
    required Map<String, dynamic> designMap,
    required bool isPublished,
    String? pageId,
  }) async {
    final effectiveCustomDomain =
        customDomain == null || customDomain.trim().isEmpty
        ? null
        : customDomain.trim();

    try {
      if (pageId != null) {
        await _client!
            .from(DbConstants.landingPagesTable)
            .update({
              'subdomain': subdomain,
              'custom_domain': effectiveCustomDomain,
              'design_json': jsonEncode(designMap),
              'is_published': isPublished,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', pageId);
        return pageId; // existing ID unchanged
      } else {
        // INSERT and retrieve the newly generated ID in one round-trip
        final result = await _client!
            .from(DbConstants.landingPagesTable)
            .insert({
              'user_id': userId,
              'subdomain': subdomain,
              'custom_domain': effectiveCustomDomain,
              'design_json': jsonEncode(designMap),
              'is_published': isPublished,
            })
            .select('id')
            .single();
        return result['id'] as String?;
      }
    } catch (e) {
      debugPrint("Error saving landing page config: $e");
      rethrow;
    }
  }

  // ----------------------------------------------------
  // LEADS CAPTURE OPERATIONS
  // ----------------------------------------------------

  Future<bool> submitLead({
    required String landingPageId,
    required Map<String, dynamic> formData,
  }) async {
    try {
      await _client!.from(DbConstants.leadsTable).insert({
        'landing_page_id': landingPageId,
        'form_data': formData,
      });
      await recordAnalyticsEvent(
        landingPageId: landingPageId,
        eventType: 'conversion',
      );
      return true;
    } catch (e) {
      debugPrint("Error submitting lead form: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLeadsByLandingPage(
    String landingPageId,
  ) async {
    try {
      final response = await _client!
          .from(DbConstants.leadsTable)
          .select()
          .eq('landing_page_id', landingPageId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error retrieving page leads: $e");
      return [];
    }
  }

  // ----------------------------------------------------
  // ANALYTICS & STATS OPERATIONS
  // ----------------------------------------------------

  Future<void> recordAnalyticsEvent({
    required String landingPageId,
    required String eventType,
  }) async {
    try {
      await _client!.from(DbConstants.analyticsTable).insert({
        'landing_page_id': landingPageId,
        'event_type': eventType,
      });
    } catch (e) {
      debugPrint("Error recording analytics event: $e");
    }
  }

  Future<Map<String, int>> getPageAnalyticsStats(String landingPageId) async {
    try {
      final viewsResponse = await _client!
          .from(DbConstants.analyticsTable)
          .select('id')
          .eq('landing_page_id', landingPageId)
          .eq('event_type', 'view');
      final conversionsResponse = await _client!
          .from(DbConstants.analyticsTable)
          .select('id')
          .eq('landing_page_id', landingPageId)
          .eq('event_type', 'conversion');

      return {
        'views': viewsResponse.length,
        'conversions': conversionsResponse.length,
      };
    } catch (e) {
      debugPrint("Error fetching analytics stats: $e");
      return {'views': 0, 'conversions': 0};
    }
  }

  // ----------------------------------------------------
  // STORAGE IMAGE UPLOADS
  // ----------------------------------------------------

  Future<String?> uploadImage(PlatformFile file) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception("User session not found. Please login again.");
      }

      // Check current quota (maximum 5 uploads per user)
      final existingFiles = await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .list(path: userId);
      if (existingFiles.length >= 5) {
        throw Exception("لقد وصلت للحد الأقصى للرفع (5 صور). يرجى حذف بعض الملفات لتتمكن من رفع صور جديدة.");
      }

      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception("File data is missing. Unexpected null value.");
      }

      final fileExtension = file.name.split('.').last;
      final filePath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .uploadBinary(filePath, bytes);

      return _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .getPublicUrl(filePath);
    } catch (e, stack) {
      ErrorHandler.logError("Error uploading image", e, stack);
      rethrow;
    }
  }

  // ----------------------------------------------------
  // SUPER ADMIN METRICS
  // ----------------------------------------------------

  Future<Map<String, dynamic>> getSuperAdminMetrics() async {
    try {
      final usersRes = await _client!
          .from(DbConstants.profilesTable)
          .select('id');
      final pagesRes = await _client!
          .from(DbConstants.landingPagesTable)
          .select('id')
          .eq('is_published', true);
      final leadsRes = await _client!.from(DbConstants.leadsTable).select('id');

      return {
        'total_users': usersRes.length,
        'active_pages': pagesRes.length,
        'total_leads': leadsRes.length,
      };
    } catch (e) {
      debugPrint("Error fetching super admin metrics: $e");
      return {'total_users': 0, 'active_pages': 0, 'total_leads': 0};
    }
  }
}
