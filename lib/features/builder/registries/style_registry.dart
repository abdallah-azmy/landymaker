// 🔴 DEPRECATED — kept as reference only.
// All variant/style logic was removed in Phase 11 (Remove Shape Variants).
// This file is dead code and no longer imported anywhere.
// Scheduled for deletion once downstream references are confirmed clean.

import 'package:flutter/material.dart';
import '../models/landing_page_theme.dart';

enum StyleCategory {
  professional,
  modern,
  creative,
  minimal,
  luxury,
}

class SectionVariant {
  final int index;
  final String name;
  final String description;

  const SectionVariant({
    required this.index,
    required this.name,
    required this.description,
  });
}

class StyleRegistry {
  static final List<SectionVariant> variants = [
    const SectionVariant(index: 0, name: 'Standard (افتراضي)', description: 'التصميم القياسي المريح للعين.'),
    const SectionVariant(index: 1, name: 'Split (منقسم)', description: 'توزيع المحتوى بشكل متوازن على الجانبين.'),
    const SectionVariant(index: 2, name: 'Centered (متمركز)', description: 'تركيز المحتوى في المنتصف لجذب الانتباه.'),
    const SectionVariant(index: 3, name: 'Glassmorphism (زجاجي)', description: 'تأثير الزجاج الشفاف مع خلفية ضبابية.'),
    const SectionVariant(index: 4, name: 'Neumorphism (نيومورفيزم)', description: 'تصميم ثلاثي الأبعاد يعتمد على الظلال الناعمة.'),
    const SectionVariant(index: 5, name: 'Gradient Flow (تدرج لوني)', description: 'خلفيات متدرجة وحيوية تعطي طابعاً عصرياً.'),
    const SectionVariant(index: 6, name: 'Bordered Accent (إطار محدد)', description: 'استخدام إطارات عريضة وألوان محددة لإبراز المحتوى.'),
    const SectionVariant(index: 7, name: 'High Contrast (تباين عالي)', description: 'ألوان صارخة وواضحة جداً للمحتوى الجريء.'),
    const SectionVariant(index: 8, name: 'Minimalist (تبسيطي)', description: 'إزالة كافة العناصر غير الضرورية والتركيز على النص.'),
    const SectionVariant(index: 9, name: 'Floating 3D (طائر ثلاثي الأبعاد)', description: 'عناصر تبدو وكأنها تطفو فوق الصفحة مع ظلال عميقة.'),
  ];

  static Map<StyleCategory, LandingPageTheme> get categoryThemes => {
    StyleCategory.professional: const LandingPageTheme(
      name: 'Professional Blue',
      primary: Color(0xFF1E3A8A),
      secondary: Color(0xFF3B82F6),
      buttonTextColor: Colors.white,
      background: Color(0xFFF8FAFC),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF475569),
      defaultFont: 'Almarai',
    ),
    StyleCategory.modern: const LandingPageTheme(
      name: 'Modern Cyan',
      primary: Color(0xFF0891B2),
      secondary: Color(0xFF22D3EE),
      buttonTextColor: Color(0xFF0F172A),
      background: Color(0xFF0F172A),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      defaultFont: 'Cairo',
    ),
    StyleCategory.creative: const LandingPageTheme(
      name: 'Creative Violet',
      primary: Color(0xFF7C3AED),
      secondary: Color(0xFFC084FC),
      buttonTextColor: Color(0xFF431407),
      background: Color(0xFFFFF7ED),
      textPrimary: Color(0xFF431407),
      textSecondary: Color(0xFF9A3412),
      defaultFont: 'Lalezar',
    ),
    StyleCategory.minimal: const LandingPageTheme(
      name: 'Minimal Slate',
      primary: Color(0xFF334155),
      secondary: Color(0xFF64748B),
      buttonTextColor: Colors.white,
      background: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF64748B),
      defaultFont: 'Tajawal',
    ),
    StyleCategory.luxury: const LandingPageTheme(
      name: 'Luxury Gold',
      primary: Color(0xFF0F172A),
      secondary: Color(0xFFD4AF37),
      buttonTextColor: Colors.black,
      background: Color(0xFF020617),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFFD1D5DB),
      defaultFont: 'Amiri',
    ),
  };

  static List<Map<String, dynamic>> getCategoryPalettes(StyleCategory category) {
    final theme = categoryThemes[category]!;
    return List.generate(10, (i) {
      double factor = i * 0.1;
      return {
        'primary': _shiftColor(theme.primary, factor),
        'secondary': _shiftColor(theme.secondary, factor),
        'background': _shiftColor(theme.background, factor * 0.2),
        'name': '${category.name.toUpperCase()} Variant ${i + 1}',
      };
    });
  }

  static Color _shiftColor(Color c, double factor) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness + (factor * 0.1)).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
