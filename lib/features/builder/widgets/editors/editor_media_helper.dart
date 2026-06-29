import 'package:flutter/material.dart';
import '../modals/image_picker_modal.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../../../../injection_container.dart';

Future<void> pickMedia(
  BuildContext context,
  LandingPageBuilderCubit cubit,
  int blockIndex, {
  String? itemKey,
  int? itemIndex,
  bool isBackground = false,
}) async {
  final selectedData = await ImagePickerModal.show(context);
  if (selectedData == null) return;

  final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';

  void updateProp(String url) {
    if (isBackground) {
      cubit.updateBlockProperty(blockIndex, 'bg_image_url', url);
    } else if (itemKey == 'items_array' && itemIndex != null) {
      final block = (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
      final List items = List.from(block['items'] ?? []);
      items[itemIndex] = url;
      cubit.updateBlockProperty(blockIndex, 'items', items);
    } else if (itemKey != null && itemIndex != null) {
      cubit.updateProductItem(blockIndex, itemIndex, itemKey, url);
    } else if (itemKey != null) {
      cubit.updateBlockProperty(blockIndex, itemKey, url);
    } else {
      cubit.updateBlockProperty(blockIndex, 'image_url', url);
    }
  }

  String oldUrl = '';
  final blockMap = (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
  if (isBackground) {
    oldUrl = blockMap['bg_image_url'] ?? '';
  } else if (itemKey == 'items_array' && itemIndex != null) {
    final items = blockMap['items'] as List? ?? [];
    if (itemIndex < items.length) {
      oldUrl = items[itemIndex] ?? '';
    }
  } else if (itemKey != null && itemIndex != null) {
    final items = blockMap[itemKey] as List? ?? [];
    if (itemIndex < items.length) {
      oldUrl = items[itemIndex]['image'] ?? '';
    }
  } else if (itemKey != null) {
    oldUrl = blockMap[itemKey] ?? '';
  } else {
    oldUrl = blockMap['image_url'] ?? '';
  }

  updateProp(uploadId);

  sl<UploadManagerCubit>().upload(
    uploadId: uploadId,
    data: selectedData,
    onSuccess: (finalUrl) {
      updateProp(finalUrl);
    },
    onCancel: () {
      updateProp(oldUrl);
    },
  );
}

Future<void> persistAsset(
  BuildContext context,
  LandingPageBuilderCubit cubit,
  int blockIndex, {
  String? itemKey,
  int? itemIndex,
  bool isBackground = false,
}) async {
  final blockMap = (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
  String? currentUrl;

  if (isBackground) {
    currentUrl = blockMap['bg_image_url'];
  } else if (itemKey == 'items_array' && itemIndex != null) {
    final items = blockMap['items'] as List? ?? [];
    if (itemIndex < items.length) {
      currentUrl = items[itemIndex];
    }
  } else if (itemKey != null && itemIndex != null) {
    final items = blockMap[itemKey] as List? ?? [];
    if (itemIndex < items.length) {
      currentUrl = items[itemIndex]['image'];
    }
  } else if (itemKey != null) {
    currentUrl = blockMap[itemKey];
  } else {
    currentUrl = blockMap['image_url'];
  }

  if (currentUrl == null || currentUrl.isEmpty) return;

  final uploadId = 'persist://${DateTime.now().millisecondsSinceEpoch}';

  void updateProp(String url) {
    if (isBackground) {
      cubit.updateBlockProperty(blockIndex, 'bg_image_url', url);
    } else if (itemKey == 'items_array' && itemIndex != null) {
      final block = (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
      final List items = List.from(block['items'] ?? []);
      items[itemIndex] = url;
      cubit.updateBlockProperty(blockIndex, 'items', items);
    } else if (itemKey != null && itemIndex != null) {
      cubit.updateProductItem(blockIndex, itemIndex, itemKey, url);
    } else if (itemKey != null) {
      cubit.updateBlockProperty(blockIndex, itemKey, url);
    } else {
      cubit.updateBlockProperty(blockIndex, 'image_url', url);
    }
  }

  updateProp('upload://$uploadId');

  sl<UploadManagerCubit>().persistExternalImage(
    uploadId: uploadId,
    externalUrl: currentUrl,
    onSuccess: (finalUrl) {
      updateProp(finalUrl);
    },
  );
}
