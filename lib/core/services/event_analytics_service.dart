class EventAnalyticsService {
  /// Emits an event to the analytics engine (e.g. Firebase Analytics, Mixpanel, etc)
  static void logEvent({
    required String eventName,
    required Map<String, dynamic> parameters,
  }) {
    // TODO: Connect to actual analytics provider here
    // print("ANALYTICS EVENT: $eventName | $parameters");
  }
}
