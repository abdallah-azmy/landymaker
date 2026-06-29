import 'package:flutter/material.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../molecules/custom_image_field.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/localization/app_localizations.dart';

class HeroEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const HeroEditor({
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
          label: context.translate('subtitle'),
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            maxLines: 3,
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 16),
        CustomImageField(
          label: context.translate('image_url'),
          imageUrl: block['image_url'],
          isUploading: (block['image_url'] ?? '').toString().startsWith('upload://'),
          onAction: () => pickImage(cubit, index),
          onSaveTemplateAsset: () => persistAsset(cubit, index),
        ),
      ],
    );
  }
}
