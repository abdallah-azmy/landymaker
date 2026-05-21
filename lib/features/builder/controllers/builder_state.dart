sealed class BuilderState {}

class BuilderInitial extends BuilderState {}

class BuilderLoading extends BuilderState {}

class BuilderLoaded extends BuilderState {
  final Map<String, dynamic> designMap;
  final String subdomain;
  final String? customDomain;
  final bool isPublished;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  BuilderLoaded({
    required this.designMap,
    required this.subdomain,
    this.customDomain,
    required this.isPublished,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  BuilderLoaded copyWith({
    Map<String, dynamic>? designMap,
    String? subdomain,
    String? customDomain,
    bool? isPublished,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearCustomDomain = false,
  }) {
    return BuilderLoaded(
      designMap: designMap ?? this.designMap,
      subdomain: subdomain ?? this.subdomain,
      customDomain: clearCustomDomain ? null : (customDomain ?? this.customDomain),
      isPublished: isPublished ?? this.isPublished,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class BuilderFailure extends BuilderState {
  final String message;

  BuilderFailure(this.message);
}
