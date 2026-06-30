part of 'builder_cubit.dart';

/// Encodes a design map to JSON in a background isolate.
String _serializeDesignMap(Map<String, dynamic> map) => jsonEncode(map);

/// Decodes a JSON string into a design map in a background isolate.
Map<String, dynamic> _decodeDesignJson(String json) =>
    Map<String, dynamic>.from(jsonDecode(json));

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
  bool get _suppressHistoryFromTheme;
  set _suppressHistoryFromTheme(bool value);

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

      final designJson = await runWebSafeIsolate(() => _serializeDesignMap(finalDesign));
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
      await _handleLoadedPage(page);
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
      await _handleLoadedPage(page);
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  // (moved to BuilderCubitPersistenceDesign in builder_cubit_persistence_design.dart)

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
  Future<void> _handleLoadedPage(Map<String, dynamic>? page) async {
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
        designMap = await runWebSafeIsolate(() => _decodeDesignJson(rawDesign));
      } else {
        designMap = Map<String, dynamic>.from(rawDesign);
      }
    }
    final loadedTheme = designMap['theme'] != null
        ? LandingPageTheme.fromJson(designMap['theme'])
        : LandingPageTheme.palettes.last;
    _themeCubit.replaceTheme(loadedTheme);
    DynamicFontService.loadFontsFromDesign(designMap);
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
      final designJson = await runWebSafeIsolate(() => _serializeDesignMap(finalDesign));
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

  // (moved to BuilderCubitPersistenceImages in builder_cubit_persistence_images.dart)

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
    DynamicFontService.loadFontsFromDesign(newDesign);
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
    DynamicFontService.loadFontsFromDesign(newDesign);
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
