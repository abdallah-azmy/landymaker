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
import 'web_auth_helper.dart';

part 'supabase/supabase_auth.dart';
part 'supabase/supabase_pages.dart';
part 'supabase/supabase_storage.dart';

class SupabaseService extends ChangeNotifier
    with SupabaseServiceAuth, SupabaseServicePages, SupabaseServiceStorage {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _client;

  String? _currentUserEmail;
  String? _currentUserId;
  String _currentUserRole = 'user';
  String _currentUserTier = 'free';
  String? _currentUserPhotoUrl;

  int? _cachedAssetsCount;
  DateTime? _lastCountFetch;

  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserId => _currentUserId;
  String get currentUserRole => _currentUserRole;
  String get currentUserTier => _currentUserTier;
  String? get currentUserPhotoUrl => _currentUserPhotoUrl;
  bool get isAuthenticated => _currentUserId != null;
  SupabaseClient get client => _client!;

  static final String supabaseUrl = EnvUtils.supabaseUrl;
  static final String supabaseAnonKey = EnvUtils.supabaseAnonKey;

  Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        "Supabase credentials are missing. Please provide SUPABASE_URL and SUPABASE_ANON_KEY.",
      );
    }

    try {
      final dio = await DioFactory.getDio();

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
        httpClient: DioHttpClientAdapter(dio),
      );
      _client = Supabase.instance.client;

      Logger.info('Supabase initialized successfully');

      final session = _client!.auth.currentSession;
      if (session != null) {
        _currentUserId = session.user.id;
        _currentUserEmail = session.user.email;

        Logger.info('Supabase initial session user metadata: ${session.user.userMetadata}');
        Logger.info('Supabase initial session user identities: ${session.user.identities?.map((i) => i.identityData).toList()}');

        final extractedPhoto = _extractPhotoUrl(session.user);
        if (extractedPhoto != null && extractedPhoto.isNotEmpty) {
          _currentUserPhotoUrl = extractedPhoto;
        }
        await _fetchUserRole(session.user.id);
      }

      _client!.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null) {
          _currentUserId = session.user.id;
          _currentUserEmail = session.user.email;

          Logger.info('Supabase auth state changed user metadata: ${session.user.userMetadata}');
          Logger.info('Supabase auth state changed user identities: ${session.user.identities?.map((i) => i.identityData).toList()}');

          final extractedPhoto = _extractPhotoUrl(session.user);
          if (extractedPhoto != null && extractedPhoto.isNotEmpty) {
            _currentUserPhotoUrl = extractedPhoto;
          }
          await _fetchUserRole(session.user.id);
        } else {
          _currentUserId = null;
          _currentUserEmail = null;
          _currentUserRole = 'user';
          _currentUserPhotoUrl = null;
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

  static String? _extractPhotoUrl(User user) {
    final meta = user.userMetadata;
    if (meta != null) {
      final picture = meta['picture'] as String?;
      if (picture != null && picture.isNotEmpty) return picture;

      final avatarUrl = meta['avatar_url'] as String?;
      if (avatarUrl != null && avatarUrl.isNotEmpty) return avatarUrl;
    }

    final identity = user.identities?.isNotEmpty == true
        ? user.identities!.first
        : null;
    if (identity != null) {
      final idPicture = identity.identityData?['picture'] as String?;
      if (idPicture != null && idPicture.isNotEmpty) return idPicture;

      final idAvatarUrl = identity.identityData?['avatar_url'] as String?;
      if (idAvatarUrl != null && idAvatarUrl.isNotEmpty) return idAvatarUrl;
    }

    return null;
  }

  Future<void> _fetchUserRole(String userId) async {
    try {
      final response = await _client!
          .from(DbConstants.profilesTable)
          .select('role, tier')
          .eq('id', userId)
          .maybeSingle();
      if (response != null) {
        _currentUserRole = response['role'] as String? ?? 'user';
        _currentUserTier = response['tier'] as String? ?? 'free';
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
    }
  }

  // ----------------------------------------------------
  // SUPER ADMIN OPERATIONS
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    try {
      final res = await _client!
          .from(DbConstants.profilesTable)
          .select('*, landing_pages(id)')
          .order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(res);
      for (var u in list) {
        final pages = u['landing_pages'] as List?;
        u['pages_count'] = pages?.length ?? 0;
      }
      return list;
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
      debugPrint("Error fetching admin affiliates: $e");
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

  Future<List<Map<String, dynamic>>> getUserSubscriptionRequests(String userId) async {
    try {
      final res = await _client!
          .from('subscription_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching user subscription requests: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserAuditLogs(String userId) async {
    try {
      final res = await _client!
          .from('system_audit_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching user audit logs: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserAggregatedAnalytics(String userId) async {
    try {
      final pages = await getLandingPagesByUserId(userId);
      int totalViews = 0;
      int totalLeads = 0;
      for (final page in pages) {
        totalViews += (page['views_count'] as num?)?.toInt() ?? 0;
        totalLeads += (page['leads_count'] as num?)?.toInt() ?? 0;
      }
      return {
        'total_views': totalViews,
        'total_leads': totalLeads,
        'pages_count': pages.length,
        'pages': pages,
      };
    } catch (e) {
      debugPrint("Error fetching user analytics: $e");
      return {'total_views': 0, 'total_leads': 0, 'pages_count': 0, 'pages': <Map<String, dynamic>>[]};
    }
  }

  // ----------------------------------------------------
  // PLATFORM SEO OPERATIONS
  // ----------------------------------------------------

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

      final systemRoutes = ['dashboard', 'admin', 'super_admin', 'login', 'register', 'builder', 'blog', 'api', '_next', 'index', ''];
      if (systemRoutes.contains(cleanSubdomain.toLowerCase())) {
        return false;
      }

      if (checkPlatform) {
        final seoRes = await _client!.from('platform_seo_settings')
            .select('route_path')
            .eq('route_path', cleanRoute)
            .maybeSingle();
        if (seoRes != null) return false;
      }

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
  // TEMPLATE OPERATIONS
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchPublicTemplates() async {
    try {
      final res = await _client!
          .from(DbConstants.templatesTable)
          .select()
          .eq('is_active', true)
          .eq('is_draft', false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching public templates: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchFeaturedTemplates() async {
    try {
      final res = await _client!
          .from(DbConstants.templatesTable)
          .select()
          .eq('is_active', true)
          .eq('is_draft', false)
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching featured templates: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllTemplates() async {
    try {
      final res = await _client!
          .from(DbConstants.templatesTable)
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching all templates: $e");
      return [];
    }
  }

  Future<void> createTemplate(Map<String, dynamic> data) async {
    try {
      await _client!.from(DbConstants.templatesTable).insert(data);
    } catch (e) {
      debugPrint("Error creating template: $e");
      rethrow;
    }
  }

  Future<void> updateTemplate(String id, Map<String, dynamic> data) async {
    try {
      await _client!.from(DbConstants.templatesTable).update(data).eq('id', id);
    } catch (e) {
      debugPrint("Error updating template: $e");
      rethrow;
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _client!.from(DbConstants.templatesTable).update({'is_active': false}).eq('id', id);
    } catch (e) {
      debugPrint("Error soft-deleting template: $e");
      rethrow;
    }
  }

  // ----------------------------------------------------
  // HOMEPAGE SECTIONS CRUD
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> getHomepageSections() async {
    try {
      final response = await _client!
          .from(DbConstants.homepageSectionsTable)
          .select('*')
          .order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching homepage sections: $e");
      return [];
    }
  }

  Future<void> upsertHomepageSection(String sectionKey, Map<String, dynamic> data) async {
    try {
      await _client!
          .from(DbConstants.homepageSectionsTable)
          .upsert({'section_key': sectionKey, ...data});
    } catch (e) {
      debugPrint("Error upserting homepage section: $e");
      rethrow;
    }
  }

  Future<void> updateHomepageSection(String id, Map<String, dynamic> data) async {
    try {
      await _client!
          .from(DbConstants.homepageSectionsTable)
          .update(data)
          .eq('id', id);
    } catch (e) {
      debugPrint("Error updating homepage section: $e");
      rethrow;
    }
  }

  Future<void> reorderHomepageSections(List<Map<String, dynamic>> sections) async {
    try {
      for (final s in sections) {
        await _client!
            .from(DbConstants.homepageSectionsTable)
            .update({'sort_order': s['sort_order']})
            .eq('id', s['id']);
      }
    } catch (e) {
      debugPrint("Error reordering homepage sections: $e");
      rethrow;
    }
  }

  Future<int> seedHomepageSectionsFromRegistry(List<Map<String, dynamic>> sections) async {
    int inserted = 0;
    for (final s in sections) {
      try {
        final existing = await _client!
            .from(DbConstants.homepageSectionsTable)
            .select('id')
            .eq('section_key', s['section_key'])
            .maybeSingle();
        if (existing == null) {
          await _client!.from(DbConstants.homepageSectionsTable).insert(s);
          inserted++;
        }
      } catch (e) {
        debugPrint("Error seeding homepage section ${s['section_key']}: $e");
      }
    }
    return inserted;
  }

  Future<int> seedTemplatesFromRegistry(List<Map<String, dynamic>> templates) async {
    int inserted = 0;
    for (final t in templates) {
      try {
        final existing = await _client!
            .from(DbConstants.templatesTable)
            .select('id')
            .eq('id', t['id'])
            .maybeSingle();
        if (existing == null) {
          await _client!.from(DbConstants.templatesTable).insert({
            ...t,
            'is_active': true,
            'is_draft': false,
            'is_featured': false,
            'design_json': t['design_json'] ?? {'blocks': []},
          });
          inserted++;
        }
      } catch (e) {
        debugPrint("Error seeding template ${t['id']}: $e");
      }
    }
    return inserted;
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
      debugPrint("Error fetching notifications: $e");
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
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _client!
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }

  Future<void> broadcastNotification(
    String title,
    String message,
    String type, {
    String? redirectTo,
  }) async {
    try {
      await _client!.rpc('broadcast_notification', params: {
        'p_title': title,
        'p_message': message,
        'p_type': type,
        if (redirectTo != null && redirectTo.isNotEmpty) 'p_redirect_to': redirectTo,
      });
      debugPrint('DB: Broadcast notification inserted successfully.');

      _sendFcmPush(userIds: null, title: title, message: message, type: type, redirectTo: redirectTo);
    } catch (e) {
      debugPrint("Error sending broadcast notification: $e");
      rethrow;
    }
  }

  Future<void> sendTargetedNotification(
    List<String> userIds,
    String title,
    String message,
    String type, {
    String? redirectTo,
  }) async {
    try {
      await _client!.rpc('send_targeted_notification', params: {
        'p_user_ids': userIds,
        'p_title': title,
        'p_message': message,
        'p_type': type,
        if (redirectTo != null && redirectTo.isNotEmpty) 'p_redirect_to': redirectTo,
      });
      debugPrint('DB: Targeted notification inserted successfully to users: $userIds');

      _sendFcmPush(userIds: userIds, title: title, message: message, type: type, redirectTo: redirectTo);
    } catch (e) {
      debugPrint("Error sending targeted notification: $e");
      rethrow;
    }
  }

  Future<void> bulkBlockUsers(List<String> userIds, bool isBlocked) async {
    try {
      await _client!.from(DbConstants.profilesTable)
          .update({'is_blocked': isBlocked, if (isBlocked) 'blocked_at': DateTime.now().toIso8601String() else 'blocked_at': null})
          .filter('id', 'in', '(${userIds.map((id) => "'$id'").join(',')})');
      debugPrint('DB: Bulk ${isBlocked ? "block" : "unblock"} completed for ${userIds.length} users.');
    } catch (e) {
      debugPrint('Error in bulk block/unblock: $e');
      rethrow;
    }
  }

  Future<void> bulkUpdateUserTier(List<String> userIds, String newTier) async {
    try {
      await _client!.from(DbConstants.profilesTable)
          .update({'tier': newTier})
          .filter('id', 'in', '(${userIds.map((id) => "'$id'").join(',')})');
      debugPrint('DB: Bulk tier update to "$newTier" completed for ${userIds.length} users.');
    } catch (e) {
      debugPrint('Error in bulk tier update: $e');
      rethrow;
    }
  }

  Future<void> bulkAddSubscriptionMonths(List<String> userIds, int months) async {
    try {
      for (final userId in userIds) {
        final current = await _client!.from(DbConstants.profilesTable)
            .select('subscription_end_date')
            .eq('id', userId)
            .maybeSingle();
        final now = DateTime.now();
        DateTime newEnd;
        if (current != null && current['subscription_end_date'] != null) {
          final existingEnd = DateTime.parse(current['subscription_end_date'] as String);
          if (existingEnd.isAfter(now)) {
            newEnd = DateTime(existingEnd.year, existingEnd.month + months, existingEnd.day);
          } else {
            newEnd = DateTime(now.year, now.month + months, now.day);
          }
        } else {
          newEnd = DateTime(now.year, now.month + months, now.day);
        }
        await _client!.from(DbConstants.profilesTable)
            .update({'subscription_end_date': newEnd.toIso8601String()})
            .eq('id', userId);
      }
      debugPrint('DB: Bulk subscription extension (+$months months) completed for ${userIds.length} users.');
    } catch (e) {
      debugPrint('Error in bulk subscription extension: $e');
      rethrow;
    }
  }

  Future<void> _sendFcmPush({
    required List<String>? userIds,
    required String title,
    required String message,
    required String type,
    required String? redirectTo,
  }) async {
    try {
      await _client!.functions.invoke('send-notification', body: {
        'user_ids': userIds,
        'title': title,
        'message': message,
        'type': type,
        'redirect_to': redirectTo?.isEmpty == true ? null : redirectTo,
      });
      debugPrint('FCM: Push notification sent successfully via edge function.');
    } catch (e) {
      debugPrint('FCM: Failed to send push notification (non-critical): $e');
    }
  }
}
