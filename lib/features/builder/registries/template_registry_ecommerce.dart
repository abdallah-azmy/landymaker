import 'package:uuid/uuid.dart';

Map<String, dynamic> storeDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'أفضل المنتجات بين يديك',
        'subtitle':
            'اكتشف مجموعتنا الحصرية من المنتجات عالية الجودة التي تناسب ذوقك الرفيع.',
        'button_text': 'تسوق الآن',
        'image_url':
            'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'products',
        'title': 'المنتجات الأكثر مبيعاً',
        'layout_style': 'grid_2',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'ساعة ذكية فاخرة',
            'price': '1200 EGP',
            'description': 'تتبع نشاطك وصحتك بكل سهولة مع تصميم عصري.',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/03/22/02/37/smart-3248678_1280.png',
            'button_text': 'اشترِ الآن',
          },
        ],
      },
    ],
  };
}

Map<String, dynamic> fashionStoreDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'تألقي بأسلوب يعبر عنك',
        'subtitle': 'أحدث صيحات الموضة العالمية المختارة بعناية لتناسب ذوقك الرفيع.',
        'button_text': 'تسوقي المجموعة الجديدة',
        'image_url': 'https://cdn.pixabay.com/photo/2016/09/21/15/27/clothes-1766891_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'products',
        'title': 'القطع المختارة لكِ',
        'layout_style': 'grid_3',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'فستان صيفي حرير',
            'price': '850 EGP',
            'image_url': 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
            'button_text': 'شراء الآن',
          },
          {
            'id': const Uuid().v4(),
            'name': 'حقيبة جلد طبيعي',
            'price': '1200 EGP',
            'image_url': 'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
            'button_text': 'شراء الآن',
          },
        ],
      },
      {
        'type': 'gallery',
        'title': 'على الإنستغرام',
        'items': [
          'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/03/23/15/00/massage-1274935_1280.jpg',
        ],
      },
      {
        'type': 'testimonials',
        'title': 'عميلاتنا يقولون',
        'items': [
          {'author': 'ليلى س.', 'role': 'عميلة دائم', 'quote': 'الجودة رائعة والتوصيل سريع جداً، تجربة ممتازة.'},
        ],
      },
      {
        'type': 'cta_banner',
        'title': 'خصم ١٠٪ على أول طلب لكِ',
        'subtitle': 'اشتركي في قائمتنا البريدية واحصلي على الخصم فوراً.',
        'button_text': 'سجلي الآن',
      },
    ],
  };
}

Map<String, dynamic> boutiqueStoreDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'مجموعة الخريف الحصرية',
        'subtitle': 'قطع مصممة بعناية لتمنحك الأناقة التي تستحقينها في كل لحظة.',
        'button_text': 'اكتشفي المجموعة',
        'image_url': 'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
        'badge_text': 'جديد',
        'animation': {'type': 'fadeIn', 'duration': 1200},
      },
      {
        'type': 'featured_product',
        'name': 'معطف صوف فاخر',
        'price': '3,200 EGP',
        'badge_text': 'الأكثر مبيعاً',
        'description': 'مصنوع من أجود أنواع الصوف الطبيعي، بتصميم كلاسيكي عصري يناسب كافة المناسبات.',
        'image_url': 'https://cdn.pixabay.com/photo/2016/11/18/22/29/vacation-1837135_1280.jpg',
        'button_text': 'أضيفي للسلة',
        'animation': {'type': 'slideInRight', 'duration': 1000},
      },
      {
        'type': 'bento_store',
        'title': 'تسوّقي حسب الفئة',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'فساتين سهرة',
            'price': 'بدءاً من 1,500 EGP',
            'image_url': 'https://cdn.pixabay.com/photo/2016/09/21/15/27/clothes-1766891_1280.jpg',
          },
          {
            'id': const Uuid().v4(),
            'name': 'إكسسوارات ذهبية',
            'price': 'بدءاً من 450 EGP',
            'image_url': 'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
          },
          {
            'id': const Uuid().v4(),
            'name': 'أحذية كلاسيك',
            'price': 'بدءاً من 800 EGP',
            'image_url': 'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
          },
        ],
      },
      {
        'type': 'whatsapp',
        'title': 'هل لديكِ استفسار؟',
        'subtitle': 'فريقنا متاح لمساعدتكِ في اختيار المقاس المناسب.',
        'button_text': 'تحدثي معنا الآن',
      },
    ],
  };
}
