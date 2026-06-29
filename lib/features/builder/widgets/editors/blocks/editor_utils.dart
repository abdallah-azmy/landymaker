import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../controllers/builder_cubit.dart';

Widget buildDropdown(
  BuildContext context,
  Map<String, dynamic> block,
  String label,
  String key,
  List<String> options,
  Function(String?) onChanged, {
  String Function(String)? translateItem,
}) {
  dynamic value;
  if (key.contains('.')) {
    final parts = key.split('.');
    value = block[parts[0]]?[parts[1]];
  } else {
    value = block[key];
  }

  final String stringValue = value?.toString() ?? options.first;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: DropdownButton<String>(
          value: options.contains(stringValue) ? stringValue : options.first,
          isExpanded: true,
          underline: SizedBox(),
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(translateItem != null ? translateItem(o) : o),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
      SizedBox(height: 16),
    ],
  );
}

Widget buildSlider(
  BuildContext context,
  String label,
  String key,
  double min,
  double max,
  Function(double) onChanged, {
  double? currentValue,
  Map<String, dynamic>? block,
}) {
  double value;
  if (currentValue != null) {
    value = currentValue;
  } else if (block != null) {
    if (key.contains('.')) {
      final parts = key.split('.');
      value = ((block[parts[0]]?[parts[1]] ?? min) as num).toDouble();
    } else {
      value = ((block[key] ?? min) as num).toDouble();
    }
  } else {
    value = min;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$label: ${value.toInt()}",
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: (v) {
          onChanged(v);
        },
      ),
    ],
  );
}

Widget buildColorPickerItem(
  BuildContext context,
  String label,
  Color color,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color == Colors.transparent ? null : color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: color == Colors.transparent
                ? const Icon(Icons.not_interested_rounded, size: 16, color: Colors.grey)
                : null,
          ),
        ],
      ),
    ),
  );
}

void showBlockColorPicker(
  BuildContext context,
  LandingPageBuilderCubit cubit,
  int index,
  String key,
  Color currentColor,
) {
  final List<Color> colors = [
    Colors.transparent,
    Theme.of(context).colorScheme.primary,
    Theme.of(context).colorScheme.secondary,
    Colors.green,
    Theme.of(context).colorScheme.error,
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.white,
    const Color(0xFF1E293B),
    const Color(0xFFF8FAFC),
    const Color(0xFFFEFAE0),
    const Color(0xFFECFDF5),
    const Color(0xFFEEF2FF),
  ];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("اختر لون خلفية القسم"),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors
            .map(
              (color) => GestureDetector(
                onTap: () {
                  final hex = color == Colors.transparent
                      ? null
                      : '#\${color.toARGB32().toRadixString(16).padLeft(8, \u00270\u0027)}';
                  cubit.updateBlockProperty(index, key, hex);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color == Colors.transparent ? null : color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: color == currentColor ? 3 : 1,
                    ),
                  ),
                  child: color == Colors.transparent
                      ? const Icon(Icons.not_interested_rounded, size: 20, color: Colors.grey)
                      : null,
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

Widget buildColorPreset(
  BuildContext context,
  LandingPageBuilderCubit cubit,
  int index,
  String hex,
  Color color, {
  bool isSelected = false,
}) {
  return InkWell(
    onTap: () {
      cubit.updateBlockProperty(index, 'bg_overlay_color', hex);
    },
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
      ),
    ),
  );
}

Widget buildAdvancedOption({
  required BuildContext context,
  required bool isSelected,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildTabButton(
  BuildContext context,
  int activeTab,
  int index,
  String label,
  IconData icon,
  VoidCallback onTap,
) {
  final isSelected = activeTab == index;
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
