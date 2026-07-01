import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../controllers/builder_state.dart';
import '../../../controllers/builder_cubit.dart';
import '../../molecules/custom_image_field.dart';
import '../../modals/image_picker_modal.dart';
import '../../../controllers/upload_manager_cubit.dart';
import '../../../../../injection_container.dart';
import '../common/dynamic_list_editor.dart';
import '../editor_types.dart';
import 'editor_utils.dart';
import '../../../../../core/localization/app_localizations.dart';

/// Editor for the features block type.
/// Exposes layout_style and the items list (title, description, image_url).
class FeaturesEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const FeaturesEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
    required this.persistAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List items = List.from(block['items'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDropdown(
          context,
          block,
          context.translate('layout_style'),
          'layout_style',
          ['grid', 'bento'],
          (val) => cubit.updateBlockProperty(index, 'layout_style', val),
        ),
        SizedBox(height: 24),
        DynamicListEditor(
          title: context.translate('features_list'),
          addLabel: context.translate('add_feature'),
          itemCount: items.length,
          itemTitleBuilder: (i) => context.translate('feature') + ' #${i + 1}',
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final List items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onAdd: () async {
            final selectedData = await ImagePickerModal.show(context);
            if (selectedData == null) return;

            final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';
            
            // Add a temporary upload:// item so the UI shows the loading spinner!
            final List freshItems = List.from(block['items'] ?? []);
            final int tIndex = freshItems.length;
            freshItems.add({'title': '', 'description': '', 'image_url': uploadId});
            cubit.updateBlockProperty(index, 'items', freshItems);

            sl<UploadManagerCubit>().upload(
              uploadId: uploadId,
              data: selectedData,
              onSuccess: (finalUrl) {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems2 = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems2.length) {
                    freshItems2[tIndex] = Map<String, dynamic>.from(freshItems2[tIndex])..['image_url'] = finalUrl;
                    cubit.updateBlockProperty(index, 'items', freshItems2);
                  }
                }
              },
              onCancel: () {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems2 = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems2.length) {
                    freshItems2.removeAt(tIndex);
                    cubit.updateBlockProperty(index, 'items', freshItems2);
                  }
                }
              },
            );
          },
          onDelete: (i) {
            final List updated = List.from(block['items'] ?? []);
            updated.removeAt(i);
            cubit.updateBlockProperty(index, 'items', updated);
          },
          itemBuilder: (context, i, onDelete) {
            final item = items[i] as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: context.translate('title'),
                  controller: getController("${index}_feat_${i}_title", item['title'] ?? ''),
                  focusNode: getFocusNode("${index}_feat_${i}_title"),
                  maxLength: 100,
                  onChanged: (val) => _updateItem(i, 'title', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('description'),
                  maxLines: 2,
                  controller: getController("${index}_feat_${i}_desc", item['description'] ?? ''),
                  focusNode: getFocusNode("${index}_feat_${i}_desc"),
                  maxLength: 300,
                  onChanged: (val) => _updateItem(i, 'description', val),
                ),
                const SizedBox(height: 12),
                CustomImageField(
                  label: context.translate('image_url'),
                  imageUrl: item['image_url'],
                  isUploading: (item['image_url'] ?? '').toString().startsWith('upload://'),
                  onAction: () => pickImage(cubit, index, itemIndex: i, itemKey: 'image_url'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: i, itemKey: 'image_url'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _updateItem(int itemIndex, String key, dynamic value) {
    final List items = List.from(block['items'] ?? []);
    final item = Map<String, dynamic>.from(items[itemIndex]);
    item[key] = value;
    items[itemIndex] = item;
    cubit.updateBlockProperty(index, 'items', items);
  }
}
