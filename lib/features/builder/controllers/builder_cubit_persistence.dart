part of 'builder_cubit.dart';

/// Encodes a design map to JSON in a background isolate.
String _serializeDesignMap(Map<String, dynamic> map) => jsonEncode(map);

/// Mixin containing page persistence operations for [LandingPageBuilderCubit].
mixin BuilderCubitPersistence on Cubit<BuilderState> {
  // Abstract declarations satisfied by LandingPageBuilderCubit.
  void _emitDirty(
    BuilderLoaded state, {
    bool isClean = false,
    bool skipHistory = false,
  });
  AuthService get _authService;
  DatabaseService get _databaseService;
  SubscriptionService get _subscriptionService;
  BuilderThemeCubit get _themeCubit;
  List<String> get _history;
  set _historyIndex(int value);

  /// Loads the landing page for the currently authenticated user.
  ///
  /// Emits `BuilderFailure` if no user is found.
  Future<void> loadForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(BuilderFailure("No authenticated user found."));
      return;
    }
    await loadPageForUser(userId);
  }

  /// Saves the current page for the authenticated user.
  ///
  /// No-op if no user is logged in.
  Future<void> saveForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    await savePage(userId);
  }

  /// Claims a guest's in-memory design after registration.
  ///
  /// Generates a random slug (`site-xxxxx`) if none is set, checks route
  /// availability, and saves to DB. Returns the new `pageId` or null on failure.
  /// Called when [userId] is first assigned after guest sign-up.
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

  /// Persists the guest design with a fresh [subdomain] for the given [userId].
  ///
  /// Sets `isClean` after successful save. Returns the DB `pageId` or null.
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

      final designJson = await Isolate.run(() => _serializeDesignMap(finalDesign));
      final savedPageId = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: subdomain,
        customDomain: currentState.customDomain,
        designMap: finalDesign,
        designJson: designJson,
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

  /// Loads the page for a specific [userId] from the database.
  ///
  /// Emits `BuilderLoading` first, then `BuilderLoaded` or `BuilderFailure`.
  /// Delegates to `_handleLoadedPage` for the actual state emission.
  Future<void> loadPageForUser(String userId) async {
    emit(BuilderLoading());
    try {
      final page = await _databaseService.getLandingPageByUserId(userId);
      _handleLoadedPage(page);
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  /// Loads a page by UUID or subdomain string.
  ///
  /// Auto-detects UUID vs. domain. Internally calls `_handleLoadedPage`.
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

  /// Merges an incoming JSON design (from AI or external source) into the current state.
  ///
  /// Supports three modes:
  /// - `full_rebuild`: replaces all blocks.
  /// - Partial (blocks with `_index`): merge/replace at specific indices.
  /// - Full list: heuristic subset-edit or block-by-block merge by type.
  /// Also merges theme and top-level metadata. Does NOT skip history.
  /// Called when AI generates or edits a design.
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

  /// Recursively strips null/empty values from [map].
  ///
  /// Used to sanitise incoming AI/API data before merging into the design.
  /// Never returns nulls or empty strings — these are considered "unset".
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

  /// Resets the builder to a blank new page.
  ///
  /// Clears history, uses the last palette as the starting theme, and emits a
  /// clean `BuilderLoaded` with an empty blocks list.
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

  /// Parses a raw DB page map and emits the corresponding `BuilderLoaded` state.
  ///
  /// Handles null → `BuilderEmptyWorkspace`, permission check, deserialisation of
  /// `design_json` (string or map), and theme restoration.
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

  /// Persists the current design to the database for [userId].
  ///
  /// Validates subdomain, checks for pending uploads, checks route availability,
  /// enforces subscription page limits, resolves Pixabay URLs, and saves.
  /// Emits success/error messages (localised Arabic).
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

      // Offload JSON encoding to background isolate (30–80ms savings)
      final designJson = await Isolate.run(() => _serializeDesignMap(finalDesign));
      final savedPageId = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: sanitizedSubdomain,
        customDomain: currentState.customDomain,
        designMap: finalDesign,
        designJson: designJson,
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

  /// Updates page-level settings (subdomain, custom domain, published flag).
  ///
  /// Passing `customDomain: ''` clears the custom domain.
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

  /// Replaces ALL images in the current design with fresh ones from Pixabay for [category].
  ///
  /// Fetches photos, illustrations, and portraits in parallel, then cycles through
  /// blocks replacing `image_url`, `bg_image_url`, and list items. Each replacement
  /// is uploaded via `UploadManagerCubit` for persistence.
  /// Called when the user taps "Magic Image Swap".
  /// **⚠️ This is a destructive, one-shot operation — every existing image URL is replaced.**
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

  /// Scans every block for external image URLs and triggers background imports.
  ///
  /// Replaces raw URLs with `upload://` placeholders; `UploadManagerCubit` persists
  /// them and calls back `updatePropertyByUploadId` with the final hosted URL.
  /// Called automatically after applying a template or custom design.
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

  /// Scans [design] for `pixabay.com` URLs and uploads them to ImgBB before publish.
  ///
  /// This ensures previews use fast Pixabay CDN URLs but published pages serve from
  /// ImgBB (persistent storage). Each unique URL is resolved with a 30-second timeout.
  /// Called from `savePage()`.
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

  /// Replaces all placeholder `[uploadId]` references in the design with the real [finalUrl].
  ///
  /// Called by `UploadManagerCubit` callbacks when an async upload completes.
  /// Searches every block's `image_url`, `bg_image_url`, and list items.
  /// **⚠️ This is the only method that resolves `upload://` placeholders — do not change
  /// the search logic or the flagging convention.**
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

  /// Applies a pre-built template by [templateType] (e.g. `'saas'`, `'store'`).
  ///
  /// Replaces the entire design and theme from `TemplateRegistry`. Automatically
  /// triggers `importTemplateAssets` for external images.
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

  /// Applies a fully custom design map (blocks + theme) from external input.
  ///
  /// Unlike `applyDesignJson`, this replaces everything wholesale.
  /// Automatically triggers `importTemplateAssets`.
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

  /// Clears both `errorMessage` and `successMessage` from the current state.
  ///
  /// Called after a toast/snackbar has been shown.
  void clearMessages() {
    final currentState = state;
    if (currentState is BuilderLoaded) {
      _emitDirty(
        currentState.copyWith(errorMessage: null, successMessage: null),
      );
    }
  }
}
