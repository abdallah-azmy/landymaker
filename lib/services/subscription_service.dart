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

  /// Calculates the maximum number of landing pages allowed for a user.
  Future<int> getMaxPages(String userId) async {
    final profile = await _databaseService.getProfile(userId);
    if (profile == null) return 1;

    final String role = profile['role'] ?? 'user';
    final String tier = profile['tier'] ?? 'free';
    
    // Ensure cache is warm
    if (_plansCache == null || _securityLimitsCache == null) {
      await refreshCache();
    }

    // Rule 1: Super Admin Special Account Limit
    if (role == 'super_admin') {
      return _securityLimitsCache?['SUPER_ADMIN_PAGE_LIMIT'] ?? 500;
    }

    // Rule 2: Tier based limits from DB
    final plan = _plansCache?.firstWhere(
      (p) => p['id'] == tier, 
      orElse: () => {'page_limit': 1},
    );
    
    return plan?['page_limit'] ?? 1;
  }

  /// Checks if a user is a super admin.
  Future<bool> isSuperAdmin(String userId) async {
    final profile = await _databaseService.getProfile(userId);
    return profile?['role'] == 'super_admin';
  }

  /// Checks if a user can access premium features.
  /// Super admins always get access.
  Future<bool> canAccessPremiumFeatures(String userId) async {
    final profile = await _databaseService.getProfile(userId);
    if (profile == null) return false;

    final String role = profile['role'] ?? 'user';
    if (role == 'super_admin') return true;

    final String tier = profile['tier'] ?? 'free';
    
    if (_plansCache == null) await refreshCache();
    
    final plan = _plansCache?.firstWhere((p) => p['id'] == tier, orElse: () => {});
    
    // Check specific flags from plan config
    return plan?['custom_domain_access'] == true || plan?['advanced_seo_access'] == true;
  }

  /// Checks if a user has reached their page limit.
  Future<bool> hasReachedLimit(String userId) async {
    // Ensure cache is warm
    if (_plansCache == null || _securityLimitsCache == null) {
      await refreshCache();
    }

    final maxPages = await getMaxPages(userId);
    final pages = await _databaseService.getLandingPagesByUserId(userId);
    return pages.length >= maxPages;
  }
}
