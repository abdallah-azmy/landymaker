import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

class BentoStoreEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PersistAsset persistAsset;

  const BentoStoreEditor({
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
            segments: const [
              ButtonSegment(value: 'modern', label: Text('عصري')),
              ButtonSegment(value: 'tight', label: Text('متلاصق')),
              ButtonSegment(value: 'glass', label: Text('زجاجي')),
            ],
            selected: {block['layout_style'] ?? 'modern'},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('title'),
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
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
        FormGroup(
          label: context.translate('hover_effect'),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'none', label: Text(context.translate('anim_none'))),
              ButtonSegment(value: 'scale', label: Text(context.translate('scale'))),
              ButtonSegment(value: 'elevate', label: Text(context.translate('elevate'))),
              const ButtonSegment(value: 'glow', label: Text('وهج')),
            ],
            selected: {block['hover_effect'] ?? 'scale'},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'hover_effect', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: block['stagger_animations'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'stagger_animations', val),
          title: Text(context.translate('stagger_animations'), style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.translate('product_list'), style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => cubit.addProductItem(index),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
              label: Text(context.translate('add_product')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (pIndex) {
          final item = ((block['items'] as List?) ?? [])[pIndex] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("#${pIndex + 1}", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                      onPressed: () => cubit.deleteProductItem(index, pIndex),
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: context.translate('product_name'),
                  controller: getController("${index}_bento_${pIndex}_name", item['name'] ?? ''),
                  focusNode: getFocusNode("${index}_bento_${pIndex}_name"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'name', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('price'),
                  controller: getController("${index}_bento_${pIndex}_price", item['price'] ?? ''),
                  focusNode: getFocusNode("${index}_bento_${pIndex}_price"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'price', val),
                ),
                const SizedBox(height: 12),
                CustomImageField(
                  label: context.translate('image_url'),
                  imageUrl: item['image_url'],
                  isUploading: (item['image_url'] ?? '').toString().startsWith('upload://'),
                  onAction: () => pickImage(cubit, index, itemIndex: pIndex, itemKey: 'image_url'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: pIndex, itemKey: 'image_url'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
