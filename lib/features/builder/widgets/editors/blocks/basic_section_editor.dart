import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/molecules/form_group.dart';
import 'package:landymaker/core/widgets/molecules/status_pill.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../molecules/custom_image_field.dart';

/// Editor for the basic_section block type.
/// Exposes layout_direction, spacing, main_axis_alignment,
/// cross_axis_alignment, and a flexible elements list (text/image).
class BasicSectionEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const BasicSectionEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
    required this.persistAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: 'اتجاه التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_direction'] as String?) ?? 'column',
            items: const [
              DropdownMenuItem(value: 'column', child: Text('عمودي')),
              DropdownMenuItem(value: 'row', child: Text('أفقي')),
            ],
            onChanged: (val) =>
                cubit.updateBlockProperty(index, 'layout_direction', val),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label:
              'المسافة بين العناصر: ${((block['spacing'] ?? 20.0) as num).toInt()}',
          child: Slider(
            value: ((block['spacing'] ?? 20.0) as num).toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) =>
                cubit.updateBlockProperty(index, 'spacing', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'محاذاة رئيسية',
          child: DropdownButtonFormField<String>(
            initialValue: (block['main_axis_alignment'] as String?) ?? 'center',
            items: const [
              DropdownMenuItem(value: 'start', child: Text('بداية')),
              DropdownMenuItem(value: 'center', child: Text('وسط')),
              DropdownMenuItem(value: 'end', child: Text('نهاية')),
              DropdownMenuItem(value: 'spaceBetween', child: Text('مسافة بين')),
            ],
            onChanged: (val) =>
                cubit.updateBlockProperty(index, 'main_axis_alignment', val),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'محاذاة عرضية',
          child: DropdownButtonFormField<String>(
            initialValue:
                (block['cross_axis_alignment'] as String?) ?? 'center',
            items: const [
              DropdownMenuItem(value: 'start', child: Text('بداية')),
              DropdownMenuItem(value: 'center', child: Text('وسط')),
              DropdownMenuItem(value: 'end', child: Text('نهاية')),
              DropdownMenuItem(value: 'stretch', child: Text('تمدد')),
            ],
            onChanged: (val) =>
                cubit.updateBlockProperty(index, 'cross_axis_alignment', val),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "العناصر (Elements)",
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onSelected: (val) {
                final elements = List<Map<String, dynamic>>.from(
                  block['elements'] ?? [],
                );
                final newId = 'elem_${DateTime.now().millisecondsSinceEpoch}';
                if (val == 'text') {
                  elements.add({
                    'id': newId,
                    'type': 'text',
                    'content': 'نص جديد',
                    'style_overrides': {},
                  });
                } else if (val == 'image') {
                  elements.add({
                    'id': newId,
                    'type': 'image',
                    'url': '',
                    'width': 200,
                    'height': 200,
                    'fit': 'cover',
                  });
                }
                cubit.updateBlockProperty(index, 'elements', elements);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'text', child: Text("إضافة نص")),
                const PopupMenuItem(value: 'image', child: Text("إضافة صورة")),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        ...List.generate((block['elements'] ?? []).length, (i) {
          final elem = (block['elements'] ?? [])[i] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(
                      label: elem['type'] == 'text' ? 'نص' : 'صورة',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 18,
                      ),
                      onPressed: () {
                        final elements = List<Map<String, dynamic>>.from(
                          block['elements'] ?? [],
                        );
                        elements.removeAt(i);
                        cubit.updateBlockProperty(index, 'elements', elements);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (elem['type'] == 'text')
                  CustomTextField(
                    controller: getController(
                      "${index}_element_${i}_content",
                      elem['content'] ?? '',
                    ),
                    focusNode: getFocusNode("${index}_element_${i}_content"),
                    maxLines: 3,
                    maxLength: 300,
                    onChanged: (val) {
                      final elements = List<Map<String, dynamic>>.from(
                        block['elements'] ?? [],
                      );
                      elements[i]['content'] = val;
                      cubit.updateBlockProperty(index, 'elements', elements);
                    },
                  )
                else if (elem['type'] == 'image') ...[
                  CustomImageField(
                    label: "الصورة",
                    imageUrl: elem['url'],
                    onAction: () =>
                        pickImage(cubit, index, itemIndex: i, itemKey: 'url'),
                    onSaveTemplateAsset: () => persistAsset(
                      cubit,
                      index,
                      itemIndex: i,
                      itemKey: 'url',
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: "العرض",
                          controller: getController(
                            "${index}_element_${i}_width",
                            elem['width']?.toString() ?? '200',
                          ),
                          focusNode: getFocusNode(
                            "${index}_element_${i}_width",
                          ),
                          onChanged: (val) {
                            final elements = List<Map<String, dynamic>>.from(
                              block['elements'] ?? [],
                            );
                            elements[i]['width'] = double.tryParse(val) ?? 200;
                            cubit.updateBlockProperty(
                              index,
                              'elements',
                              elements,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          hintText: "الطول",
                          controller: getController(
                            "${index}_element_${i}_height",
                            elem['height']?.toString() ?? '200',
                          ),
                          focusNode: getFocusNode(
                            "${index}_element_${i}_height",
                          ),
                          onChanged: (val) {
                            final elements = List<Map<String, dynamic>>.from(
                              block['elements'] ?? [],
                            );
                            elements[i]['height'] = double.tryParse(val) ?? 200;
                            cubit.updateBlockProperty(
                              index,
                              'elements',
                              elements,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
