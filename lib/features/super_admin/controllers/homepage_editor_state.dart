sealed class HomepageEditorState {}

class HomepageEditorInitial extends HomepageEditorState {}

class HomepageEditorLoading extends HomepageEditorState {}

class HomepageEditorLoaded extends HomepageEditorState {
  final List<Map<String, dynamic>> sections;
  HomepageEditorLoaded({required this.sections});

  HomepageEditorLoaded copyWith({List<Map<String, dynamic>>? sections}) {
    return HomepageEditorLoaded(sections: sections ?? this.sections);
  }
}

class HomepageEditorFailure extends HomepageEditorState {
  final String message;
  HomepageEditorFailure(this.message);
}
