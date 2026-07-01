import 'package:uuid/uuid.dart';

Map<String, dynamic> saasStartupDesign() {
  return {
    'blocks': [
      {
        'type': 'hero_saas',
        'title': 'حوّل أفكارك إلى واقع رقمي',
        'subtitle':
            'منصة متكاملة لبناء وإدارة تطبيقات الأعمال بذكاء. انطلق مع أدواتنا المتطورة وزبائنك سيرون الفرق.',
        'button_text': 'اطلب نسختك التجريبية',
        'image_url':
            'https://cdn.pixabay.com/photo/2018/03/22/02/37/smart-3248678_1280.png',
        'badge_text': 'مميز',
        'animation': {'type': 'fadeIn', 'duration': 1000},
      },
      {
        'type': 'features',
        'title': 'مميزات المنصة',
        'layout_style': 'bento',
        'items': [
          {
            'title': 'لوحة تحكم تفاعلية',
            'description': 'تحليلات آنية وتقارير ذكية لفهم أداء عملك.',
          },
          {
            'title': 'تكامل سلس',
            'description': 'اربط مع أدواتك المفضلة عبر API مفتوح.',
          },
          {
            'title': 'دعم فني 24/7',
            'description': 'فريق دعم متخصص جاهز لمساعدتك في أي وقت.',
          },
          {
            'title': 'أتمتة ذكية',
            'description': 'وفّر وقتك مع سير العمل الآلي المدعوم بالذكاء الاصطناعي.',
          },
          {
            'title': 'أمان من الدرجة الأولى',
            'description': 'تشفير كامل وحماية متقدمة لبياناتك.',
          },
          {
            'title': 'قابلية توسع لا محدودة',
            'description': 'ينمو معاك من البداية وحتى آلاف المستخدمين.',
          },
        ],
        'animation': {'type': 'slideUp', 'duration': 800},
      },
      {
        'type': 'pricing',
        'title': 'خطط الأسعار',
        'has_toggle': true,
        'toggle_labels': {'monthly': 'شهري', 'yearly': 'سنوي (وفر 20%)'},
        'items': [
          {
            'name': 'الباقة الأساسية',
            'price': '99',
            'currency': 'ريال',
            'period': '/شهر',
            'features': ['3 مشاريع', '5GB تخزين', 'دعم عبر البريد'],
            'is_popular': false,
          },
          {
            'name': 'باقة الأعمال',
            'price': '199',
            'currency': 'ريال',
            'period': '/شهر',
            'features': ['مشاريع غير محدودة', '50GB تخزين', 'دعم فوري', 'API كامل'],
            'is_popular': true,
          },
          {
            'name': 'باقة المؤسسات',
            'price': '499',
            'currency': 'ريال',
            'period': '/شهر',
            'features': ['كل شيء', '500GB تخزين', 'مدير حساب مخصص', 'SLA مضمون'],
            'is_popular': false,
          },
        ],
        'animation': {'type': 'zoomIn', 'duration': 1000},
      },
      {
        'type': 'testimonials',
        'title': 'ماذا قالوا عنا',
        'items': [
          {
            'name': 'نورة الأحمدي',
            'role': 'رائدة أعمال',
            'text': 'هذه المنصة غيرت طريقة إدارة أعمالي بالكامل. وفرت عليّ ساعات طويلة من العمل اليدوي.',
          },
          {
            'name': 'عبدالله السبيعي',
            'role': 'مدير تقني',
            'text': 'التكامل مع أنظمتنا كان سلساً جداً. فريق الدعم احترافي وسريع.',
          },
          {
            'name': 'سارة آل سعود',
            'role': 'مؤسسة شركة ناشئة',
            'text': 'منصة مثالية للشركات الناشئة. الباقة المجانية سخية جداً والتوسع سهل.',
          },
        ],
        'animation': {'type': 'slideInRight', 'duration': 900},
      },
      {
        'type': 'contact_info',
        'title': 'تواصل معنا',
        'email': 'hello@saasstartup.com',
        'phone': '966500000000',
        'location': 'الرياض، المملكة العربية السعودية',
        'animation': {'type': 'fadeIn', 'duration': 800},
      },
    ],
  };
}

