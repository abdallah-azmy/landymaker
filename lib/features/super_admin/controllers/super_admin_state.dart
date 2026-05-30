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

  SuperAdminLoaded({
    required this.totalUsers,
    required this.activePages,
    required this.totalLeads,
    this.users = const [],
    this.pages = const [],
    this.requests = const [],
    this.affiliates = const [],
    this.globalStats = const {},
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
    );
  }
}

class SuperAdminFailure extends SuperAdminState {
  final String message;
  SuperAdminFailure(this.message);
}
