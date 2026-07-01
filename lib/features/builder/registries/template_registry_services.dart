import 'package:uuid/uuid.dart';

Map<String, dynamic> professionalDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'حلول استشارية لنمو عملك',
        'subtitle':
            'نقدم استشارات مبنية على البيانات لتحقيق أهدافك التجارية.',
        'button_text': 'احجز استشارة مجانية',
        'image_url':
            'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'lead_form',
        'title': 'تواصل مع فريق الخبراء',
        'button_text': 'إرسال الطلب',
      },
    ],
  };
}

Map<String, dynamic> realEstateDesign() {
  return {
    'blocks': [
      {
        'type': 'logo_header',
        'title': 'Landy Real Estate',
        'alignment': 'left',
      },
      {
        'type': 'hero',
        'title': 'Find Your Dream Home',
        'subtitle':
            'Discover the finest properties in the most prestigious neighborhoods with flexible payment plans.',
        'button_text': 'Browse Units',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/11/29/03/53/house-1867187_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'features',
        'title': 'Why Invest With Us?',
        'layout_style': 'grid',
        'items': [
          {
            'title': 'Prime Locations',
            'description': 'Strategic spots with high ROI potential.',
          },
          {
            'title': 'Modern Design',
            'description': 'Smart homes with luxury finishes.',
          },
        ],
      },
      {
        'type': 'contact_info',
        'title': 'Contact Our Sales Team',
        'phone': '+201100000000',
        'location': 'New Cairo, Egypt',
      },
    ],
  };
}

Map<String, dynamic> restaurantDesign() {
  return {
    'blocks': [
      {
        'type': 'logo_header',
        'title': 'Bistro Cairo',
        'alignment': 'center',
        'ai_intent': 'brand_header',
        'ai_slots': ['brand_name', 'logo_url'],
      },
      {
        'type': 'hero',
        'title': 'مذاق طازج يصل إليك بسرعة',
        'subtitle':
            'وجبات يومية، قهوة مختصة، وحجوزات سهلة للعائلات والأصدقاء.',
        'button_text': 'اطلب عبر واتساب',
        'button_url': 'https://wa.me/201000000000',
        'image_url':
            'https://cdn.pixabay.com/photo/2019/07/15/13/22/restaurant-4497194_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'food_offer',
        'ai_slots': [
          'restaurant_name',
          'signature_dish',
          'delivery_or_booking_cta',
        ],
      },
      {
        'type': 'products',
        'title': 'أشهر اختياراتنا',
        'layout_style': 'grid_2',
        'whatsapp_number': '201000000000',
        'ai_intent': 'menu_catalog',
        'ai_slots': ['menu_items', 'prices', 'food_images'],
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'برجر شيف سبيشل',
            'price': '220 EGP',
            'category': 'وجبات رئيسية',
            'description': 'لحم طازج، صوص خاص، وخبز محمص.',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/05/30/19/18/burger-3442227_1280.jpg',
            'button_text': 'اطلب الآن',
          },
          {
            'id': const Uuid().v4(),
            'name': 'قهوة لاتيه مثلجة',
            'price': '95 EGP',
            'category': 'مشروبات',
            'description': 'قهوة مختصة بلمسة كريمية منعشة.',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg',
            'button_text': 'أضف للطلب',
          },
        ],
      },
      {
        'type': 'gallery',
        'title': 'أجواء المكان',
        'display_mode': 'grid',
        'items': [
          'https://cdn.pixabay.com/photo/2018/07/11/21/51/toast-3532016_1280.jpg',
          'https://cdn.pixabay.com/photo/2014/10/23/18/05/burger-500054_1280.jpg',
          'https://cdn.pixabay.com/photo/2017/12/09/08/18/pizza-3007395_1280.jpg',
        ],
        'ai_intent': 'venue_showcase',
        'ai_slots': ['interior_photos', 'food_photos'],
      },
      {
        'type': 'working_hours',
        'title': 'مواعيد العمل',
        'schedule': {
          'السبت - الخميس': '9:00 AM - 1:00 AM',
          'الجمعة': '1:00 PM - 2:00 AM',
        },
        'ai_intent': 'availability',
      },
      {
        'type': 'location_map',
        'title': 'زورونا',
        'address': 'القاهرة، مصر',
        'map_iframe_url':
            'https://maps.google.com/maps?q=Cairo&t=&z=13&ie=UTF8&iwloc=&output=embed',
        'ai_intent': 'physical_location',
      },
      {
        'type': 'whatsapp',
        'title': 'جاهز تطلب؟',
        'phone_number': '201000000000',
        'message': 'مرحباً، أريد طلب من المنيو.',
        'button_text': 'ابدأ الطلب',
        'ai_intent': 'direct_order_cta',
      },
    ],
  };
}

