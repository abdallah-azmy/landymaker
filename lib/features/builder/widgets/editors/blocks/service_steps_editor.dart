import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';

class ServiceStepsEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final TextEditingController Function(String, String) getController;
  final FocusNode Function(String) getFocusNode;

  const ServiceStepsEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final List items = List.from(block['items'] ?? []);

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
        const SizedBox(height: 16),
        FormGroup(
          label: 'العنوان الفرعي',
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        const SizedBox(height: 24),
        Text("خطوات العمل", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("الخطوة ${i + 1}", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () {
                        items.removeAt(i);
                        cubit.updateBlockProperty(index, 'items', items);
                      },
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "العنوان",
                  controller: getController("${index}_step_${i}_title", item['title'] ?? ''),
                  focusNode: getFocusNode("${index}_step_${i}_title"),
                  onChanged: (val) {
                    items[i]['title'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "الشرح",
                  maxLines: 2,
                  controller: getController("${index}_step_${i}_desc", item['description'] ?? ''),
                  focusNode: getFocusNode("${index}_step_${i}_desc"),
                  onChanged: (val) {
                    items[i]['description'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            items.add({'title': 'خطوة جديدة', 'description': 'اشرح ماذا يحدث في هذه المرحلة.'});
            cubit.updateBlockProperty(index, 'items', items);
          },
          icon: const Icon(Icons.add),
          label: const Text("إضافة خطوة"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
