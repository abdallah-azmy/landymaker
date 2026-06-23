import 'package:flutter/material.dart';

/// Typography scale for LandyMaker.
///
/// **Important**: These styles intentionally omit a hardcoded [Color]
/// so that callers apply the appropriate foreground colour from the
/// active [ColorScheme] (e.g. via `Theme.of(context).colorScheme.onSurface`).
/// This guarantees correct contrast in both light and dark mode without
/// duplicated theme logic.
class AppTypography {
  // Font Family Fallbacks for Arabic & English clean rendering
  static const List<String> fontFallbacks = [
    'Cairo',
    'Outfit',
    'Inter',
    'system-ui',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif'
  ];

  static TextStyle get h1 => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 38,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get button => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  static TextStyle get caption => TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );
}