Map<String, dynamic> clinicDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'رعاية طبية موثوقة لك ولأسرتك',
        'subtitle':
            'فريق متخصص، متابعة دقيقة، وحجز مواعيد سريع بدون انتظار طويل.',
        'button_text': 'احجز موعدك',
        'image_url':
            'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563428_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'healthcare_trust_offer',
        'ai_slots': ['clinic_name', 'specialty', 'appointment_cta'],
        'animation': {'type': 'fadeIn', 'duration': 1000},
      },
      {
        'type': 'features',
        'title': 'خدماتنا الطبية',
        'layout_style': 'grid',
        'items': [
          {
            'title': 'كشف متخصص',
            'description': 'تشخيص دقيق وخطة علاج واضحة.',
          },
          {
            'title': 'متابعة دورية',
            'description': 'رعاية مستمرة ونتائج قابلة للقياس.',
          },
          {
            'title': 'حجز مرن',
            'description': 'اختر الموعد المناسب لك بسهولة.',
          },
        ],
        'ai_intent': 'medical_services',
        'animation': {'type': 'slideInUp', 'duration': 800},
      },
      {
        'type': 'animated_counter',
        'title': 'ثقة مبنية على خبرة',
        'items': [
          {'value': '12', 'label': 'سنة خبرة', 'prefix': '+', 'suffix': ''},
          {
            'value': '8000',
            'label': 'مريض تم خدمتهم',
            'prefix': '+',
            'suffix': '',
          },
          {'value': '98', 'label': 'رضا المرضى', 'prefix': '', 'suffix': '%'},
        ],
        'ai_intent': 'medical_proof_metrics',
      },
      {
        'type': 'testimonials',
        'title': 'آراء المرضى',
        'items': [
          {
            'author': 'أحمد م.',
            'role': 'مريض سابق',
            'quote': 'تنظيم ممتاز وشرح واضح لكل خطوة.',
            'image_url': 'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
          },
          {
            'author': 'سارة ع.',
            'role': 'مريضة متابعة',
            'quote': 'التجربة كانت مريحة من الحجز حتى المتابعة.',
            'image_url': 'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
          },
        ],
        'ai_intent': 'patient_testimonials',
        'animation': {'type': 'zoomIn', 'duration': 800},
      },
      {
        'type': 'multi_step_lead_form',
        'schema_version': 1,
        'title': 'احجز موعدك الآن',
        'subtitle': 'املأ البيانات وسيتواصل معك فريق الاستقبال لتأكيد الموعد',
        'success_message': 'تم استلام طلب الحجز بنجاح.',
        'enable_local_save': true,
        'ai_intent': 'appointment_booking',
        'steps': [
          {
            'step_id': const Uuid().v4(),
            'step_title': 'بيانات المريض',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'text',
                'label': 'الاسم الكامل',
                'is_required': true,
                'validation': {'min_length': 3},
              },
              {
                'field_id': const Uuid().v4(),
                'field_type': 'phone',
                'label': 'رقم الهاتف',
                'is_required': true,
              },
            ],
          },
          {
            'step_id': const Uuid().v4(),
            'step_title': 'تفاصيل الموعد',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'select',
                'label': 'الخدمة المطلوبة',
                'is_required': true,
                'options': [
                  {'value': 'checkup', 'label': 'كشف'},
                  {'value': 'followup', 'label': 'متابعة'},
                ],
              },
              {
                'field_id': const Uuid().v4(),
                'field_type': 'textarea',
                'label': 'ملاحظات إضافية',
                'is_required': false,
              },
            ],
          },
        ],
      },
      {
        'type': 'working_hours',
        'title': 'مواعيد العيادة',
        'schedule': {
          'الأحد - الخميس': '5:00 PM - 10:00 PM',
          'الجمعة': 'مغلق',
        },
      },
      {
        'type': 'location_map',
        'title': 'عنوان العيادة',
        'address': 'مدينة نصر، القاهرة',
        'map_iframe_url':
            'https://maps.google.com/maps?q=Nasr%20City%20Cairo&t=&z=13&ie=UTF8&iwloc=&output=embed',
      },
    ],
  };
}

