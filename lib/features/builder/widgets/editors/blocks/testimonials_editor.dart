import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';

import '../../molecules/custom_image_field.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "آراء العملاء (Testimonials)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => cubit.addTestimonialItem(index),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("أضف رأي"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (tIndex) {
          final item = ((block['items'] as List?) ?? [])[tIndex] as Map<String, dynamic>;
          final String imageUrl = item['image_url'] ?? '';
          final isUploading = imageUrl.startsWith('upload://');

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "رأي #${tIndex + 1}",
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                      onPressed: () => cubit.deleteTestimonialItem(index, tIndex),
                    ),
                  ],
                ),
                CustomImageField(
                  label: "صورة العميل (Avatar)",
                  imageUrl: imageUrl,
                  isUploading: isUploading,
                  onAction: () => pickImage(cubit, index, itemIndex: tIndex, itemKey: 'image_url'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: tIndex, itemKey: 'image_url'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: "الاسم",
                  controller: getController("${index}_testimonial_${tIndex}_author", item['author'] ?? ''),
                  focusNode: getFocusNode("${index}_testimonial_${tIndex}_author"),
                  onChanged: (val) => cubit.updateTestimonialItem(index, tIndex, 'author', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "المنصب/الوصف",
                  controller: getController("${index}_testimonial_${tIndex}_role", item['role'] ?? ''),
                  focusNode: getFocusNode("${index}_testimonial_${tIndex}_role"),
                  onChanged: (val) => cubit.updateTestimonialItem(index, tIndex, 'role', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "الرأي",
                  maxLines: 3,
                  controller: getController("${index}_testimonial_${tIndex}_quote", item['quote'] ?? ''),
                  focusNode: getFocusNode("${index}_testimonial_${tIndex}_quote"),
                  onChanged: (val) => cubit.updateTestimonialItem(index, tIndex, 'quote', val),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
