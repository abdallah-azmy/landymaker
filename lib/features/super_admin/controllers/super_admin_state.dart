sealed class SuperAdminState {}

class SuperAdminInitial extends SuperAdminState {}

class SuperAdminLoading extends SuperAdminState {}

class SuperAdminLoaded extends SuperAdminState {
  final int totalUsers;
  final int activePages;
  final int totalLeads;

  SuperAdminLoaded({
    required this.totalUsers,
    required this.activePages,
    required this.totalLeads,
  });
}

class SuperAdminFailure extends SuperAdminState {
  final String message;
  SuperAdminFailure(this.message);
}