Map<String, dynamic> mobileAppSaasDesign() {
  return {
    'blocks': [
      {
        'type': 'hero_saas',
        'title': 'أدر عملك من لوحة واحدة',
        'subtitle':
            'منصة ذكية للفرق التي تريد متابعة العملاء، الطلبات، والتحليلات بسرعة.',
        'button_text': 'اطلب تجربة مجانية',
        'button_url': '#demo',
        'image_url':
            'https://pixabay.com/get/g6e5b0e0c0f0e0d0c0b0a09080706050403020100_1280.png',
        'badge_text': 'مميز',
        'ai_intent': 'saas_product_offer',
        'ai_slots': ['product_name', 'core_problem', 'main_cta'],
        'animation': {'type': 'slideInDown', 'duration': 1000},
      },
      {
        'type': 'trust_logos',
        'title': 'تثق بنا فرق نامية',
        'items': [
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
        ],
        'animation': {'type': 'fadeIn', 'duration': 1200, 'delay': 400},
      },
      {
        'type': 'features',
        'title': 'كل ما تحتاجه للنمو',
        'items': [
          {
            'title': 'أتمتة المهام',
            'description': 'قلل العمل اليدوي وركز على القرارات.',
          },
          {
            'title': 'تقارير فورية',
            'description': 'تابع الأداء والتحويلات لحظة بلحظة.',
          },
          {
            'title': 'تكاملات مرنة',
            'description': 'اربط أدواتك الحالية بسهولة.',
          },
        ],
      },
      {
        'type': 'video_embed',
        'title': 'شاهد المنتج في دقيقتين',
        'subtitle': 'نظرة سريعة على تجربة المستخدم وسير العمل.',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'aspect_ratio': '16:9',
        'max_width': 900,
        'use_thumbnail': true,
      },
      {
        'type': 'pricing',
        'schema_version': 2,
        'title': 'خطط تناسب كل فريق',
        'subtitle': 'ابدأ صغيراً ووسع استخدامك عند الحاجة',
        'has_toggle': true,
        'toggle_labels': {'monthly': 'شهري', 'yearly': 'سنوي'},
        'items': [
          {
            'plan_id': const Uuid().v4(),
            'name': 'Starter',
            'prices': {'monthly': 19, 'yearly': 190},
            'currency': '\$',
            'periods': {'monthly': '/ mo', 'yearly': '/ yr'},
            'features': ['3 users', 'Basic analytics'],
            'button_text': 'Start',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false,
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'Growth',
            'prices': {'monthly': 49, 'yearly': 490},
            'currency': '\$',
            'periods': {'monthly': '/ mo', 'yearly': '/ yr'},
            'features': [
              'Unlimited users',
              'Advanced automations',
              'Priority support',
            ],
            'button_text': 'Try Growth',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': true,
          },
        ],
      },
      {
        'type': 'faq',
        'title': 'أسئلة قبل التجربة',
        'items': [
          {
            'question': 'هل توجد فترة تجربة؟',
            'answer': 'نعم، يمكنك تجربة المنصة قبل الاشتراك.',
          },
          {
            'question': 'هل يدعم المنتج الفرق العربية؟',
            'answer': 'نعم، التصميم واللغة قابلان للتخصيص.',
          },
        ],
      },
      {
        'type': 'lead_form',
        'title': 'اطلب Demo مخصص',
        'button_text': 'احجز العرض',
      },
    ],
  };
}

Map<String, dynamic> fintechCryptoDesign() {
  return {
    'blocks': [
      {
        'type': 'hero_saas',
        'variant': 8,
        'title': 'إدارة أصولك الرقمية بذكاء',
        'subtitle': 'منصة آمنة، سريعة، وسهلة الاستخدام لتداول وإدارة محفظتك المالية الحديثة.',
        'button_text': 'ابدأ الآن مجانًا',
        'image_url': 'https://cdn.pixabay.com/photo/2017/03/14/12/15/bitcoin-2007769_1280.jpg',
        'badge_text': 'مميز',
        'animation': {'type': 'zoomIn', 'duration': 1200},
      },
      {
        'type': 'trust_logos',
        'title': 'شركاء في الثقة والأمان',
        'items': [
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
        ],
      },
      {
        'type': 'comparison_table',
        'title': 'قارن بين باقات التداول',
        'plans': [
          {'name': 'الأساسية', 'price': 'مجاني'},
          {'name': 'برو', 'price': '\$29/mo'},
        ],
        'features': [
          {'name': 'عدد العملات', 'values': ['10', 'الكل']},
          {'name': 'دعم فني 24/7', 'values': [false, true]},
          {'name': 'تنبيهات فورية', 'values': [true, true]},
        ],
      },
      {
        'type': 'cta_banner',
        'title': 'جاهز للانطلاق في عالم الـ Crypto؟',
        'subtitle': 'انضم لأكثر من مليون مستخدم حول العالم اليوم.',
        'button_text': 'إنشاء محفظة',
      },
    ],
  };
}

Map<String, dynamic> digitalCourseDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'Master Modern Web Development',
        'subtitle':
            'An intensive, hands-on course to take you from zero to pro in 12 weeks.',
        'button_text': 'Enroll Now',
        'image_url':
            'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'pricing',
        'title': 'Choose Your Learning Path',
        'items': [
          {
            'name': 'Standard',
            'price': '2000 EGP',
            'features': ['Lifetime access', 'Course files'],
          },
          {
            'name': 'Pro',
            'price': '4500 EGP',
            'features': ['1-on-1 Mentorship', 'Job assistance'],
            'is_popular': true,
          },
        ],
      },
      {
        'type': 'faq',
        'title': 'Course FAQs',
        'items': [
          {
            'question': 'Is it for beginners?',
            'answer': 'Yes, we start from the basics.',
          },
        ],
      },
    ],
  };
}

