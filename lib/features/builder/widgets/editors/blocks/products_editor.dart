import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../editor_types.dart';
import '../../modals/image_picker_modal.dart';
import '../../../controllers/upload_manager_cubit.dart';
import '../../../../../injection_container.dart';
import '../common/dynamic_list_editor.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

/// Editor for the products block type.
/// Exposes layout_style, whatsapp_number, mobile_columns, card_style,
/// hover_effect, stagger_animations, show_category_filter, categories,
/// and the product items list editor.
class ProductsEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const ProductsEditor({
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
          label: context.translate('layout_style'),
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_style'] as String?) ?? 'grid_2',
            items: const [
              DropdownMenuItem(value: 'grid_2', child: Text('2 أعمدة')),
              DropdownMenuItem(value: 'grid_3', child: Text('3 أعمدة')),
              DropdownMenuItem(value: 'list', child: Text('قائمة')),
              DropdownMenuItem(value: 'carousel', child: Text('شريط متحرك')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('whatsapp_orders'),
          helperText: "2010...",
          child: CustomTextField(
            controller: getController("${index}_whatsapp_number", block['whatsapp_number'] ?? ''),
            focusNode: getFocusNode("${index}_whatsapp_number"),
            maxLength: 20,
            onChanged: (val) => cubit.updateBlockProperty(index, 'whatsapp_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'أعمدة الجوال',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1')),
              ButtonSegment(value: 2, label: Text('2')),
            ],
            selected: {block['mobile_columns'] ?? 2},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'mobile_columns', val.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('card_style'),
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'classic', label: Text(context.translate('classic'))),
              ButtonSegment(value: 'modern', label: Text(context.translate('modern'))),
              ButtonSegment(value: 'minimal', label: Text(context.translate('minimal'))),
            ],
            selected: {block['card_style'] ?? 'classic'},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'card_style', val.first),
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
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
            style: ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: block['stagger_animations'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'stagger_animations', val),
          title: Text(context.translate('stagger_animations'), style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: block['show_category_filter'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'show_category_filter', val),
          title: Text(context.translate('show_filters'), style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('categories'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: getController("new_category", ""),
                      hintText: context.translate('add_category'),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final val = getController("new_category", "").text.trim();
                      if (val.isNotEmpty) {
                        final List<String> cats = (block['categories'] as List?)?.cast<String>() ?? [];
                        if (!cats.contains(val)) {
                          cubit.updateBlockProperty(index, 'categories', [...cats, val]);
                        }
                        getController("new_category", "").clear();
                      }
                    },
                    icon: Icon(Icons.add_circle),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ((block['categories'] as List?)?.cast<String>() ?? []).map((cat) {
                  return Chip(
                    label: Text(cat, style: TextStyle(fontSize: 12)),
                    onDeleted: () {
                      final List<String> cats = (block['categories'] as List?)?.cast<String>() ?? [];
                      cats.remove(cat);
                      cubit.updateBlockProperty(index, 'categories', cats);
                    },
                  );
                }).toList(),
              ),
            ],
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
              'id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
              'name': 'منتج جديد',
              'price': '',
              'purchase_url': '',
              'category': '',
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
          actionsBuilder: (i) {
            final items = (block['items'] as List?) ?? [];
            final item = items[i] as Map<String, dynamic>;
            return [
              IconButton(
                icon: Icon(Icons.qr_code_2_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                onPressed: () {
                  final state = cubit.state;
                  if (state is BuilderLoaded) _showProductQrShare(context, item, state.subdomain);
                },
              ),
            ];
          },
          itemBuilder: (context, pIndex, onDelete) {
            final items = (block['items'] as List?) ?? [];
            final item = items[pIndex] as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: context.translate('product_name'),
                  controller: getController("${index}_product_${pIndex}_name", item['name'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_name"),
                  maxLength: 100,
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'name', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('price'),
                  controller: getController("${index}_product_${pIndex}_price", item['price'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_price"),
                  maxLength: 30,
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'price', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('purchase_url'),
                  controller: getController("${index}_product_${pIndex}_purchase_url", item['purchase_url'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_purchase_url"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'purchase_url', val),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ((block['categories'] as List?)?.cast<String>() ?? []).map((cat) {
                    final bool isSelected = (item['category'] ?? '') == cat;
                    return ChoiceChip(
                      label: Text(cat, style: TextStyle(fontSize: 10)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) cubit.updateProductItem(index, pIndex, 'category', cat);
                      },
                    );
                  }).toList(),
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

  void _showProductQrShare(BuildContext context, Map<String, dynamic> product, String subdomain) {
    final String productUrl = "${Uri.base.origin}/$subdomain?product=${product['id']}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(context.translate('share'), style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: PrettyQrView.data(data: productUrl, decoration: PrettyQrDecoration(shape: PrettyQrSmoothSymbol(color: Theme.of(context).colorScheme.surface))),
            ),
            SizedBox(height: 24),
            Text(productUrl, textAlign: TextAlign.center, style: AppTypography.caption),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: productUrl));
                ToastService.showSuccess(context, message: context.translate('copy_link_success'));
              },
              icon: Icon(Icons.copy_rounded, size: 18),
              label: Text(context.translate('copy')),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.translate('close')))],
      ),
    );
  }
}
