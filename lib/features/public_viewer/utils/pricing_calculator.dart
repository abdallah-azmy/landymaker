import '../models/pricing_models.dart';

class PricingCalculator {
  static String formatPriceDisplay(
    int schemaVersion,
    PricingItemModel item,
    String activePeriodKey,
    String lang,
  ) {
    if (schemaVersion <= 1) {
      return item.legacyPriceString ?? '';
    }

    // V2 Logic
    final value = item.prices[activePeriodKey];
    if (value == 0) {
      return lang == 'ar' ? 'مجانًا' : 'Free';
    }
    if (value == null) {
      return lang == 'ar' ? 'تواصل معنا' : 'Contact Sales';
    }

    // Format number nicely (e.g. 1000.0 -> 1000)
    final formattedValue = value.truncateToDouble() == value 
        ? value.toInt().toString() 
        : value.toString();

    final currency = item.currency;
    final period = item.periods[activePeriodKey] ?? '';

    return '$formattedValue $currency $period'.trim();
  }

  static String? resolveDiscountBadge(
    PricingItemModel item,
    String activePeriodKey,
    String lang,
  ) {
    if (item.discountMode == 'hidden') return null;
    
    if (item.discountMode == 'manual') {
      return item.manualDiscountText;
    }

    if (item.discountMode == 'auto') {
      // Auto calculation only makes sense if we have both monthly and yearly defined, 
      // and we are actively looking at yearly.
      if (activePeriodKey != 'yearly') return null;

      final monthly = item.prices['monthly'];
      final yearly = item.prices['yearly'];

      if (monthly == null || yearly == null || monthly <= 0) return null;

      final yearlyCostWithoutDiscount = monthly * 12;
      final savings = yearlyCostWithoutDiscount - yearly;

      if (savings <= 0) return null; // No savings or invalid configuration

      final percentage = (savings / yearlyCostWithoutDiscount) * 100;
      
      return lang == 'ar' 
          ? 'وفر ${percentage.round()}%' 
          : 'Save ${percentage.round()}%';
    }

    return null;
  }
}
