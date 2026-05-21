sealed class PublicPageState {}

class PublicPageInitial extends PublicPageState {}

class PublicPageLoading extends PublicPageState {}

class PublicPageLoaded extends PublicPageState {
  final Map<String, dynamic> pageData;
  final List<Map<String, dynamic>> blocks;

  PublicPageLoaded({required this.pageData, required this.blocks});
}

class PublicPageNotFound extends PublicPageState {
  final String identifier;
  PublicPageNotFound(this.identifier);
}

class PublicPageFailure extends PublicPageState {
  final String message;
  PublicPageFailure(this.message);
}
