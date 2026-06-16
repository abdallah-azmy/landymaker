import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../common/dynamic_list_editor.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';

import '../../molecules/custom_image_field.dart';

class TrustLogosEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const TrustLogosEditor({
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
          label: 'العنوان الرئيسي',
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
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
            final isUploading = url.startsWith('upload://');
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("شعار رقم ${tIndex + 1}", style: AppTypography.bodySmall),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 18),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomImageField(
                  label: "",
                  imageUrl: url,
                  isUploading: isUploading,
                  onAction: () => pickImage(cubit, index, itemIndex: tIndex, itemKey: 'items_array'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: tIndex, itemKey: 'items_array'),
                ),
                SizedBox(height: 12),
              ],
            );
          },
        ),
      ],
    );
  }
}
