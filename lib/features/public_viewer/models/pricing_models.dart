class PricingBlockModel {
  final int schemaVersion;
  final String title;
  final String subtitle;
  final bool hasToggle;
  final Map<String, String> toggleLabels;
  final List<PricingItemModel> items;

  PricingBlockModel({
    required this.schemaVersion,
    required this.title,
    required this.subtitle,
    required this.hasToggle,
    required this.toggleLabels,
    required this.items,
  });
}

class PricingItemModel {
  final String planId;
  final String name;
  final Map<String, double?> prices;
  final Map<String, String> billingIds;
  final String currency;
  final Map<String, String> periods;
  final String discountMode;
  final String? manualDiscountText;
  final List<String> features;
  final String buttonText;
  final String buttonActionType;
  final String buttonActionValue;
  final bool isPopular;

  // Legacy fallback
  final String? legacyPriceString;

  PricingItemModel({
    required this.planId,
    required this.name,
    required this.prices,
    required this.billingIds,
    required this.currency,
    required this.periods,
    required this.discountMode,
    this.manualDiscountText,
    required this.features,
    required this.buttonText,
    required this.buttonActionType,
    required this.buttonActionValue,
    required this.isPopular,
    this.legacyPriceString,
  });
}
