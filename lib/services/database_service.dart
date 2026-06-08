import 'supabase_service.dart';

class DatabaseService {
  final SupabaseService _supabase;

  DatabaseService(this._supabase);

  Future<Map<String, dynamic>?> getLandingPageByUserId(String userId) {
    return _supabase.getLandingPageByUserId(userId);
  }

  Future<Map<String, dynamic>?> getLandingPageById(String pageId) {
    return _supabase.getLandingPageById(pageId);
  }

  Future<Map<String, dynamic>?> getLandingPageByDomain(String domain, {bool isCustom = false, bool publishedOnly = true}) {
    return _supabase.getLandingPageByDomain(domain, isCustom: isCustom, publishedOnly: publishedOnly);
  }

  Future<String?> saveLandingPage({
    required String userId,
    required String subdomain,
    String? customDomain,
    required Map<String, dynamic> designMap,
    required bool isPublished,
    String? websiteType,
    String? pageId,
  }) {
    return _supabase.saveLandingPage(
      userId: userId,
      subdomain: subdomain,
      customDomain: customDomain,
      designMap: designMap,
      isPublished: isPublished,
      websiteType: websiteType,
      pageId: pageId,
    );
  }

  Future<void> updatePagePublishStatus(String pageId, bool isPublished) {
    return _supabase.updatePagePublishStatus(pageId, isPublished);
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

  Future<List<Map<String, dynamic>>> listUserImages() {
    return _supabase.listUserImages();
  }

  Future<void> deleteImage(String fileName) {
    return _supabase.deleteImage(fileName);
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

  Future<List<Map<String, dynamic>>> getAdminAffiliates() {
    return _supabase.getAdminAffiliates();
  }

  Future<void> updateSubscriptionStatus(String id, String status) {
    return _supabase.updateSubscriptionStatus(id, status);
  }

  Future<void> updateCustomDomain(String pageId, String? domain) {
    return _supabase.updateCustomDomain(pageId, domain);
  }

  Future<String> refreshDomainVerificationToken(String pageId) {
    return _supabase.refreshDomainVerificationToken(pageId);
  }

  Future<Map<String, dynamic>> verifyCustomDomain(String pageId, {String? previousDomain, String action = 'verify'}) {
    return _supabase.verifyCustomDomain(pageId, previousDomain: previousDomain, action: action);
  }

  Future<Map<String, dynamic>> getAdminGlobalStats() {
    return _supabase.getAdminGlobalStats();
  }

  Future<List<Map<String, dynamic>>> getSubscriptionPlans() {
    return _supabase.getSubscriptionPlans();
  }

  Future<Map<String, int>> getSystemSecurityLimits() {
    return _supabase.getSystemSecurityLimits();
  }

  Future<void> updateSubscriptionPlan(String id, Map<String, dynamic> data) {
    return _supabase.updateSubscriptionPlan(id, data);
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _supabase.updateUserProfile(userId, data);
  }

  Future<List<Map<String, dynamic>>> getSystemAuditLogs() {
    return _supabase.getSystemAuditLogs();
  }

  Future<List<Map<String, dynamic>>> getPlatformSeoSettings() {
    return _supabase.getPlatformSeoSettings();
  }

  Future<void> updatePlatformSeoSettings(String routePath, Map<String, dynamic> data) {
    return _supabase.updatePlatformSeoSettings(routePath, data);
  }

  Future<bool> isRouteAvailable(String route, {String? excludePageId, bool checkPlatform = true, bool checkUsers = true}) {
    return _supabase.isRouteAvailable(route, excludePageId: excludePageId, checkPlatform: checkPlatform, checkUsers: checkUsers);
  }
}


