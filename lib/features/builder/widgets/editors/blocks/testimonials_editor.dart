import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../controllers/builder_state.dart';
import '../../molecules/custom_image_field.dart';
import '../../modals/image_picker_modal.dart';
import '../../../controllers/upload_manager_cubit.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../injection_container.dart';
import '../common/dynamic_list_editor.dart';

/// Editor for the testimonials block type.
/// Exposes title, layout_style (cards/carousel), card_style, hover_effect,
/// stagger_animations, and items with author, role, quote, image_url.
class TestimonialsEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PersistAsset persistAsset;

  const TestimonialsEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.persistAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: 'نوع التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_style'] as String?) ?? 'cards',
            items: const [
              DropdownMenuItem(value: 'cards', child: Text('بطاقات (Cards)')),
              DropdownMenuItem(value: 'carousel', child: Text('شريط متحرك (Carousel)')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
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
          title: "آراء العملاء (Testimonials)",
          addLabel: "أضف رأي",
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: (i) {
            final List items = block['items'] ?? [];
            return (items[i]['author'] ?? '').isEmpty ? 'رأي جديد' : items[i]['author'];
          },
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
            freshItems.add({
              'author': 'اسم العميل',
              'role': 'المنصب/الوصف',
              'quote': '',
              'image_url': uploadId,
            });
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
          onDelete: (i) => cubit.deleteTestimonialItem(index, i),
          itemBuilder: (context, tIndex, onDelete) {
            final items = (block['items'] as List?) ?? [];
            final item = items[tIndex] as Map<String, dynamic>;
            final String imageUrl = item['image_url'] ?? '';
            final isUploading = imageUrl.startsWith('upload://');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageField(
                  label: "صورة العميل (Avatar)",
                  imageUrl: imageUrl,
                  isUploading: isUploading,
                  onAction: () => pickImage(
                    cubit,
                    index,
                    itemIndex: tIndex,
                    itemKey: 'image_url',
                  ),
                  onSaveTemplateAsset: () => persistAsset(
                    cubit,
                    index,
                    itemIndex: tIndex,
                    itemKey: 'image_url',
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: "الاسم",
                  controller: getController(
                    "${index}_testimonial_${tIndex}_author",
                    item['author'] ?? '',
                  ),
                  focusNode: getFocusNode(
                    "${index}_testimonial_${tIndex}_author",
                  ),
                  maxLength: 100,
                  onChanged: (val) =>
                      cubit.updateTestimonialItem(index, tIndex, 'author', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "المنصب/الوصف",
                  controller: getController(
                    "${index}_testimonial_${tIndex}_role",
                    item['role'] ?? '',
                  ),
                  focusNode: getFocusNode(
                    "${index}_testimonial_${tIndex}_role",
                  ),
                  maxLength: 100,
                  onChanged: (val) =>
                      cubit.updateTestimonialItem(index, tIndex, 'role', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "الرأي",
                  maxLines: 3,
                  controller: getController(
                    "${index}_testimonial_${tIndex}_quote",
                    item['quote'] ?? '',
                  ),
                  focusNode: getFocusNode(
                    "${index}_testimonial_${tIndex}_quote",
                  ),
                  maxLength: 500,
                  onChanged: (val) =>
                      cubit.updateTestimonialItem(index, tIndex, 'quote', val),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
