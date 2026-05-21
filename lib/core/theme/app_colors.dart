import 'package:flutter/material.dart';

class AppColors {
  // Theme Backgrounds
  static const Color background = Color(0xFF0F172A); // Deep Slate 900
  static const Color cardBg = Color(0xFF1E293B);      // Slate 800
  static const Color cardBgHover = Color(0xFF2E3B4E); // Slate 750
  static const Color border = Color(0xFF334155);      // Slate 700
  static const Color borderGlow = Color(0xFF475569);  // Slate 600

  // Brand Primaries & Accents
  static const Color primary = Color(0xFF6366F1);     // Electric Indigo
  static const Color secondary = Color(0xFF06B6D4);   // Neon Cyan
  static const Color accent = Color(0xFFEC4899);      // Hot Pink
  static const Color activeGreen = Color(0xFF10B981);  // Emerald Success
  static const Color dangerRed = Color(0xFFEF4444);    // Crimson Error
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Warning

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF8FAFC);   // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B);     // Slate 500

  // Gradients for Hero sections, dashboard stats, and premium glass cards
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF020617)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF), // White with 10% opacity
      Color(0x05FFFFFF), // White with 2% opacity
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
