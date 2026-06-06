sealed class LeadsAnalyticsState {}

class LeadsAnalyticsInitial extends LeadsAnalyticsState {}

class LeadsAnalyticsLoading extends LeadsAnalyticsState {}

class LeadsAnalyticsLoaded extends LeadsAnalyticsState {
  final List<Map<String, dynamic>> leads;
  final int views;
  final int uniqueVisitors;
  final int conversions;
  final bool isSubmittingLead;
  final String? leadSuccessMessage;
  final String? leadErrorMessage;
  final String? errorMessage;

  LeadsAnalyticsLoaded({
    required this.leads,
    required this.views,
    required this.uniqueVisitors,
    required this.conversions,
    this.isSubmittingLead = false,
    this.leadSuccessMessage,
    this.leadErrorMessage,
    this.errorMessage,
  });

  double get conversionRate => uniqueVisitors > 0 ? (conversions / uniqueVisitors) * 100 : 0.0;

  LeadsAnalyticsLoaded copyWith({
    List<Map<String, dynamic>>? leads,
    int? views,
    int? uniqueVisitors,
    int? conversions,
    bool? isSubmittingLead,
    String? leadSuccessMessage,
    String? leadErrorMessage,
    String? errorMessage,
  }) {
    return LeadsAnalyticsLoaded(
      leads: leads ?? this.leads,
      views: views ?? this.views,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
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
