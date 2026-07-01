import 'package:flutter/material.dart';
import 'package:landymaker/core/localization/localization_cubit.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../common/dynamic_list_editor.dart';

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
        DynamicListEditor(
          title: "الأسئلة الشائعة (FAQ Items)",
          addLabel: "أضف سؤال",
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: (i) {
            final List items = block['items'] ?? [];
            return (items[i]['question'] ?? '').isEmpty ? 'سؤال جديد' : items[i]['question'];
          },
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final List items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onAdd: () => cubit.addFaqItem(index),
          onDelete: (i) => cubit.deleteFaqItem(index, i),
          itemBuilder: (context, fIndex, onDelete) {
            final items = (block['items'] as List?) ?? [];
            final item = items[fIndex] as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 12),
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
            );
          },
        ),
      ],
    );
  }
}
