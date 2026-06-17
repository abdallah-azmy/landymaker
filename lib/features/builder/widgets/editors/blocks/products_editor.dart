import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

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
          label: context.translate('title'),
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
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
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.translate('product_list'), style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => cubit.addProductItem(index),
              icon: Icon(Icons.add_shopping_cart_rounded, size: 16),
              label: Text(context.translate('add_product')),
            ),
          ],
        ),
        SizedBox(height: 10),
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.qr_code_2_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                          onPressed: () {
                            final state = cubit.state;
                            if (state is BuilderLoaded) _showProductQrShare(context, item, state.subdomain);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                          onPressed: () => cubit.deleteProductItem(index, pIndex),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: context.translate('product_name'),
                  controller: getController("${index}_product_${pIndex}_name", item['name'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_name"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'name', val),
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('price'),
                  controller: getController("${index}_product_${pIndex}_price", item['price'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_price"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'price', val),
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('purchase_url'),
                  controller: getController("${index}_product_${pIndex}_purchase_url", item['purchase_url'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_purchase_url"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'purchase_url', val),
                  keyboardType: TextInputType.url,
                ),
                SizedBox(height: 12),
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
                SizedBox(height: 12),
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
