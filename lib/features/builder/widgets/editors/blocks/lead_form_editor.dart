import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

class LeadFormEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const LeadFormEditor({
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
    final imageUrl = block['image_url'];
    final isUploading = (imageUrl ?? '').toString().startsWith('upload://');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block['type'] == 'lead_magnet') ...[
          FormGroup(
            label: context.translate('subtitle'),
            child: CustomTextField(
              controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
              focusNode: getFocusNode("${index}_subtitle"),
              maxLines: 2,
              onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
            ),
          ),
          const SizedBox(height: 16),
          CustomImageField(
            label: context.translate('image_url'),
            imageUrl: imageUrl,
            isUploading: isUploading,
            onAction: () => pickImage(cubit, index),
            onSaveTemplateAsset: () => persistAsset(cubit, index),
          ),
          const SizedBox(height: 16),
        ],
        FormGroup(
          label: context.translate('button_text'),
          child: CustomTextField(
            controller: getController("${index}_button_text", block['button_text'] ?? ''),
            focusNode: getFocusNode("${index}_button_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
          ),
        ),
      ],
    );
  }
}
