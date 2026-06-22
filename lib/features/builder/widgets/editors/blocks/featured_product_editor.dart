import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../models/landing_page_theme.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

class FeaturedProductEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PersistAsset persistAsset;

  const FeaturedProductEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.persistAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: context.translate('layout_style'),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'split', label: Text(context.translate('split'))),
              ButtonSegment(value: 'reversed', label: Text(context.translate('reversed'))),
              ButtonSegment(value: 'centered', label: Text(context.translate('centered'))),
            ],
            selected: {block['layout_style'] ?? 'split'},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('theme_override'),
          child: DropdownButtonFormField<String>(
            initialValue: block['theme_override'],
            items: [
              DropdownMenuItem(value: null, child: Text(context.translate('default'))),
              ...LandingPageTheme.palettes.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'theme_override', val),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('product_name'),
          child: CustomTextField(
            controller: getController("${index}_name", block['name'] ?? ''),
            focusNode: getFocusNode("${index}_name"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'name', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('price'),
          child: CustomTextField(
            controller: getController("${index}_price", block['price'] ?? ''),
            focusNode: getFocusNode("${index}_price"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'price', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: 'نص الشارة (Badge)',
          child: CustomTextField(
            controller: getController("${index}_badge_text", block['badge_text'] ?? ''),
            focusNode: getFocusNode("${index}_badge_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'badge_text', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('description'),
          child: CustomTextField(
            controller: getController("${index}_description", block['description'] ?? ''),
            focusNode: getFocusNode("${index}_description"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'description', val),
            maxLines: 3,
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
        FormGroup(
          label: context.translate('whatsapp_orders'),
          helperText: "2010...",
          child: CustomTextField(
            controller: getController("${index}_whatsapp_number", block['whatsapp_number'] ?? ''),
            focusNode: getFocusNode("${index}_whatsapp_number"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'whatsapp_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 16),
        CustomImageField(
          label: context.translate('image_url'),
          imageUrl: block['image_url'],
          isUploading: (block['image_url'] ?? '').toString().startsWith('upload://'),
          onAction: () => pickImage(cubit, index, itemKey: 'image_url'),
          onSaveTemplateAsset: () => persistAsset(cubit, index, itemKey: 'image_url'),
        ),
      ],
    );
  }
}
