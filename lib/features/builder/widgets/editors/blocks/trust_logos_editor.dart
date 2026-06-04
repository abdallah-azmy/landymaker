import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../common/dynamic_list_editor.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';

class TrustLogosEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const TrustLogosEditor({
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
        DynamicListEditor(
          title: "الشعارات (Logos)",
          addLabel: "أضف شعار",
          addIcon: Icons.add_photo_alternate_rounded,
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: null,
          onAdd: () {
            final List items = List.from(block['items'] ?? []);
            items.add('https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg');
            cubit.updateBlockProperty(index, 'items', items);
          },
          onDelete: (tIndex) {
            final List items = List.from(block['items'] ?? []);
            items.removeAt(tIndex);
            cubit.updateBlockProperty(index, 'items', items);
          },
          itemBuilder: (context, tIndex, onDelete) {
            final String url = ((block['items'] as List?) ?? [])[tIndex];
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "رابط الشعار",
                        controller: getController("${index}_trustlogo_${tIndex}", url),
                        focusNode: getFocusNode("${index}_trustlogo_${tIndex}"),
                        onChanged: (val) {
                          final List items = List.from(block['items'] ?? []);
                          items[tIndex] = val;
                          cubit.updateBlockProperty(index, 'items', items);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: "ابحث في الصور",
                  icon: Icons.search_rounded,
                  isSecondary: true,
                  onPressed: () => pickImage(
                    cubit,
                    index,
                    itemIndex: tIndex,
                    itemKey: 'items_array',
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
