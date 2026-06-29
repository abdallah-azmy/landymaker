import 'package:flutter/material.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../molecules/custom_image_field.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/localization/app_localizations.dart';
import 'editor_utils.dart';

/// Editor for the hero_saas block type.
/// Handles subtitle, image_url, button_text, button_url, badge_text,
/// tech_logos, and layout_style (dashboardSplit / launchCenter / darkSaas).
class HeroSaasEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const HeroSaasEditor({
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
    final List<String> techLogos = (block['tech_logos'] as List?)?.cast<String>() ?? [];

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
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('button_text'),
          child: CustomTextField(
            controller: getController("${index}_button_text", block['button_text'] ?? ''),
            focusNode: getFocusNode("${index}_button_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('button_url'),
          child: CustomTextField(
            controller: getController("${index}_button_url", block['button_url'] ?? ''),
            focusNode: getFocusNode("${index}_button_url"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_url', val),
            keyboardType: TextInputType.url,
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('badge_text'),
          child: CustomTextField(
            controller: getController("${index}_badge_text", block['badge_text'] ?? ''),
            focusNode: getFocusNode("${index}_badge_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'badge_text', val),
          ),
        ),
        SizedBox(height: 16),
        buildDropdown(
          context,
          block,
          context.translate('layout_style'),
          'layout_style',
          ['dashboardSplit', 'launchCenter', 'darkSaas'],
          (val) => cubit.updateBlockProperty(index, 'layout_style', val),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('tech_logos'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(techLogos.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(techLogos[i], style: const TextStyle(fontSize: 12)),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                        onPressed: () {
                          final updated = List<String>.from(techLogos)..removeAt(i);
                          cubit.updateBlockProperty(index, 'tech_logos', updated);
                        },
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () {
                  final updated = List<String>.from(techLogos)..add('https://');
                  cubit.updateBlockProperty(index, 'tech_logos', updated);
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text(context.translate('add_logo')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
