import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database_service.dart';
import 'homepage_editor_state.dart';

class HomepageEditorCubit extends Cubit<HomepageEditorState> {
  final DatabaseService _databaseService;

  HomepageEditorCubit(this._databaseService) : super(HomepageEditorInitial());

  Future<void> loadSections() async {
    emit(HomepageEditorLoading());
    try {
      final sections = await _databaseService.getHomepageSections();
      emit(HomepageEditorLoaded(sections: sections));
    } catch (e) {
      emit(HomepageEditorFailure('فشل تحميل الأقسام: $e'));
    }
  }

  Future<void> toggleVisibility(String id, bool visible) async {
    if (state is! HomepageEditorLoaded) return;
    try {
      await _databaseService.updateHomepageSection(id, {'is_visible': visible});
      await loadSections();
    } catch (e) {
      emit(HomepageEditorFailure('فشل تغيير حالة القسم: $e'));
    }
  }

  Future<void> updateConfig(String id, Map<String, dynamic> config) async {
    if (state is! HomepageEditorLoaded) return;
    try {
      await _databaseService.updateHomepageSection(id, {'config': config});
      await loadSections();
    } catch (e) {
      emit(HomepageEditorFailure('فشل تحديث الإعدادات: $e'));
    }
  }

  Future<void> reorder(List<Map<String, dynamic>> sections) async {
    if (state is! HomepageEditorLoaded) return;
    try {
      await _databaseService.reorderHomepageSections(sections);
      await loadSections();
    } catch (e) {
      emit(HomepageEditorFailure('فشل إعادة الترتيب: $e'));
    }
  }
}
