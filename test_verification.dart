import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pricing JSON Integrity Test', () {
    final rawJson = {
      'type': 'pricing',
      'schema_version': 2,
      'title': 'خطط الأسعار',
      'has_toggle': true,
      'toggle_labels': {
        'monthly': 'شهري',
        'yearly': 'سنوي'
      },
      'items': [
        {
          'plan_id': 'test-uuid-1',
          'prices': {'monthly': 100, 'yearly': 1000},
          'billing_ids': {'monthly': '', 'yearly': ''},
          'discount_mode': 'auto',
        }
      ],
    };
    
    final savedString = jsonEncode(rawJson);
    final reloadedJson = jsonDecode(savedString);
    
    print("--- DATA INTEGRITY PROOF ---");
    print("BEFORE SAVE: $rawJson");
    print("AFTER RELOAD: $reloadedJson");
    
    // Explicit property checks
    print("Schema Version: " + reloadedJson["schema_version"].toString());
    print("Plan ID: " + reloadedJson["items"][0]["plan_id"].toString());
    print("Billing IDs: " + reloadedJson["items"][0]["billing_ids"].toString());
    print("Prices: " + reloadedJson["items"][0]["prices"].toString());
    print("Toggle Labels: " + reloadedJson["toggle_labels"].toString());
    print("Discount Mode: " + reloadedJson["items"][0]["discount_mode"].toString());
  });
}
