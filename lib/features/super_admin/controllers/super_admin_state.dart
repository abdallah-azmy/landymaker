sealed class SuperAdminState {}

class SuperAdminInitial extends SuperAdminState {}

class SuperAdminLoading extends SuperAdminState {}

class SuperAdminLoaded extends SuperAdminState {
  final int totalUsers;
  final int activePages;
  final int totalLeads;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> pages;
  final List<Map<String, dynamic>> requests;
  final List<Map<String, dynamic>> affiliates;
  final Map<String, dynamic> globalStats;
  
  // New configuration data
  final List<Map<String, dynamic>> plans;
  final Map<String, int> securityLimits;
  final List<Map<String, dynamic>> auditLogs;
  final List<Map<String, dynamic>> platformSeoSettings;

  SuperAdminLoaded({
    required this.totalUsers,
    required this.activePages,
    required this.totalLeads,
    this.users = const [],
    this.pages = const [],
    this.requests = const [],
    this.affiliates = const [],
    this.globalStats = const {},
    this.plans = const [],
    this.securityLimits = const {},
    this.auditLogs = const [],
    this.platformSeoSettings = const [],
  });

  SuperAdminLoaded copyWith({
    int? totalUsers,
    int? activePages,
    int? totalLeads,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? pages,
    List<Map<String, dynamic>>? requests,
    List<Map<String, dynamic>>? affiliates,
    Map<String, dynamic>? globalStats,
    List<Map<String, dynamic>>? plans,
    Map<String, int>? securityLimits,
    List<Map<String, dynamic>>? auditLogs,
    List<Map<String, dynamic>>? platformSeoSettings,
  }) {
    return SuperAdminLoaded(
      totalUsers: totalUsers ?? this.totalUsers,
      activePages: activePages ?? this.activePages,
      totalLeads: totalLeads ?? this.totalLeads,
      users: users ?? this.users,
      pages: pages ?? this.pages,
      requests: requests ?? this.requests,
      affiliates: affiliates ?? this.affiliates,
      globalStats: globalStats ?? this.globalStats,
      plans: plans ?? this.plans,
      securityLimits: securityLimits ?? this.securityLimits,
      auditLogs: auditLogs ?? this.auditLogs,
      platformSeoSettings: platformSeoSettings ?? this.platformSeoSettings,
    );
  }
}

class SuperAdminFailure extends SuperAdminState {
  final String message;
  SuperAdminFailure(this.message);
}
