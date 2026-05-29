import 'supabase_service.dart';

class DatabaseService {
  final SupabaseService _supabase;

  DatabaseService(this._supabase);

  Future<Map<String, dynamic>?> getLandingPageByUserId(String userId) {
    return _supabase.getLandingPageByUserId(userId);
  }

  Future<Map<String, dynamic>?> getLandingPageByDomain(String domain, {bool isCustom = false}) {
    return _supabase.getLandingPageByDomain(domain, isCustom: isCustom);
  }

  Future<String?> saveLandingPage({
    required String userId,
    required String subdomain,
    String? customDomain,
    required Map<String, dynamic> designMap,
    required bool isPublished,
    String? pageId,
  }) {
    return _supabase.saveLandingPage(
      userId: userId,
      subdomain: subdomain,
      customDomain: customDomain,
      designMap: designMap,
      isPublished: isPublished,
      pageId: pageId,
    );
  }

  Future<bool> submitLead({required String landingPageId, required Map<String, dynamic> formData}) {
    return _supabase.submitLead(landingPageId: landingPageId, formData: formData);
  }

  Future<List<Map<String, dynamic>>> getLeadsByLandingPage(String landingPageId) {
    return _supabase.getLeadsByLandingPage(landingPageId);
  }

  Future<void> recordAnalyticsEvent({required String landingPageId, required String eventType}) {
    return _supabase.recordAnalyticsEvent(landingPageId: landingPageId, eventType: eventType);
  }

  Future<Map<String, int>> getPageAnalyticsStats(String landingPageId) {
    return _supabase.getPageAnalyticsStats(landingPageId);
  }

  Future<Map<String, dynamic>> getSuperAdminMetrics() {
    return _supabase.getSuperAdminMetrics();
  }
  Future<List<Map<String, dynamic>>> getLandingPagesByUserId(String userId) {
    return _supabase.getLandingPagesByUserId(userId);
  }

  Future<Map<String, dynamic>?> getProfile(String userId) {
    return _supabase.getProfile(userId);
  }

  Future<List<Map<String, dynamic>>> getAdminUsers() {
    return _supabase.getAdminUsers();
  }

  Future<List<Map<String, dynamic>>> getAdminPages() {
    return _supabase.getAdminPages();
  }

  Future<List<Map<String, dynamic>>> getAdminSubscriptionRequests() {
    return _supabase.getAdminSubscriptionRequests();
  }

  Future<void> updateSubscriptionStatus(String id, String status) {
    return _supabase.updateSubscriptionStatus(id, status);
  }
}
