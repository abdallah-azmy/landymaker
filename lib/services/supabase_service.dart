import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/db_constants.dart';

class SupabaseService extends ChangeNotifier {
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isMockMode = true;

  // Track currently authenticated mock/real user info
  String? _currentUserEmail;
  String? _currentUserId;
  String _currentUserRole = 'user'; // 'user' or 'super_admin'

  bool get isMockMode => _isMockMode;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserId => _currentUserId;
  String get currentUserRole => _currentUserRole;
  bool get isAuthenticated => _currentUserId != null;

  // Placeholder keys (replaced at run-time or compile-time)
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Initialize Supabase Flutter Client
  Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      if (kDebugMode) {
        print("Supabase Key credentials empty. Initializing in mock/offline mode.");
      }
      _isMockMode = true;
      _initializeMockUser();
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isMockMode = false;

      // Check current session
      final session = _client!.auth.currentSession;
      if (session != null) {
        _currentUserId = session.user.id;
        _currentUserEmail = session.user.email;
        await _fetchUserRole(session.user.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to initialize Supabase: $e. Falling back to mock mode.");
      }
      _isMockMode = true;
      _initializeMockUser();
    }
  }

  void _initializeMockUser() {
    // Default mock user logged out initially
    _currentUserEmail = null;
    _currentUserId = null;
    _currentUserRole = 'user';
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
      if (kDebugMode) {
        print("Error fetching user role: $e");
      }
    }
  }

  // ----------------------------------------------------
  // AUTHENTICATION OPERATIONS
  // ----------------------------------------------------

  Future<bool> register({required String email, required String password, required String fullName, String role = 'user'}) async {
    if (_isMockMode) {
      // Simulate registration
      _currentUserId = 'mock-user-uuid-12345';
      _currentUserEmail = email;
      _currentUserRole = role;
      notifyListeners();
      return true;
    }

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
      if (kDebugMode) {
        print("Register exception: $e");
      }
      rethrow;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (_isMockMode) {
      // Direct mock login simulations
      _currentUserId = 'mock-user-uuid-12345';
      _currentUserEmail = email;
      if (email.contains('admin')) {
        _currentUserRole = 'super_admin';
      } else {
        _currentUserRole = 'user';
      }
      notifyListeners();
      return true;
    }

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
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Login exception: $e");
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    if (!_isMockMode) {
      await _client!.auth.signOut();
    }
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserRole = 'user';
    notifyListeners();
  }

  // ----------------------------------------------------
  // LANDING PAGES OPERATIONS
  // ----------------------------------------------------

  // Local storage mock page mapping
  final Map<String, Map<String, dynamic>> _mockPages = {
    'mock-user-uuid-12345': {
      'id': 'page-uuid-11111',
      'user_id': 'mock-user-uuid-12345',
      'subdomain': 'saasgo',
      'custom_domain': 'saasgo.com',
      'is_published': true,
      'design_json': jsonEncode({
        'blocks': [
          {
            'type': 'hero',
            'title': 'Build Beautiful SaaS Pages in Seconds',
            'subtitle': 'The fast, responsive solution for your startup validation.',
            'button_text': 'Get Started Free',
            'image_url': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800'
          },
          {
            'type': 'features',
            'title': 'Power Packed Features',
            'items': [
              {'title': 'Lightning Fast', 'description': 'Optimized structure loading instantly on any Vercel domain.'},
              {'title': 'Arabic Default RTL', 'description': 'Seamless localizations built straight into Flutter widgets.'},
              {'title': 'Integrated Leads', 'description': 'Track and download every visitor request on the fly.'}
            ]
          },
          {
            'type': 'lead_form',
            'title': 'Sign Up For Early Access',
            'button_text': 'Submit Request'
          }
        ]
      })
    }
  };

  Future<Map<String, dynamic>?> getLandingPageByUserId(String userId) async {
    if (_isMockMode) {
      return _mockPages[userId];
    }

    try {
      final response = await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching landing page by user ID: $e");
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLandingPageByDomain(String domain, {bool isCustom = false}) async {
    if (_isMockMode) {
      // Find mock page match by subdomain or custom domain
      for (var page in _mockPages.values) {
        if (isCustom) {
          if (page['custom_domain'] == domain) return page;
        } else {
          if (page['subdomain'] == domain) return page;
        }
      }
      // Return first mock page as default match if no match is found on localhost
      return _mockPages.values.first;
    }

    try {
      final column = isCustom ? 'custom_domain' : 'subdomain';
      final response = await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .eq(column, domain)
          .eq('is_published', true)
          .maybeSingle();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching landing page by domain: $e");
      }
      return null;
    }
  }

  Future<bool> saveLandingPage({
    required String userId,
    required String subdomain,
    String? customDomain,
    required Map<String, dynamic> designMap,
    required bool isPublished,
  }) async {
    final designJsonStr = jsonEncode(designMap);

    if (_isMockMode) {
      _mockPages[userId] = {
        'id': _mockPages[userId]?['id'] ?? 'page-uuid-11111',
        'user_id': userId,
        'subdomain': subdomain,
        'custom_domain': customDomain,
        'design_json': designJsonStr,
        'is_published': isPublished,
      };
      return true;
    }

    try {
      final existingPage = await getLandingPageByUserId(userId);
      if (existingPage != null) {
        // Update existing page
        await _client!.from(DbConstants.landingPagesTable).update({
          'subdomain': subdomain,
          'custom_domain': customDomain,
          'design_json': designJsonStr,
          'is_published': isPublished,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', existingPage['id']);
      } else {
        // Insert new page record
        await _client!.from(DbConstants.landingPagesTable).insert({
          'user_id': userId,
          'subdomain': subdomain,
          'custom_domain': customDomain,
          'design_json': designJsonStr,
          'is_published': isPublished,
        });
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error saving landing page config: $e");
      }
      rethrow;
    }
  }

  // ----------------------------------------------------
  // LEADS CAPTURE OPERATIONS
  // ----------------------------------------------------

  final List<Map<String, dynamic>> _mockLeads = [
    {
      'id': 'lead-1',
      'landing_page_id': 'page-uuid-11111',
      'form_data': {'name': 'Ahmed Ali', 'email': 'ahmed@mail.com', 'message': 'I want a demo!'},
      'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()
    },
    {
      'id': 'lead-2',
      'landing_page_id': 'page-uuid-11111',
      'form_data': {'name': 'Sarah Smith', 'email': 'sarah@web.org', 'message': 'Pricing details please.'},
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()
    }
  ];

  Future<bool> submitLead({required String landingPageId, required Map<String, dynamic> formData}) async {
    if (_isMockMode) {
      _mockLeads.add({
        'id': 'lead-mock-${DateTime.now().millisecondsSinceEpoch}',
        'landing_page_id': landingPageId,
        'form_data': formData,
        'created_at': DateTime.now().toIso8601String(),
      });
      // Simulate conversion analytics increment
      await recordAnalyticsEvent(landingPageId: landingPageId, eventType: 'conversion');
      return true;
    }

    try {
      await _client!.from(DbConstants.leadsTable).insert({
        'landing_page_id': landingPageId,
        'form_data': formData,
      });
      // Trigger analytics conversion event record
      await recordAnalyticsEvent(landingPageId: landingPageId, eventType: 'conversion');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error submitting lead form: $e");
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLeadsByLandingPage(String landingPageId) async {
    if (_isMockMode) {
      return _mockLeads.where((lead) => lead['landing_page_id'] == landingPageId).toList();
    }

    try {
      final response = await _client!
          .from(DbConstants.leadsTable)
          .select()
          .eq('landing_page_id', landingPageId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error retrieving page leads: $e");
      }
      return [];
    }
  }

  // ----------------------------------------------------
  // ANALYTICS & STATS OPERATIONS
  // ----------------------------------------------------

  final List<Map<String, dynamic>> _mockAnalytics = [
    {'id': 'a-1', 'landing_page_id': 'page-uuid-11111', 'event_type': 'view', 'created_at': DateTime.now().toIso8601String()},
    {'id': 'a-2', 'landing_page_id': 'page-uuid-11111', 'event_type': 'view', 'created_at': DateTime.now().toIso8601String()},
    {'id': 'a-3', 'landing_page_id': 'page-uuid-11111', 'event_type': 'conversion', 'created_at': DateTime.now().toIso8601String()},
  ];

  Future<void> recordAnalyticsEvent({required String landingPageId, required String eventType}) async {
    if (_isMockMode) {
      _mockAnalytics.add({
        'id': 'analytic-mock-${DateTime.now().millisecondsSinceEpoch}',
        'landing_page_id': landingPageId,
        'event_type': eventType,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    try {
      await _client!.from(DbConstants.analyticsTable).insert({
        'landing_page_id': landingPageId,
        'event_type': eventType,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error recording analytics event: $e");
      }
    }
  }

  Future<Map<String, int>> getPageAnalyticsStats(String landingPageId) async {
    if (_isMockMode) {
      final views = _mockAnalytics.where((a) => a['landing_page_id'] == landingPageId && a['event_type'] == 'view').length;
      final conversions = _mockAnalytics.where((a) => a['landing_page_id'] == landingPageId && a['event_type'] == 'conversion').length;
      return {'views': views, 'conversions': conversions};
    }

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
      if (kDebugMode) {
        print("Error fetching analytics stats: $e");
      }
      return {'views': 0, 'conversions': 0};
    }
  }

  // ----------------------------------------------------
  // STORAGE IMAGE UPLOADS
  // ----------------------------------------------------

  Future<String?> uploadImage(PlatformFile file) async {
    if (_isMockMode) {
      // Return a fixed unsplash mockup URL for design preview purposes
      return "https://images.unsplash.com/photo-1542744094-3a31f103e35f?q=80&w=800&auto=format&fit=crop";
    }

    try {
      final userId = _currentUserId!;
      final fileExtension = file.name.split('.').last;
      final filePath = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload binary to Supabase bucket
      await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .uploadBinary(filePath, file.bytes!);

      // Get public URL
      final publicUrl = _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image: $e");
      }
      rethrow;
    }
  }

  // ----------------------------------------------------
  // SUPER ADMIN METRICS
  // ----------------------------------------------------

  Future<Map<String, dynamic>> getSuperAdminMetrics() async {
    if (_isMockMode) {
      return {
        'total_users': 14,
        'active_pages': _mockPages.length,
        'total_leads': _mockLeads.length,
      };
    }

    try {
      final usersRes = await _client!.from(DbConstants.profilesTable).select('id');
      final pagesRes = await _client!.from(DbConstants.landingPagesTable).select('id').eq('is_published', true);
      final leadsRes = await _client!.from(DbConstants.leadsTable).select('id');
      return {
        'total_users': usersRes.length,
        'active_pages': pagesRes.length,
        'total_leads': leadsRes.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching super admin metrics: $e");
      }
      return {
        'total_users': 0,
        'active_pages': 0,
        'total_leads': 0,
      };
    }
  }
}
