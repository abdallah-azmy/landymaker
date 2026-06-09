import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/molecules/status_pill.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../molecules/custom_image_field.dart';

class BasicSectionEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const BasicSectionEditor({
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
        const SizedBox(height: 16),
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
              color: AppColors.cardBg,
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.secondary,
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
        const SizedBox(height: 12),
        ...List.generate((block['elements'] ?? []).length, (i) {
          final elem = (block['elements'] ?? [])[i] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(
                      label: elem['type'] == 'text' ? 'نص' : 'صورة',
                      color: AppColors.secondary,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.dangerRed,
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
                const SizedBox(height: 8),
                if (elem['type'] == 'text')
                  CustomTextField(
                    controller: getController(
                      "${index}_element_${i}_content",
                      elem['content'] ?? '',
                    ),
                    focusNode: getFocusNode("${index}_element_${i}_content"),
                    maxLines: 3,
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
                    onAction: () => pickImage(cubit, index, itemIndex: i, itemKey: 'url'),
                  ),
                  const SizedBox(height: 12),
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
                      const SizedBox(width: 8),
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
