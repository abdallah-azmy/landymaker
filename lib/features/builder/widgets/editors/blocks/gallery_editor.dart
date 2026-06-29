import 'package:flutter/material.dart';
import 'package:landymaker/core/localization/localization_cubit.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../../molecules/custom_image_field.dart';
import '../editor_types.dart';

// Note: items in the gallery block schema is a stringList of image URLs.
// gallery_links is a parallel stringList of URLs to navigate to on click.

/// Editor for the gallery block type.
/// Exposes display_mode, title, grid_columns, mobile_columns,
/// card_style, hover_effect, stagger_animations, and items (image URLs
/// with optional gallery_links).
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
          label: 'نوع العرض',
          child: DropdownButtonFormField<String>(
            initialValue: (block['display_mode'] as String?) ?? 'grid',
            items: const [
              DropdownMenuItem(value: 'grid', child: Text('شبكة')),
              DropdownMenuItem(value: 'carousel', child: Text('شريط متحرك')),
              DropdownMenuItem(value: 'masonry', child: Text('ماسونري')),
            ],
            onChanged: (val) =>
                cubit.updateBlockProperty(index, 'display_mode', val),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        SizedBox(height: 16),
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
          label: 'أعمدة سطح المكتب',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('2')),
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 4, label: Text('4')),
              ButtonSegment(value: 6, label: Text('6')),
            ],
            selected: {(block['grid_columns'] as int?) ?? 3},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'grid_columns', val.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'mobile_columns', val.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'نوع البطاقة',
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'classic', label: Text('كلاسيكي')),
              ButtonSegment(value: 'modern', label: Text('حديث')),
              ButtonSegment(value: 'minimal', label: Text('بسيط')),
            ],
            selected: {block['card_style'] ?? 'classic'},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'card_style', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'تأثير التحويم',
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'none', label: Text('بدون')),
              ButtonSegment(value: 'scale', label: Text('تكبير')),
              ButtonSegment(value: 'elevate', label: Text('رفع')),
              const ButtonSegment(value: 'glow', label: Text('وهج')),
            ],
            selected: {block['hover_effect'] ?? 'scale'},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'hover_effect', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: block['stagger_animations'] ?? true,
          onChanged: (val) =>
              cubit.updateBlockProperty(index, 'stagger_animations', val),
          title: Text('تحريك متدرج', style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
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
                        color: Theme.of(context).colorScheme.error,
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
