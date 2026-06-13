/// Defines the height sizing mode for section cards.
enum CardLayoutMode {
  /// Cards size themselves naturally based on their internal content (content-driven sizing).
  auto,

  /// Cards within a row are forced to be the same height (comparison-driven sizing).
  equal,
}

extension CardLayoutModeExt on CardLayoutMode {
  static CardLayoutMode fromString(String? value) {
    if (value == null) return CardLayoutMode.auto;
    switch (value.toLowerCase()) {
      case 'equal':
        return CardLayoutMode.equal;
      case 'auto':
      default:
        return CardLayoutMode.auto;
    }
  }
}
