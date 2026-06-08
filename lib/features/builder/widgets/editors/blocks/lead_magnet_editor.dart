import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

class LeadMagnetEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const LeadMagnetEditor({
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
          label: context.translate('subtitle'),
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            maxLines: 2,
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('button_text'),
          child: CustomTextField(
            controller: getController("${index}_button_text", block['button_text'] ?? ''),
            focusNode: getFocusNode("${index}_button_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
          ),
        ),
        const SizedBox(height: 16),
        CustomImageField(
          label: context.translate('image_url'),
          imageUrl: block['image_url'],
          onAction: () => pickImage(cubit, index),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
