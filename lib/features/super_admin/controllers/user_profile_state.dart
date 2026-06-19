sealed class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> pages;
  final List<Map<String, dynamic>> subscriptionRequests;
  final List<Map<String, dynamic>> auditLogs;
  final Map<String, dynamic> analytics;

  UserProfileLoaded({
    required this.profile,
    required this.pages,
    required this.subscriptionRequests,
    required this.auditLogs,
    required this.analytics,
  });
}

class UserProfileFailure extends UserProfileState {
  final String message;
  UserProfileFailure(this.message);
}