Map<String, dynamic> beautySalonDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'جمالك يبدأ من تجربة مريحة',
        'subtitle': 'خدمات شعر، عناية بالبشرة، ومكياج احترافي بمواعيد مرنة.',
        'button_text': 'احجزي موعدك',
        'button_url': 'https://wa.me/201000000000',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/03/23/15/00/massage-1274935_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'beauty_booking_offer',
      },
      {
        'type': 'gallery',
        'title': 'نتائج نفتخر بها',
        'display_mode': 'masonry',
        'items': [
          'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
          'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
          'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
        ],
        'ai_intent': 'before_after_or_portfolio',
      },
      {
        'type': 'pricing',
        'title': 'باقات العناية',
        'items': [
          {
            'name': 'تصفيف شعر',
            'price': '350 EGP',
            'features': ['استشارة سريعة', 'تصفيف احترافي'],
            'is_popular': false,
          },
          {
            'name': 'باقة العروس',
            'price': '2500 EGP',
            'features': ['مكياج كامل', 'تصفيف شعر', 'جلسة تحضير'],
            'is_popular': true,
          },
        ],
        'ai_intent': 'beauty_service_packages',
      },
      {
        'type': 'testimonials',
        'title': 'تجارب عميلاتنا',
        'items': [
          {
            'author': 'منى',
            'role': 'عميلة',
            'quote': 'الخدمة راقية والنتيجة أجمل من المتوقع.',
          },
          {
            'author': 'ريم',
            'role': 'عميلة',
            'quote': 'التزام بالمواعيد وفريق محترف جداً.',
          },
        ],
      },
      {
        'type': 'working_hours',
        'title': 'مواعيد الصالون',
        'schedule': {'يومياً': '12:00 PM - 10:00 PM'},
      },
      {
        'type': 'whatsapp',
        'title': 'احجزي جلستك الآن',
        'phone_number': '201000000000',
        'message': 'مرحباً، أريد حجز موعد في الصالون.',
        'button_text': 'تواصلي عبر واتساب',
      },
    ],
  };
}

Map<String, dynamic> gymFitnessDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'ابدأ تحولك خلال 30 يوم',
        'subtitle': 'برامج تدريب، تغذية، ومتابعة مستمرة لتصل لهدفك بثقة.',
        'button_text': 'اشترك الآن',
        'image_url':
            'https://cdn.pixabay.com/photo/2017/09/09/16/33/dumbbells-2465478_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'fitness_transformation_offer',
      },
      {
        'type': 'features',
        'title': 'لماذا ينضم الأعضاء إلينا؟',
        'items': [
          {
            'title': 'مدربون معتمدون',
            'description': 'خطط تدريب مناسبة لكل مستوى.',
          },
          {'title': 'متابعة قياسات', 'description': 'تقييم أسبوعي لتقدمك.'},
          {
            'title': 'برامج جماعية',
            'description': 'طاقة عالية والتزام أسهل.',
          },
        ],
      },
      {
        'type': 'pricing',
        'schema_version': 2,
        'title': 'اختار عضويتك',
        'subtitle': 'باقات مرنة حسب هدفك',
        'has_toggle': true,
        'toggle_labels': {'monthly': 'شهري', 'yearly': 'سنوي'},
        'items': [
          {
            'plan_id': const Uuid().v4(),
            'name': 'Basic',
            'prices': {'monthly': 900, 'yearly': 9000},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'features': ['دخول الجيم', 'برنامج أساسي'],
            'button_text': 'ابدأ',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false,
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'Coaching',
            'prices': {'monthly': 1800, 'yearly': 18000},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'features': ['كل مزايا Basic', 'مدرب خاص', 'متابعة تغذية'],
            'button_text': 'احجز تقييم',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': true,
          },
        ],
      },
      {
        'type': 'animated_counter',
        'title': 'نتائج حقيقية',
        'items': [
          {'value': '500', 'label': 'عضو نشط', 'prefix': '+', 'suffix': ''},
          {
            'value': '30',
            'label': 'برنامج تدريبي',
            'prefix': '+',
            'suffix': '',
          },
          {
            'value': '7',
            'label': 'أيام أسبوعياً',
            'prefix': '',
            'suffix': '/7',
          },
        ],
      },
      {
        'type': 'lead_form',
        'title': 'احصل على تقييم مجاني',
        'button_text': 'اطلب التواصل',
        'ai_intent': 'fitness_lead_capture',
      },
    ],
  };
}

