import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import 'leads_analytics_state.dart';

class LeadsAnalyticsCubit extends Cubit<LeadsAnalyticsState> {
  final AuthService _authService;
  final DatabaseService _databaseService;

  LeadsAnalyticsCubit({
    required AuthService authService,
    required DatabaseService databaseService,
  })  : _authService = authService,
        _databaseService = databaseService,
        super(LeadsAnalyticsInitial());

  /// Convenience method — UI does not need to know about userId
  Future<void> fetchStatsForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(LeadsAnalyticsFailure("No authenticated user found."));
      return;
    }
    await fetchStatsAndLeads(userId);
  }

  Future<void> fetchStatsAndLeads(String userId) async {
    emit(LeadsAnalyticsLoading());
    try {
      final page = await _databaseService.getLandingPageByUserId(userId);
      if (page != null) {
        final pageId = page['id'] as String;
        final stats = await _databaseService.getPageAnalyticsStats(pageId);
        final leads = await _databaseService.getLeadsByLandingPage(pageId);
        emit(LeadsAnalyticsLoaded(
          leads: leads,
          views: stats['views'] ?? 0,
          conversions: stats['conversions'] ?? 0,
        ));
      } else {
        emit(LeadsAnalyticsLoaded(
          leads: const [],
          views: 0,
          conversions: 0,
        ));
      }
    } catch (e) {
      emit(LeadsAnalyticsFailure(e.toString()));
    }
  }

  Future<void> recordView(String pageId) async {
    try {
      await _databaseService.recordAnalyticsEvent(
        landingPageId: pageId,
        eventType: 'view',
      );
      final currentState = state;
      if (currentState is LeadsAnalyticsLoaded) {
        emit(currentState.copyWith(views: currentState.views + 1));
      }
    } catch (_) {}
  }

  Future<void> recordConversion(String pageId) async {
    try {
      await _databaseService.recordAnalyticsEvent(
        landingPageId: pageId,
        eventType: 'conversion',
      );
      final currentState = state;
      if (currentState is LeadsAnalyticsLoaded) {
        emit(currentState.copyWith(conversions: currentState.conversions + 1));
      }
    } catch (_) {}
  }

  Future<void> submitLead(String pageId, Map<String, dynamic> formData) async {
    final currentState = state;
    final bool isLoaded = currentState is LeadsAnalyticsLoaded;

    final initialLeads = isLoaded ? currentState.leads : <Map<String, dynamic>>[];
    final initialViews = isLoaded ? currentState.views : 0;
    final initialConversions = isLoaded ? currentState.conversions : 0;

    emit(LeadsAnalyticsLoaded(
      leads: initialLeads,
      views: initialViews,
      conversions: initialConversions,
      isSubmittingLead: true,
    ));

    try {
      final success = await _databaseService.submitLead(
        landingPageId: pageId,
        formData: formData,
      );
      if (success) {
        await recordConversion(pageId);
        final updatedState = state as LeadsAnalyticsLoaded;
        emit(updatedState.copyWith(
          isSubmittingLead: false,
          leadSuccessMessage: "Lead submitted successfully!",
        ));
      } else {
        final updatedState = state as LeadsAnalyticsLoaded;
        emit(updatedState.copyWith(
          isSubmittingLead: false,
          leadErrorMessage: "Failed to submit lead.",
        ));
      }
    } catch (e) {
      final updatedState = state as LeadsAnalyticsLoaded;
      emit(updatedState.copyWith(
        isSubmittingLead: false,
        leadErrorMessage: "Error: $e",
      ));
    }
  }
}
