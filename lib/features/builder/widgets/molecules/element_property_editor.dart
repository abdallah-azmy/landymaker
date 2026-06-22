import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/utils/numeric_parser.dart';
import '../../registries/font_registry.dart';

class ElementPropertyEditor extends StatelessWidget {
  final String type;
  final Map<String, dynamic> styleOverrides;
  final Function(String, dynamic) onUpdate;

  const ElementPropertyEditor({
    super.key,
    required this.type,
    required this.styleOverrides,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocalizationCubit>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type == 'text' ? "تنسيق النص" : "تنسيق الصورة",
            style: AppTypography.h3.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 20),
          if (type == 'text') ..._buildTextControls(context, loc),
          if (type == 'image') ..._buildImageControls(context, loc),
        ],
      ),
    );
  }

  List<Widget> _buildTextControls(BuildContext context, LocalizationCubit loc) {
    return [
      _buildFontSelector(context),
      const SizedBox(height: 16),
      _buildSlider(context, "حجم الخط", 'fontSize', 12, 72),
      const SizedBox(height: 16),
      _buildWeightToggle(context),
    ];
  }

  List<Widget> _buildImageControls(BuildContext context, LocalizationCubit loc) {
    return [
      _buildSlider(context, "العرض", 'width', 50, 500),
      const SizedBox(height: 16),
      _buildSlider(context, "الارتفاع", 'height', 50, 500),
      const SizedBox(height: 16),
      _buildSlider(context, "انحناء الزوايا", 'borderRadius', 0, 100),
    ];
  }

  Widget _buildFontSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "نوع الخط",
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: DropdownButton<String>(
            value:
                styleOverrides['fontFamily'] ?? FontRegistry.defaultArabic,
            isExpanded: true,
            underline: const SizedBox(),
            items: FontRegistry.fonts
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) => onUpdate('fontFamily', val),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(BuildContext context, String label, String key, double min, double max) {
    final double value = NumericParser.parseDouble(styleOverrides[key], min);
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
          activeColor: Theme.of(context).colorScheme.secondary,
          onChanged: (val) => onUpdate(key, val),
        ),
      ],
    );
  }

  Widget _buildWeightToggle(BuildContext context) {
    final bool isBold = styleOverrides['fontWeight'] == 'bold';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "خط عريض",
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Switch(
          value: isBold,
          onChanged: (val) => onUpdate('fontWeight', val ? 'bold' : 'normal'),
          activeThumbColor: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }
}
