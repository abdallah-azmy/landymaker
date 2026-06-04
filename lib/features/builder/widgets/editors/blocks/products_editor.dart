import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';

class ProductsEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const ProductsEditor({
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
        SwitchListTile(
          value: block['show_category_filter'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'show_category_filter', val),
          title: Text(
            "إظهار أزرار تصفية الفئات",
            style: AppTypography.bodyMedium,
          ),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.secondary,
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "إدارة الفئات (Manage Categories)",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: getController("new_category", ""),
                      hintText: "اسم الفئة الجديدة...",
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      final val = getController("new_category", "").text.trim();
                      if (val.isNotEmpty) {
                        final List<String> cats = (block['categories'] as List?)?.cast<String>() ?? [];
                        if (!cats.contains(val)) {
                          cubit.updateBlockProperty(
                            index,
                            'categories',
                            [...cats, val],
                          );
                        }
                        getController("new_category", "").clear();
                      }
                    },
                    icon: const Icon(Icons.add_circle),
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ((block['categories'] as List?)?.cast<String>() ?? []).map((cat) {
                  return Chip(
                    label: Text(cat),
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
        const SizedBox(height: 16),
        FormGroup(
          label: "شكل العرض (Layout Style)",
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (block['layout_style'] == 'grid' || block['layout_style'] == null)
                    ? 'grid_2'
                    : block['layout_style'],
                dropdownColor: AppColors.cardBg,
                isExpanded: true,
                style: AppTypography.bodyMedium,
                items: const [
                  DropdownMenuItem(value: 'grid_2', child: Text("شبكة (عمودين)")),
                  DropdownMenuItem(value: 'grid_3', child: Text("شبكة (٣ أعمدة)")),
                  DropdownMenuItem(value: 'list', child: Text("قائمة (List)")),
                  DropdownMenuItem(value: 'list_large', child: Text("قائمة (صورة كبيرة)")),
                ],
                onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "قائمة المنتجات (Product List)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => cubit.addProductItem(index),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
              label: const Text("أضف منتج"),
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
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "المنتج #${pIndex + 1}",
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.secondary, size: 20),
                          onPressed: () {
                            final state = cubit.state;
                            if (state is BuilderLoaded) {
                              _showProductQrShare(context, item, state.subdomain);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                          onPressed: () => cubit.deleteProductItem(index, pIndex),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "اسم المنتج",
                  controller: getController("${index}_product_${pIndex}_name", item['name'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_name"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'name', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "السعر",
                  controller: getController("${index}_product_${pIndex}_price", item['price'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_price"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'price', val),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ((block['categories'] as List?)?.cast<String>() ?? []).map((cat) {
                    final bool isSelected = (item['category'] ?? '') == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          cubit.updateProductItem(index, pIndex, 'category', cat);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "وصف المنتج",
                  controller: getController("${index}_product_${pIndex}_description", item['description'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_description"),
                  maxLines: 2,
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'description', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "رابط الصورة",
                  controller: getController("${index}_product_${pIndex}_image_url", item['image_url'] ?? ''),
                  focusNode: getFocusNode("${index}_product_${pIndex}_image_url"),
                  onChanged: (val) => cubit.updateProductItem(index, pIndex, 'image_url', val),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: "ابحث في الصور (Stock Images)",
                  icon: Icons.search_rounded,
                  isSecondary: true,
                  onPressed: () => pickImage(
                    cubit,
                    index,
                    itemIndex: pIndex,
                    itemKey: 'image_url',
                  ),
                  width: double.infinity,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }


  void _showProductQrShare(
      BuildContext context,
      Map<String, dynamic> product,
      String subdomain,
    ) {
      final String baseUrl = Uri.base.origin;
      final String productUrl = "$baseUrl/$subdomain?product=${product['id']}";
  
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("مشاركة المنتج", style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PrettyQrView.data(
                  data: productUrl,
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(color: AppColors.background),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "سيقوم هذا الكود بتوجيه العميل مباشرة إلى منتج: ${product['name']}",
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: productUrl));
                  ToastService.showSuccess(
                    context,
                    message: "تم نسخ الرابط بنجاح!",
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text("نسخ الرابط المباشر"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        ),
      );
    }
}