Map<String, dynamic> eventDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'TechFlow 2026 Conference',
        'subtitle':
            'The biggest annual gathering for developers and AI enthusiasts in the region.',
        'button_text': 'Get Your Ticket',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/11/18/22/29/vacation-1837135_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'qr_code',
        'title': 'Quick Registration',
        'subtitle': 'Scan this code at the gate.',
        'qr_size': 200.0,
      },
      {
        'type': 'location_map',
        'title': 'Event Venue',
        'address': 'Cairo International Convention Centre',
        'map_iframe_url':
            'https://maps.google.com/maps?q=CICC&t=&z=13&ie=UTF8&iwloc=&output=embed',
      },
    ],
  };
}

Map<String, dynamic> solarEnergyDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'مستقبل الطاقة بين يديك',
        'subtitle': 'وفر في فواتير الكهرباء وساهم في حماية البيئة مع أنظمة الطاقة الشمسية الأكثر كفاءة.',
        'button_text': 'احصل على عرض سعر مجاني',
        'image_url': 'https://cdn.pixabay.com/photo/2016/08/11/23/48/solar-panels-1477986_1280.jpg',
        'badge_text': 'جديد',
        'animation': {'type': 'zoomIn', 'duration': 1000},
      },
      {
        'type': 'statistics_grid',
        'title': 'أرقام تتحدث عن جودتنا',
        'items': [
          {'value': '1500+', 'label': 'منزل تم تجهيزه', 'icon': 'people'},
          {'value': '25MW', 'label': 'طاقة مولدة سنويًا', 'icon': 'speed'},
          {'value': '30%', 'label': 'توفير في الفواتير', 'icon': 'trending'},
          {'value': '10', 'label': 'سنوات ضمان', 'icon': 'check'},
        ],
        'animation': {'type': 'fadeInUp', 'duration': 800, 'delay': 200},
      },
      {
        'type': 'service_steps',
        'title': 'كيف نبدأ؟',
        'subtitle': 'خطوات بسيطة نحو طاقة نظيفة ومستدامة لمنزلك.',
        'items': [
          {'title': 'معاينة الموقع', 'description': 'يقوم فريقنا بزيارة الموقع وتقييم زوايا الشمس.'},
          {'title': 'التصميم الفني', 'description': 'نصمم نظاماً مخصصاً يناسب احتياجك الفعلي.'},
          {'title': 'التركيب والتشغيل', 'description': 'تركيب احترافي وتفعيل النظام خلال ٤٨ ساعة.'},
        ],
      },
      {
        'type': 'lead_form',
        'title': 'تواصل مع خبراء الطاقة',
        'button_text': 'إرسال الطلب',
      },
    ],
  };
}

Map<String, dynamic> luxuryResortDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'variant': 7,
        'title': 'ملاذ الفخامة والهدوء',
        'subtitle': 'استمتع بتجربة إقامة استثنائية في قلب الطبيعة الخلابة مع أرقى الخدمات العالمية.',
        'button_text': 'احجز جناحك الآن',
        'image_url': 'https://cdn.pixabay.com/photo/2019/03/04/17/30/pool-3962981_1280.jpg',
        'badge_text': 'جديد',
        'animation': {'type': 'slideInLeft', 'duration': 1000},
      },
      {
        'type': 'gallery',
        'title': 'اكتشف عالمنا',
        'display_mode': 'masonry',
        'items': [
          'https://cdn.pixabay.com/photo/2016/11/18/22/29/vacation-1837135_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/11/29/03/53/house-1867187_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/11/29/05/07/architecture-1857171_1280.jpg',
        ],
      },
      {
        'type': 'team_members',
        'title': 'فريق الضيافة بانتظارك',
        'items': [
          {'name': 'مارك دو', 'role': 'مدير المنتجع', 'image_url': 'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg'},
          {'name': 'سارة لين', 'role': 'كبير الطهاة', 'image_url': 'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg'},
        ],
      },
      {
        'type': 'cta_banner',
        'title': 'عرض حصري للموسم الحالي',
        'subtitle': 'احصل على ليلة إضافية مجانية عند حجز ٣ ليالي أو أكثر.',
        'button_text': 'اغتنم العرض',
        'button_url': '#booking',
      },
    ],
  };
}

