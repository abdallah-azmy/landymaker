import 'package:flutter/material.dart';

class LandingPageTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final String name;

  const LandingPageTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'primary': primary.value,
        'secondary': secondary.value,
        'background': background.value,
        'textPrimary': textPrimary.value,
        'textSecondary': textSecondary.value,
        'name': name,
      };

  factory LandingPageTheme.fromJson(Map<String, dynamic> json) {
    return LandingPageTheme(
      primary: Color(json['primary'] ?? 0xFF6366F1),
      secondary: Color(json['secondary'] ?? 0xFF06B6D4),
      background: Color(json['background'] ?? 0xFF0F172A),
      textPrimary: Color(json['textPrimary'] ?? 0xFFF8FAFC),
      textSecondary: Color(json['textSecondary'] ?? 0xFF94A3B8),
      name: json['name'] ?? 'Default Dark',
    );
  }

  LandingPageTheme copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    String? name,
  }) {
    return LandingPageTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      name: name ?? this.name,
    );
  }

  static List<LandingPageTheme> get palettes => [
        const LandingPageTheme(
          name: 'Lux-Earth (Store)',
          primary: Color(0xFF5E3023),
          secondary: Color(0xFFA86A24),
          background: Color(0xFFFEFAE0),
          textPrimary: Color(0xFF281510),
          textSecondary: Color(0xFF5E3023),
        ),
        const LandingPageTheme(
          name: 'Vibrant Urgency',
          primary: Color(0xFFE96950),
          secondary: Color(0xFFFACF55),
          background: Color(0xFFFDF6EF),
          textPrimary: Color(0xFF2D1410),
          textSecondary: Color(0xFFE96950),
        ),
        const LandingPageTheme(
          name: 'Butter & Sky (Personal)',
          primary: Color(0xFF31393C),
          secondary: Color(0xFFCAE4DB),
          background: Color(0xFFFFF4D6),
          textPrimary: Color(0xFF31393C),
          textSecondary: Color(0xFF5A666B),
        ),
        const LandingPageTheme(
          name: 'Trusted Innovator',
          primary: Color(0xFF133C55),
          secondary: Color(0xFFF2C14E),
          background: Color(0xFFF7F9FB),
          textPrimary: Color(0xFF133C55),
          textSecondary: Color(0xFF4B6E82),
        ),
        const LandingPageTheme(
          name: 'Stadium Neon (TV Bar)',
          primary: Color(0xFF00d084),
          secondary: Color(0xFF3E96F4),
          background: Color(0xFF000000),
          textPrimary: Color(0xFFFFFFFF),
          textSecondary: Color(0xFFB0B0B0),
        ),
        const LandingPageTheme(
          name: 'Default Dark',
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF06B6D4),
          background: Color(0xFF0F172A),
          textPrimary: Color(0xFFF8FAFC),
          textSecondary: Color(0xFF94A3B8),
        ),
      ];
}
