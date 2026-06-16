import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';

class ComparisonTableEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final TextEditingController Function(String, String) getController;
  final FocusNode Function(String) getFocusNode;

  const ComparisonTableEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final List plans = List.from(block['plans'] ?? []);
    final List features = List.from(block['features'] ?? []);

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
        Text("الخطط/الخيارات", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ...List.generate(plans.length, (i) {
          final plan = plans[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "اسم الخطة",
                    controller: getController("${index}_plan_${i}_name", plan['name'] ?? ''),
                    focusNode: getFocusNode("${index}_plan_${i}_name"),
                    onChanged: (val) {
                      plans[i]['name'] = val;
                      cubit.updateBlockProperty(index, 'plans', plans);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: () {
                    plans.removeAt(i);
                    // Also need to remove values from features
                    for (var f in features) {
                      final List vals = List.from(f['values'] ?? []);
                      if (i < vals.length) vals.removeAt(i);
                      f['values'] = vals;
                    }
                    cubit.updateBlockProperty(index, 'plans', plans);
                    cubit.updateBlockProperty(index, 'features', features);
                  },
                ),
              ],
            ),
          );
        }),
        OutlinedButton(
          onPressed: () {
            plans.add({'name': 'خطة جديدة'});
            for (var f in features) {
              final List vals = List.from(f['values'] ?? []);
              vals.add(false);
              f['values'] = vals;
            }
            cubit.updateBlockProperty(index, 'plans', plans);
            cubit.updateBlockProperty(index, 'features', features);
          },
          child: const Text("إضافة خطة"),
        ),
        SizedBox(height: 32),
        Text("المميزات والمقارنة", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ...List.generate(features.length, (fi) {
          final feature = features[fi];
          final List values = List.from(feature['values'] ?? []);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "اسم الميزة",
                        controller: getController("${index}_feat_${fi}_name", feature['name'] ?? ''),
                        focusNode: getFocusNode("${index}_feat_${fi}_name"),
                        onChanged: (val) {
                          features[fi]['name'] = val;
                          cubit.updateBlockProperty(index, 'features', features);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () {
                        features.removeAt(fi);
                        cubit.updateBlockProperty(index, 'features', features);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...List.generate(plans.length, (pi) {
                  final val = pi < values.length ? values[pi] : null;
                  return CheckboxListTile(
                    title: Text(plans[pi]['name'] ?? '', style: AppTypography.caption),
                    value: val is bool ? val : false,
                    onChanged: (v) {
                      while (values.length <= pi) {
                        values.add(false);
                      }
                      values[pi] = v;
                      features[fi]['values'] = values;
                      cubit.updateBlockProperty(index, 'features', features);
                    },
                  );
                }),
              ],
            ),
          );
        }),
        OutlinedButton(
          onPressed: () {
            features.add({'name': 'ميزة جديدة', 'values': List.generate(plans.length, (_) => false)});
            cubit.updateBlockProperty(index, 'features', features);
          },
          child: const Text("إضافة ميزة للمقارنة"),
        ),
      ],
    );
  }
}
