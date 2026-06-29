import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../../molecules/custom_image_field.dart';
import '../common/dynamic_list_editor.dart';
import '../editor_types.dart';

/// Editor for the trust_logos block type.
/// Exposes title, layout_style (row/grid), card_style, hover_effect,
/// stagger_animations, and items (stringList of logo image URLs).
class TrustLogosEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const TrustLogosEditor({
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
          label: 'العنوان الرئيسي',
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'نوع التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_style'] as String?) ?? 'row',
            items: const [
              DropdownMenuItem(value: 'row', child: Text('صف')),
              DropdownMenuItem(value: 'grid', child: Text('شبكة')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
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
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'card_style', val.first),
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
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'hover_effect', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: block['stagger_animations'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'stagger_animations', val),
          title: Text('تحريك متدرج', style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16),
        DynamicListEditor(
          title: "الشعارات (Logos)",
          addLabel: "أضف شعار",
          addIcon: Icons.add_photo_alternate_rounded,
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: null,
          onAdd: () {
            final List items = List.from(block['items'] ?? []);
            items.add('https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg');
            cubit.updateBlockProperty(index, 'items', items);
          },
          onDelete: (tIndex) {
            final List items = List.from(block['items'] ?? []);
            items.removeAt(tIndex);
            cubit.updateBlockProperty(index, 'items', items);
          },
          itemBuilder: (context, tIndex, onDelete) {
            final String url = ((block['items'] as List?) ?? [])[tIndex];
            final isUploading = url.startsWith('upload://');
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("شعار رقم ${tIndex + 1}", style: AppTypography.bodySmall),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomImageField(
                  label: "",
                  imageUrl: url,
                  isUploading: isUploading,
                  onAction: () => pickImage(cubit, index, itemIndex: tIndex, itemKey: 'items_array'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: tIndex, itemKey: 'items_array'),
                ),
                SizedBox(height: 12),
              ],
            );
          },
        ),
      ],
    );
  }
}
