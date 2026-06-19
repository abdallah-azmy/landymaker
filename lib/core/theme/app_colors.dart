import 'package:flutter/material.dart';

/// Design tokens for LandyMaker.
/// These hold the raw brand palette and semantic colors used across themes.
class AppColors {
  // ── Brand Primaries & Accents ──────────────────────────────────────
  static const Color primary = Color(0xFF00E5FF);
  static const Color secondaryLightTheme = Color(0xFF1E3A8A); // Navy blue for light theme secondary
  static const Color secondaryDarkTheme = Color(0xFF6366F1); // Vibrant indigo for dark theme secondary
  static const Color activeGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);

  // ── Light Surface Palette ──────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // ── Dark Surface Palette ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF030712);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkCardBg = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ── Deprecated Aliases (kept for backward compatibility) ───────────
  /// These names are kept so existing widgets compile without changes.
  /// New code should use `Theme.of(context).colorScheme` instead.
  @Deprecated('Use secondaryLightTheme or Theme.of(context).colorScheme.secondary instead')
  static const Color secondary = secondaryLightTheme;

  @Deprecated('Use secondaryDarkTheme or Theme.of(context).colorScheme.secondary instead')
  static const Color darkSecondary = secondaryDarkTheme;

  @Deprecated('Use Theme.of(context).colorScheme.surface instead')
  static const Color background = darkBackground;

  @Deprecated('Use Theme.of(context).colorScheme.surface instead')
  static const Color cardBg = darkCardBg;

  @Deprecated('Use Theme.of(context).colorScheme.surface.withValues(alpha: 0.8) instead')
  static const Color cardBgHover = Color(0xFF1E293B);

  @Deprecated('Use Theme.of(context).colorScheme.outline instead')
  static const Color border = darkBorder;

  @Deprecated('Use Theme.of(context).colorScheme.primary instead')
  static const Color borderGlow = primary;

  @Deprecated('Use Theme.of(context).colorScheme.onSurface instead')
  static const Color textPrimary = darkTextPrimary;

  @Deprecated('Use Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7) instead')
  static const Color textSecondary = darkTextSecondary;

  @Deprecated('Use Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5) instead')
  static const Color textMuted = darkTextMuted;

  // ── Gradients ──────────────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, secondaryLightTheme],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient accentGradient = LinearGradient(
    colors: [primary, primary.withValues(alpha: .8)],
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
      Color(0x1AFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
