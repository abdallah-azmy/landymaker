sealed class LeadsAnalyticsState {}

class LeadsAnalyticsInitial extends LeadsAnalyticsState {}

class LeadsAnalyticsLoading extends LeadsAnalyticsState {}

class LeadsAnalyticsLoaded extends LeadsAnalyticsState {
  final List<Map<String, dynamic>> leads;
  final int views;
  final int conversions;
  final bool isSubmittingLead;
  final String? leadSuccessMessage;
  final String? leadErrorMessage;
  final String? errorMessage;

  LeadsAnalyticsLoaded({
    required this.leads,
    required this.views,
    required this.conversions,
    this.isSubmittingLead = false,
    this.leadSuccessMessage,
    this.leadErrorMessage,
    this.errorMessage,
  });

  LeadsAnalyticsLoaded copyWith({
    List<Map<String, dynamic>>? leads,
    int? views,
    int? conversions,
    bool? isSubmittingLead,
    String? leadSuccessMessage,
    String? leadErrorMessage,
    String? errorMessage,
  }) {
    return LeadsAnalyticsLoaded(
      leads: leads ?? this.leads,
      views: views ?? this.views,
      conversions: conversions ?? this.conversions,
      isSubmittingLead: isSubmittingLead ?? this.isSubmittingLead,
      leadSuccessMessage: leadSuccessMessage,
      leadErrorMessage: leadErrorMessage,
      errorMessage: errorMessage,
    );
  }
}

class LeadsAnalyticsFailure extends LeadsAnalyticsState {
  final String message;

  LeadsAnalyticsFailure(this.message);
}
