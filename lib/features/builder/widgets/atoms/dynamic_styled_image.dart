import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DynamicStyledImage extends StatelessWidget {
  final String imageUrl;
  final Map<String, dynamic> styleOverrides;

  const DynamicStyledImage({
    super.key,
    required this.imageUrl,
    required this.styleOverrides,
  });

  @override
  Widget build(BuildContext context) {
    final double? width = styleOverrides['width'] != null ? (styleOverrides['width'] as num).toDouble() : null;
    final double? height = styleOverrides['height'] != null ? (styleOverrides['height'] as num).toDouble() : null;
    final double borderRadius = (styleOverrides['borderRadius'] ?? 0.0).toDouble();
    final BoxFit fit = _parseBoxFit(styleOverrides['fit']);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width ?? 100,
          height: height ?? 100,
          color: AppColors.border,
          child: const Icon(Icons.broken_image, color: AppColors.textMuted),
        ),
      ),
    );
  }

  BoxFit _parseBoxFit(dynamic value) {
    switch (value?.toString()) {
      case 'contain': return BoxFit.contain;
      case 'fill': return BoxFit.fill;
      case 'fitWidth': return BoxFit.fitWidth;
      default: return BoxFit.cover;
    }
  }
}
