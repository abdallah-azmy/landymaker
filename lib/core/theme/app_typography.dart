import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Font Family Fallbacks for Arabic & English clean rendering
  static const List<String> fontFallbacks = [
    'Cairo',
    'Tajawal',
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

  static TextStyle get h1 => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 38,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: Colors.white,
      );

  static TextStyle get caption => const TextStyle(
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AppColors.textMuted,
      );
}
