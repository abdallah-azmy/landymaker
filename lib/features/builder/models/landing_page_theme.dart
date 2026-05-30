import 'package:flutter/material.dart';

class LandingPageTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final String name;
  final String? defaultFont; // New: Assign a default font per theme
  final String? category;
  final String? description;

  const LandingPageTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.name,
    this.defaultFont,
    this.category,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'primary': primary.toARGB32(),
    'secondary': secondary.toARGB32(),
    'background': background.toARGB32(),
    'textPrimary': textPrimary.toARGB32(),
    'textSecondary': textSecondary.toARGB32(),
    'name': name,
    'defaultFont': defaultFont,
    'category': category,
    'description': description,
  };

  factory LandingPageTheme.fromJson(Map<String, dynamic> json) {
    return LandingPageTheme(
      primary: Color(json['primary'] ?? 0xFF6366F1),
      secondary: Color(json['secondary'] ?? 0xFF06B6D4),
      background: Color(json['background'] ?? 0xFF0F172A),
      textPrimary: Color(json['textPrimary'] ?? 0xFFF8FAFC),
      textSecondary: Color(json['textSecondary'] ?? 0xFF94A3B8),
      name: json['name'] ?? 'Default Dark',
      defaultFont: json['defaultFont'],
      category: json['category'],
      description: json['description'],
    );
  }

  LandingPageTheme copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    String? name,
    String? category,
    String? description,
  }) {
    return LandingPageTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  static List<LandingPageTheme> get palettes => [
    const LandingPageTheme(
      name: 'Lux-Earth',
      category: 'التجارة / متجر',
      description: 'ألوان ترابية دافئة توحي بالفخامة والثقة.',
      defaultFont: 'Tajawal',
      primary: Color(0xFF5E3023),
      secondary: Color(0xFFA86A24),
      background: Color(0xFFFEFAE0),
      textPrimary: Color(0xFF281510),
      textSecondary: Color(0xFF5E3023),
    ),
    const LandingPageTheme(
      name: 'Fresh Mint',
      category: 'مطاعم / صحة',
      description: 'ألوان هادئة ومنعشة تناسب المحتوى الغذائي والصحي.',
      defaultFont: 'Almarai',
      primary: Color(0xFF064E3B),
      secondary: Color(0xFF10B981),
      background: Color(0xFFECFDF5),
      textPrimary: Color(0xFF064E3B),
      textSecondary: Color(0xFF047857),
    ),
    const LandingPageTheme(
      name: 'Tech Indigo',
      category: 'تكنولوجيا / SaaS',
      description: 'نمط عصري احترافي للشركات التقنية والبرمجيات.',
      defaultFont: 'Roboto',
      primary: Color(0xFF4338CA),
      secondary: Color(0xFF818CF8),
      background: Color(0xFFEEF2FF),
      textPrimary: Color(0xFF312E81),
      textSecondary: Color(0xFF4338CA),
    ),
    const LandingPageTheme(
      name: 'Royal Gold',
      category: 'عقارات / فخامة',
      description: 'مزيج الكحلي والذهبي لإعطاء طابع ملكي وراقي.',
      defaultFont: 'Amiri',
      primary: Color(0xFF0F1E36),
      secondary: Color(0xFFD4AF37),
      background: Color(0xFFF4F6F9),
      textPrimary: Color(0xFF0F1E36),
      textSecondary: Color(0xFF5A6678),
    ),
    const LandingPageTheme(
      name: 'Stadium Neon',
      category: 'ترفيه / رياضة',
      description: 'تباين عالي وألوان صارخة للفعاليات والأنشطة الليلية.',
      defaultFont: 'Oswald',
      primary: Color(0xFF00d084),
      secondary: Color(0xFF3E96F4),
      background: Color(0xFF000000),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB0B0B0),
    ),
    const LandingPageTheme(
      name: 'Butter & Sky',
      category: 'شخصي / إبداعي',
      description: 'ألوان لطيفة ومشرقة تناسب معرض الأعمال الشخصي.',
      defaultFont: 'Montserrat',
      primary: Color(0xFF31393C),
      secondary: Color(0xFFCAE4DB),
      background: Color(0xFFFFF4D6),
      textPrimary: Color(0xFF31393C),
      textSecondary: Color(0xFF5A666B),
    ),
    const LandingPageTheme(
      name: 'Minimal Slate',
      category: 'عام / بسيط',
      description: 'تصميم بسيط ونظيف يركز على المحتوى.',
      defaultFont: 'Open Sans',
      primary: Color(0xFF334155),
      secondary: Color(0xFF64748B),
      background: Color(0xFFF8FAFC),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF475569),
    ),
    const LandingPageTheme(
      name: 'Deep Forest',
      category: 'طبيعة / تعليم',
      description: 'ألوان داكنة مستوحاة من الطبيعة تعطي انطباعاً بالهدوء.',
      defaultFont: 'Almarai',
      primary: Color(0xFF14532D),
      secondary: Color(0xFF22C55E),
      background: Color(0xFFF0FDF4),
      textPrimary: Color(0xFF064E3B),
      textSecondary: Color(0xFF14532D),
    ),
    const LandingPageTheme(
      name: 'Coral Dream',
      category: 'جمال / تجميل',
      description: 'ألوان أنثوية وناعمة لخدمات التجميل والأناقة.',
      defaultFont: 'Playfair Display',
      primary: Color(0xFF991B1B),
      secondary: Color(0xFFF87171),
      background: Color(0xFFFEF2F2),
      textPrimary: Color(0xFF7F1D1D),
      textSecondary: Color(0xFF991B1B),
    ),
    const LandingPageTheme(
      name: 'Midnight Ocean',
      category: 'شركات / رسمي',
      description: 'أزرق داكن رسمي يوحي بالاستقرار والاحترافية.',
      defaultFont: 'Changa',
      primary: Color(0xFF1E3A8A),
      secondary: Color(0xFF3B82F6),
      background: Color(0xFFEFF6FF),
      textPrimary: Color(0xFF1E3A8A),
      textSecondary: Color(0xFF2563EB),
    ),
    const LandingPageTheme(
      name: 'glowingNexusPalette',
      category: 'تكنولوجيا / Premium',
      description: 'تصميم عالي التقنية مع إضاءات نيون سيان وظلال عميقة.',
      defaultFont: 'Cairo',
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF1E3A8A),
      background: Color(0xFF030712),
      textPrimary: Color(0xFFF3F4F6),
      textSecondary: Color(0xFF94A3B8),
    ),
    const LandingPageTheme(
      name: 'Cyber Slate',
      category: 'ألعاب / برمجة',
      description: 'نمط داكن مع إضاءات نيون لمحبي التكنولوجيا الحديثة.',
      defaultFont: 'Oswald',
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFD946EF),
      background: Color(0xFF020617),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
    ),
    const LandingPageTheme(
      name: 'Default Dark',
      category: 'عام',
      description: 'النمط الافتراضي الداكن للمنصة.',
      defaultFont: 'Cairo',
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF06B6D4),
      background: Color(0xFF0F172A),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
    ),
  ];
}
