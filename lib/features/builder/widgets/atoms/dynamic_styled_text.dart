import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/numeric_parser.dart';
import '../../models/landing_page_theme.dart';

class DynamicStyledText extends StatelessWidget {
  final String text;
  final Map<String, dynamic> styleOverrides;
  final LandingPageTheme theme;
  final TextAlign? textAlign;

  const DynamicStyledText({
    super.key,
    required this.text,
    required this.styleOverrides,
    required this.theme,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final String fontFamily = styleOverrides['fontFamily'] ?? 'Cairo';
    final double fontSize = NumericParser.parseDouble(styleOverrides['fontSize'], 16.0);
    final Color color = _parseColor(styleOverrides['color']) ?? theme.textPrimary;
    final FontWeight fontWeight = _parseFontWeight(styleOverrides['fontWeight']);

    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }

  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return Color(int.parse('FF${value.replaceAll('#', '')}', radix: 16));
    }
    return null;
  }

  FontWeight _parseFontWeight(dynamic value) {
    switch (value?.toString()) {
      case 'bold': return FontWeight.bold;
      case 'light': return FontWeight.w300;
      default: return FontWeight.normal;
    }
  }
}
