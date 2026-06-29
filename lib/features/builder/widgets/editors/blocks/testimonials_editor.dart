import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../molecules/custom_image_field.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "آراء العملاء (Testimonials)",
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => cubit.addTestimonialItem(index),
              icon: Icon(Icons.add_rounded, size: 16),
              label: const Text("أضف رأي"),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (tIndex) {
          final item =
              ((block['items'] as List?) ?? [])[tIndex] as Map<String, dynamic>;
          final String imageUrl = item['image_url'] ?? '';
          final isUploading = imageUrl.startsWith('upload://');

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
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
                      "رأي #${tIndex + 1}",
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () =>
                          cubit.deleteTestimonialItem(index, tIndex),
                    ),
                  ],
                ),
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
                SizedBox(height: 16),
                CustomTextField(
                  hintText: "الاسم",
                  controller: getController(
                    "${index}_testimonial_${tIndex}_author",
                    item['author'] ?? '',
                  ),
                  focusNode: getFocusNode(
                    "${index}_testimonial_${tIndex}_author",
                  ),
                  onChanged: (val) =>
                      cubit.updateTestimonialItem(index, tIndex, 'author', val),
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: "المنصب/الوصف",
                  controller: getController(
                    "${index}_testimonial_${tIndex}_role",
                    item['role'] ?? '',
                  ),
                  focusNode: getFocusNode(
                    "${index}_testimonial_${tIndex}_role",
                  ),
                  onChanged: (val) =>
                      cubit.updateTestimonialItem(index, tIndex, 'role', val),
                ),
                SizedBox(height: 12),
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
                  onChanged: (val) =>
                      cubit.updateTestimonialItem(index, tIndex, 'quote', val),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
