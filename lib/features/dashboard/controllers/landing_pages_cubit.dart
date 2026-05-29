import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import 'landing_pages_state.dart';

class LandingPagesCubit extends Cubit<LandingPagesState> {
  final DatabaseService _databaseService;
  final AuthService _authService;

  LandingPagesCubit({
    required DatabaseService databaseService,
    required AuthService authService,
  })  : _databaseService = databaseService,
        _authService = authService,
        super(LandingPagesInitial());

  Future<void> loadPages() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(const LandingPagesFailure("No authenticated user found."));
      return;
    }

    emit(LandingPagesLoading());
    try {
      final pages = await _databaseService.getLandingPagesByUserId(userId);
      emit(LandingPagesLoaded(pages: pages));
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
