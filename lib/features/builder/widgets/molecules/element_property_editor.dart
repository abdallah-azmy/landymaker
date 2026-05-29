import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
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
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type == 'text' ? "تنسيق النص" : "تنسيق الصورة",
            style: AppTypography.h3.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 20),
          if (type == 'text') ..._buildTextControls(loc),
          if (type == 'image') ..._buildImageControls(loc),
        ],
      ),
    );
  }

  List<Widget> _buildTextControls(LocalizationCubit loc) {
    return [
      _buildFontSelector(),
      const SizedBox(height: 16),
      _buildSlider("حجم الخط", 'fontSize', 12, 72),
      const SizedBox(height: 16),
      _buildWeightToggle(),
    ];
  }

  List<Widget> _buildImageControls(LocalizationCubit loc) {
    return [
      _buildSlider("العرض", 'width', 50, 500),
      const SizedBox(height: 16),
      _buildSlider("الارتفاع", 'height', 50, 500),
      const SizedBox(height: 16),
      _buildSlider("انحناء الزوايا", 'borderRadius', 0, 100),
    ];
  }

  Widget _buildFontSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("نوع الخط", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: styleOverrides['fontFamily'] ?? FontRegistry.defaultArabicFont,
            isExpanded: true,
            underline: const SizedBox(),
            items: FontRegistry.fonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val) => onUpdate('fontFamily', val),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, String key, double min, double max) {
    final double value = (styleOverrides[key] ?? min).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("\$label: \${value.toInt()}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.secondary,
          onChanged: (val) => onUpdate(key, val),
        ),
      ],
    );
  }

  Widget _buildWeightToggle() {
    final bool isBold = styleOverrides['fontWeight'] == 'bold';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("خط عريض", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Switch(
          value: isBold,
          onChanged: (val) => onUpdate('fontWeight', val ? 'bold' : 'normal'),
          activeColor: AppColors.secondary,
        ),
      ],
    );
  }
}
