import 'package:uuid/uuid.dart';
import '../../../core/utils/localized_text_parser.dart';
import '../models/pricing_models.dart';

class PricingParser {
  static PricingBlockModel parse(Map<String, dynamic> block, String lang) {
    final int schemaVersion = block['schema_version'] ?? 1;

    final title = LocalizedTextParser.extractText(block['title'], lang);
    final subtitle = LocalizedTextParser.extractText(block['subtitle'], lang);
    final hasToggle = block['has_toggle'] == true;

    final toggleLabelsMap = (block['toggle_labels'] as Map?) ?? {};
    final Map<String, String> toggleLabels = {};
    toggleLabelsMap.forEach((key, value) {
      toggleLabels[key.toString()] = LocalizedTextParser.extractText(value, lang);
    });

    final itemsRaw = (block['items'] as List?) ?? [];
    final List<PricingItemModel> items = [];

    for (var itemRaw in itemsRaw) {
      if (itemRaw is! Map) continue;

      final name = LocalizedTextParser.extractText(itemRaw['name'], lang);
      final legacyPriceString = LocalizedTextParser.extractText(itemRaw['price'], lang);
      
      // Use deterministic UUID v5 for legacy plans missing an ID so analytics events stay stable
      final planId = itemRaw['plan_id']?.toString() ?? const Uuid().v5(Namespace.oid.value, 'legacy_plan_${name}_$legacyPriceString');
      
      final currency = LocalizedTextParser.extractText(itemRaw['currency'], lang);
      
      final Map<String, double?> prices = {};
      if (itemRaw['prices'] is Map) {
        (itemRaw['prices'] as Map).forEach((k, v) {
          if (v == null) {
            prices[k.toString()] = null;
          } else {
            prices[k.toString()] = double.tryParse(v.toString());
          }
        });
      }

      final Map<String, String> billingIds = {};
      if (itemRaw['billing_ids'] is Map) {
        (itemRaw['billing_ids'] as Map).forEach((k, v) {
          billingIds[k.toString()] = v?.toString() ?? '';
        });
      }

      final Map<String, String> periods = {};
      if (itemRaw['periods'] is Map) {
        (itemRaw['periods'] as Map).forEach((k, v) {
          periods[k.toString()] = LocalizedTextParser.extractText(v, lang);
        });
      }

      final discountMode = itemRaw['discount_mode']?.toString() ?? 'hidden';
      final manualDiscountText = LocalizedTextParser.extractText(itemRaw['manual_discount_text'], lang);
      
      final featuresRaw = (itemRaw['features'] as List?) ?? [];
      final List<String> features = featuresRaw.map((e) => LocalizedTextParser.extractText(e, lang)).toList();
      
      final buttonText = LocalizedTextParser.extractText(itemRaw['button_text'], lang);
      final buttonActionType = itemRaw['button_action_type']?.toString() ?? 'link';
      final buttonActionValue = itemRaw['button_action_value']?.toString() ?? '';
      
      final isPopular = itemRaw['is_popular'] == true;

      items.add(PricingItemModel(
        planId: planId,
        name: name,
        prices: prices,
        billingIds: billingIds,
        currency: currency,
        periods: periods,
        discountMode: discountMode,
        manualDiscountText: manualDiscountText.isEmpty ? null : manualDiscountText,
        features: features,
        buttonText: buttonText,
        buttonActionType: buttonActionType,
        buttonActionValue: buttonActionValue,
        isPopular: isPopular,
        legacyPriceString: legacyPriceString.isEmpty ? null : legacyPriceString,
      ));
    }

    return PricingBlockModel(
      schemaVersion: schemaVersion,
      title: title,
      subtitle: subtitle,
      hasToggle: hasToggle,
      toggleLabels: toggleLabels,
      items: items,
    );
  }
}
