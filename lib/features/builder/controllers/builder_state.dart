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
  final String websiteType;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final bool canUndo;
  final bool canRedo;
  final String? errorMessage;
  final String? successMessage;
  final LandingPageTheme theme;
  final String? focusedElementId; // Track long-pressed element
  final int? focusedSectionIndex;

  BuilderLoaded({
    this.pageId,
    required this.designMap,
    required this.subdomain,
    this.customDomain,
    required this.isPublished,
    this.websiteType = 'landing_page',
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.canUndo = false,
    this.canRedo = false,
    this.errorMessage,
    this.successMessage,
    required this.theme,
    this.focusedElementId,
    this.focusedSectionIndex,
  });

  BuilderLoaded copyWith({
    String? pageId,
    Map<String, dynamic>? designMap,
    String? subdomain,
    String? customDomain,
    bool? isPublished,
    String? websiteType,
    bool? isSaving,
    bool? hasUnsavedChanges,
    bool? canUndo,
    bool? canRedo,
    String? errorMessage,
    String? successMessage,
    LandingPageTheme? theme,
    String? focusedElementId,
    int? focusedSectionIndex,
    bool clearFocusedElement = false,
    bool clearCustomDomain = false,
    bool clearPageId = false,
  }) {
    return BuilderLoaded(
      pageId: clearPageId ? null : (pageId ?? this.pageId),
      designMap: designMap ?? this.designMap,
      subdomain: subdomain ?? this.subdomain,
      customDomain: clearCustomDomain ? null : (customDomain ?? this.customDomain),
      isPublished: isPublished ?? this.isPublished,
      websiteType: websiteType ?? this.websiteType,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      errorMessage: errorMessage,
      successMessage: successMessage,
      theme: theme ?? this.theme,
      focusedElementId: clearFocusedElement ? null : (focusedElementId ?? this.focusedElementId),
      focusedSectionIndex: clearFocusedElement ? null : (focusedSectionIndex ?? this.focusedSectionIndex),
    );
  }
}

class BuilderFailure extends BuilderState {
  final String message;

  BuilderFailure(this.message);
}
