import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../../../core/utils/numeric_parser.dart';

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
    final parsedWidth = NumericParser.tryParseDouble(styleOverrides['width']);
    final parsedHeight = NumericParser.tryParseDouble(styleOverrides['height']);
    final double? width = (parsedWidth?.isFinite == true) ? parsedWidth : null;
    final double? height = (parsedHeight?.isFinite == true) ? parsedHeight : null;
    final double borderRadius = NumericParser.parseDouble(styleOverrides['borderRadius'], 0.0);
    final BoxFit fit = _parseBoxFit(styleOverrides['fit']);

    return CustomNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(borderRadius),
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
