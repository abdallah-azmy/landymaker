class PlaceholderGenerator {
  static String generate(String field, {String? industry}) {
    final Map<String, Map<String, String>> placeholders = {
      'section_title': {
        'gym': 'النادي الرياضي',
        'clinic': 'العيادة الطبية',
        'restaurant': 'المطعم',
        'default': 'قسم جديد',
      },
      'business_name': {
        'gym': '[اسم النادي الرياضي]',
        'clinic': '[اسم العيادة]',
        'restaurant': '[اسم المطعم]',
        'agency': '[اسم الوكالة]',
        'law_firm': '[اسم مكتب المحاماة]',
        'default': '[اسم عملك]',
      },
      'cta_text': {
        'gym': 'اشترك الآن',
        'clinic': 'احجز موعداً',
        'restaurant': 'اطلب الآن',
        'agency': 'ابدأ مشروعك',
        'default': 'ابدأ الآن',
      },
      'offer_details': {
        'gym': 'خصم 50% على الاشتراك السنوي',
        'clinic': 'استشارة أولية مجانية',
        'restaurant': 'توصيل مجاني لأول طلب',
        'default': 'عرض حصري لفترة محدودة',
      }
    };

    final ind = (industry ?? 'default').toLowerCase();
    
    if (placeholders.containsKey(field)) {
      final category = placeholders[field]!;
      return category[ind] ?? category['default']!;
    }

    return '[${field.replaceAll('_', ' ')}]';
  }

  /// Ensures a design object has no missing critical strings by filling them with placeholders
  static Map<String, dynamic> fillPlaceholders(Map<String, dynamic> designJson, String? industry) {
    if (designJson['blocks'] == null) return designJson;

    final List blocks = designJson['blocks'];
    for (var block in blocks) {
      if (block['title'] == null || block['title'].isEmpty) {
        block['title'] = generate('section_title', industry: industry);
      }

      // Handle specific block items
      if (block['items'] != null && block['items'] is List) {
        for (var item in block['items']) {
          if (item is Map) {
            item.forEach((key, value) {
              if (value == null || (value is String && value.isEmpty)) {
                item[key] = generate(key, industry: industry);
              }
            });
          }
        }
      }
    }

    return designJson;
  }
}
