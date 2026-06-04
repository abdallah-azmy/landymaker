import re
import uuid

filepath = 'lib/features/builder/controllers/builder_cubit.dart'

with open(filepath, 'r') as f:
    content = f.read()

# We need to replace the existing 'pricing' block template
search_pattern = "} else if (type == 'pricing') {"
end_pattern = "} else if (type == 'faq') {"

start_idx = content.find(search_pattern)
end_idx = content.find(end_pattern)

if start_idx != -1 and end_idx != -1:
    pricing_code = """} else if (type == 'pricing') {
      blocks.add({
        'type': 'pricing',
        'schema_version': 2,
        'title': 'خطط الأسعار',
        'subtitle': 'اختر الخطة التي تناسب أعمالك',
        'has_toggle': true,
        'toggle_labels': {
          'monthly': 'شهري',
          'yearly': 'سنوي'
        },
        'items': [
          {
            'plan_id': const Uuid().v4(),
            'name': 'الخطة الأساسية',
            'prices': {'monthly': 100, 'yearly': 1000},
            'billing_ids': {'monthly': '', 'yearly': ''},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'discount_mode': 'auto',
            'features': ['ميزة أساسية 1', 'ميزة أساسية 2'],
            'button_text': 'ابدأ الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'خطة المحترفين',
            'prices': {'monthly': 250, 'yearly': 2500},
            'billing_ids': {'monthly': '', 'yearly': ''},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'discount_mode': 'manual',
            'manual_discount_text': 'الأكثر توفيراً',
            'features': ['كل المزايا الأساسية', 'ميزة احترافية', 'دعم أولوية'],
            'button_text': 'اشترك الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': true
          }
        ],
      });
    """
    
    new_content = content[:start_idx] + pricing_code + content[end_idx:]
    with open(filepath, 'w') as f:
        f.write(new_content)
    print("Updated builder_cubit.dart")
else:
    print("Could not find patterns")
