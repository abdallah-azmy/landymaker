import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/draggable_modal_sheet.dart';

const List<_WidgetTypeOption> _widgetTypes = [
  _WidgetTypeOption('heading', Icons.title_rounded, 'Heading'),
  _WidgetTypeOption('paragraph', Icons.text_fields_rounded, 'Paragraph'),
  _WidgetTypeOption('image', Icons.image_rounded, 'Image'),
  _WidgetTypeOption('button', Icons.smart_button_rounded, 'Button'),
  _WidgetTypeOption('icon', Icons.emoji_symbols_rounded, 'Icon'),
  _WidgetTypeOption('video', Icons.videocam_rounded, 'Video'),
];

class _WidgetTypeOption {
  final String type;
  final IconData icon;
  final String label;
  const _WidgetTypeOption(this.type, this.icon, this.label);
}

class SlotWidgetSelector extends StatelessWidget {
  final String? currentType;

  const SlotWidgetSelector({super.key, this.currentType});

  static Future<String?> show(BuildContext context, {String? currentType}) {
    return DraggableModalSheet.show<String>(
      context: context,
      title: 'اختر نوع العنصر',
      initialChildSize: 0.5,
      minChildSize: 0.35,
      child: SlotWidgetSelector(currentType: currentType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: _widgetTypes.map((wt) {
                final isSelected = wt.type == currentType;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, wt.type),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(wt.icon, color: isSelected ? AppColors.secondary : AppColors.textSecondary, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            wt.label,
                            style: AppTypography.bodySmall.copyWith(
                              color: isSelected ? AppColors.secondary : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
