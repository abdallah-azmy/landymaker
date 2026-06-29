import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/json_utils.dart';
import '../../../services/database_service.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import 'public_page_state.dart';

class PublicPageCubit extends Cubit<PublicPageState> {
  final DatabaseService _databaseService;
  final LeadsAnalyticsCubit _leadsAnalyticsCubit;

  PublicPageCubit({
    required DatabaseService databaseService,
    required LeadsAnalyticsCubit leadsAnalyticsCubit,
  })  : _databaseService = databaseService,
        _leadsAnalyticsCubit = leadsAnalyticsCubit,
        super(PublicPageInitial());

  Future<void> loadByIdentifier(String identifier, bool isCustom) async {
    emit(PublicPageLoading());
    try {
      final page = await _databaseService.getLandingPageByDomain(identifier, isCustom: isCustom);
      if (page != null) {
        final designMap = await parseJsonDesign(page['design_json']);

        final List rawBlocks = designMap['blocks'] ?? [];
        final List<Map<String, dynamic>> blocks = rawBlocks
            .map((b) => Map<String, dynamic>.from(b as Map))
            .toList();

        emit(PublicPageLoaded(
          pageData: page,
          blocks: blocks,
          designJson: designMap,
        ));

        // Record a page view event in the background
        final pageId = page['id'] as String;
        _leadsAnalyticsCubit.recordView(pageId);
      } else {
        emit(PublicPageNotFound(identifier));
      }
    } catch (e) {
      emit(PublicPageFailure(e.toString()));
    }
  }
}
