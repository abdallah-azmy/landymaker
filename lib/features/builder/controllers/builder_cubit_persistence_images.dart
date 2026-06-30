part of 'builder_cubit.dart';

/// Mixin handling image-related operations (magic replace, asset import).
mixin BuilderCubitPersistenceImages on Cubit<BuilderState> {
  void _emitDirty(
    BuilderLoaded state, {
    bool isClean = false,
    bool skipHistory = false,
  });
  void updatePropertyByUploadId(String uploadId, String finalUrl);

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
}
