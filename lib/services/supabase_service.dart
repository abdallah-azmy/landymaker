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


/// [SupabaseService] — singleton service wrapping Supabase with Supabase SDK.
///
/// **Responsibility**: Owns all Supabase interactions — auth, landing pages CRUD,
/// analytics, storage, templates, notifications, admin/bulk operations. Acts as the
/// single source of truth for current user identity (id, email, role, tier, photo).
/// **Used by**: All screens and view models that require Supabase data. Accessed via
/// `SupabaseService.instance`.
/// **Key state**: `_currentUserId`, `_currentUserRole`, `_currentUserTier`, `_client`.
/// **⚠️ AI Warning**: Never replace the singleton or call `Supabase.initialize` twice.
/// Do not bypass auth checks. The `client` getter assumes it is non-null after init.
class SupabaseService extends ChangeNotifier {
  /// Singleton accessor. Use `SupabaseService.instance` everywhere.
  static final SupabaseService instance = SupabaseService._internal();

  /// Private internal constructor for singleton pattern.
  SupabaseService._internal();

  /// The underlying Supabase client, set during [initialize]. Access via [client] getter.
  SupabaseClient? _client;

  /// Email of the currently authenticated user, or null when logged out.
  String? _currentUserEmail;
  /// ID (UUID) of the currently authenticated user, or null when logged out.
  String? _currentUserId;
  /// Role of the current user: `'user'` or `'super_admin'`.
  String _currentUserRole = 'user';
  /// Tier of the current user: `'free'`, `'pro'`, `'business'`, or `'agency'`.
  String _currentUserTier = 'free';
  /// URL of the current user's profile photo (from Google OAuth or identity data).
  String? _currentUserPhotoUrl;

  /// The current user's email address, or null if not authenticated.
  String? get currentUserEmail => _currentUserEmail;
  /// The current user's Supabase user ID (UUID), or null if not authenticated.
  String? get currentUserId => _currentUserId;
  /// The current user's role — `'user'` or `'super_admin'`.
  String get currentUserRole => _currentUserRole;
  /// The current user's subscription tier — `'free'`, `'pro'`, `'business'`, or `'agency'`.
  String get currentUserTier => _currentUserTier;
  /// The current user's profile photo URL (from OAuth provider).
  String? get currentUserPhotoUrl => _currentUserPhotoUrl;
  /// Whether a user is currently authenticated (non-null userId).
  bool get isAuthenticated => _currentUserId != null;
  /// The initialized Supabase client. Throws if accessed before [initialize].
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

  /// Supabase project URL, resolved from environment via [EnvUtils].
  static final String supabaseUrl = EnvUtils.supabaseUrl;
  /// Supabase anonymous API key, resolved from environment via [EnvUtils].
  static final String supabaseAnonKey = EnvUtils.supabaseAnonKey;

  /// Initializes the Supabase Flutter SDK, restores the existing session, and
  /// starts listening to auth state changes.
  ///
  /// Called once at app startup. Must complete before any other Supabase call.
  /// Side effects: Sets `_client`, fetches user role/tier via `_fetchUserRole`,
  /// registers an `onAuthStateChange` listener that updates local state and calls
  /// `notifyListeners`.
  /// Do NOT call directly from UI — call it once in the app bootstrap layer.
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
        
        Logger.info('Supabase initial session user metadata: ${session.user.userMetadata}');
        Logger.info('Supabase initial session user identities: ${session.user.identities?.map((i) => i.identityData).toList()}');
        