Map<String, dynamic> bookLaunchDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'كتاب عملي لبناء عادة مربحة',
        'subtitle':
            'دليل واضح يساعدك على تحويل الأفكار إلى خطة قابلة للتنفيذ خلال 30 يوم.',
        'button_text': 'احصل على الفصل الأول',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/03/31/19/42/books-1163695_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'digital_product_launch',
      },
      {
        'type': 'lead_magnet',
        'title': 'حمّل الفصل الأول مجاناً',
        'subtitle': 'اترك بريدك لتحصل على نسخة تجريبية وقائمة تطبيق عملية.',
        'button_text': 'أرسل النسخة',
        'image_url':
            'https://cdn.pixabay.com/photo/2018/03/22/02/37/smart-3248678_1280.png',
        'ai_intent': 'sample_chapter_capture',
      },
      {
        'type': 'features',
        'title': 'ماذا ستتعلم؟',
        'items': [
          {
            'title': 'خطة 30 يوم',
            'description': 'خطوات قصيرة وسهلة المتابعة.',
          },
          {
            'title': 'تمارين تطبيقية',
            'description': 'حوّل القراءة إلى تنفيذ.',
          },
          {
            'title': 'قوالب جاهزة',
            'description': 'استخدمها فوراً في مشروعك.',
          },
        ],
      },
      {
        'type': 'testimonials',
        'title': 'قرّاء النسخة التجريبية',
        'items': [
          {
            'author': 'قارئ مبكر',
            'role': 'Founder',
            'quote': 'الكتاب عملي ومباشر، لا يضيع وقتك في التنظير.',
          },
        ],
      },
      {
        'type': 'pricing',
        'title': 'اختر نسختك',
        'items': [
          {
            'name': 'النسخة الرقمية',
            'price': '299 EGP',
            'features': ['PDF كامل', 'قوالب قابلة للتحميل'],
            'is_popular': true,
          },
          {
            'name': 'حزمة الكاتب',
            'price': '799 EGP',
            'features': ['الكتاب', 'جلسة Q&A', 'تحديثات مجانية'],
            'is_popular': false,
          },
        ],
      },
      {
        'type': 'faq',
        'title': 'قبل الشراء',
        'items': [
          {
            'question': 'هل يناسب المبتدئين؟',
            'answer': 'نعم، يبدأ من الأساسيات ثم ينتقل للتطبيق.',
          },
          {
            'question': 'هل الملفات قابلة للتحميل؟',
            'answer': 'نعم، تحصل على الكتاب والقوالب بعد التسجيل أو الشراء.',
          },
        ],
      },
    ],
  };
}

Map<String, dynamic> creativeAgencyDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'نصمم حملات تترك أثراً',
        'subtitle': 'استراتيجية، تصميم، ومحتوى يساعد علامتك على الظهور بثقة.',
        'button_text': 'ابدأ مشروعك',
        'image_url':
            'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'agency_value_proposition',
      },
      {
        'type': 'features',
        'title': 'خدماتنا',
        'items': [
          {'title': 'هوية بصرية', 'description': 'نظام بصري متكامل لعلامتك.'},
          {
            'title': 'حملات إعلانية',
            'description': 'رسائل واضحة وتجارب تحويل أعلى.',
          },
          {
            'title': 'صفحات هبوط',
            'description': 'تصميم وتنفيذ صفحات موجهة للنتائج.',
          },
        ],
      },
      {
        'type': 'gallery',
        'title': 'نماذج من أعمالنا',
        'items': [
          'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
          'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
          'https://cdn.pixabay.com/photo/2018/03/22/02/37/smart-3248678_1280.png',
        ],
      },
      {
        'type': 'animated_counter',
        'title': 'أثر يمكن قياسه',
        'items': [
          {'value': '120', 'label': 'مشروع مكتمل', 'prefix': '+', 'suffix': ''},
          {'value': '40', 'label': 'عميل مستمر', 'prefix': '+', 'suffix': ''},
          {'value': '3', 'label': 'أسواق نخدمها', 'prefix': '', 'suffix': ''},
        ],
      },
      {
        'type': 'testimonials',
        'title': 'ماذا يقول عملاؤنا؟',
        'items': [
          {
            'author': 'شركة ناشئة',
            'role': 'Founder',
            'quote': 'حولوا فكرتنا إلى حملة واضحة وسهلة البيع.',
          },
        ],
      },
      {
        'type': 'lead_form',
        'title': 'احكِ لنا عن مشروعك',
        'button_text': 'إرسال brief',
      },
    ],
  };
}

Map<String, dynamic> personalDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'مرحباً، أنا مصمم مبدع',
        'subtitle':
            'أساعد الشركات على بناء هويات بصرية مذهلة وتجارب مستخدم فريدة.',
        'button_text': 'شاهد أعمالي',
        'image_url':
            'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'social_qr',
        'title': 'تواصل معي',
        'subtitle': 'تابعني على المنصات التالية',
        'links': [
          {'platform': 'instagram', 'url': 'https://instagram.com'},
          {'platform': 'linkedin', 'url': 'https://linkedin.com'},
        ],
      },
    ],
  };
}
