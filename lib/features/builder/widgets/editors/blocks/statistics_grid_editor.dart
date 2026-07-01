import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../../../../core/localization/app_localizations.dart';

class StatisticsGridEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final TextEditingController Function(String, String) getController;
  final FocusNode Function(String) getFocusNode;

  const StatisticsGridEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final List items = List.from(block['items'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: context.translate('subtitle'),
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 24),
        FormGroup(
          label: 'نوع التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_style'] as String?) ?? 'horizontal',
            items: const [
              DropdownMenuItem(value: 'horizontal', child: Text('أفقي (بدون أيقونات)')),
              DropdownMenuItem(value: 'withIcons', child: Text('مع أيقونات')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
          ),
        ),
        SizedBox(height: 24),
        Text(context.translate('statistics'), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildIconPicker(context, i, item['icon'], (icon) {
                        items[i]['icon'] = icon;
                        cubit.updateBlockProperty(index, 'items', items);
                      }),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        items.removeAt(i);
                        cubit.updateBlockProperty(index, 'items', items);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('value_hint'), // e.g. 500+
                  controller: getController("${index}_stat_${i}_val", item['value'] ?? ''),
                  focusNode: getFocusNode("${index}_stat_${i}_val"),
                  onChanged: (val) {
                    items[i]['value'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
                SizedBox(height: 8),
                CustomTextField(
                  hintText: context.translate('label_hint'), // e.g. Happy Customers
                  controller: getController("${index}_stat_${i}_label", item['label'] ?? ''),
                  focusNode: getFocusNode("${index}_stat_${i}_label"),
                  onChanged: (val) {
                    items[i]['label'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            items.add({'value': '0', 'label': context.translate('new_stat'), 'icon': 'star'});
            cubit.updateBlockProperty(index, 'items', items);
          },
          icon: Icon(Icons.add),
          label: Text(context.translate('add_statistic')),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker(BuildContext context, int index, String? current, Function(String) onSelect) {
    final icons = ['star', 'people', 'check', 'trending', 'business', 'thumb_up', 'public', 'speed', 'favorite'];
    return DropdownButton<String>(
      value: icons.contains(current) ? current : icons.first,
      isExpanded: true,
      items: icons.map((icon) => DropdownMenuItem(
        value: icon,
        child: Row(
          children: [
            Icon(_getIconData(icon), size: 18),
            SizedBox(width: 12),
            Text(icon),
          ],
        ),
      )).toList(),
      onChanged: (val) => onSelect(val!),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'people': return Icons.people_rounded;
      case 'star': return Icons.star_rounded;
      case 'check': return Icons.check_circle_rounded;
      case 'trending': return Icons.trending_up_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'thumb_up': return Icons.thumb_up_rounded;
      case 'public': return Icons.public_rounded;
      case 'speed': return Icons.speed_rounded;
      case 'favorite': return Icons.favorite_rounded;
      default: return Icons.bar_chart_rounded;
    }
  }
}
