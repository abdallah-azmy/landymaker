part of 'builder_cubit.dart';

/// Mixin containing sub-item CRUD operations (FAQ, testimonials, gallery, features, products).
mixin BuilderCubitBlocksItems on Cubit<BuilderState> {
  void _emitDirty(BuilderLoaded state);

  /// Adds a default FAQ item to the FAQ block at [blockIndex].
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

  /// Removes the FAQ item at [itemIndex] from the FAQ block at [blockIndex].
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

  /// Updates a single field [key] on a FAQ item inside the block at [blockIndex].
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

  /// Adds a default testimonial item to the testimonials block at [blockIndex].
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
        'image_url': AppConstants.placeholderImageUrl,
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  /// Removes the testimonial at [itemIndex] from the block at [blockIndex].
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

  /// Updates a field on a testimonial item inside the block at [blockIndex].
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

  /// Adds a default image URL to the gallery block at [blockIndex].
  ///
  /// Also syncs a parallel `gallery_links` list (kept in lockstep with `items`).
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
        AppConstants.placeholderLargeImageUrl,
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

  /// Removes the image at [itemIndex] from the gallery block at [blockIndex].
  ///
  /// Also removes the corresponding entry from `gallery_links`.
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

  /// Updates a field on a feature item inside the features block at [blockIndex].
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

  /// Adds a default product item to the products block at [blockIndex].
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
            AppConstants.placeholderImageUrl,
        'button_text': 'اشترِ الآن',
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  /// Removes the product at [itemIndex] from the products block at [blockIndex].
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

  /// Updates a field on a product item inside the products block at [blockIndex].
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
}
