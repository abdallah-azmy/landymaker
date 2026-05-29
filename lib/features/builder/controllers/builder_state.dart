import '../models/landing_page_theme.dart';

sealed class BuilderState {}

class BuilderInitial extends BuilderState {}

class BuilderLoading extends BuilderState {}

class BuilderLoaded extends BuilderState {
  final String? pageId; // null when page not yet created in DB
  final Map<String, dynamic> designMap;
  final String subdomain;
  final String? customDomain;
  final bool isPublished;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final LandingPageTheme theme;

  BuilderLoaded({
    this.pageId,
    required this.designMap,
    required this.subdomain,
    this.customDomain,
    required this.isPublished,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    required this.theme,
  });

  BuilderLoaded copyWith({
    String? pageId,
    Map<String, dynamic>? designMap,
    String? subdomain,
    String? customDomain,
    bool? isPublished,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    LandingPageTheme? theme,
    bool clearCustomDomain = false,
    bool clearPageId = false,
  }) {
    return BuilderLoaded(
      pageId: clearPageId ? null : (pageId ?? this.pageId),
      designMap: designMap ?? this.designMap,
      subdomain: subdomain ?? this.subdomain,
      customDomain: clearCustomDomain ? null : (customDomain ?? this.customDomain),
      isPublished: isPublished ?? this.isPublished,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      theme: theme ?? this.theme,
    );
  }
}

class BuilderFailure extends BuilderState {
  final String message;

  BuilderFailure(this.message);
}
