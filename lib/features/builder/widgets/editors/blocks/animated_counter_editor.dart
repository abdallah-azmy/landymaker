import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../common/dynamic_list_editor.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';

/// Editor for the animated_counter block type.
/// Exposes title, variant (0=Row/1=Grid), and counter items with value, label, prefix, suffix.
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
        FormGroup(
          label: 'نوع العرض',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('صف')),
              ButtonSegment(value: 1, label: Text('شبكة')),
            ],
            selected: {(block['variant'] as int?) ?? 0},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'variant', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        DynamicListEditor(
          title: "العدادات (Counters)",
          addLabel: "أضف عداد",
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: (i) {
            final List items = block['items'] ?? [];
            final String valueStr = items[i]['value']?.toString() ?? '';
            final String labelStr = items[i]['label'] ?? '';
            return labelStr.isEmpty ? 'عداد #$i' : '$labelStr ($valueStr)';
          },
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final List items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onAdd: () {
            final List items = List.from(block['items'] ?? []);
            items.add({
              'value': '100',
              'label': 'تسمية جديدة',
              'prefix': '',
              'suffix': '',
            });
            cubit.updateBlockProperty(index, 'items', items);
          },
          onDelete: (i) {
            final List items = List.from(block['items'] ?? []);
            items.removeAt(i);
            cubit.updateBlockProperty(index, 'items', items);
          },
          itemBuilder: (context, tIndex, onDelete) {
            final items = (block['items'] as List?) ?? [];
            final Map<String, dynamic> item = items[tIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: "القيمة (الرقم)",
                  controller: getController(
                    "${index}_counter_${tIndex}_value",
                    item['value']?.toString() ?? '',
                  ),
                  focusNode: getFocusNode("${index}_counter_${tIndex}_value"),
                  onChanged: (val) {
                    final List items = List.from(block['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(
                      items[tIndex],
                    );
                    updatedItem['value'] = val;
                    items[tIndex] = updatedItem;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "التسمية (مثال: عميل سعيد)",
                  controller: getController(
                    "${index}_counter_${tIndex}_label",
                    item['label'] ?? '',
                  ),
                  focusNode: getFocusNode("${index}_counter_${tIndex}_label"),
                  onChanged: (val) {
                    final List items = List.from(block['items'] ?? []);
                    final updatedItem = Map<String, dynamic>.from(
                      items[tIndex],
                    );
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
                        controller: getController(
                          "${index}_counter_${tIndex}_prefix",
                          item['prefix'] ?? '',
                        ),
                        focusNode: getFocusNode(
                          "${index}_counter_${tIndex}_prefix",
                        ),
                        onChanged: (val) {
                          final List items = List.from(block['items'] ?? []);
                          final updatedItem = Map<String, dynamic>.from(
                            items[tIndex],
                          );
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
                        controller: getController(
                          "${index}_counter_${tIndex}_suffix",
                          item['suffix'] ?? '',
                        ),
                        focusNode: getFocusNode(
                          "${index}_counter_${tIndex}_suffix",
                        ),
                        onChanged: (val) {
                          final List items = List.from(block['items'] ?? []);
                          final updatedItem = Map<String, dynamic>.from(
                            items[tIndex],
                          );
                          updatedItem['suffix'] = val;
                          items[tIndex] = updatedItem;
                          cubit.updateBlockProperty(index, 'items', items);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
