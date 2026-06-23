/// ======================================================
/// FEATURE: Builder State Management
/// PURPOSE: Core logic for editing landing pages (Undo/Redo, Auto-save)
/// USED BY: BuilderWorkspaceScreen
/// DEPENDENCIES:
/// - DatabaseService
/// - StorageService
/// - TemplateRegistry
/// ======================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/controllers/upload_manager_cubit.dart';
import 'package:landymaker/features/builder/models/selected_image_data.dart';
import 'package:landymaker/injection_container.dart';
import 'package:landymaker/services/image_media_service.dart';
import 'package:uuid/uuid.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/subscription_service.dart';
import '../models/landing_page_theme.dart';
import '../registries/template_registry.dart';
import 'builder_state.dart';
import 'builder_theme_cubit.dart';

class LandingPageBuilderCubit extends Cubit<BuilderState> {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;
  final SubscriptionService _subscriptionService;
  final BuilderThemeCubit _themeCubit;
  StreamSubscription? _themeSubscription;
  bool _suppressHistoryFromTheme = false;

  final List<String> _history = [];
  int _historyIndex = -1;

  LandingPageBuilderCubit({
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
    required SubscriptionService subscriptionService,
    required BuilderThemeCubit themeCubit,
  }) : _authService = authService,
       _databaseService = databaseService,
       _storageService = storageService,
       _subscriptionService = subscriptionService,
       _themeCubit = themeCubit,
       super(BuilderInitial()) {
    _themeSubscription = _themeCubit.stream.listen((theme) {
      if (_suppressHistoryFromTheme) return;
      final currentState = state;
      if (currentState is BuilderLoaded) {
        _emitDirty(currentState.copyWith(theme: theme));
      }
    });
  }

  @override
  Future<void> close() {
    _themeSubscription?.cancel();
    return super.close();
  }

