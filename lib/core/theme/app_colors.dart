import 'package:flutter/material.dart';

class AppColors {
  // Theme Backgrounds
  static const Color background = Color(0xFF030712); // Deep Space Black
  static const Color cardBg = Color(0xFF111827);      // Dark Slate (Surface)
  static const Color cardBgHover = Color(0xFF1E293B); // Slate 800 (for hover)
  static const Color border = Color(0xFF1F2937);      // Deep Slate Border
  static const Color borderGlow = Color(0xFF00E5FF);  // Cyan Glow

  // Brand Primaries & Accents
  static const Color primary = Color(0xFF00E5FF);     // Cyan Glow
  static const Color secondary = Color(0xFF1E3A8A);   // Deep Tech Blue
  static const Color accent = Color(0xFF00E5FF);      // Cyan Glow
  static const Color activeGreen = Color(0xFF10B981);  // Emerald Success
  static const Color dangerRed = Color(0xFFEF4444);    // Crimson Error
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Warning

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF3F4F6);   // Ice White
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
