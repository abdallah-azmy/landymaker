import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'slot_widget_selector.dart';

const Map<String, IconData> _slotIcons = {
  'image': Icons.image_rounded,
  'heading': Icons.title_rounded,
  'paragraph': Icons.text_fields_rounded,
  'button': Icons.smart_button_rounded,
  'icon': Icons.emoji_symbols_rounded,
  'video': Icons.videocam_rounded,
};

class LayoutSlotGrid extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final Map<String, String> selections;
  final void Function(String slotKey, String widgetType) onSlotChanged;

  const LayoutSlotGrid({
    required this.slots,
    required this.selections,
    required this.onSlotChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          'عناصر التخطيط',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'اضغط على عنصر لتغيير نوعه',
          style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: 12),
        if (slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'لا توجد عناصر قابلة للتخصيص',
                style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          )
        else
          ...slots.map((slot) => _SlotCard(
                slotKey: slot['slotKey'] as String,
                label: slot['label'] as String,
                currentType: selections[slot['slotKey']] ?? (slot['defaultType'] as String? ?? 'heading'),
                allowedTypes: (slot['allowedTypes'] as List? ?? []).cast<String>(),
                onTap: () async {
                  final result = await SlotWidgetSelector.show(
                    context,
                    currentType: selections[slot['slotKey']] ?? (slot['defaultType'] as String? ?? 'heading'),
                  );
                  if (result != null) {
                    onSlotChanged(slot['slotKey'] as String, result);
                  }
                },
              )),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  final String slotKey;
  final String label;
  final String currentType;
  final List<String> allowedTypes;
  final VoidCallback onTap;

  const _SlotCard({
    required this.slotKey,
    required this.label,
    required this.currentType,
    required this.allowedTypes,
    required this.onTap,
  });

  IconData get _icon => _slotIcons[currentType] ?? Icons.widgets_rounded;

  String get _typeName {
    switch (currentType) {
      case 'heading':
        return 'عنوان';
      case 'paragraph':
        return 'نص';
      case 'image':
        return 'صورة';
      case 'button':
        return 'زر';
      case 'icon':
        return 'أيقونة';
      case 'video':
        return 'فيديو';
      default:
        return currentType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _typeName,
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
