import '../models/landing_page_theme.dart';

class PaletteRegistry {
  /// Open-Closed Principle: To add a new palette, just add to this list.
  static final List<LandingPageTheme> palettes = LandingPageTheme.palettes;

  static LandingPageTheme getByName(String name) {
    return palettes.firstWhere(
      (p) => p.name == name,
      orElse: () => palettes.last,
    );
  }
}
