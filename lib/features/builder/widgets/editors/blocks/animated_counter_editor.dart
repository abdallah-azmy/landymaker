import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';

class AnimatedCounterEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const AnimatedCounterEditor({
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
              "العدادات (Counters)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                final List items = List.from(block['items'] ?? []);
                items.add({'value': '100', 'label': 'تسمية جديدة', 'prefix': '', 'suffix': ''});
                cubit.updateBlockProperty(index, 'items', items);
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("أضف عداد"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate((block['items'] as List).length, (tIndex) {
          final Map<String, dynamic> item = (block['items'] as List)[tIndex];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("عداد #${tIndex + 1}", style: AppTypography.caption),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                      onPressed: () {
                        final List items = List.from(block['items'] ?? []);
                        items.removeAt(tIndex);
                        cubit.updateBlockProperty(index, 'items', items);
                      },
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "القيمة (الرقم)",
                  controller: getController("${index}_counter_${tIndex}_value", item['value']?.toString() ?? ''),
                  focusNode: getFocusNode("${index}_counter_${tIndex}_value"),
                  onChanged: (val) {
                    final List items = List.from(block['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(items[tIndex]);
                    updatedItem['value'] = val;
                    items[tIndex] = updatedItem;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "التسمية (مثال: عميل سعيد)",
                  controller: getController("${index}_counter_${tIndex}_label", item['label'] ?? ''),
                  focusNode: getFocusNode("${index}_counter_${tIndex}_label"),
                  onChanged: (val) {
                    final List items = List.from(block['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(items[tIndex]);
                    updatedItem['label'] = val;
                    items[tIndex] = updatedItem;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "بادئة (Prefix)",
                        controller: getController("${index}_counter_${tIndex}_prefix", item['prefix'] ?? ''),
                        focusNode: getFocusNode("${index}_counter_${tIndex}_prefix"),
                        onChanged: (val) {
                          final List items = List.from(block['items'] ?? []);
                          final updatedItem = Map<String, dynamic>.from(items[tIndex]);
                          updatedItem['prefix'] = val;
                          items[tIndex] = updatedItem;
                          cubit.updateBlockProperty(index, 'items', items);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        hintText: "خاتمة (Suffix)",
                        controller: getController("${index}_counter_${tIndex}_suffix", item['suffix'] ?? ''),
                        focusNode: getFocusNode("${index}_counter_${tIndex}_suffix"),
                        onChanged: (val) {
                          final List items = List.from(block['items'] ?? []);
                          final updatedItem = Map<String, dynamic>.from(items[tIndex]);
                          updatedItem['suffix'] = val;
                          items[tIndex] = updatedItem;
                          cubit.updateBlockProperty(index, 'items', items);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
