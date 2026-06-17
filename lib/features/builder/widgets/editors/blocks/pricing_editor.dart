import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/utils/localized_text_parser.dart';
import '../common/dynamic_list_editor.dart';

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
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: (block['layout_style'] as String?) ?? 'cards',
          decoration: const InputDecoration(labelText: 'نوع التخطيط'),
          items: const [
            DropdownMenuItem(value: 'cards', child: Text('بطاقات')),
            DropdownMenuItem(value: 'table', child: Text('جدول')),
          ],
          onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
        ),
        SizedBox(height: 16),
        if (isV2) ...[
          SwitchListTile(
            title: const Text("تفعيل نظام الدفع المتعدد (شهري/سنوي)"),
            value: block['has_toggle'] == true,
            onChanged: (val) => cubit.updateBlockProperty(index, 'has_toggle', val),
            contentPadding: EdgeInsets.zero,
          ),
          Divider(),
        ],
        DynamicListEditor(
          title: "خطط الأسعار (Pricing Plans)",
          addLabel: "أضف خطة",
          itemCount: ((block['items'] as List?) ?? []).length,
          itemTitleBuilder: (pIndex) => "الخطة #${pIndex + 1}",
          onAdd: () {
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
          onDelete: (pIndex) {
            final items = List.from(block['items']);
            items.removeAt(pIndex);
            cubit.updateBlockProperty(index, 'items', items);
          },
          itemBuilder: (context, pIndex, onDelete) {
            final item = ((block['items'] as List?) ?? [])[pIndex] as Map<String, dynamic>;
            final prices = (item['prices'] as Map?) ?? {};
            return Container(
              padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                  hintText: "اسم الخطة",
                  controller: getController("${index}_pricing_${pIndex}_name", LocalizedTextParser.extractText(item['name'], 'ar')),
                  focusNode: getFocusNode("${index}_pricing_${pIndex}_name"),
                  onChanged: (val) {
                    _updateItemProp(pIndex, 'name', val);
                  },
                ),
                SizedBox(height: 12),
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
                      SizedBox(width: 8),
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
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: ['auto', 'manual', 'hidden'].contains(item['discount_mode']) ? item['discount_mode'] : 'hidden',
                    decoration: const InputDecoration(labelText: "وضع الخصم"),
                    items: const [
                      DropdownMenuItem(value: 'hidden', child: Text('مخفي')),
                      DropdownMenuItem(value: 'auto', child: Text('حساب تلقائي (رياضي)')),
                      DropdownMenuItem(value: 'manual', child: Text('نص ترويجي مخصص')),
                    ],
                    onChanged: (val) => _updateItemProp(pIndex, 'discount_mode', val),
                  ),
                  if (item['discount_mode'] == 'manual') ...[
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: "مثال: الأكثر توفيراً!",
                      controller: getController("${index}_pricing_${pIndex}_mdisc", LocalizedTextParser.extractText(item['manual_discount_text'], 'ar')),
                      focusNode: getFocusNode("${index}_pricing_${pIndex}_mdisc"),
                      onChanged: (val) => _updateItemProp(pIndex, 'manual_discount_text', val),
                    ),
                  ],
                ],
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text("خطة مميزة؟", style: AppTypography.caption),
                  value: item['is_popular'] ?? false,
                  onChanged: (val) => _updateItemProp(pIndex, 'is_popular', val),
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
             ),
            );
          },
        ),
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