  void _saveToHistory(BuilderLoaded state) {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final newStateStr = jsonEncode({
      'designMap': state.designMap,
      'theme': state.theme.toJson(),
    });

    // Do not add duplicate states if the data hasn't actually changed
    if (_history.isNotEmpty &&
        _historyIndex >= 0 &&
        _historyIndex < _history.length) {
      if (_history[_historyIndex] == newStateStr) {
        return;
      }
    }

    _history.add(newStateStr);
    _historyIndex = _history.length - 1;

    // Limit history to 50 steps
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void _emitDirty(
    BuilderLoaded state, {
    bool isClean = false,
    bool skipHistory = false,
  }) {
    if (!skipHistory) {
      _saveToHistory(state);
    }
    emit(
      state.copyWith(
        hasUnsavedChanges: !isClean,
        canUndo: _historyIndex > 0,
        canRedo: _historyIndex < _history.length - 1,
      ),
    );
  }

  void undo() {
    final currentState = state;
    if (currentState is! BuilderLoaded || _historyIndex <= 0) return;

    _historyIndex--;
    final snapshot = jsonDecode(_history[_historyIndex]);
    final restoredTheme = LandingPageTheme.fromJson(snapshot['theme']);
    _suppressHistoryFromTheme = true;
    _themeCubit.replaceTheme(restoredTheme);
    _suppressHistoryFromTheme = false;
    _emitDirty(
      currentState.copyWith(
        designMap: snapshot['designMap'],
        theme: restoredTheme,
      ),
      isClean: false,
      skipHistory: true,
    );
  }

  void redo() {
    final currentState = state;
    if (currentState is! BuilderLoaded || _historyIndex >= _history.length - 1)
      return;

    _historyIndex++;
    final snapshot = jsonDecode(_history[_historyIndex]);
    final restoredTheme = LandingPageTheme.fromJson(snapshot['theme']);
    _suppressHistoryFromTheme = true;
    _themeCubit.replaceTheme(restoredTheme);
    _suppressHistoryFromTheme = false;
    _emitDirty(
      currentState.copyWith(
        designMap: snapshot['designMap'],
        theme: restoredTheme,
      ),
      isClean: false,
      skipHistory: true,
    );
  }

  Future<void> loadForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(BuilderFailure("No authenticated user found."));
      return;
    }
    await loadPageForUser(userId);
  }

  Future<void> saveForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    await savePage(userId);
  }

  /// Claim a guest's in-memory design after registration:
  /// generates a random slug (site-xxxxx) and saves to DB.
  Future<String?> claimGuestDesign(String userId) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return null;

    // Generate random slug if none set
    String slug = currentState.subdomain.trim();
    if (slug.isEmpty) {
      const String prefix = 'site-';
      final String random = const Uuid().v4().substring(0, 8);
      slug = '$prefix$random';
    }

    final String sanitized = slug
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    // Check route availability
    final isAvailable = await _databaseService.isRouteAvailable(
      sanitized,
      excludePageId: currentState.pageId,
    );
    if (!isAvailable) {
      // Fallback: retry with a different random suffix
      final String retrySlug = 'site-${const Uuid().v4().substring(0, 8)}';
      final retryAvailable = await _databaseService.isRouteAvailable(retrySlug);
      if (!retryAvailable) return null;
      return _saveGuestDesign(userId, retrySlug, currentState);
    }

    return _saveGuestDesign(userId, sanitized, currentState);
  }

  Future<String?> _saveGuestDesign(
    String userId,
    String subdomain,
    BuilderLoaded currentState,
  ) async {
    try {
      final Map<String, dynamic> finalDesign = Map<String, dynamic>.from(
        currentState.designMap,
      );
      finalDesign['theme'] = currentState.theme.toJson();

      final savedPageId = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: subdomain,
        customDomain: currentState.customDomain,
        designMap: finalDesign,
        isPublished: currentState.isPublished,
        websiteType: currentState.websiteType,
        pageId: null,
      );

      if (savedPageId != null) {
        _emitDirty(
          currentState.copyWith(pageId: savedPageId, subdomain: subdomain),
          isClean: true,
        );
      }
      return savedPageId;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPageForUser(String userId) async {
    emit(BuilderLoading());
    try {
      final page = await _databaseService.getLandingPageByUserId(userId);
      _handleLoadedPage(page);
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  Future<void> loadPageById(String pageIdOrSubdomain) async {
    emit(BuilderLoading());
    try {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );
      Map<String, dynamic>? page;
      if (uuidRegex.hasMatch(pageIdOrSubdomain)) {
        page = await _databaseService.getLandingPageById(pageIdOrSubdomain);
      } else {
        page = await _databaseService.getLandingPageByDomain(
          pageIdOrSubdomain,
          publishedOnly: false,
        );
      }
      _handleLoadedPage(page);
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  void applyDesignJson(Map<String, dynamic> designJson) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    // 1. Theme Update
    LandingPageTheme? newTheme;
    final themeJson = designJson['theme'] ?? designJson['global_theme'];
    if (themeJson != null && themeJson is Map) {
      final Map<String, dynamic> mergedThemeJson = currentState.theme.toJson();
      themeJson.forEach((key, value) {
        if (value != null) {
          mergedThemeJson[key] = value;
        }
      });
      newTheme = LandingPageTheme.fromJson(mergedThemeJson);
    }

    // 2. Blocks Update
    Map<String, dynamic> newDesignMap = Map<String, dynamic>.from(
      currentState.designMap,
    );
    if (newTheme != null) {
      newDesignMap['theme'] = newTheme.toJson();
      newDesignMap['global_theme'] = newTheme.toJson();
    }

    final List incomingBlocks = designJson['blocks'] as List? ?? [];

    // Check if it's a partial update (contains _index)
    bool isPartial = incomingBlocks.any(
      (b) => b is Map && b.containsKey('_index'),
    );
    final bool isFullRebuild = designJson['full_rebuild'] == true;

    if (isFullRebuild) {
      newDesignMap['blocks'] = incomingBlocks;
      designJson.forEach((key, value) {
        if (key != 'blocks' &&
            key != 'theme' &&
            key != 'global_theme' &&
            key != 'full_rebuild') {
          newDesignMap[key] = value;
        }
      });
    } else if (isPartial) {
      final List currentBlocks = List.from(newDesignMap['blocks'] ?? []);
      for (var block in incomingBlocks) {
        if (block is Map && block.containsKey('_index')) {
          final int index = block['_index'];
          if (index >= 0 && index < currentBlocks.length) {
            // Merge or replace specific block
            final existing = Map<String, dynamic>.from(
              currentBlocks[index] as Map,
            );
            final updated = Map<String, dynamic>.from(block)..remove('_index');
            final cleanedUpdated = _cleanIncomingMap(updated);
            existing.addAll(cleanedUpdated);
            currentBlocks[index] = existing;
          } else if (index == currentBlocks.length) {
            // New block at the end
            final updated = Map<String, dynamic>.from(block)..remove('_index');
            currentBlocks.add(_cleanIncomingMap(updated));
          }
        }
      }
      newDesignMap['blocks'] = currentBlocks;

      // Also update business info if provided
      if (designJson.containsKey('business_name'))
        newDesignMap['business_name'] = designJson['business_name'];
      if (designJson.containsKey('business_type'))
        newDesignMap['business_type'] = designJson['business_type'];
    } else {
      final List currentBlocks = List.from(newDesignMap['blocks'] ?? []);

      // Smart Heuristic: Check if the incoming blocks list is a subset edit
      bool isSubsetEdit = false;
      if (currentBlocks.isNotEmpty &&
          incomingBlocks.isNotEmpty &&
          incomingBlocks.length < currentBlocks.length) {
        final bool currentHasHero = currentBlocks.any(
          (b) => b is Map && (b['type'] == 'hero' || b['type'] == 'hero_saas'),
        );
        final bool incomingHasHero = incomingBlocks.any(
          (b) => b is Map && (b['type'] == 'hero' || b['type'] == 'hero_saas'),
        );

        if ((currentHasHero && !incomingHasHero) ||
            incomingBlocks.length <= 2) {
          isSubsetEdit = true;
        }
      }

      if (incomingBlocks.isEmpty) {
        // AI returned empty blocks - DO NOT overwrite with empty. Keep current blocks.
      } else if (isSubsetEdit) {
        // Merge incoming blocks into current blocks by matching their types sequentially
        final List<bool> matched = List.filled(currentBlocks.length, false);
        for (var inBlock in incomingBlocks) {
          if (inBlock is Map) {
            final String inType = (inBlock['type'] ?? '').toString();
            int matchIdx = -1;
            for (int j = 0; j < currentBlocks.length; j++) {
              if (!matched[j]) {
                final currentBlock = currentBlocks[j] as Map;
                if (currentBlock['type'] == inType) {
                  matchIdx = j;
                  break;
                }
              }
            }

            if (matchIdx != -1) {
              matched[matchIdx] = true;
              final existing = Map<String, dynamic>.from(
                currentBlocks[matchIdx] as Map,
              );
              final updated = Map<String, dynamic>.from(inBlock);
              final cleanedUpdated = _cleanIncomingMap(updated);
              existing.addAll(cleanedUpdated);
              currentBlocks[matchIdx] = existing;
            } else {
              // No matching type found, append it as a new block
              currentBlocks.add(
                _cleanIncomingMap(Map<String, dynamic>.from(inBlock)),
              );
            }
          }
        }
        newDesignMap['blocks'] = currentBlocks;
      } else {
        // Full update edit: merge block-by-block with current blocks.
        // We want to preserve all current blocks, and merge incoming blocks where they match.
        final List mergedBlocks = List.from(currentBlocks);
        final List<bool> mergedIndices = List.filled(
          currentBlocks.length,
          false,
        );

        for (int blockIdx = 0; blockIdx < incomingBlocks.length; blockIdx++) {
          final inBlock = incomingBlocks[blockIdx];
          if (inBlock is Map) {
            final String inType = (inBlock['type'] ?? '').toString();
            int matchIdx = -1;

            // First, try matching at the same index if the type matches and it's not already merged
            final int index = blockIdx;
            if (index < currentBlocks.length && !mergedIndices[index]) {
              final currentBlock = currentBlocks[index] as Map;
              if (currentBlock['type'] == inType) {
                matchIdx = index;
              }
            }

            // If no index match, search for the first unmerged block of the same type
            if (matchIdx == -1) {
              for (int j = 0; j < currentBlocks.length; j++) {
                if (!mergedIndices[j]) {
                  final currentBlock = currentBlocks[j] as Map;
                  if (currentBlock['type'] == inType) {
                    matchIdx = j;
                    break;
                  }
                }
              }
            }

            if (matchIdx != -1) {
              mergedIndices[matchIdx] = true;
              final existing = Map<String, dynamic>.from(
                mergedBlocks[matchIdx] as Map,
              );
              final cleanedInBlock = _cleanIncomingMap(
                Map<String, dynamic>.from(inBlock),
              );
              existing.addAll(cleanedInBlock);
              mergedBlocks[matchIdx] = existing;
            } else {
              // No matching block found, append it as a new block
              mergedBlocks.add(
                _cleanIncomingMap(Map<String, dynamic>.from(inBlock)),
              );
            }
          }
        }
        newDesignMap['blocks'] = mergedBlocks;
        designJson.forEach((key, value) {
          if (key != 'blocks' && key != 'theme' && key != 'global_theme') {
            newDesignMap[key] = value;
          }
        });
      }
    }

    if (newTheme != null) {
      _themeCubit.replaceTheme(newTheme);
    }
    _emitDirty(
      currentState.copyWith(
        designMap: newDesignMap,
        theme: newTheme,
        hasUnsavedChanges: true,
      ),
    );
  }

  Map<String, dynamic> _cleanIncomingMap(Map<String, dynamic> map) {
    final cleaned = <String, dynamic>{};
    map.forEach((key, value) {
      if (value == null || value == "") {
        return;
      }
      if (value is Map<String, dynamic>) {
        cleaned[key] = _cleanIncomingMap(value);
      } else if (value is Map) {
        cleaned[key] = _cleanIncomingMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        cleaned[key] = value
            .map((item) {
              if (item is Map<String, dynamic>) {
                return _cleanIncomingMap(item);
              } else if (item is Map) {
                return _cleanIncomingMap(Map<String, dynamic>.from(item));
              }
              return item;
            })
            .where((item) => item != null && item != "")
            .toList();
      } else {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }

  void initializeNewPage() {
    _history.clear();
    _historyIndex = -1;

    final initialTheme = LandingPageTheme.palettes.last;
    _themeCubit.replaceTheme(initialTheme);
    _emitDirty(
      BuilderLoaded(
        designMap: {'blocks': []},
        subdomain: '',
        isPublished: false,
        websiteType: 'landing_page',
        theme: initialTheme,
      ),
      isClean: true,
    );
  }

  void _handleLoadedPage(Map<String, dynamic>? page) {
    _history.clear();
    _historyIndex = -1;

    if (page == null) {
      emit(BuilderEmptyWorkspace());
      return;
    }

    final currentUserId = _authService.currentUserId;
    if (page['user_id'] != null &&
        currentUserId != null &&
        page['user_id'] != currentUserId) {
      emit(BuilderFailure("You do not have permission to access this page."));
      return;
    }

    Map<String, dynamic> designMap = {'blocks': []};
    String subdomain = page['subdomain'] ?? '';
    String? customDomain = page['custom_domain'];
    bool isPublished = page['is_published'] ?? false;
    String? pageId = page['id'] as String?;
    final String websiteType = page['website_type'] ?? 'landing_page';

    final dynamic rawDesign = page['design_json'];
    if (rawDesign != null) {
      if (rawDesign is String) {
        designMap = Map<String, dynamic>.from(jsonDecode(rawDesign));
      } else {
        designMap = Map<String, dynamic>.from(rawDesign);
      }
    }

    final loadedTheme = designMap['theme'] != null
        ? LandingPageTheme.fromJson(designMap['theme'])
        : LandingPageTheme.palettes.last;
    _themeCubit.replaceTheme(loadedTheme);
    _emitDirty(
      BuilderLoaded(
        pageId: pageId,
        designMap: designMap,
        subdomain: subdomain,
        customDomain: customDomain,
        isPublished: isPublished,
        websiteType: websiteType,
        theme: loadedTheme,
      ),
      isClean: true,
    );
  }

  Future<void> savePage(String userId) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final String sanitizedSubdomain = currentState.subdomain
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    if (sanitizedSubdomain.isEmpty) {
      _emitDirty(
        currentState.copyWith(
          isSaving: false,
          errorMessage: "يرجى إدخال اسم براند صالح.",
        ),
      );
      return;
    }

    // Safety Guard: Don't save if there are active background uploads/imports
    final designStr = jsonEncode(currentState.designMap);
    if (designStr.contains('upload://')) {
      _emitDirty(
        currentState.copyWith(
          isSaving: false,
          errorMessage: "يرجى الانتظار حتى اكتمال تحميل جميع الصور.",
        ),
      );
      return;
    }

    emit(currentState.copyWith(isSaving: true));
    try {
      // 1. Check Route Availability
      final isAvailable = await _databaseService.isRouteAvailable(
        sanitizedSubdomain,
        excludePageId: currentState.pageId,
      );

      if (!isAvailable) {
        _emitDirty(
          currentState.copyWith(
            isSaving: false,
            errorMessage:
                "اسم الرابط ($sanitizedSubdomain) محجوز بالفعل. يرجى اختيار اسم آخر.",
          ),
        );
        return;
      }

      // 2. Check Multi-Page Guard with Super Admin Bypass
      if (currentState.pageId == null) {
        final profile = await _databaseService.getProfile(userId);
        final String tier = profile?['tier'] ?? 'free';
        final bool reachedLimit = await _subscriptionService.hasReachedLimit(
          userId,
        );

        if (reachedLimit) {
          _emitDirty(
            currentState.copyWith(
              isSaving: false,
              errorMessage:
                  "لقد وصلت للحد الأقصى لعدد الصفحات المسموح به في خطتك الحالية ($tier).",
            ),
          );
          return;
        }
      }

      final Map<String, dynamic> finalDesign = Map<String, dynamic>.from(
        currentState.designMap,
      );
      finalDesign['theme'] = currentState.theme.toJson();

      // Upload any remaining Pixabay URLs to ImgBB before saving
      await _resolvePixabayUrlsInDesign(finalDesign);

      final savedPageId = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: sanitizedSubdomain,
        customDomain: currentState.customDomain,
        designMap: finalDesign,
        isPublished: currentState.isPublished,
        websiteType: currentState.websiteType,
        pageId: currentState.pageId,
      );

      _emitDirty(
        currentState.copyWith(
          pageId: savedPageId ?? currentState.pageId,
          subdomain: sanitizedSubdomain,
          isSaving: false,
          successMessage: "تم الحفظ والنشر بنجاح!",
        ),
        isClean: true,
      );
    } catch (e) {
      _emitDirty(
        currentState.copyWith(
          isSaving: false,
          errorMessage:
              "فشل الحفظ: ${e.toString().replaceAll('Exception: ', '')}",
        ),
      );
    }
  }

  void updateSettings({
    String? subdomain,
    String? customDomain,
    bool? isPublished,
  }) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final shouldClear = customDomain == '';
    _emitDirty(
      currentState.copyWith(
        subdomain: subdomain ?? currentState.subdomain,
        customDomain: shouldClear
            ? null
            : (customDomain ?? currentState.customDomain),
        clearCustomDomain: shouldClear,
        isPublished: isPublished ?? currentState.isPublished,
      ),
    );
  }

  /// Magic Image Swapper: Replaces all images in the design with new ones from Pixabay
  Future<void> magicReplaceImages(String category) async {
    final currentState = state;
    if (currentState is! BuilderLoaded || category.isEmpty) return;

    final mediaService = sl<ImageMediaService>();
    final uploadManager = sl<UploadManagerCubit>();

    // 1. Fetch pools of images
    List<PixabayImageModel> photos = [];
    List<PixabayImageModel> illustrations = [];
    List<PixabayImageModel> portraits = [];

    try {
      photos = await mediaService.fetchPixabayImages(
        category,
        imageType: 'photo',
      );
      illustrations = await mediaService.fetchPixabayImages(
        '$category tech illustration',
        imageType: 'illustration',
      );
      portraits = await mediaService.fetchPixabayImages(
        '$category portrait person',
        imageType: 'photo',
      );
    } catch (e) {
      _emitDirty(
        currentState.copyWith(errorMessage: "فشل البحث في Pixabay: $e"),
      );
      return;
    }

    if (photos.isEmpty && illustrations.isEmpty) {
      _emitDirty(
        currentState.copyWith(
          errorMessage: "لم نجد صوراً مناسبة لهذا التصنيف.",
        ),
      );
      return;
    }

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    final blocks = List.from(newDesign['blocks'] ?? []);

    int photoIdx = 0;
    int illustrationIdx = 0;
    int portraitIdx = 0;

    for (int i = 0; i < blocks.length; i++) {
      final block = Map<String, dynamic>.from(blocks[i]);
      final String type = block['type'] ?? '';

      // Helper to trigger upload and return placeholder
      String triggerUpload(PixabayImageModel img) {
        final uploadId =
            'magic_${DateTime.now().millisecondsSinceEpoch}_${img.id}';
        uploadManager.upload(
          uploadId: uploadId,
          data: SelectedImageData.pixabay(
            previewUrl: img.previewUrl,
            webformatUrl: img.webformatUrl,
          ),
          onSuccess: (url) => updatePropertyByUploadId(uploadId, url),
        );
        return uploadId;
      }

      // 1. Handle Background Image
      if (block.containsKey('bg_image_url') && photos.isNotEmpty) {
        block['bg_image_url'] = triggerUpload(photos[photoIdx % photos.length]);
        photoIdx++;
      }

      // 2. Handle Primary Image based on block type
      if (block.containsKey('image_url')) {
        if (type == 'hero_saas' && illustrations.isNotEmpty) {
          block['image_url'] = triggerUpload(
            illustrations[illustrationIdx % illustrations.length],
          );
          illustrationIdx++;
        } else if ((type == 'testimonials' || type == 'team_members') &&
            portraits.isNotEmpty) {
          block['image_url'] = triggerUpload(
            portraits[portraitIdx % portraits.length],
          );
          portraitIdx++;
        } else if (photos.isNotEmpty) {
          block['image_url'] = triggerUpload(photos[photoIdx % photos.length]);
          photoIdx++;
        }
      }

      // 3. Handle Lists (Gallery, Products, Testimonials, Team)
      if (block.containsKey('items') && block['items'] is List) {
        final List items = List.from(block['items']);
        for (int j = 0; j < items.length; j++) {
          if (items[j] is String) {
            // Gallery case
            if (photos.isNotEmpty) {
              items[j] = triggerUpload(photos[photoIdx % photos.length]);
              photoIdx++;
            }
          } else if (items[j] is Map) {
            final item = Map<String, dynamic>.from(items[j]);
            if (item.containsKey('image_url')) {
              if ((type == 'testimonials' || type == 'team_members') &&
                  portraits.isNotEmpty) {
                item['image_url'] = triggerUpload(
                  portraits[portraitIdx % portraits.length],
                );
                portraitIdx++;
              } else if (photos.isNotEmpty) {
                item['image_url'] = triggerUpload(
                  photos[photoIdx % photos.length],
                );
                photoIdx++;
              }
            }
            items[j] = item;
          }
        }
        block['items'] = items;
      }

      blocks[i] = block;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(
      currentState.copyWith(
        designMap: newDesign,
        successMessage: "جاري تبديل الصور سحرياً...",
      ),
    );
  }

  /// Scans the design for external assets and imports them to the user's gallery
  void importTemplateAssets(UploadManagerCubit uploadManager) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    final blocks = List.from(newDesign['blocks'] ?? []);

    bool found = false;

    for (int i = 0; i < blocks.length; i++) {
      final block = Map<String, dynamic>.from(blocks[i]);

      String? triggerImport(String? url) {
        if (url == null ||
            url.isEmpty ||
            url.startsWith('upload://') ||
            url.contains('supabase.co'))
          return url;

        found = true;
        final uploadId =
            'import_${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}';
        uploadManager.persistExternalImage(
          uploadId: uploadId,
          externalUrl: url,
          onSuccess: (finalUrl) =>
              updatePropertyByUploadId('upload://$uploadId', finalUrl),
        );
        return 'upload://$uploadId';
      }

      block['image_url'] = triggerImport(block['image_url']);
      block['bg_image_url'] = triggerImport(block['bg_image_url']);

      if (block['items'] is List) {
        final List items = List.from(block['items']);
        for (int j = 0; j < items.length; j++) {
          if (items[j] is String) {
            items[j] = triggerImport(items[j]);
          } else if (items[j] is Map) {
            final item = Map<String, dynamic>.from(items[j]);
            item['image_url'] = triggerImport(item['image_url']);
            items[j] = item;
          }
        }
        block['items'] = items;
      }

      blocks[i] = block;
    }

    if (found) {
      newDesign['blocks'] = blocks;
      _emitDirty(
        currentState.copyWith(designMap: newDesign),
        skipHistory: true,
      );
    }
  }

  /// Scans design map for pixabay.com URLs and uploads them to ImgBB before publish.
  /// This ensures previews use fast Pixabay CDN URLs but published pages serve from ImgBB.
  Future<void> _resolvePixabayUrlsInDesign(Map<String, dynamic> design) async {
    final pixabayUrls = <String>[];
    final replacements = <String, String>{};

    void scan(Object? node) {
      if (node is Map<String, dynamic>) {
        for (final val in node.values) {
          if (val is String && val.contains('pixabay.com')) {
            pixabayUrls.add(val);
          } else {
            scan(val);
          }
        }
      } else if (node is List) {
        for (final item in node) {
          if (item is String && item.contains('pixabay.com')) {
            pixabayUrls.add(item);
          } else {
            scan(item);
          }
        }
      }
    }

    scan(design);
    if (pixabayUrls.isEmpty) return;

    final uploadManager = sl<UploadManagerCubit>();
    final uniqueUrls = pixabayUrls.toSet();

    await Future.wait(
      uniqueUrls.map((url) async {
        final completer = Completer<String>();
        final uploadId =
            'prepublish_${DateTime.now().millisecondsSinceEpoch}_${url.hashCode}';
        uploadManager.persistExternalImage(
          uploadId: uploadId,
          externalUrl: url,
          onSuccess: (finalUrl) {
            if (!completer.isCompleted) completer.complete(finalUrl);
          },
        );
        try {
          final imgbbUrl = await completer.future.timeout(
            const Duration(seconds: 30),
            onTimeout: () => url, // fallback to original Pixabay URL
          );
          replacements[url] = imgbbUrl;
        } catch (_) {
          replacements[url] = url; // keep original on failure
        }
      }),
    );

    if (replacements.isEmpty) return;

    void replace(Object? node) {
      if (node is Map<String, dynamic>) {
        for (final key in node.keys) {
          final val = node[key];
          if (val is String && replacements.containsKey(val)) {
            node[key] = replacements[val];
          } else {
            replace(val);
          }
        }
      } else if (node is List) {
        for (int i = 0; i < node.length; i++) {
          final val = node[i];
          if (val is String && replacements.containsKey(val)) {
            node[i] = replacements[val];
          } else {
            replace(val);
          }
        }
      }
    }

    replace(design);
  }

  /// Reactive update for background uploads/imports
  void updatePropertyByUploadId(String uploadId, String finalUrl) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    final blocks = List.from(newDesign['blocks'] ?? []);

    bool updated = false;

    for (int i = 0; i < blocks.length; i++) {
      final block = Map<String, dynamic>.from(blocks[i]);

      if (block['image_url'] == uploadId) {
        block['image_url'] = finalUrl;
        updated = true;
      }
      if (block['bg_image_url'] == uploadId) {
        block['bg_image_url'] = finalUrl;
        updated = true;
      }

      if (block['items'] is List) {
        final List items = List.from(block['items']);
        for (int j = 0; j < items.length; j++) {
          if (items[j] == uploadId) {
            items[j] = finalUrl;
            updated = true;
          } else if (items[j] is Map) {
            final item = Map<String, dynamic>.from(items[j]);
            if (item['image_url'] == uploadId) {
              item['image_url'] = finalUrl;
              updated = true;
            }
            items[j] = item;
          }
        }
        block['items'] = items;
      }

      blocks[i] = block;
    }

    if (updated) {
      newDesign['blocks'] = blocks;
      _emitDirty(
        currentState.copyWith(designMap: newDesign),
        skipHistory: true,
      );
    }
  }

  void applyTemplate(String templateType) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final newDesign = TemplateRegistry.getTemplateDesign(templateType);
    final newTheme = TemplateRegistry.getTemplateTheme(templateType);

    _themeCubit.replaceTheme(newTheme);
    _emitDirty(
      currentState.copyWith(
        designMap: newDesign,
        theme: newTheme,
        successMessage: "تم تطبيق القالب بنجاح!",
      ),
    );

    // Automatically trigger import of external assets into user's account
    importTemplateAssets(sl<UploadManagerCubit>());
  }

  void applyCustomDesign(Map<String, dynamic> customDesign) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final blocksRaw = customDesign['blocks'] as List<dynamic>? ?? [];
    final themeRaw = customDesign['theme'] as Map<String, dynamic>? ?? {};

    final newDesign = {'blocks': blocksRaw};
    final newTheme = LandingPageTheme.fromJson(themeRaw);

    _themeCubit.replaceTheme(newTheme);
    _emitDirty(
      currentState.copyWith(
        designMap: newDesign,
        theme: newTheme,
        successMessage: "تم تطبيق التصميم المخصص بنجاح!",
      ),
    );

    // Automatically trigger import of external assets into user's account
    importTemplateAssets(sl<UploadManagerCubit>());
  }

  void addBlock(String type, {Map<String, dynamic>? presetOverrides}) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);

    Map<String, dynamic>? blockToAdd;

    if (type == 'hero' || type == 'hero_saas') {
      blockToAdd = {
        'type': type,
        'title': type == 'hero_saas'
            ? 'منصتك الشاملة لإدارة الأعمال'
            : 'عنوان القسم الرئيسي الجديد',
        'subtitle': type == 'hero_saas'
            ? 'نظام متكامل يجمع كل ما تحتاجه لإدارة مشروعك بكفاءة.'
            : 'اكتب هنا عرض القيمة الأساسي لخدمتك أو منتجك.',
        'button_text': 'ابدأ الآن مجاناً',
        'image_url': type == 'hero_saas'
            ? 'https://cdn.pixabay.com/photo/2016/11/19/14/00/code-1839406_1280.jpg'
            : 'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
      };
    } else if (type == 'logo_header') {
      blockToAdd = {
        'type': 'logo_header',
        'title': 'اسم العلامة التجارية',
        'alignment': 'center',
        'logo_height': 48.0,
      };
    } else if (type == 'features') {
      blockToAdd = {
        'type': 'features',
        'title': 'لماذا نحن؟',
        'layout_style': 'grid',
        'items': [
          {'title': 'ميزة 1', 'description': 'اشرح فوائد هذه الميزة هنا.'},
          {'title': 'ميزة 2', 'description': 'سلط الضوء على أهمية هذا البند.'},
        ],
      };
    } else if (type == 'lead_form') {
      blockToAdd = {
        'type': 'lead_form',
        'title': 'تواصل معنا اليوم',
        'button_text': 'إرسال',
        'fields': [
          {
            'field_id': 'name',
            'field_type': 'text',
            'label': 'الاسم الكامل',
            'placeholder': 'أدخل اسمك',
            'is_required': true,
          },
          {
            'field_id': 'phone',
            'field_type': 'text',
            'label': 'رقم الجوال',
            'placeholder': '05xxxxxxxx',
            'is_required': true,
          },
          {
            'field_id': 'message',
            'field_type': 'textarea',
            'label': 'رسالتك',
            'placeholder': 'كيف يمكننا مساعدتك؟',
            'is_required': false,
          },
        ],
      };
    } else if (type == 'lead_magnet') {
      blockToAdd = {
        'type': 'lead_magnet',
        'title': 'احصل على دليلك المجاني',
        'subtitle':
            'سجل الآن لتحصل على نسخة مجانية من الدليل الشامل لزيادة مبيعاتك بنسبة 300%.',
        'button_text': 'أرسل الدليل الآن',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/02/19/11/19/office-1209640_1280.jpg',
        'fields': [
          {
            'field_id': 'name',
            'field_type': 'text',
            'label': 'الاسم الكامل',
            'placeholder': 'أدخل اسمك',
            'is_required': true,
          },
          {
            'field_id': 'email',
            'field_type': 'email',
            'label': 'البريد الإلكتروني',
            'placeholder': 'example@domain.com',
            'is_required': true,
          },
          {
            'field_id': 'phone',
            'field_type': 'text',
            'label': 'رقم الجوال',
            'placeholder': '05xxxxxxxx',
            'is_required': false,
          },
        ],
      };
    } else if (type == 'whatsapp') {
      blockToAdd = {
        'type': 'whatsapp',
        'title': 'تواصل معنا عبر واتساب',
        'phone_number': '',
        'message': 'أهلاً بك! أريد الاستفسار عن...',
        'button_text': 'إرسال رسالة',
      };
    } else if (type == 'products') {
      blockToAdd = {
        'type': 'products',
        'title': 'منتجاتنا',
        'layout_style': 'grid_2',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'اسم المنتج',
            'price': '0 EGP',
            'category': 'عام',
            'description': 'وصف مختصر للمنتج.',
            'image_url':
                'https://cdn.pixabay.com/photo/2014/07/31/23/00/watch-407092_1280.jpg',
            'button_text': 'اشترِ الآن',
          },
        ],
      };
    } else if (type == 'qr_code') {
      blockToAdd = {
        'type': 'qr_code',
        'title': 'امسح الكود لزيارة موقعنا',
        'subtitle': 'شارك الصفحة بسهولة.',
        'qr_size': 200.0,
      };
    } else if (type == 'social_qr') {
      blockToAdd = {
        'type': 'social_qr',
        'title': 'تواصل معنا',
        'subtitle': 'تابعنا على منصات التواصل',
        'links': [
          {'platform': 'instagram', 'url': 'https://instagram.com'},
          {'platform': 'whatsapp', 'url': 'https://wa.me/'},
        ],
      };
    } else if (type == 'pricing') {
      blockToAdd = {
        'type': 'pricing',
        'schema_version': 2,
        'title': 'خطط الأسعار',
        'subtitle': 'اختر الخطة التي تناسب أعمالك',
        'has_toggle': true,
        'toggle_labels': {'monthly': 'شهري', 'yearly': 'سنوي'},
        'items': [
          {
            'plan_id': const Uuid().v4(),
            'name': 'الخطة الأساسية',
            'prices': {'monthly': 100, 'yearly': 1000},
            'billing_ids': {'monthly': '', 'yearly': ''},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'discount_mode': 'auto',
            'features': ['ميزة أساسية 1', 'ميزة أساسية 2'],
            'button_text': 'ابدأ الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false,
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'خطة المحترفين',
            'prices': {'monthly': 250, 'yearly': 2500},
            'billing_ids': {'monthly': '', 'yearly': ''},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'discount_mode': 'manual',
            'manual_discount_text': 'الأكثر توفيراً',
            'features': ['كل المزايا الأساسية', 'ميزة احترافية', 'دعم أولوية'],
            'button_text': 'اشترك الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': true,
          },
        ],
      };
    } else if (type == 'featured_product') {
      blockToAdd = {
        'type': 'featured_product',
        'name': 'اسم المنتج المميز',
        'price': '0.00',
        'description': 'وصف مختصر للمنتج يبرز أهم مميزاته.',
        'image_url':
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        'button_text': 'إضافة للسلة',
        'layout_style': 'split',
      };
    } else if (type == 'bento_store') {
      blockToAdd = {
        'type': 'bento_store',
        'title': 'مجموعاتنا المختارة',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'منتج 1',
            'price': '0 EGP',
            'image_url':
                'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
          },
          {
            'id': const Uuid().v4(),
            'name': 'منتج 2',
            'price': '0 EGP',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
          },
        ],
        'layout_style': 'modern',
      };
    } else if (type == 'faq') {
      blockToAdd = {
        'type': 'faq',
        'title': 'الأسئلة الشائعة',
        'items': [
          {'question': 'سؤال؟', 'answer': 'إجابة مفصلة.'},
        ],
      };
    } else if (type == 'testimonials') {
      blockToAdd = {
        'type': 'testimonials',
        'title': 'قالوا عنا',
        'items': [
          {'author': 'الاسم', 'role': 'الوظيفة', 'quote': 'رأيه هنا.'},
        ],
      };
    } else if (type == 'contact_info') {
      blockToAdd = {
        'type': 'contact_info',
        'title': 'تواصل معنا',
        'email': 'contact@example.com',
        'phone': '+20',
        'location': 'القاهرة، مصر',
      };
    } else if (type == 'working_hours') {
      blockToAdd = {
        'type': 'working_hours',
        'title': 'مواعيد العمل',
        'schedule': {
          'السبت - الخميس': '10:00 AM - 10:00 PM',
          'الجمعة': '2:00 PM - 10:00 PM',
        },
      };
    } else if (type == 'location_map') {
      blockToAdd = {
        'type': 'location_map',
        'title': 'موقعنا',
        'address': 'القاهرة، مصر',
        'map_iframe_url':
            'https://maps.google.com/maps?q=Cairo&t=&z=13&ie=UTF8&iwloc=&output=embed',
      };
    } else if (type == 'gallery') {
      blockToAdd = {
        'type': 'gallery',
        'title': 'معرض الصور',
        'items': [
          'https://cdn.pixabay.com/photo/2015/07/17/22/43/student-849825_1280.jpg',
        ],
      };
    } else if (type == 'multi_step_lead_form') {
      blockToAdd = {
        'type': 'multi_step_lead_form',
        'schema_version': 1,
        'title': 'طلب تسعير',
        'subtitle': 'أجب على الأسئلة للحصول على عرض سعر دقيق',
        'success_message': 'تم الإرسال بنجاح!',
        'enable_local_save': true,
        'steps': [
          {
            'step_id': const Uuid().v4(),
            'step_title': 'البيانات الأساسية',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'text',
                'label': 'الاسم الكامل',
                'placeholder': 'أدخل اسمك ثلاثياً',
                'is_required': true,
                'validation': {'min_length': 3},
              },
              {
                'field_id': const Uuid().v4(),
                'field_type': 'radio',
                'label': 'نوع الحساب',
                'options': [
                  {'value': 'individual', 'label': 'فرد'},
                  {'value': 'business', 'label': 'شركة'},
                ],
                'is_required': true,
              },
            ],
          },
          {
            'step_id': const Uuid().v4(),
            'step_title': 'معلومات الاتصال',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'phone',
                'label': 'رقم الهاتف',
                'placeholder': '+201xxxxxxxxx',
                'is_required': true,
              },
            ],
          },
        ],
      };
    } else if (type == 'video_embed') {
      blockToAdd = {
        'type': 'video_embed',
        'title': 'شاهد كيف نعمل',
        'subtitle': 'فيديو تعريفي قصير يوضح مزايا المنصة.',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'aspect_ratio': '16:9',
        'max_width': 900,
        'use_thumbnail': true,
        'autoplay': false,
        'show_controls': true,
      };
    } else if (type == 'trust_logos') {
      blockToAdd = {
        'type': 'trust_logos',
        'title': 'شركاء نعتز بهم',
        'items': [
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
        ],
      };
    } else if (type == 'animated_counter') {
      blockToAdd = {
        'type': 'animated_counter',
        'title': 'أرقام تتحدث عن نفسها',
        'items': [
          {'value': '150', 'label': 'عميل سعيد', 'prefix': '+', 'suffix': ''},
          {'value': '99', 'label': 'نسبة الرضا', 'prefix': '', 'suffix': '%'},
          {'value': '24', 'label': 'ساعة دعم', 'prefix': '', 'suffix': '/7'},
        ],
      };
    } else if (type == 'basic_section') {
      blockToAdd = {
        'type': 'basic_section',
        'title': 'قسم مرن جديد',
        'layout_direction': 'column',
        'main_axis_alignment': 'center',
        'cross_axis_alignment': 'center',
        'spacing': 20.0,
      };
    }

    if (blockToAdd == null) return;
    if (presetOverrides != null && presetOverrides.isNotEmpty) {
      blockToAdd = _mergeBlockPreset(blockToAdd, presetOverrides);
    }
    blocks.add(blockToAdd);

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));

    // Trigger import for new block assets (background images, etc. in overrides)
    importTemplateAssets(sl<UploadManagerCubit>());
  }

  Map<String, dynamic> _mergeBlockPreset(
    Map<String, dynamic> base,
    Map<String, dynamic> overrides,
  ) {
    final merged = Map<String, dynamic>.from(base);
    overrides.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          merged[key] is Map<String, dynamic>) {
        merged[key] = _mergeBlockPreset(
          Map<String, dynamic>.from(merged[key] as Map<String, dynamic>),
          value,
        );
      } else if (value is List) {
        merged[key] = List.from(value);
      } else {
        merged[key] = value;
      }
    });
    return merged;
  }

  void updateStickyCta(String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final Map<String, dynamic> stickyCta = Map<String, dynamic>.from(
      newDesign['sticky_cta'] ?? {},
    );

    stickyCta[key] = value;
    newDesign['sticky_cta'] = stickyCta;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updatePricingPlan(
    int blockIndex,
    int itemIndex,
    String key,
    dynamic value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addFaqItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({'question': 'سؤال جديد؟', 'answer': 'الإجابة هنا.'});
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteFaqItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateFaqItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addTestimonialItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({
        'author': 'عميل جديد',
        'role': 'وظيفة',
        'quote': 'رأي العميل هنا.',
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteTestimonialItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateTestimonialItem(
    int blockIndex,
    int itemIndex,
    String key,
    String value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addGalleryImage(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add(
        'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
      );
      updatedBlock['items'] = items;

      // Sync parallel gallery_links list
      final List galleryLinks = List.from(updatedBlock['gallery_links'] ?? []);
      galleryLinks.add('');
      updatedBlock['gallery_links'] = galleryLinks;

      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteGalleryImage(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;

      // Sync parallel gallery_links list
      final List galleryLinks = List.from(updatedBlock['gallery_links'] ?? []);
      if (itemIndex >= 0 && itemIndex < galleryLinks.length) {
        galleryLinks.removeAt(itemIndex);
      }
      updatedBlock['gallery_links'] = galleryLinks;

      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteBlock(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void reorderBlocks(int oldIndex, int newIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final blocks = List<Map<String, dynamic>>.from(
      currentState.designMap['blocks'],
    );
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    newDesign['blocks'] = blocks;

    _emitDirty(
      currentState.copyWith(
        designMap: newDesign,
        focusedSectionIndex: newIndex,
      ),
    );
  }

  void moveBlock(int index, bool up) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    final targetIndex = up ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= blocks.length) return;

    final temp = blocks[index];
    blocks[index] = blocks[targetIndex];
    blocks[targetIndex] = temp;

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateBlockProperty(int index, String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[index],
      );

      // Support nested updates like 'layout_config.direction'
      if (key.contains('.')) {
        final parts = key.split('.');
        final parentKey = parts[0];
        final childKey = parts[1];
        final Map<String, dynamic> parent = Map<String, dynamic>.from(
          updatedBlock[parentKey] ?? {},
        );
        parent[childKey] = value;
        updatedBlock[parentKey] = parent;
      } else {
        updatedBlock[key] = value;
      }

      blocks[index] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateFeatureItem(
    int blockIndex,
    int itemIndex,
    String key,
    String value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addProductItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({
        'id': const Uuid().v4(),
        'name': 'منتج جديد',
        'price': '0.00 EGP',
        'description': 'وصف قصير للمنتج.',
        'image_url':
            'https://cdn.pixabay.com/photo/2014/07/31/23/00/watch-407092_1280.jpg',
        'button_text': 'اشترِ الآن',
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteProductItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateProductItem(
    int blockIndex,
    int itemIndex,
    String key,
    String value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateMetadata(String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    newDesign[key] = value;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void selectSection(int? index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    _emitDirty(
      currentState.copyWith(
        focusedSectionIndex: index,
        clearFocusedElement: index == null,
      ),
    );
  }

  void focusElement(int sectionIndex, String elementId) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    _emitDirty(
      currentState.copyWith(
        focusedSectionIndex: sectionIndex,
        focusedElementId: elementId,
      ),
    );
  }

  void duplicateBlock(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      final duplicate = Map<String, dynamic>.from(blocks[index]);
      blocks.insert(index + 1, duplicate);
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void toggleBlockVisibility(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final blocks = List<Map<String, dynamic>>.from(
      currentState.designMap['blocks'],
    );
    final block = Map<String, dynamic>.from(blocks[index]);

    final bool isVisible = block['is_visible'] ?? true;
    block['is_visible'] = !isVisible;
    blocks[index] = block;

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    newDesign['blocks'] = blocks;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateElementProperty(
    int sectionIndex,
    String elementId,
    String key,
    dynamic value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);

    if (sectionIndex >= 0 && sectionIndex < blocks.length) {
      final Map<String, dynamic> block = Map<String, dynamic>.from(
        blocks[sectionIndex],
      );
      final List elements = List.from(block['elements'] ?? []);

      final int elementIndex = elements.indexWhere((e) => e['id'] == elementId);
      if (elementIndex != -1) {
        final Map<String, dynamic> element = Map<String, dynamic>.from(
          elements[elementIndex],
        );
        final Map<String, dynamic> styles = Map<String, dynamic>.from(
          element['style_overrides'] ?? {},
        );

        styles[key] = value;
        element['style_overrides'] = styles;
        elements[elementIndex] = element;
        block['elements'] = elements;
        blocks[sectionIndex] = block;
        newDesign['blocks'] = blocks;

        _emitDirty(currentState.copyWith(designMap: newDesign));
      }
    }
  }

  void clearMessages() {
    final currentState = state;
    if (currentState is BuilderLoaded) {
      _emitDirty(
        currentState.copyWith(errorMessage: null, successMessage: null),
      );
    }
  }
}