Map<String, dynamic> architectureDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'نصمم المساحات، لنلهم الحياة',
        'subtitle': 'استوديو عمارة وتصميم داخلي يدمج بين الوظيفة والجمال لخلق بيئات فريدة.',
        'button_text': 'استشرنا في مشروعك',
        'image_url': 'https://cdn.pixabay.com/photo/2016/11/29/03/53/house-1867187_1280.jpg',
        'badge_text': 'جديد',
      },
      {
        'type': 'gallery',
        'title': 'من مشاريعنا الأخيرة',
        'display_mode': 'grid',
        'items': [
          'https://cdn.pixabay.com/photo/2016/11/29/05/07/architecture-1857171_1280.jpg',
          'https://cdn.pixabay.com/photo/2019/03/04/17/30/pool-3962981_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
        ],
      },
      {
        'type': 'service_steps',
        'title': 'رحلة التصميم',
        'items': [
          {'title': 'المفهوم الأول', 'description': 'نبدأ برسم الأفكار الأساسية وتحديد الهوية.'},
          {'title': 'التطوير التقني', 'description': 'تحويل الرسومات إلى نماذج ثلاثية الأبعاد دقيقة.'},
          {'title': 'التنفيذ والإشراف', 'description': 'متابعة دقيقة لكل تفاصيل العمل في الموقع.'},
        ],
      },
      {
        'type': 'team_members',
        'title': 'العقول المبدعة',
        'items': [
          {'name': 'م. عمر كمال', 'role': 'كبير المعماريين', 'image_url': 'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg'},
        ],
      },
    ],
  };
}

Map<String, dynamic> nonprofitCampaignDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'ساهم في تغيير حقيقي اليوم',
        'subtitle':
            'حملة مجتمعية لدعم الأسر الأكثر احتياجاً عبر مبادرات شفافة وقابلة للقياس.',
        'button_text': 'انضم للحملة',
        'image_url':
            'https://cdn.pixabay.com/photo/2017/04/20/08/21/hands-1838658_1280.jpg',
        'badge_text': 'جديد',
        'ai_intent': 'mission_led_offer',
      },
      {
        'type': 'animated_counter',
        'title': 'أثرنا حتى الآن',
        'items': [
          {'value': '2500', 'label': 'مستفيد', 'prefix': '+', 'suffix': ''},
          {'value': '80', 'label': 'متطوع', 'prefix': '+', 'suffix': ''},
          {'value': '15', 'label': 'مبادرة', 'prefix': '+', 'suffix': ''},
        ],
      },
      {
        'type': 'features',
        'title': 'كيف نعمل؟',
        'items': [
          {
            'title': 'تحديد الاحتياج',
            'description': 'نراجع الحالات ونحدد الأولويات.',
          },
          {
            'title': 'تنفيذ ميداني',
            'description': 'فرقنا توصل الدعم للمستحقين.',
          },
          {
            'title': 'تقارير شفافة',
            'description': 'نشارك الأثر والنتائج باستمرار.',
          },
        ],
      },
      {
        'type': 'gallery',
        'title': 'من أرض الواقع',
        'items': [
          'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
          'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
          'https://cdn.pixabay.com/photo/2017/08/06/11/09/concert-2527495_1280.jpg',
        ],
      },
      {
        'type': 'lead_form',
        'title': 'سجل كمتطوع',
        'button_text': 'أرسل بياناتي',
      },
      {
        'type': 'faq',
        'title': 'أسئلة شائعة',
        'items': [
          {
            'question': 'هل يمكن التطوع عن بعد؟',
            'answer': 'نعم، توجد مهام ميدانية وعن بعد حسب احتياج الحملة.',
          },
          {
            'question': 'كيف أتابع أثر المشاركة؟',
            'answer': 'نرسل تحديثات دورية وتقارير مختصرة للمشاركين.',
          },
        ],
      },
    ],
  };
}
