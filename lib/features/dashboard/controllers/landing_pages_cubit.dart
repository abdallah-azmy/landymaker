import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../services/subscription_service.dart';
import 'landing_pages_state.dart';

class LandingPagesCubit extends Cubit<LandingPagesState> {
  final DatabaseService _databaseService;
  final AuthService _authService;
  final SubscriptionService _subscriptionService;

  LandingPagesCubit({
    required DatabaseService databaseService,
    required AuthService authService,
    required SubscriptionService subscriptionService,
  })  : _databaseService = databaseService,
        _authService = authService,
        _subscriptionService = subscriptionService,
        super(LandingPagesInitial());

  Future<void> loadPages() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(const LandingPagesFailure("No authenticated user found."));
      return;
    }

    emit(LandingPagesLoading());
    try {
      // Warm up the subscription cache first
      await _subscriptionService.refreshCache();
      
      final pages = await _databaseService.getLandingPagesByUserId(userId);
      
      // Centralized Tier & Role Enforcement from DB
      final profile = await _databaseService.getProfile(userId);
      final String tier = profile?['tier'] ?? 'free';
      final int maxPages = await _subscriptionService.getMaxPages(userId);

      emit(LandingPagesLoaded(
        pages: pages,
        maxPages: maxPages,
        currentTier: tier,
      ));
    } catch (e) {
      emit(LandingPagesFailure(e.toString()));
    }
  }

  Future<void> deletePage(String pageId) async {
    // Basic deletion logic
    try {
      // Assuming DatabaseService has deleteLandingPage (need to add or check)
      // For now, reload after delete
      await loadPages();
    } catch (e) {
      emit(LandingPagesFailure(e.toString()));
    }
  }
}
