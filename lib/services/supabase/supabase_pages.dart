// ignore_for_file: unused_element
part of '../supabase_service.dart';


// ----------------------------------------------------
// LANDING PAGES OPERATIONS
// ----------------------------------------------------

mixin SupabaseServicePages on ChangeNotifier {
  SupabaseClient? get _client;
  set _client(SupabaseClient? val);

  String? get _currentUserId;
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

        if (isCustom && tier == 'free') {
          debugPrint("Access denied: Custom domain accessed on free tier.");
          return null;
        }

        final lastVisited = DateTime.parse(res['last_visited_at'] ?? res['created_at']);

        if (tier == 'free' && DateTime.now().difference(lastVisited).inDays > 30) {
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

  Future<String?> saveLandingPage({
    required String userId,
    required String subdomain,
    String? customDomain,
    required Map<String, dynamic> designMap,
    String? designJson,
    required bool isPublished,
    String? websiteType,
    String? pageId,
  }) async {
    final effectiveCustomDomain =
        customDomain == null || customDomain.trim().isEmpty
        ? null
        : customDomain.trim();

    final encoded = designJson ?? jsonEncode(designMap);

    try {
      if (pageId != null) {
        await _client!
            .from(DbConstants.landingPagesTable)
            .update({
              'subdomain': subdomain,
              'custom_domain': effectiveCustomDomain,
              'design_json': encoded,
              'is_published': isPublished,
              'website_type': websiteType ?? 'landing_page',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', pageId);
        return pageId;
      } else {
        final result = await _client!
            .from(DbConstants.landingPagesTable)
            .insert({
              'user_id': userId,
              'subdomain': subdomain,
              'custom_domain': effectiveCustomDomain,
              'design_json': encoded,
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
        debugPrint("Edge Function error: $error");
        return false;
      }
    } catch (e) {
      debugPrint("Error submitting lead via Edge Function: $e");
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
    await recordPageEvent(landingPageId: landingPageId, eventType: eventType);
  }

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

  Future<Map<String, int>> getPageAnalyticsStats(String landingPageId) async {
    try {
      final res = await _client!.rpc('get_enhanced_page_stats', params: {'page_id': landingPageId});

      return {
        'views': res['total_views'] ?? 0,
        'unique_visitors': res['unique_visitors'] ?? 0,
        'conversions': res['total_conversions'] ?? 0,
      };
    } catch (e) {
      debugPrint("Error fetching analytics stats: $e");
      return {'views': 0, 'unique_visitors': 0, 'conversions': 0};
    }
  }
}

