import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../editor_types.dart';
import '../../modals/image_picker_modal.dart';
import '../../../controllers/upload_manager_cubit.dart';
import '../../../../../injection_container.dart';
import '../common/dynamic_list_editor.dart';
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
          label: context.translate('whatsapp_orders'),
          helperText: "2010...",
          child: CustomTextField(
            controller: getController("${index}_whatsapp_number", block['whatsapp_number'] ?? ''),
            focusNode: getFocusNode("${index}_whatsapp_number"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'whatsapp_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        DynamicListEditor(
          title: context.translate('product_list'),
          addLabel: context.translate('add_product'),
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: (i) {
            final List items = block['items'] ?? [];
            return (items[i]['name'] ?? '').isEmpty ? 'منتج جديد' : items[i]['name'];
          },
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final List items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onAdd: () async {
            final selectedData = await ImagePickerModal.show(context);
            if (selectedData == null) return;

            final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';
            
            // Add a temporary upload:// item so the UI shows the loading spinner!
            final List freshItems = List.from(block['items'] ?? []);
            final int tIndex = freshItems.length;
            freshItems.add({
              'id': 'bento_${DateTime.now().millisecondsSinceEpoch}',
              'name': 'منتج جديد',
              'price': '',
              'image_url': uploadId,
            });
            cubit.updateBlockProperty(index, 'items', freshItems);

            sl<UploadManagerCubit>().upload(
              uploadId: uploadId,
              data: selectedData,
              onSuccess: (finalUrl) {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems2 = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems2.length) {
                    freshItems2[tIndex] = Map<String, dynamic>.from(freshItems2[tIndex])..['image_url'] = finalUrl;
                    cubit.updateBlockProperty(index, 'items', freshItems2);
                  }
                }
              },
              onCancel: () {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems2 = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems2.length) {
                    freshItems2.removeAt(tIndex);
                    cubit.updateBlockProperty(index, 'items', freshItems2);
                  }
                }
              },
            );
          },
          onDelete: (i) => cubit.deleteProductItem(index, i),
          itemBuilder: (context, pIndex, onDelete) {
            final items = (block['items'] as List?) ?? [];
            final item = items[pIndex] as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            );
          },
        ),
      ],
    );
  }
}
