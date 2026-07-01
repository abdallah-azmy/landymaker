import 'package:uuid/uuid.dart';

Map<String, dynamic> comprehensiveDesign() {
  return {
    'blocks': [
      {
        'type': 'hero',
        'title': 'القالب الشامل - اختبار جميع الأقسام',
        'subtitle':
            'هذا القالب مصمم لعرض جميع أنواع الأقسام المتاحة في النظام لاختبارها وتجربتها.',
        'button_text': 'ابدأ الاختبار',
        'image_url':
            'https://cdn.pixabay.com/photo/2018/03/22/02/37/smart-3248678_1280.png',
        'badge_text': 'قالب اختبار',
        'animation': {'type': 'fadeIn', 'duration': 1000},
      },
      {
        'type': 'hero_saas',
        'title': 'قسم SaaS Hero',
        'subtitle':
            'نموذج للقسم العلوي بنمط الشركات السحابية مع شعارات تقنية.',
        'button_text': 'اكتشف المزيد',
        'image_url':
            'https://cdn.pixabay.com/photo/2021/09/23/11/19/dashboard-6649784_1280.jpg',
        'badge_text': 'مميز',
        'tech_logos': [
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
        ],
        'animation': {'type': 'slideInDown', 'duration': 1000},
      },
      {
        'type': 'logo_header',
        'title': 'Landy Maker',
        'logo_url': '',
        'logo_height': 40.0,
        'alignment': 'center',
      },
      {
        'type': 'features',
        'title': 'المميزات',
        'layout_style': 'grid',
        'items': [
          {
            'title': 'سهولة الاستخدام',
            'description': 'واجهة بسيطة وبديهية تتيح لك بناء صفحاتك بسرعة.',
          },
          {
            'title': 'مرونة عالية',
            'description': 'خصص كل قسم حسب احتياجك مع خيارات غير محدودة.',
          },
          {
            'title': 'تصاميم جاهزة',
            'description': 'العديد من القوالب الجاهزة للاستخدام الفوري.',
          },
          {
            'title': 'دعم فني',
            'description': 'فريق دعم متواجد لمساعدتك في أي وقت.',
          },
        ],
        'animation': {'type': 'slideUp', 'duration': 800},
      },
      {
        'type': 'lead_form',
        'title': 'نموذج تواصل',
        'button_text': 'إرسال',
      },
      {
        'type': 'lead_magnet',
        'title': 'حمّل الدليل المجاني',
        'subtitle': 'احصل على دليل شامل لبناء صفحات الهبوط.',
        'button_text': 'حمّل الآن',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/03/31/19/42/books-1163695_1280.jpg',
      },
      {
        'type': 'whatsapp',
        'title': 'تواصل عبر واتساب',
        'phone_number': '201000000000',
        'message': 'مرحباً، أريد استفساراً.',
        'button_text': 'راسلنا الآن',
      },
      {
        'type': 'contact_info',
        'title': 'معلومات الاتصال',
        'email': 'info@landymaker.com',
        'phone': '+966500000000',
        'location': 'الرياض، المملكة العربية السعودية',
      },
      {
        'type': 'location_map',
        'title': 'موقعنا',
        'address': 'الرياض، المملكة العربية السعودية',
        'map_iframe_url':
            'https://maps.google.com/maps?q=Riyadh&t=&z=13&ie=UTF8&iwloc=&output=embed',
      },
      {
        'type': 'working_hours',
        'title': 'مواعيد العمل',
        'schedule': {
          'السبت - الخميس': '9:00 ص - 6:00 م',
          'الجمعة': 'مغلق',
        },
      },
      {
        'type': 'social_qr',
        'title': 'تابعنا على',
        'subtitle': 'منصات التواصل الاجتماعي',
        'links': [
          {'platform': 'instagram', 'url': 'https://instagram.com'},
          {'platform': 'linkedin', 'url': 'https://linkedin.com'},
          {'platform': 'twitter', 'url': 'https://twitter.com'},
          {'platform': 'youtube', 'url': 'https://youtube.com'},
        ],
      },
      {
        'type': 'qr_code',
        'title': 'رمز QR',
        'subtitle': 'امسح الرابط للوصول السريع.',
        'qr_payload': 'https://landymaker.com',
        'qr_size': 200.0,
      },
      {
        'type': 'pricing',
        'schema_version': 2,
        'title': 'خطط الأسعار',
        'subtitle': 'اختر الخطة المناسبة لك',
        'has_toggle': true,
        'toggle_labels': {'monthly': 'شهري', 'yearly': 'سنوي'},
        'items': [
          {
            'plan_id': const Uuid().v4(),
            'name': 'الباقة الأساسية',
            'prices': {'monthly': 99, 'yearly': 990},
            'currency': 'ريال',
            'periods': {'monthly': '/شهر', 'yearly': '/سنة'},
            'features': ['مشروع واحد', '5GB تخزين', 'دعم عبر البريد'],
            'button_text': 'ابدأ الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false,
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'باقة الأعمال',
            'prices': {'monthly': 199, 'yearly': 1990},
            'currency': 'ريال',
            'periods': {'monthly': '/شهر', 'yearly': '/سنة'},
            'features': ['مشاريع غير محدودة', '50GB تخزين', 'دعم فوري'],
            'button_text': 'اختر الخطة',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': true,
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'باقة المؤسسات',
            'prices': {'monthly': 499, 'yearly': 4990},
            'currency': 'ريال',
            'periods': {'monthly': '/شهر', 'yearly': '/سنة'},
            'features': ['كل شيء', '500GB تخزين', 'مدير حساب مخصص'],
            'button_text': 'تواصل معنا',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false,
          },
        ],
      },
      {
        'type': 'featured_product',
        'title': 'منتج مميز',
        'name': 'منتج احترافي',
        'price': '1,200 ريال',
        'badge_text': 'الأكثر مبيعاً',
        'description': 'منتج عالي الجودة مصمم خصيصاً ليلبي احتياجاتك.',
        'image_url':
            'https://cdn.pixabay.com/photo/2016/11/18/22/29/vacation-1837135_1280.jpg',
        'button_text': 'اطلب الآن',
        'animation': {'type': 'slideInRight', 'duration': 1000},
      },
      {
        'type': 'bento_store',
        'title': 'تصفح الفئات',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'فئة أولى',
            'price': 'تبدأ من 99 ريال',
            'image_url':
                'https://cdn.pixabay.com/photo/2016/09/21/15/27/clothes-1766891_1280.jpg',
          },
          {
            'id': const Uuid().v4(),
            'name': 'فئة ثانية',
            'price': 'تبدأ من 149 ريال',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
          },
          {
            'id': const Uuid().v4(),
            'name': 'فئة ثالثة',
            'price': 'تبدأ من 199 ريال',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
          },
        ],
      },
      {
        'type': 'products',
        'title': 'المنتجات',
        'layout_style': 'grid_3',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'منتج أول',
            'price': '99 ريال',
            'category': 'فئة أ',
            'description': 'وصف المنتج الأول.',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/05/30/19/18/burger-3442227_1280.jpg',
            'button_text': 'أضف للسلة',
          },
          {
            'id': const Uuid().v4(),
            'name': 'منتج ثاني',
            'price': '149 ريال',
            'category': 'فئة ب',
            'description': 'وصف المنتج الثاني.',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
            'button_text': 'أضف للسلة',
          },
          {
            'id': const Uuid().v4(),
            'name': 'منتج ثالث',
            'price': '199 ريال',
            'category': 'فئة أ',
            'description': 'وصف المنتج الثالث.',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/03/31/19/29/schnitzel-3279045_1280.jpg',
            'button_text': 'أضف للسلة',
          },
        ],
      },
      {
        'type': 'faq',
        'title': 'الأسئلة الشائعة',
        'items': [
          {
            'question': 'ما هو هذا القالب؟',
            'answer': 'هذا قالب شامل يحتوي على جميع أنواع الأقسام المتاحة لاختبارها.',
          },
          {
            'question': 'هل يمكنني حذف الأقسام؟',
            'answer': 'نعم، يمكنك حذف أي قسم أو تعديله حسب احتياجك.',
          },
          {
            'question': 'كيف أبدأ بالتعديل؟',
            'answer': 'اختر أي قسم وابدأ بتخصيصه من لوحة التحكم الجانبية.',
          },
        ],
      },
      {
        'type': 'testimonials',
        'title': 'آراء المستخدمين',
        'layout_style': 'carousel',
        'items': [
          {
            'author': 'أحمد',
            'role': 'مطور',
            'quote': 'منصة رائعة وسهلة الاستخدام. أنصح بها الجميع.',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
          },
          {
            'author': 'سارة',
            'role': 'مصممة',
            'quote': 'أفضل أداة لبناء صفحات الهبوط بسرعة واحترافية.',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
          },
          {
            'author': 'محمد',
            'role': 'مسوق',
            'quote': 'وفرت علينا الكثير من الوقت والجهد في بناء الصفحات.',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
          },
        ],
      },
      {
        'type': 'gallery',
        'title': 'معرض الصور',
        'display_mode': 'grid',
        'grid_columns': 3,
        'items': [
          'https://cdn.pixabay.com/photo/2016/11/18/22/29/vacation-1837135_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/11/29/03/53/house-1867187_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/11/29/05/07/architecture-1857171_1280.jpg',
          'https://cdn.pixabay.com/photo/2017/08/06/11/09/concert-2527495_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
          'https://cdn.pixabay.com/photo/2016/03/23/15/00/massage-1274935_1280.jpg',
        ],
      },
      {
        'type': 'trust_logos',
        'title': 'شركاؤنا',
        'items': [
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
        ],
      },
      {
        'type': 'animated_counter',
        'title': 'إحصائيات',
        'items': [
          {'value': '500', 'label': 'مستخدم', 'prefix': '+', 'suffix': ''},
          {'value': '50', 'label': 'قالب', 'prefix': '+', 'suffix': ''},
          {'value': '99', 'label': 'رضا', 'prefix': '', 'suffix': '%'},
          {'value': '24', 'label': 'دعم', 'prefix': '', 'suffix': '/7'},
        ],
      },
      {
        'type': 'basic_section',
        'title': 'قسم مخصص',
        'layout_direction': 'column',
        'spacing': 20.0,
        'elements': [
          {
            'element_type': 'text',
            'id': const Uuid().v4(),
            'content': 'هذا قسم مخصص يمكنك تعديله بحرية.',
            'style': {'fontSize': 18, 'fontWeight': 'bold'},
          },
          {
            'element_type': 'text',
            'id': const Uuid().v4(),
            'content': 'أضف أي محتوى تريده هنا.',
            'style': {'fontSize': 14},
          },
        ],
      },
      {
        'type': 'video_embed',
        'title': 'فيديو توضيحي',
        'subtitle': 'شاهد الفيديو لتعرف المزيد.',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'aspect_ratio': '16:9',
        'max_width': 900,
        'use_thumbnail': true,
      },
      {
        'type': 'multi_step_lead_form',
        'schema_version': 1,
        'title': 'نموذج متعدد الخطوات',
        'subtitle': 'املأ البيانات خطوة بخطوة.',
        'success_message': 'تم إرسال البيانات بنجاح.',
        'enable_local_save': true,
        'steps': [
          {
            'step_id': const Uuid().v4(),
            'step_title': 'البيانات الشخصية',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'text',
                'label': 'الاسم الكامل',
                'is_required': true,
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
            'step_title': 'تفاصيل إضافية',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'select',
                'label': 'الخدمة المطلوبة',
                'is_required': true,
                'options': [
                  {'value': 'service1', 'label': 'خدمة أولى'},
                  {'value': 'service2', 'label': 'خدمة ثانية'},
                ],
              },
              {
                'field_id': const Uuid().v4(),
                'field_type': 'textarea',
                'label': 'ملاحظات',
                'is_required': false,
              },
            ],
          },
        ],
      },
      {
        'type': 'statistics_grid',
        'title': 'إحصائيات مع أيقونات',
        'subtitle': 'أرقام تعبر عن التميز',
        'layout_style': 'withIcons',
        'items': [
          {'value': '1500+', 'label': 'عميل', 'icon': 'people'},
          {'value': '99%', 'label': 'رضا', 'icon': 'thumb_up'},
          {'value': '24/7', 'label': 'دعم', 'icon': 'support'},
          {'value': '50+', 'label': 'جائزة', 'icon': 'star'},
        ],
      },
      {
        'type': 'team_members',
        'title': 'فريق العمل',
        'subtitle': 'نخبة من المحترفين',
        'items': [
          {
            'name': 'أحمد علي',
            'role': 'المدير التنفيذي',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
            'bio': 'خبرة 15 عاماً في مجال التقنية.',
          },
          {
            'name': 'سارة محمد',
            'role': 'مديرة التصميم',
            'image_url':
                'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
            'bio': 'مصممة حائزة على جوائز عالمية.',
          },
          {
            'name': 'خالد عمر',
            'role': 'مطور أول',
            'image_url':
                'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
            'bio': 'خبير في تطوير الويب وتطبيقات الجوال.',
          },
        ],
      },
      {
        'type': 'service_steps',
        'title': 'خطوات العمل',
        'subtitle': 'كيف نعمل لتحقيق أفضل النتائج',
        'items': [
          {
            'title': 'الاستشارة',
            'description': 'نبدأ بفهم احتياجاتك وأهدافك.',
          },
          {
            'title': 'التخطيط',
            'description': 'نضع خطة عمل مخصصة تناسب متطلباتك.',
          },
          {
            'title': 'التنفيذ',
            'description': 'ننفذ الخطة بأعلى معايير الجودة.',
          },
          {
            'title': 'المتابعة',
            'description': 'نقدم دعماً مستمراً لضمان نجاحك.',
          },
        ],
      },
      {
        'type': 'cta_banner',
        'title': 'هل أنت مستعد للانطلاق؟',
        'subtitle': 'ابدأ رحلتك معنا اليوم واحصل على أفضل الحلول.',
        'button_text': 'ابدأ الآن',
        'button_url': '#',
      },
      {
        'type': 'comparison_table',
        'title': 'مقارنة الباقات',
        'plans': [
          {'name': 'الباقة المجانية', 'price': '0 ريال'},
          {'name': 'الباقة المدفوعة', 'price': '99 ريال/شهر'},
          {'name': 'باقة المؤسسات', 'price': '499 ريال/شهر'},
        ],
        'features': [
          {'name': 'عدد المشاريع', 'values': ['1', '10', 'غير محدود']},
          {'name': 'مساحة تخزين', 'values': ['1GB', '50GB', '500GB']},
          {'name': 'دعم فني', 'values': ['بريد إلكتروني', 'دردشة مباشرة', 'مدير حساب']},
          {'name': 'قوالب مخصصة', 'values': [false, true, true]},
        ],
      },
    ],
  };
}
