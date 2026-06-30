import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../molecules/custom_image_field.dart';
import '../../../controllers/builder_cubit.dart';
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.translate('features_list'), style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () {
                final List newItems = List.from(block['items'] ?? []);
                newItems.add({'title': '', 'description': '', 'image_url': ''});
                cubit.updateBlockProperty(index, 'items', newItems);
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(context.translate('add_feature')),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...List.generate(items.length, (i) {
          final item = items[i] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.translate('feature') + ' #${i + 1}', style: AppTypography.caption),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                      onPressed: () {
                        final List updated = List.from(block['items'] ?? []);
                        updated.removeAt(i);
                        cubit.updateBlockProperty(index, 'items', updated);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomTextField(
                  hintText: context.translate('title'),
                  controller: getController("${index}_feat_${i}_title", item['title'] ?? ''),
                  focusNode: getFocusNode("${index}_feat_${i}_title"),
                  maxLength: 100,
                  onChanged: (val) => _updateItem(i, 'title', val),
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('description'),
                  maxLines: 2,
                  controller: getController("${index}_feat_${i}_desc", item['description'] ?? ''),
                  focusNode: getFocusNode("${index}_feat_${i}_desc"),
                  maxLength: 300,
                  onChanged: (val) => _updateItem(i, 'description', val),
                ),
                SizedBox(height: 12),
                CustomImageField(
                  label: context.translate('image_url'),
                  imageUrl: item['image_url'],
                  isUploading: (item['image_url'] ?? '').toString().startsWith('upload://'),
                  onAction: () => pickImage(cubit, index, itemIndex: i, itemKey: 'image_url'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: i, itemKey: 'image_url'),
                ),
              ],
            ),
          );
        }),
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