        final extractedPhoto = _extractPhotoUrl(session.user);
        if (extractedPhoto != null && extractedPhoto.isNotEmpty) {
          _currentUserPhotoUrl = extractedPhoto;
        }
        await _fetchUserRole(session.user.id);
      }

      // Listen to auth state updates to handle updates reactively
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

  /// Extracts the user's profile photo URL from Supabase auth User object.
  ///
  /// Checks in order:
  /// 1. `user_metadata['picture']` — OIDC standard (GoTrue JWT source of truth)
  /// 2. `user_metadata['avatar_url']` — legacy Supabase key
  /// 3. `identities[0].identity_data['picture']` — provider-level fallback
  /// 4. `identities[0].identity_data['avatar_url']` — provider-level fallback
  ///
  /// Called during [initialize] and on auth state changes.
  /// ⚠️ Do not change lookup order without verifying OIDC claim structure.
  static String? _extractPhotoUrl(User user) {
    // ── user_metadata (from raw_user_meta_data column) ──
    final meta = user.userMetadata;
    if (meta != null) {
      final picture = meta['picture'] as String?;
      if (picture != null && picture.isNotEmpty) return picture;

      final avatarUrl = meta['avatar_url'] as String?;
      if (avatarUrl != null && avatarUrl.isNotEmpty) return avatarUrl;
    }

    // ── identity_data (from auth.identities table) ──
    // Populated even when raw_user_meta_data is empty for some projects.
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

  /// Fetches the current user's `role` and `tier` from the profiles table.
  ///
  /// Called after login, session restore, and auth state changes.
  /// Side effects: Updates `_currentUserRole` and `_currentUserTier`.
  /// Uses `maybeSingle` so it gracefully handles missing profiles.
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
  // AUTHENTICATION OPERATIONS
  // ----------------------------------------------------

  /// Registers a new user via Supabase Auth with email, password, and full name.
  ///
  /// Called when the user submits the registration form.
  /// Side effects: On success, sets local auth state and calls `notifyListeners`.
  /// Returns `true` if the user was created, `false` otherwise.
  /// Do NOT call directly from UI — use the AuthViewModel instead.
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

  /// Authenticates an existing user with email and password.
  ///
  /// Called when the user submits the login form.
  /// Side effects: On success, sets local auth state, fetches role via
  /// `_fetchUserRole`, and calls `notifyListeners`.
  /// Returns `true` if login succeeds, `false` otherwise.
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

  /// Signs out the current user and clears all local auth state.
  ///
  /// Called when the user taps "Sign Out".
  /// Side effects: Clears `_currentUserId`, `_currentUserEmail`,
  /// `_currentUserRole`, `_currentUserPhotoUrl`, and calls `notifyListeners`.
  Future<void> logout() async {
    await _client!.auth.signOut();
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserRole = 'user';
    _currentUserPhotoUrl = null;
    notifyListeners();
  }

  /// Sends a password reset email to the given address via Supabase Auth.
  ///
  /// Called from the "Forgot Password" flow.
  /// Uses `Uri.base.origin` to construct the redirect URL for the reset page.
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

  /// Updates the current user's password via Supabase Auth.
  ///
  /// Called from the "Reset Password" form after the user clicks the email link.
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

  /// Initiates Google OAuth sign-in. On web uses a custom popup flow via
  /// [signInWithGoogleWeb]; on mobile uses Supabase's built-in OAuth.
  ///
  /// Called when the user taps "Sign in with Google".
  /// [selectAccount] forces the Google account picker to show on every attempt.
  Future<void> signInWithGoogle({bool selectAccount = false}) async {
    try {
      if (kIsWeb) {
        final success = await signInWithGoogleWeb(
          client: _client!,
          selectAccount: selectAccount,
        );
        if (!success) {
          debugPrint('Google Sign In web flow completed without authentication (cancelled).');
        }
      } else {
        final queryParams = selectAccount ? {'prompt': 'select_account'} : null;
        await _client!.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'com.landymaker.app://login-callback',
          queryParams: queryParams,
        );
      }
    } catch (e) {
      debugPrint('Google Sign In exception: $e');
      rethrow;
    }
  }

  // ----------------------------------------------------
  // LANDING PAGES OPERATIONS
  // ----------------------------------------------------

  /// Fetches all landing pages owned by [userId], ordered by most recently updated.
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

  /// Fetches every landing page across all users, ordered by creation date.
  ///
  /// Used by super admin dashboard.
  Future<List<Map<String, dynamic>>> getAllLandingPages() async {
    try {
      final response = await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching all landing pages: $e");
      return [];
    }
  }

  /// Fetches landing pages with `website_type` = `'homepage_preview'`.
  ///
  /// Used to display preview cards on the main landing page.
  Future<List<Map<String, dynamic>>> getHomepagePreviewPages() async {
    try {
      final response = await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .eq('website_type', 'homepage_preview')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching homepage preview pages: $e");
      return [];
    }
  }

  /// Clones a source landing page's design into a new page with a new subdomain.
  ///
  /// Called when a user duplicates a page from the dashboard or picks a template.
  /// Returns the newly created page ID, or null on failure.
  Future<String?> cloneLandingPage({
    required String sourcePageId,
    required String newSubdomain,
    required String websiteType,
    required String userId,
  }) async {
    try {
      final source = await getLandingPageById(sourcePageId);
      if (source == null) throw Exception("Source landing page not found");

      final result = await _client!
          .from(DbConstants.landingPagesTable)
          .insert({
            'user_id': userId,
            'subdomain': newSubdomain,
            'design_json': source['design_json'],
            'is_published': false,
            'website_type': websiteType,
          })
          .select('id')
          .single();
      return result['id'] as String?;
    } catch (e) {
      debugPrint("Error cloning landing page: $e");
      rethrow;
    }
  }

  /// Returns the first (most recent) landing page for [userId], or null if none exist.
  Future<Map<String, dynamic>?> getLandingPageByUserId(String userId) async {
    try {
      final pages = await getLandingPagesByUserId(userId);
      return pages.isNotEmpty ? pages.first : null;
    } catch (e) {
      debugPrint("Error fetching default landing page: $e");
      return null;
    }
  }

  /// Fetches a single landing page by its UUID [pageId].
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

  /// Fetches multiple landing pages in a single query by their UUIDs [pageIds].
  Future<List<Map<String, dynamic>>> getLandingPagesByIds(List<String> pageIds) async {
    try {
      if (pageIds.isEmpty) return [];
      final response = await _client!
          .from(DbConstants.landingPagesTable)
          .select()
          .inFilter('id', pageIds);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching landing pages by IDs: $e");
      return [];
    }
  }


  /// Fetches a landing page by its subdomain or custom domain.
  ///
  /// Used by the public renderer when resolving a URL to a landing page.
  /// When [isCustom] is true, checks `custom_domain` column and enforces the
  /// Pro-tier gate. When [publishedOnly] is true, excludes unpublished pages.
  /// Applies the 30-day inactivity auto-suspend policy for free-tier pages.
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

  /// Saves (inserts or updates) a landing page and returns its page ID.
  ///
  /// When [pageId] is null, performs an INSERT and returns the new ID in one
  /// round-trip. When [pageId] is non-null, performs an UPDATE on that row.
  /// Called by the page builder when the user hits "Save".
  /// Side effects: Encodes [designMap] via `jsonEncode` before writing.
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

  /// Toggles the `is_published` flag on a landing page.
  ///
  /// Called when the user publishes or unpublishes a page from the dashboard.
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

  /// Submits a lead via the `lead-submit` Edge Function.
  ///
  /// Called when a visitor fills out a form on a published landing page.
  /// Returns `true` on HTTP 200, `false` otherwise.
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

  /// Fetches all leads for a given landing page, newest first.
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

  /// Records an analytics event for a landing page.
  ///
  /// Delegates to [recordPageEvent].
  /// Called by the public renderer when a visitor views or interacts with a page.
  Future<void> recordAnalyticsEvent({
    required String landingPageId,
    required String eventType,
  }) async {
    await recordPageEvent(landingPageId: landingPageId, eventType: eventType);
  }

  /// Records a page event via the `record_page_event` RPC function.
  ///
  /// Called when a visitor views, converts, or performs an action on a page.
  /// Side effects: Captures a browser fingerprint via [FingerprintUtils].
  Future<void> recordPageEvent({
    required String landingPageId,
    required String eventType,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final fingerprint = FingerprintUtils.getFingerprint();
      await _client!.rpc('record_page_event', params: {
        'p_page_id': landingPageId,
        'p_event_type': eventType,
        'p_fingerprint': fingerprint,
        'p_metadata': metadata,
      });
    } catch (e) {
      debugPrint("Error recording page event: $e");
    }
  }

  /// Returns view, unique visitor, and conversion counts for a page via the
  /// `get_enhanced_page_stats` RPC function.
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

  /// Lists all images for the current user, combining Supabase Storage files
  /// and ImgBB assets from the `user_assets` table.
  ///
  /// Results are sorted by creation date (newest first).
  /// Returns an empty list if the user is not authenticated.
  Future<List<Map<String, dynamic>>> listUserImages() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      // 1. Fetch from Supabase Storage (Legacy/Direct uploads)
      final List<FileObject> files = await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .list(path: userId);

      final storageImages = files.map((f) {
        final publicUrl = _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .getPublicUrl('$userId/${f.name}');
        
        return {
          'name': f.name,
          'id': f.id,
          'url': publicUrl,
          'size': f.metadata?['size'],
          'created_at': f.createdAt,
          'source': 'storage',
        };
      }).toList();

      // 2. Fetch from user_assets table (ImgBB links)
      final dbAssets = await _client!
          .from(DbConstants.userAssetsTable)
          .select()
          .eq('user_id', userId);

      final dbImages = List<Map<String, dynamic>>.from(dbAssets).map((a) {
        return {
          'name': a['name'] ?? 'ImgBB Asset',
          'id': a['id'],
          'url': a['url'],
          'created_at': a['created_at'],
          'source': 'imgbb',
          'hash': a['image_hash'],
        };
      }).toList();

      // Combine both
      return [...storageImages, ...dbImages]
        ..sort((a, b) => b['created_at'].compareTo(a['created_at']));
    } catch (e) {
      debugPrint("Error listing user images: $e");
      return [];
    }
  }

  /// Looks up an ImgBB asset URL by its image hash in the `user_assets` table.
  ///
  /// Used to avoid re-uploading duplicate images.
  Future<String?> findAssetByHash(String hash) async {
    try {
      final res = await _client!
          .from(DbConstants.userAssetsTable)
          .select('url')
          .eq('image_hash', hash)
          .maybeSingle();
      return res?['url'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Registers an external ImgBB asset URL in the `user_assets` table for the
  /// current user.
  ///
  /// Called after a successful ImgBB upload to keep a record of the image.
  Future<void> registerExternalAsset(String url, String name, {String? hash}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _client!.from(DbConstants.userAssetsTable).insert({
        'user_id': userId,
        'url': url,
        'name': name,
        'source': 'imgbb',
        'image_hash': hash,
      });
    } catch (e) {
      debugPrint("Error registering external asset: $e");
    }
  }

  /// Deletes an image. If [source] is `'imgbb'`, removes the record from
  /// `user_assets` by [assetId]. Otherwise removes the file from Supabase Storage.
  Future<void> deleteImage(String fileName, {String? source, String? assetId}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      if (source == 'imgbb' && assetId != null) {
        await _client!.from(DbConstants.userAssetsTable).delete().eq('id', assetId);
      } else {
        await _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .remove(['$userId/$fileName']);
      }
    } catch (e) {
      debugPrint("Error deleting image: $e");
      rethrow;
    }
  }

  /// Uploads a [PlatformFile] (from `file_picker`) to Supabase Storage.
  ///
  /// Delegates to [uploadImageBytes]. Throws if [file.bytes] is null.
  Future<String?> uploadImage(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception("File data is missing. Unexpected null value.");
    }
    return uploadImageBytes(bytes, file.name);
  }

  int? _cachedAssetsCount;
  DateTime? _lastCountFetch;

  /// Uploads raw image [bytes] to Supabase Storage under the current user's folder.
  ///
  /// Enforces tier-based upload quotas (Free: 50, Pro: 200, Business: 500,
  /// Agency: 1000, Super Admin: unlimited). Caches the asset count for 10 seconds
  /// to avoid repeated LIST calls during bulk uploads.
  /// Returns the public URL of the uploaded file, or throws on failure.
  Future<String?> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception("User session not found. Please login again.");
      }

      // 1. Define Dynamic Quota based on Tier & Role
      int quota = 50; // Default Free
      if (_currentUserRole == 'super_admin') {
        quota = 999999; // Unlimited
      } else if (_currentUserTier == 'pro') {
        quota = 200;
      } else if (_currentUserTier == 'business') {
        quota = 500;
      } else if (_currentUserTier == 'agency') {
        quota = 1000;
      }

      // 2. Check current quota efficiently (Cache the count for 10 seconds during bulk operations)
      if (_cachedAssetsCount == null || 
          _lastCountFetch == null || 
          DateTime.now().difference(_lastCountFetch!).inSeconds > 10) {
        final existingFiles = await _client!.storage
            .from(DbConstants.landingAssetsBucket)
            .list(path: userId);
        _cachedAssetsCount = existingFiles.length;
        _lastCountFetch = DateTime.now();
      }
      
      if (_cachedAssetsCount! >= quota && _currentUserRole != 'super_admin') {
        String msg = "لقد وصلت للحد الأقصى للرفع ($quota صورة).";
        if (_currentUserTier == 'free') {
          msg += " قم بالترقية للحصول على مساحة أكبر تصل إلى 1000 صورة.";
        } else {
          msg += " يرجى حذف بعض الصور القديمة لتتمكن من إضافة صور جديدة.";
        }
        throw Exception(msg);
      }

      final fileExtension = fileName.split('.').last;
      final filePath =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .uploadBinary(filePath, bytes);

      // Increment cache optimistically
      _cachedAssetsCount = (_cachedAssetsCount ?? 0) + 1;

      return _client!.storage
          .from(DbConstants.landingAssetsBucket)
          .getPublicUrl(filePath);
    } catch (e, stack) {
      ErrorHandler.logError("Error uploading image bytes", e, stack);
      rethrow;
    }
  }

  // ----------------------------------------------------
  // SUPER ADMIN OPERATIONS (REAL DATA)
  // ----------------------------------------------------

  /// Fetches all user profiles with their landing page count for the admin dashboard.
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

  /// Fetches all landing pages with owner profile data for the admin dashboard.
  Future<List<Map<String, dynamic>>> getAdminPages() async {
    try {
      final res = await _client!.from(DbConstants.landingPagesTable).select('*, profiles(full_name, email)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin pages: $e");
      return [];
    }
  }

  /// Fetches all subscription requests for the admin dashboard.
  Future<List<Map<String, dynamic>>> getAdminSubscriptionRequests() async {
    try {
      final res = await _client!.from('subscription_requests').select('*, profiles(full_name, email)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin subscription requests: $e");
      return [];
    }
  }

  /// Updates the `status` of a subscription request row.
  Future<void> updateSubscriptionStatus(String id, String status) async {
    try {
      await _client!.from('subscription_requests').update({'status': status}).eq('id', id);
    } catch (e) {
      debugPrint("Error updating subscription status: $e");
      rethrow;
    }
  }

  /// Sets or clears the `custom_domain` on a landing page and resets
  /// `domain_status` to `'pending'`.
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

  /// Calls the `refresh_domain_verification_token` RPC and returns the new token.
  Future<String> refreshDomainVerificationToken(String pageId) async {
    try {
      final res = await _client!.rpc('refresh_domain_verification_token', params: {'page_id': pageId});
      return res as String;
    } catch (e) {
      debugPrint("Error refreshing domain token: $e");
      rethrow;
    }
  }

  /// Invokes the `verify-custom-domain` Edge Function to verify or detach a
  /// custom domain DNS configuration.
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

  /// Fetches all affiliate profiles with user data for the admin dashboard.
  Future<List<Map<String, dynamic>>> getAdminAffiliates() async {
    try {
      final res = await _client!.from('affiliate_profiles').select('*, profiles(full_name, email)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching admin affiliates: \$e");
      return [];
    }
  }

  /// Aggregates total views, purchases, and recent analytics logs for the admin dashboard.
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

  /// Fetches all subscription plans ordered by monthly price ascending.
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final res = await _client!.from('subscription_plans').select().order('monthly_price', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching subscription plans: $e");
      return [];
    }
  }

  /// Fetches system-wide security limits (e.g. rate limits) as a key-value map.
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

  /// Updates a subscription plan row by [id] with the given [data].
  Future<void> updateSubscriptionPlan(String id, Map<String, dynamic> data) async {
    try {
      await _client!.from('subscription_plans').update(data).eq('id', id);
    } catch (e) {
      debugPrint("Error updating subscription plan: $e");
      rethrow;
    }
  }

  /// Updates a user's profile row by [userId] with the given [data].
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client!.from(DbConstants.profilesTable).update(data).eq('id', userId);
    } catch (e) {
      debugPrint("Error updating user profile: $e");
      rethrow;
    }
  }

  /// Fetches the 100 most recent system audit logs with user profile data.
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

  /// Fetches subscription requests for a specific user, newest first.
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

  /// Fetches audit logs for a specific user, limited to the 50 most recent entries.
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

  /// Aggregates total views, leads, and page count for a specific user.
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

  /// Fetches all platform SEO settings ordered by route path.
  Future<List<Map<String, dynamic>>> getPlatformSeoSettings() async {
    try {
      final res = await _client!.from('platform_seo_settings').select().order('route_path', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint("Error fetching platform SEO settings: $e");
      return [];
    }
  }

  /// Checks whether a given subdomain [route] is available for use.
  ///
  /// Verifies against three sources:
  /// 1. Hardcoded system routes (e.g. `'dashboard'`, `'admin'`)
  /// 2. `platform_seo_settings` table (when [checkPlatform] is true)
  /// 3. `landing_pages` table (when [checkUsers] is true, optionally excluding [excludePageId])
  /// Returns `false` (not available) on any error to fail safe.
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

  /// Upserts a platform SEO settings row keyed by [routePath].
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

  /// Returns aggregate counts (total users, active pages, total leads) for the
  /// super admin dashboard.
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
  /// Fetches a single user profile by [userId].
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

  /// Fetches public templates that are active and not draft.
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

  /// Fetches templates that are active, not draft, and marked as featured.
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

  /// Fetches every template (active or inactive) for the admin panel.
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

  /// Inserts a new template row with the given [data].
  Future<void> createTemplate(Map<String, dynamic> data) async {
    try {
      await _client!.from(DbConstants.templatesTable).insert(data);
    } catch (e) {
      debugPrint("Error creating template: $e");
      rethrow;
    }
  }

  /// Updates an existing template row by [id] with the given [data].
  Future<void> updateTemplate(String id, Map<String, dynamic> data) async {
    try {
      await _client!.from(DbConstants.templatesTable).update(data).eq('id', id);
    } catch (e) {
      debugPrint("Error updating template: $e");
      rethrow;
    }
  }

  /// Soft-deletes a template by setting `is_active` to false.
  Future<void> deleteTemplate(String id) async {
    try {
      await _client!.from(DbConstants.templatesTable).update({'is_active': false}).eq('id', id);
    } catch (e) {
      debugPrint("Error soft-deleting template: $e");
      rethrow;
    }
  }

  // ── Homepage Sections CRUD ──────────────────────────────────────────────

  /// Fetches all homepage sections ordered by `sort_order`.
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

  /// Upserts a homepage section keyed by [sectionKey].
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

  /// Updates a homepage section row by [id] with the given [data].
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

  /// Updates the `sort_order` for each section in [sections] to persist drag-and-drop reordering.
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

  /// Inserts homepage sections from a registry if they do not already exist.
  ///
  /// Used during seeding/initialization. Returns the count of inserted rows.
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

  /// Inserts templates from a registry if they do not already exist (by ID).
  ///
  /// Used during seeding/initialization. Returns the count of inserted rows.
  Future<int> seedTemplatesFromRegistry(List<Map<String, dynamic>> templates) async {
    int inserted = 0;
    for (final t in templates) {
      try {
        // Check if template already exists by ID
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

  /// Fetches notifications for a user, newest first.
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

  /// Marks a single notification as read.
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

  /// Marks all notifications for a user as read.
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

  /// Sends a notification to all users via the `broadcast_notification` RPC,
  /// then fires an FCM push notification in the background.
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

      // Send FCM push in background (fire-and-forget)
      _sendFcmPush(userIds: null, title: title, message: message, type: type, redirectTo: redirectTo);
    } catch (e) {
      debugPrint("Error sending broadcast notification: $e");
      rethrow;
    }
  }

  /// Sends a notification to specific [userIds] via the `send_targeted_notification`
  /// RPC, then fires an FCM push notification in the background.
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

      // Send FCM push in background (fire-and-forget)
      _sendFcmPush(userIds: userIds, title: title, message: message, type: type, redirectTo: redirectTo);
    } catch (e) {
      debugPrint("Error sending targeted notification: $e");
      rethrow;
    }
  }

  /// Blocks or unblocks a list of users by setting `is_blocked` and `blocked_at`.
  ///
  /// Called from the admin panel for moderation actions.
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

  /// Changes the `tier` for a list of users in a single batch query.
  ///
  /// Called from the admin panel for bulk tier changes.
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

  /// Extends the subscription end date by [months] for each user in [userIds].
  ///
  /// Calculates the new end date relative to the existing `subscription_end_date`
  /// if it is in the future, or relative to the current date if it has expired.
  /// Called from the admin panel for bulk subscription extensions.
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

  /// Sends an FCM push notification via the `send-notification` Edge Function.
  ///
  /// Called fire-and-forget from [broadcastNotification] and [sendTargetedNotification].
  /// Failures are logged but never thrown — FCM errors must not break the UI flow.
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
      // Don't rethrow — FCM push failure shouldn't break the UI flow
    }
  }
}
