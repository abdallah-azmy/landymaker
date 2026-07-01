import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../common/dynamic_list_editor.dart';

/// Editor for the service_steps block type.
/// Exposes title, subtitle, layout_style (vertical/horizontal),
/// and steps with title and description.
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
        SizedBox(height: 16),
        FormGroup(
          label: 'العنوان الفرعي',
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 24),
        FormGroup(
          label: 'نوع التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_style'] as String?) ?? 'vertical',
            items: const [
              DropdownMenuItem(value: 'vertical', child: Text('عمودي (Vertical)')),
              DropdownMenuItem(value: 'horizontal', child: Text('أفقي (Horizontal)')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        DynamicListEditor(
          title: "خطوات العمل",
          addLabel: "إضافة خطوة",
          itemCount: items.length,
          itemTitleBuilder: (i) => (items[i]['title'] ?? '').isEmpty ? 'الخطوة ${i + 1}' : items[i]['title'],
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final List items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onAdd: () {
            final List items = List.from(block['items'] ?? []);
            items.add({'title': 'خطوة جديدة', 'description': 'اشرح ماذا يحدث في هذه المرحلة.'});
            cubit.updateBlockProperty(index, 'items', items);
          },
          onDelete: (i) {
            final List items = List.from(block['items'] ?? []);
            items.removeAt(i);
            cubit.updateBlockProperty(index, 'items', items);
          },
          itemBuilder: (context, i, onDelete) {
            final item = items[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: "العنوان",
                  controller: getController("${index}_step_${i}_title", item['title'] ?? ''),
                  focusNode: getFocusNode("${index}_step_${i}_title"),
                  onChanged: (val) {
                    final List items = List.from(block['items'] ?? []);
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
                    final List items = List.from(block['items'] ?? []);
                    items[i]['description'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
