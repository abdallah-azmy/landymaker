import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../services/storage_service.dart';
import 'builder_state.dart';

class LandingPageBuilderCubit extends Cubit<BuilderState> {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;

  LandingPageBuilderCubit({
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
  })  : _authService = authService,
        _databaseService = databaseService,
        _storageService = storageService,
        super(BuilderInitial());

  /// Convenience method — UI does not need to know about userId
  Future<void> loadForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(BuilderFailure("No authenticated user found."));
      return;
    }
    await loadPageForUser(userId);
  }

  /// Convenience method — UI does not need to know about userId
  Future<void> saveForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    await savePage(userId);
  }

  Future<void> loadPageForUser(String userId) async {
    emit(BuilderLoading());
    try {
      final page = await _databaseService.getLandingPageByUserId(userId);
      Map<String, dynamic> designMap = {'blocks': []};
      String subdomain = '';
      String? customDomain;
      bool isPublished = false;

      if (page != null) {
        subdomain = page['subdomain'] ?? '';
        customDomain = page['custom_domain'];
        isPublished = page['is_published'] ?? false;

        final dynamic rawDesign = page['design_json'];
        if (rawDesign != null) {
          if (rawDesign is String) {
            designMap = Map<String, dynamic>.from(jsonDecode(rawDesign));
          } else {
            designMap = Map<String, dynamic>.from(rawDesign);
          }
        }
      }

      if (designMap['blocks'] == null || (designMap['blocks'] as List).isEmpty) {
        designMap['blocks'] = [
          {
            'type': 'hero',
            'title': 'Stunning Landing Pages Made Simple',
            'subtitle': 'Build responsive sites in under 5 minutes with our block builder.',
            'button_text': 'Get Started',
            'image_url': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800'
          }
        ];
      }

      emit(BuilderLoaded(
        designMap: designMap,
        subdomain: subdomain,
        customDomain: customDomain,
        isPublished: isPublished,
      ));
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  Future<void> savePage(String userId) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    emit(currentState.copyWith(isSaving: true));
    try {
      final success = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: currentState.subdomain,
        customDomain: currentState.customDomain,
        designMap: currentState.designMap,
        isPublished: currentState.isPublished,
      );
      if (success) {
        emit(currentState.copyWith(
          isSaving: false,
          successMessage: "Page configuration saved & deployed successfully.",
        ));
      } else {
        emit(currentState.copyWith(
          isSaving: false,
          errorMessage: "Save failed.",
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: "Save failed: $e",
      ));
    }
  }

  void updateSettings({String? subdomain, String? customDomain, bool? isPublished}) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final shouldClear = customDomain == '';
    emit(currentState.copyWith(
      subdomain: subdomain ?? currentState.subdomain,
      customDomain: shouldClear ? null : (customDomain ?? currentState.customDomain),
      clearCustomDomain: shouldClear,
      isPublished: isPublished ?? currentState.isPublished,
    ));
  }

  void addBlock(String type) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);

    if (type == 'hero') {
      blocks.add({
        'type': 'hero',
        'title': 'New Hero Section Title',
        'subtitle': 'Describe your primary value proposition here.',
        'button_text': 'Click Me',
        'image_url': 'https://images.unsplash.com/photo-1542744094-3a31f103e35f?w=800'
      });
    } else if (type == 'features') {
      blocks.add({
        'type': 'features',
        'title': 'Why Choose Us',
        'items': [
          {'title': 'Feature One', 'description': 'Explain the benefits of this feature.'},
          {'title': 'Feature Two', 'description': 'Highlight why this value item matters.'}
        ]
      });
    } else if (type == 'lead_form') {
      blocks.add({
        'type': 'lead_form',
        'title': 'Join Our Newsletter Today',
        'button_text': 'Subscribe Now'
      });
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deleteBlock(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void moveBlock(int index, bool up) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    final targetIndex = up ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= blocks.length) return;

    final temp = blocks[index];
    blocks[index] = blocks[targetIndex];
    blocks[targetIndex] = temp;

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateBlockProperty(int index, String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[index]);
      updatedBlock[key] = value;
      blocks[index] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateFeatureItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(items[itemIndex]);
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  Future<void> uploadBlockImage(int index, PlatformFile file) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    emit(currentState.copyWith(isSaving: true));
    try {
      final publicUrl = await _storageService.uploadImage(file);
      if (publicUrl != null) {
        final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
        final List blocks = List.from(newDesign['blocks'] ?? []);
        if (index >= 0 && index < blocks.length) {
          final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[index]);
          updatedBlock['image_url'] = publicUrl;
          blocks[index] = updatedBlock;
        }
        newDesign['blocks'] = blocks;
        emit(currentState.copyWith(designMap: newDesign, isSaving: false));
      } else {
        emit(currentState.copyWith(isSaving: false, errorMessage: "Image upload failed."));
      }
    } catch (e) {
      emit(currentState.copyWith(isSaving: false, errorMessage: "Upload failed: $e"));
    }
  }
}
