import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/utils/localized_text_parser.dart';

class PricingEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;

  const PricingEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isV2 = (block['schema_version'] ?? 1) == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: "العنوان الرئيسي",
          controller: getController("${index}_title", LocalizedTextParser.extractText(block['title'], 'ar')),
          focusNode: getFocusNode("${index}_title"),
          onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
        ),
        const SizedBox(height: 16),
        if (isV2) ...[
          SwitchListTile(
            title: const Text("تفعيل نظام الدفع المتعدد (شهري/سنوي)"),
            value: block['has_toggle'] == true,
            onChanged: (val) => cubit.updateBlockProperty(index, 'has_toggle', val),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "خطط الأسعار (Pricing Plans)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                final items = List.from(block['items'] ?? []);
                items.add({
                  'name': 'خطة جديدة',
                  'prices': {'monthly': 0, 'yearly': 0},
                  'currency': 'ج.م',
                  'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
                  'discount_mode': 'hidden',
                  'features': ['ميزة 1'],
                  'button_text': 'اشترك الآن',
                  'is_popular': false,
                });
                cubit.updateBlockProperty(index, 'items', items);
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text("أضف خطة"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate((block['items'] as List).length, (pIndex) {
          final item = (block['items'] as List)[pIndex] as Map<String, dynamic>;
          final prices = (item['prices'] as Map?) ?? {};
          
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
                      "الخطة #${pIndex + 1}",
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                      onPressed: () {
                        final items = List.from(block['items']);
                        items.removeAt(pIndex);
                        cubit.updateBlockProperty(index, 'items', items);
                      },
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "اسم الخطة",
                  controller: getController("${index}_pricing_${pIndex}_name", LocalizedTextParser.extractText(item['name'], 'ar')),
                  focusNode: getFocusNode("${index}_pricing_${pIndex}_name"),
                  onChanged: (val) {
                    _updateItemProp(pIndex, 'name', val);
                  },
                ),
                const SizedBox(height: 12),
                if (!isV2) ...[
                  CustomTextField(
                    hintText: "السعر",
                    controller: getController("${index}_pricing_${pIndex}_price", item['price'] ?? ''),
                    focusNode: getFocusNode("${index}_pricing_${pIndex}_price"),
                    onChanged: (val) => _updateItemProp(pIndex, 'price', val),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: "السعر الشهري",
                          controller: getController("${index}_pricing_${pIndex}_mprice", prices['monthly']?.toString() ?? ''),
                          focusNode: getFocusNode("${index}_pricing_${pIndex}_mprice"),
                          onChanged: (val) {
                            final p = Map<String, dynamic>.from(prices);
                            p['monthly'] = double.tryParse(val);
                            _updateItemProp(pIndex, 'prices', p);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          hintText: "السعر السنوي",
                          controller: getController("${index}_pricing_${pIndex}_yprice", prices['yearly']?.toString() ?? ''),
                          focusNode: getFocusNode("${index}_pricing_${pIndex}_yprice"),
                          onChanged: (val) {
                            final p = Map<String, dynamic>.from(prices);
                            p['yearly'] = double.tryParse(val);
                            _updateItemProp(pIndex, 'prices', p);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: ['auto', 'manual', 'hidden'].contains(item['discount_mode']) ? item['discount_mode'] : 'hidden',
                    decoration: const InputDecoration(labelText: "وضع الخصم"),
                    items: const [
                      DropdownMenuItem(value: 'hidden', child: Text('مخفي')),
                      DropdownMenuItem(value: 'auto', child: Text('حساب تلقائي (رياضي)')),
                      DropdownMenuItem(value: 'manual', child: Text('نص ترويجي مخصص')),
                    ],
                    onChanged: (val) => _updateItemProp(pIndex, 'discount_mode', val),
                  ),
                  if (item['discount_mode'] == 'manual') ...[
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "مثال: الأكثر توفيراً!",
                      controller: getController("${index}_pricing_${pIndex}_mdisc", LocalizedTextParser.extractText(item['manual_discount_text'], 'ar')),
                      focusNode: getFocusNode("${index}_pricing_${pIndex}_mdisc"),
                      onChanged: (val) => _updateItemProp(pIndex, 'manual_discount_text', val),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text("خطة مميزة؟", style: AppTypography.caption),
                  value: item['is_popular'] ?? false,
                  onChanged: (val) => _updateItemProp(pIndex, 'is_popular', val),
                  activeThumbColor: AppColors.secondary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _updateItemProp(int itemIndex, String key, dynamic value) {
    final items = List.from(block['items']);
    final item = Map<String, dynamic>.from(items[itemIndex]);
    item[key] = value;
    items[itemIndex] = item;
    cubit.updateBlockProperty(index, 'items', items);
  }
}
