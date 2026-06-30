import 'package:flutter/material.dart';
import 'package:landymaker/core/localization/localization_cubit.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';

/// Editor for the faq block type.
/// Exposes title, variant (0=Accordion/1=List), card_style, hover_effect,
/// stagger_animations, and FAQ items with question/answer/image_url.
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
          label: 'نوع العرض',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('أكورديون')),
              ButtonSegment(value: 1, label: Text('قائمة')),
            ],
            selected: {(block['variant'] as int?) ?? 0},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'variant', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
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
              "الأسئلة الشائعة (FAQ Items)",
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => cubit.addFaqItem(index),
              icon: Icon(Icons.add_rounded, size: 16),
              label: const Text("أضف سؤال"),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (fIndex) {
          final item =
              ((block['items'] as List?) ?? [])[fIndex] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
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
                      "سؤال #${fIndex + 1}",
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
                      onPressed: () => cubit.deleteFaqItem(index, fIndex),
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "السؤال",
                  maxLength: 200,
                  controller: getController(
                    "${index}_faq_${fIndex}_question",
                    item['question'] ?? '',
                  ),
                  focusNode: getFocusNode("${index}_faq_${fIndex}_question"),
                  onChanged: (val) =>
                      cubit.updateFaqItem(index, fIndex, 'question', val),
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: "الإجابة",
                  maxLines: 3,
                  maxLength: 500,
                  controller: getController(
                    "${index}_faq_${fIndex}_answer",
                    item['answer'] ?? '',
                  ),
                  focusNode: getFocusNode("${index}_faq_${fIndex}_answer"),
                  onChanged: (val) =>
                      cubit.updateFaqItem(index, fIndex, 'answer', val),
                ),
                SizedBox(height: 12),
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
