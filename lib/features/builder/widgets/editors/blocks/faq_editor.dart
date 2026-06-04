import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';

class FaqEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const FaqEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
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
              "الأسئلة الشائعة (FAQ Items)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => cubit.addFaqItem(index),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("أضف سؤال"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (fIndex) {
          final item = ((block['items'] as List?) ?? [])[fIndex] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "سؤال #${fIndex + 1}",
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                      onPressed: () => cubit.deleteFaqItem(index, fIndex),
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "السؤال",
                  controller: getController("${index}_faq_${fIndex}_question", item['question'] ?? ''),
                  focusNode: getFocusNode("${index}_faq_${fIndex}_question"),
                  onChanged: (val) => cubit.updateFaqItem(index, fIndex, 'question', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "الإجابة",
                  maxLines: 3,
                  controller: getController("${index}_faq_${fIndex}_answer", item['answer'] ?? ''),
                  focusNode: getFocusNode("${index}_faq_${fIndex}_answer"),
                  onChanged: (val) => cubit.updateFaqItem(index, fIndex, 'answer', val),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: "ابحث في الصور (Stock Images)",
                  icon: Icons.search_rounded,
                  isSecondary: true,
                  onPressed: () => pickImage(
                    cubit,
                    index,
                    itemIndex: fIndex,
                    itemKey: 'image_url',
                  ),
                  width: double.infinity,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
