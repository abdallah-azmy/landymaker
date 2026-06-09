import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

import '../../molecules/ai_copywriter_trigger.dart';

class HeroEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const HeroEditor({
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
    final businessContext = {
      'type': block['type'],
      'title': block['title'],
      'subtitle': block['subtitle'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.translate('subtitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
            AiCopywriterTrigger(
              fieldType: 'Hero Subtitle',
              contextData: businessContext,
              onApply: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
          focusNode: getFocusNode("${index}_subtitle"),
          maxLines: 3,
          onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
        ),
        const SizedBox(height: 16),
        CustomImageField(
          label: context.translate('hero_image'),
          imageUrl: block['image_url'],
          onAction: () => pickImage(cubit, index),
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white10),
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
        FormGroup(
          label: context.translate('button_url'),
          helperText: "https://...",
          child: CustomTextField(
            controller: getController("${index}_button_url", block['button_url'] ?? ''),
            focusNode: getFocusNode("${index}_button_url"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_url', val),
            keyboardType: TextInputType.url,
          ),
        ),
      ],
    );
  }
}
