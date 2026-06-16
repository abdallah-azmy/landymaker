import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

import '../../molecules/custom_image_field.dart';

class GalleryEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const GalleryEditor({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: context.translate('title'),
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'أعمدة الجوال',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1')),
              ButtonSegment(value: 2, label: Text('2')),
            ],
            selected: {block['mobile_columns'] ?? 1},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'mobile_columns', val.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.translate('gallery'),
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => cubit.addGalleryImage(index),
              icon: Icon(Icons.add_photo_alternate_rounded, size: 16),
              label: Text(context.translate('add_image')),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (gIndex) {
          final String imageUrl = ((block['items'] as List?) ?? [])[gIndex];
          final List galleryLinks = List.from(block['gallery_links'] ?? []);
          while (galleryLinks.length <= gIndex) galleryLinks.add('');
          final String linkVal = galleryLinks[gIndex];
          final isUploading = imageUrl.startsWith('upload://');

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "صورة رقم ${gIndex + 1}",
                      style: AppTypography.bodySmall,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.dangerRed,
                      ),
                      onPressed: () => cubit.deleteGalleryImage(index, gIndex),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomImageField(
                  label: "",
                  imageUrl: imageUrl,
                  isUploading: isUploading,
                  onAction: () => pickImage(
                    cubit,
                    index,
                    itemIndex: gIndex,
                    itemKey: 'items_array',
                  ),
                  onSaveTemplateAsset: () => persistAsset(
                    cubit,
                    index,
                    itemIndex: gIndex,
                    itemKey: 'items_array',
                  ),
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('redirect_url'),
                  controller: getController(
                    "${index}_gallery_link_${gIndex}",
                    linkVal,
                  ),
                  focusNode: getFocusNode("${index}_gallery_link_${gIndex}"),
                  onChanged: (val) {
                    final List updatedLinks = List.from(galleryLinks);
                    updatedLinks[gIndex] = val;
                    cubit.updateBlockProperty(
                      index,
                      'gallery_links',
                      updatedLinks,
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
