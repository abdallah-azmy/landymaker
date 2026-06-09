import 'database_service.dart';

class SubscriptionService {
  final DatabaseService _databaseService;

  // Cache for plans and security limits to avoid excessive DB calls
  List<Map<String, dynamic>>? _plansCache;
  Map<String, int>? _securityLimitsCache;

  SubscriptionService(this._databaseService);

  Future<void> refreshCache() async {
    final plans = await _databaseService.getSubscriptionPlans();
    final limits = await _databaseService.getSystemSecurityLimits();
    _plansCache = plans;
    _securityLimitsCache = limits;
  }

  Future<Map<String, dynamic>?> _getUserPlan(String userId) async {
    final profile = await _databaseService.getProfile(userId);
    if (profile == null) return null;

    final String role = profile['role'] ?? 'user';
    final String tier = profile['tier'] ?? 'free';

    // Ensure cache is warm
    if (_plansCache == null || _securityLimitsCache == null) {
      await refreshCache();
    }

    if (role == 'super_admin') {
      return {
        'id': 'super_admin',
        'page_limit': _securityLimitsCache?['SUPER_ADMIN_PAGE_LIMIT'] ?? 500,
        'custom_domain_access': true,
        'advanced_seo_access': true,
        'ai_generation_limit': 999999,
        'has_smart_whatsapp': true,
        'has_white_label': true,
        'lead_limit_monthly': 999999,
        'team_member_limit': 999,
      };
    }

    return _plansCache?.firstWhere(
      (p) => p['id'] == tier,
      orElse: () => {'page_limit': 1},
    );
  }

  /// Calculates the maximum number of landing pages allowed for a user.
  Future<int> getMaxPages(String userId) async {
    final plan = await _getUserPlan(userId);
    return plan?['page_limit'] ?? 1;
  }

  /// Gets the AI generation limit for the user.
  Future<int> getAiGenerationLimit(String userId) async {
    final plan = await _getUserPlan(userId);
    return plan?['ai_generation_limit'] ?? 0;
  }

  /// Checks if the user can use Smart WhatsApp features.
  Future<bool> canAccessSmartWhatsApp(String userId) async {
    final plan = await _getUserPlan(userId);
    return plan?['has_smart_whatsapp'] == true;
  }

  /// Checks if the user can use White Label features.
  Future<bool> canAccessWhiteLabel(String userId) async {
    final plan = await _getUserPlan(userId);
    return plan?['has_white_label'] == true;
  }

  /// Gets the monthly lead limit for the user.
  Future<int> getMonthlyLeadLimit(String userId) async {
    final plan = await _getUserPlan(userId);
    return plan?['lead_limit_monthly'] ?? 100;
  }

  /// Gets the team member limit for the user.
  Future<int> getTeamMemberLimit(String userId) async {
    final plan = await _getUserPlan(userId);
    return plan?['team_member_limit'] ?? 1;
  }

  /// Checks if a user is a super admin.
  Future<bool> isSuperAdmin(String userId) async {
    final profile = await _databaseService.getProfile(userId);
    return profile?['role'] == 'super_admin';
  }

  /// Checks if a user can access premium features.
  /// Super admins always get access.
  Future<bool> canAccessPremiumFeatures(String userId) async {
    final plan = await _getUserPlan(userId);
    if (plan == null) return false;

    // Check specific flags from plan config
    return plan['custom_domain_access'] == true ||
        plan['advanced_seo_access'] == true;
  }

  /// Checks if a user has reached their page limit.
  Future<bool> hasReachedLimit(String userId) async {
    final maxPages = await getMaxPages(userId);
    final pages = await _databaseService.getLandingPagesByUserId(userId);
    return pages.length >= maxPages;
  }
}
