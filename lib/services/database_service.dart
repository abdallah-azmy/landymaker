import 'supabase_service.dart';

class DatabaseService {
  final SupabaseService _supabase;

  DatabaseService(this._supabase);

  Future<List<Map<String, dynamic>>> fetchAllLandingPages() {
    return _supabase.getAllLandingPages();
  }

  Future<Map<String, dynamic>?> getLandingPageByUserId(String userId) {
    return _supabase.getLandingPageByUserId(userId);
  }

  Future<Map<String, dynamic>?> getLandingPageById(String pageId) {
    return _supabase.getLandingPageById(pageId);
  }

  Future<List<Map<String, dynamic>>> getLandingPagesByIds(List<String> pageIds) {
    return _supabase.getLandingPagesByIds(pageIds);
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

  Future<void> recordPageEvent({
    required String landingPageId,
    required String eventType,
    Map<String, dynamic> metadata = const {},
  }) {
    return _supabase.recordPageEvent(
      landingPageId: landingPageId,
      eventType: eventType,
      metadata: metadata,
    );
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

  Future<List<Map<String, dynamic>>> getUserSubscriptionRequests(String userId) {
    return _supabase.getUserSubscriptionRequests(userId);
  }

  Future<List<Map<String, dynamic>>> getUserAuditLogs(String userId) {
    return _supabase.getUserAuditLogs(userId);
  }

  Future<Map<String, dynamic>> getUserAggregatedAnalytics(String userId) {
    return _supabase.getUserAggregatedAnalytics(userId);
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

  // ----------------------------------------------------
  // TEMPLATE OPERATIONS
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchPublicTemplates() {
    return _supabase.fetchPublicTemplates();
  }

  Future<List<Map<String, dynamic>>> fetchFeaturedTemplates() {
    return _supabase.fetchFeaturedTemplates();
  }

  Future<List<Map<String, dynamic>>> fetchAllTemplates() {
    return _supabase.fetchAllTemplates();
  }

  Future<void> createTemplate(Map<String, dynamic> data) {
    return _supabase.createTemplate(data);
  }

  Future<void> updateTemplate(String id, Map<String, dynamic> data) {
    return _supabase.updateTemplate(id, data);
  }

  Future<void> deleteTemplate(String id) {
    return _supabase.deleteTemplate(id);
  }

  Future<List<Map<String, dynamic>>> getHomepageSections() {
    return _supabase.getHomepageSections();
  }

  Future<void> upsertHomepageSection(String sectionKey, Map<String, dynamic> data) {
    return _supabase.upsertHomepageSection(sectionKey, data);
  }

  Future<void> updateHomepageSection(String id, Map<String, dynamic> data) {
    return _supabase.updateHomepageSection(id, data);
  }

  Future<void> reorderHomepageSections(List<Map<String, dynamic>> sections) {
    return _supabase.reorderHomepageSections(sections);
  }

  Future<int> seedHomepageSectionsFromRegistry(List<Map<String, dynamic>> sections) {
    return _supabase.seedHomepageSectionsFromRegistry(sections);
  }

  Future<int> seedTemplatesFromRegistry(List<Map<String, dynamic>> templates) {
    return _supabase.seedTemplatesFromRegistry(templates);
  }

  // ----------------------------------------------------
  // BULK OPERATIONS
  // ----------------------------------------------------

  Future<void> bulkBlockUsers(List<String> userIds, bool isBlocked) {
    return _supabase.bulkBlockUsers(userIds, isBlocked);
  }

  Future<void> bulkUpdateUserTier(List<String> userIds, String newTier) {
    return _supabase.bulkUpdateUserTier(userIds, newTier);
  }

  Future<void> bulkAddSubscriptionMonths(List<String> userIds, int months) {
    return _supabase.bulkAddSubscriptionMonths(userIds, months);
  }

  Future<void> sendTargetedNotification(
    List<String> userIds,
    String title,
    String message,
    String type, {
    String? redirectTo,
  }) {
    return _supabase.sendTargetedNotification(userIds, title, message, type, redirectTo: redirectTo);
  }
}


