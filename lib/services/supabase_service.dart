/// ======================================================
/// SERVICE: Supabase Adapter
/// PURPOSE: Primary entry point for Supabase SDK interactions
/// USED BY: Global Service Layer
/// DEPENDENCIES:
/// - supabase_flutter
/// - EnvUtils
/// ======================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/db_constants.dart';
import '../core/error_handler.dart';
import '../core/logger.dart';
import '../core/dio_http_client_adapter.dart';
import '../core/http_client.dart';
import '../core/utils/env_utils.dart';
import '../core/utils/fingerprint_utils.dart';

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
  SupabaseClient get client => _client!;

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

  static final String supabaseUrl = EnvUtils.supabaseUrl;
  static final String supabaseAnonKey = EnvUtils.supabaseAnonKey;

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
  }) async {
    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'user'},
      );
      if (response.user != null) {
        _currentUserId = response.user!.id;
        _currentUserEmail = response.user!.email;
        _currentUserRole = 'user';
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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final redirectTo = '${Uri.base.origin}/reset-password';
      await _client!.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } catch (e) {
      debugPrint('Reset password email exception: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client!.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Update password exception: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.landymaker.app://login-callback',
      );
    } catch (e) {
      debugPrint('Google Sign In exception: $e');
      rethrow;
    }
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
          .order('updated_at', ascending: false);
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
    bool publishedOnly = true,
  }) async {
    try {
      final column = isCustom ? 'custom_domain' : 'subdomain';
      var query = _client!
          .from(DbConstants.landingPagesTable)
          .select('*, profiles(tier)')
          .eq(column, domain);

      if (publishedOnly) {
        query = query.eq('is_published', true);
      }

      final res = await query.maybeSingle();

      if (res != null) {
        final tier = res['profiles']?['tier'] ?? 'free';

        // Security Guard: Only Pro/Enterprise can use custom domains
        if (isCustom && tier == 'free') {
          debugPrint("Access denied: Custom domain accessed on free tier.");
          return null;
        }

        // SPEC 2: Lifetime Expiry Policy
        final lastVisited = DateTime.parse(res['last_visited_at'] ?? res['created_at']);
        
        if (tier == 'free' && DateTime.now().difference(lastVisited).inDays > 30) {
          // Auto-suspend inactive free pages
          return {...res, 'is_active': false};
        }
        
        return res;
      }
      return null;
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
    String? websiteType,
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
              'website_type': websiteType ?? 'landing_page',
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
              'website_type': websiteType ?? 'landing_page',
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

  Future<void> updatePagePublishStatus(String pageId, bool isPublished) async {
    try {
      await _client!
          .from(DbConstants.landingPagesTable)
          .update({'is_published': isPublished})
          .eq('id', pageId);
    } catch (e) {
      debugPrint("Error updating page publish status: $e");
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
      final response = await _client!.functions.invoke(
        'lead-submit',
        body: {
          'landing_page_id': landingPageId,
          'form_data': formData,
        },
      );

      if (response.status == 200) {
        return true;
      } else {
        final error = response.data?['error'] ?? 'Failed to submit lead';
        debugPrint("Edge Function error: \$error");
        return false;
      }
    } catch (e) {
      debugPrint("Error submitting lead via Edge Function: \$e");
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
      if (eventType == 'view') {
        final fingerprint = FingerprintUtils.getFingerprint();
        await _client!.rpc('increment_page_view', params: {
          'page_id': landingPageId,
          'fingerprint': fingerprint,
        });
      } else {
        await _client!.from('analytics').insert({
          'landing_page_id': landingPageId,
          'event_type': eventType,
        });
      }
    } catch (e) {
      debugPrint("Error recording analytics event: \$e");
    }
  }

  Future<Map<String, int>> getPageAnalyticsStats(String landingPageId) async {
    try {
      final res = await _client!.rpc('get_enhanced_page_stats', params: {'page_id': landingPageId});
      
      return {
        'views': res['total_views'] ?? 0,
        'unique_visitors': res['unique_visitors'] ?? 0,
        'conversions': res['total_conversions'] ?? 0,
      };
    } catch (e) {
      debugPrint("Error fetching analytics stats: \$e");
      return {'views': 0, 'unique_visitors': 0, 'conversions': 0};
    }
  }

  // ----------------------------------------------------
  // STORAGE IMAGE UPLOADS & MANAGEMENT
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> listUserImages() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final List<FileObject> files = await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .list(path: userId);

      return files.map((f) {
        final publicUrl = _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .getPublicUrl('$userId/${f.name}');
        
        return {
          'name': f.name,
          'id': f.id,
          'url': publicUrl,
          'size': f.metadata?['size'],
          'created_at': f.createdAt,
        };
      }).toList();
    } catch (e) {
      debugPrint("Error listing user images: $e");
      return [];
    }
  }

  Future<void> deleteImage(String fileName) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .remove(['$userId/$fileName']);
    } catch (e) {
      debugPrint("Error deleting image: $e");
      rethrow;
    }
  }

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
  // SUPER ADMIN OPERATIONS (REAL DATA)
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    try {
      final res = await _client!.from(DbConstants.profilesTable).select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin users: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAdminPages() async {
    try {
      final res = await _client!.from(DbConstants.landingPagesTable).select('*, profiles(full_name, email)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin pages: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAdminSubscriptionRequests() async {
    try {
      final res = await _client!.from('subscription_requests').select('*, profiles(full_name, email)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin subscription requests: $e");
      return [];
    }
  }

  Future<void> updateSubscriptionStatus(String id, String status) async {
    try {
      await _client!.from('subscription_requests').update({'status': status}).eq('id', id);
    } catch (e) {
      debugPrint("Error updating subscription status: $e");
      rethrow;
    }
  }

  Future<void> updateCustomDomain(String pageId, String? domain) async {
    try {
      await _client!.from(DbConstants.landingPagesTable).update({
        'custom_domain': domain,
        'domain_status': 'pending',
      }).eq('id', pageId);
    } catch (e) {
      debugPrint("Error updating custom domain: $e");
      rethrow;
    }
  }

  Future<String> refreshDomainVerificationToken(String pageId) async {
    try {
      final res = await _client!.rpc('refresh_domain_verification_token', params: {'page_id': pageId});
      return res as String;
    } catch (e) {
      debugPrint("Error refreshing domain token: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyCustomDomain(String pageId, {String? previousDomain, String action = 'verify'}) async {
    try {
      final res = await _client!.functions.invoke('verify-custom-domain', body: {
        'page_id': pageId,
        'previous_domain': previousDomain,
        'action': action,
      });
      return res.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error invoking domain verification: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAdminAffiliates() async {
    try {
      final res = await _client!.from('affiliate_profiles').select('*, profiles(full_name, email)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin affiliates: \$e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getAdminGlobalStats() async {
    try {
      final pagesRes = await _client!.from(DbConstants.landingPagesTable).select('views_count, purchases_count');
      
      int totalViews = 0;
      int totalPurchases = 0;
      
      for (var p in pagesRes) {
        totalViews += (p['views_count'] as int? ?? 0);
        totalPurchases += (p['purchases_count'] as int? ?? 0);
      }

      final logsRes = await _client!.from('page_analytics_logs').select().order('created_at', ascending: false).limit(100);

      return {
        'total_views': totalViews,
        'total_purchases': totalPurchases,
        'recent_logs': List<Map<String, dynamic>>.from(logsRes),
      };
    } catch (e) {
      debugPrint("Error fetching admin global stats: $e");
      return {'total_views': 0, 'total_purchases': 0, 'recent_logs': []};
    }
  }

  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final res = await _client!.from('subscription_plans').select().order('monthly_price', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching subscription plans: $e");
      return [];
    }
  }

  Future<Map<String, int>> getSystemSecurityLimits() async {
    try {
      final res = await _client!.from('system_security_limits').select('key, value_int');
      final Map<String, int> limits = {};
      for (var item in res) {
        limits[item['key']] = item['value_int'];
      }
      return limits;
    } catch (e) {
      debugPrint("Error fetching security limits: $e");
      return {};
    }
  }

  Future<void> updateSubscriptionPlan(String id, Map<String, dynamic> data) async {
    try {
      await _client!.from('subscription_plans').update(data).eq('id', id);
    } catch (e) {
      debugPrint("Error updating subscription plan: $e");
      rethrow;
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client!.from(DbConstants.profilesTable).update(data).eq('id', userId);
    } catch (e) {
      debugPrint("Error updating user profile: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSystemAuditLogs() async {
    try {
      final res = await _client!
          .from('system_audit_logs')
          .select('*, profiles(full_name, email)')
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching audit logs: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPlatformSeoSettings() async {
    try {
      final res = await _client!.from('platform_seo_settings').select().order('route_path', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching platform SEO settings: $e");
      return [];
    }
  }

  Future<bool> isRouteAvailable(String route, {String? excludePageId, bool checkPlatform = true, bool checkUsers = true}) async {
    try {
      final cleanRoute = route.startsWith('/') ? route : '/$route';
      final cleanSubdomain = route.startsWith('/') ? route.substring(1) : route;

      // 1. Check hardcoded system routes
      final systemRoutes = ['dashboard', 'admin', 'super_admin', 'login', 'register', 'builder', 'blog', 'api', '_next', 'index', ''];
      if (systemRoutes.contains(cleanSubdomain.toLowerCase())) {
        return false;
      }

      // 2. Check platform_seo_settings
      if (checkPlatform) {
        final seoRes = await _client!.from('platform_seo_settings')
            .select('route_path')
            .eq('route_path', cleanRoute)
            .maybeSingle();
        if (seoRes != null) return false;
      }

      // 3. Check landing_pages
      if (checkUsers) {
        var query = _client!.from(DbConstants.landingPagesTable)
            .select('id')
            .eq('subdomain', cleanSubdomain);
        
        if (excludePageId != null) {
          query = query.neq('id', excludePageId);
        }
        
        final lpRes = await query.maybeSingle();
        if (lpRes != null) return false;
      }

      return true;
    } catch (e) {
      debugPrint("Error checking route availability: $e");
      // Fail safe: if error, don't let them take it just in case
      return false;
    }
  }

  Future<void> updatePlatformSeoSettings(String routePath, Map<String, dynamic> data) async {
    try {
      await _client!.from('platform_seo_settings').upsert({
        'route_path': routePath,
        ...data,
      });
    } catch (e) {
      debugPrint("Error updating platform SEO settings: $e");
      rethrow;
    }
  }

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
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      return await _client!.from(DbConstants.profilesTable).select().eq('id', userId).maybeSingle();
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      return null;
    }
  }

  // ----------------------------------------------------
  // NOTIFICATIONS OPERATIONS
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final res = await _client!
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching notifications: \$e");
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client!
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint("Error marking notification as read: \$e");
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _client!
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint("Error marking all notifications as read: \$e");
    }
  }
}
