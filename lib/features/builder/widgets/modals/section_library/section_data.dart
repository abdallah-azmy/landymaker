part of '../section_library_modal.dart';

final Map<String, String> _categories = {
  'all': 'الكل',
  'popular': 'شائع ومهم',
  'basic': 'أساسي',
  'conversion': 'مبيعات',
  'trust': 'ثقة',
  'content': 'محتوى',
  'ecommerce': 'تجارة',
  'contact': 'تواصل',
};

final List<_SectionDefinition> _sections = [
  _section(
    type: 'logo_header',
    name: 'هيدر الشعار',
    icon: Icons.title_rounded,
    category: 'basic',
    desc: 'شعار أو اسم العلامة أعلى الصفحة.',
    aiRole: 'brand_identity',
    aiWhenToUse:
        'Use as the first block when the prompt mentions a brand, store, clinic, agency, or formal company header.',
    variants: [
      _variant('وسط الصفحة', 'شعار centered بسيط', 'centered', {
        'layout_style': 'centered',
        'alignment': 'center',
        'logo_height': 48.0,
      }),
      _variant('يمين/بداية', 'مناسب للعلامات الرسمية', 'split', {
        'layout_style': 'edge_aligned',
        'alignment': 'right',
        'logo_height': 42.0,
      }),
      _variant('هيدر داكن', 'شريط واضح أعلى الصفحة', 'dark', {
        'layout_style': 'dark_bar',
        'alignment': 'center',
        'logo_height': 52.0,
        'bg_overlay_color': '#0F172A',
        'bg_overlay_opacity': 1.0,
      }),
    ],
  ),
  _section(
    type: 'hero',
    name: 'القسم الرئيسي (Hero)',
    icon: Icons.auto_awesome_rounded,
    category: 'basic',
    desc: 'واجهة الموقع مع عنوان وزر جذاب.',
    popular: true,
    aiRole: 'primary_offer',
    aiWhenToUse:
        'Use once near the top to express the core offer, audience, CTA, and primary image.',
    variants: [
      _variant('نص وصورة', 'العرض التقليدي الأكثر وضوحاً', 'split', {
        'layout_style': 'split',
        'vertical_padding': 88.0,
      }),
      _variant('Hero كثيف', 'مناسب للحملات الإعلانية', 'centered', {
        'layout_style': 'centered',
        'vertical_padding': 48.0,
        'bg_overlay_color': '#111827',
        'bg_overlay_opacity': 0.08,
      }),
      _variant('خلفية قوية', 'صورة كاملة مع طبقة داكنة', 'immersive', {
        'layout_style': 'fullWidthBg',
        'vertical_padding': 108.0,
        'bg_image_url':
            'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
        'bg_overlay_color': '#020617',
        'bg_overlay_opacity': 0.62,
      }),
      _variant('تدرج لوني', 'خلفية متدرجة بدون صورة', 'gradientOnly', {
        'layout_style': 'gradientOnly',
        'vertical_padding': 48.0,
      }),
      _variant('خلفية صورة كاملة', 'صورة خلفية كاملة مع طبقة تعتيم', 'fullWidthImage', {
        'layout_style': 'fullWidthImage',
        'vertical_padding': 48.0,
      }),
    ],
  ),
  _section(
    type: 'basic_section',
    name: 'قسم مرن متقدم',
    icon: Icons.view_quilt_rounded,
    category: 'basic',
    desc: 'صمم أي شكل بحرية كاملة.',
    popular: true,
    aiRole: 'custom_layout',
    aiWhenToUse:
        'Use when the user asks for a unique composition that does not map cleanly to a specialized section.',
    variants: [
      _variant('عمودي', 'نصوص وعناصر تحت بعض', 'stack', {
        'layout_style': 'vertical_stack',
        'layout_direction': 'column',
        'spacing': 20.0,
        'vertical_padding': 64.0,
      }),
      _variant('صفّي', 'مناسب لمقارنة أو عرض سريع', 'split', {
        'layout_style': 'horizontal_split',
        'layout_direction': 'row',
        'spacing': 28.0,
        'vertical_padding': 56.0,
      }),
    ],
  ),
  _section(
    type: 'hero_saas',
    name: 'بطل تطبيقات (SaaS)',
    icon: Icons.dashboard_customize_rounded,
    category: 'basic',
    desc: 'قسم رئيسي مثالي للبرمجيات والتطبيقات.',
    aiRole: 'saas_hero',
    aiWhenToUse:
        'Use for software, dashboards, apps, subscriptions, and B2B technology offers.',
    variants: [
      _variant('Dashboard', 'لقطة منتج مع CTA', 'split', {
        'vertical_padding': 86.0,
      }),
      _variant('Launch', 'عرض إطلاق منتج سريع', 'centered', {
        'layout_style': 'launchCenter',
        'vertical_padding': 68.0,
        'bg_overlay_color': '#EEF2FF',
        'bg_overlay_opacity': 1.0,
      }),
      _variant('Dark SaaS', 'نمط تقني داكن', 'dark', {
        'layout_style': 'darkSaas',
        'vertical_padding': 96.0,
        'bg_overlay_color': '#030712',
        'bg_overlay_opacity': 1.0,
      }),
    ],
  ),
  _section(
    type: 'trust_logos',
    name: 'شركاء النجاح',
    icon: Icons.verified_user_rounded,
    category: 'trust',
    desc: 'عرض شعارات الشركات لزيادة الثقة.',
    popular: true,
    aiRole: 'social_proof',
    aiWhenToUse:
        'Use after the hero when the prompt mentions clients, partners, certifications, press, or credibility.',
    variants: [
      _variant('شريط شعارات', 'صف أفقي بسيط', 'logos', {
        'layout_style': 'logo_strip',
      }),
      _variant('ثقة داكنة', 'خلفية داكنة للشركات', 'dark', {
        'layout_style': 'dark_trust',
        'bg_overlay_color': '#111827',
        'bg_overlay_opacity': 1.0,
      }),
    ],
  ),
  _section(
    type: 'animated_counter',
    name: 'عداد أرقام',
    icon: Icons.onetwothree_rounded,
    category: 'conversion',
    desc: 'عداد متحرك للإحصائيات.',
    aiRole: 'proof_metrics',
    aiWhenToUse:
        'Use for measurable claims such as customers, years, projects, savings, success rates, or capacity.',
    variants: [
      _variant('٣ مؤشرات', 'أرقام ثقة مختصرة', 'metrics', {
        'layout_style': 'three_metrics',
      }),
      _variant('Impact', 'أربعة مؤشرات للحملات', 'metrics4', {
        'layout_style': 'impact_grid',
        'items': [
          {'value': '500', 'label': 'عميل', 'prefix': '+', 'suffix': ''},
          {'value': '98', 'label': 'رضا', 'prefix': '', 'suffix': '%'},
          {'value': '24', 'label': 'دعم', 'prefix': '', 'suffix': '/7'},
          {'value': '12', 'label': 'سنة خبرة', 'prefix': '+', 'suffix': ''},
        ],
      }),
    ],
  ),
  _section(
    type: 'multi_step_lead_form',
    name: 'نموذج متعدد الخطوات',
    icon: Icons.dynamic_form_rounded,
    category: 'conversion',
    desc: 'جمع بيانات العملاء باحترافية على مراحل.',
    popular: true,
    aiRole: 'qualified_lead_capture',
    aiWhenToUse:
        'Use for quotes, bookings, eligibility checks, real estate inquiries, medical appointments, or complex lead qualification.',
    variants: [
      _variant('طلب تسعير', 'خطوات لتأهيل العميل', 'form_steps', {
        'layout_style': 'quote_wizard',
        'title': 'طلب تسعير سريع',
      }),
      _variant('حجز موعد', 'مناسب للعيادات والخدمات', 'form_steps', {
        'layout_style': 'appointment_wizard',
        'title': 'احجز موعدك',
        'subtitle': 'أجب على الأسئلة وسنؤكد الموعد معك',
      }),
    ],
  ),
  _section(
    type: 'lead_form',
    name: 'نموذج تواصل سريع',
    icon: Icons.mark_email_read_rounded,
    category: 'conversion',
    desc: 'نموذج مباشر لجمع بيانات التواصل.',
    popular: true,
    aiRole: 'simple_lead_capture',
    aiWhenToUse:
        'Use when the user needs a short contact, callback, demo, or newsletter form.',
    variants: [
      _variant('مركزي', 'عنوان ونموذج مباشر', 'form', {
        'layout_style': 'centered_form',
      }),
      _variant('خلفية صورة', 'نموذج واضح فوق خلفية', 'form_dark', {
        'layout_style': 'image_form',
        'bg_image_url':
            'https://cdn.pixabay.com/photo/2017/10/10/21/47/laptop-2838921_1280.jpg',
        'bg_overlay_color': '#020617',
        'bg_overlay_opacity': 0.68,
      }),
    ],
  ),
  _section(
    type: 'lead_magnet',
    name: 'التقاط العملاء',
    icon: Icons.person_add_rounded,
    category: 'conversion',
    desc: 'نموذج مغناطيس لجمع البيانات.',
    popular: true,
    aiRole: 'resource_gate',
    aiWhenToUse:
        'Use for free guides, coupons, catalogs, reports, checklists, or downloadable resources.',
    variants: [
      _variant('دليل مجاني', 'صورة + نموذج', 'split', {
        'layout_style': 'guide_download',
      }),
      _variant('كوبون', 'عرض ترويجي سريع', 'offer', {
        'layout_style': 'coupon_capture',
        'title': 'احصل على خصمك الآن',
        'subtitle': 'سجل بياناتك وسنرسل لك كود الخصم فوراً.',
      }),
    ],
  ),
  _section(
    type: 'features',
    name: 'المميزات',
    icon: Icons.list_alt_rounded,
    category: 'content',
    desc: 'عرض مميزات خدمتك أو منتجك.',
    popular: true,
    aiRole: 'benefit_explanation',
    aiWhenToUse:
        'Use to translate product/service capabilities into user benefits, usually 3 to 6 items.',
    variants: [
      _variant('شبكة', 'بطاقات متساوية وواضحة', 'grid', {
        'layout_style': 'feature_grid',
        'layout_style': 'grid',
      }),
      _variant('Bento', 'بطاقات بأحجام مختلفة', 'bento', {
        'layout_style': 'feature_bento',
        'layout_style': 'bento',
        'items': [
          {'title': 'ميزة رئيسية', 'description': 'اشرح أكبر فائدة هنا.'},
          {'title': 'ميزة داعمة', 'description': 'وضح سبب الثقة.'},
          {'title': 'سرعة', 'description': 'نتائج أسرع للمستخدم.'},
          {'title': 'سهولة', 'description': 'تجربة بسيطة من أول زيارة.'},
        ],
      }),
    ],
  ),
  _section(
    type: 'whatsapp',
    name: 'تواصل واتساب',
    icon: Icons.chat_bubble_outline_rounded,
    category: 'contact',
    desc: 'زر سريع للتواصل عبر الواتساب.',
    aiRole: 'direct_chat_cta',
    aiWhenToUse:
        'Use for MENA businesses, urgent booking, product orders, support, or when the prompt includes a WhatsApp number.',
    variants: [
      _variant('زر مباشر', 'دعوة بسيطة للمحادثة', 'cta', {
        'layout_style': 'simple_chat',
      }),
      _variant('حجز سريع', 'نص مناسب للمواعيد', 'cta_dark', {
        'layout_style': 'booking_chat',
        'title': 'احجز الآن عبر واتساب',
        'message': 'مرحباً، أريد حجز موعد مناسب.',
        'bg_overlay_color': '#064E3B',
        'bg_overlay_opacity': 1.0,
      }),
    ],
  ),
  _section(
    type: 'products',
    name: 'المنتجات',
    icon: Icons.shopping_bag_outlined,
    category: 'ecommerce',
    desc: 'عرض منتجاتك مع الأسعار وصور.',
    popular: true,
    aiRole: 'catalog',
    aiWhenToUse:
        'Use for stores, menus, packages, property units, service bundles, or any sellable item list.',
    variants: [
      _variant('شبكة ٢', 'منتجات كبيرة وواضحة', 'grid', {
        'layout_style': 'product_grid_2',
        'layout_style': 'grid_2',
      }),
      _variant('شبكة ٣', 'كاتالوج أكبر', 'grid3', {
        'layout_style': 'product_grid_3',
        'layout_style': 'grid_3',
      }),
      _variant('قائمة', 'قائمة أسعار أو منيو', 'list', {
        'layout_style': 'product_list',
        'layout_style': 'list',
        'show_category_filter': false,
      }),
      _variant('شريط متحرك', 'تصفح أفقي للمنتجات', 'gallery_carousel', {
        'layout_style': 'product_carousel',
        'layout_style': 'carousel',
      }),
    ],
  ),
  _section(
    type: 'featured_product',
    name: 'المنتج المميز',
    icon: Icons.star_border_rounded,
    category: 'ecommerce',
    desc: 'تركيز قوي على منتج واحد بطل.',
    aiRole: 'featured_offer',
    aiWhenToUse: 'Use to highlight a best-seller, a specific high-value product, or a primary offer.',
    variants: [
      _variant('Split', 'صورة يمين ونص يسار', 'split', {
        'layout_style': 'split',
      }),
      _variant('عكسي', 'نص يمين وصورة يسار', 'split', {
        'layout_style': 'reversed',
      }),
      _variant('مركزي', 'صورة كبيرة وعنوان بالوسط', 'centered', {
        'layout_style': 'centered',
      }),
    ],
  ),
  _section(
    type: 'bento_store',
    name: 'متجر بينتو',
    icon: Icons.grid_view_rounded,
    category: 'ecommerce',
    desc: 'شبكة منتجات بأسلوب عصري غير منتظم.',
    aiRole: 'modern_catalog',
    aiWhenToUse: 'Use for visual brands that want a magazine-style product display.',
    variants: [
      _variant('بينتو عصري', 'تخطيط متباعد وأنيق', 'bento', {
        'layout_style': 'modern',
      }),
      _variant('متلاصق', 'تصميم مضغوط وجذاب', 'grid', {
        'layout_style': 'tight',
      }),
    ],
  ),
  _section(
    type: 'pricing',
    name: 'خطط الأسعار',
    icon: Icons.payments_rounded,
    category: 'ecommerce',
    desc: 'جداول الأسعار والاشتراكات.',
    aiRole: 'price_comparison',
    aiWhenToUse:
        'Use for subscription tiers, service packages, course plans, memberships, and clear price comparison.',
    variants: [
      _variant('شهري/سنوي', 'خطط اشتراك قابلة للمقارنة', 'pricing', {
        'layout_style': 'toggle_pricing',
        'layout_style': 'cards',
        'has_toggle': true,
      }),
      _variant('باقات ثابتة', 'خدمات أو أسعار مباشرة', 'pricing_cards', {
        'layout_style': 'fixed_packages',
        'layout_style': 'cards',
        'has_toggle': false,
        'items': [
          {
            'name': 'الباقة الأساسية',
            'price': '499 EGP',
            'features': ['ميزة 1', 'ميزة 2'],
            'button_text': 'اطلب الآن',
            'is_popular': false,
          },
          {
            'name': 'الباقة المتقدمة',
            'price': '999 EGP',
            'features': ['كل الأساسيات', 'دعم أسرع', 'إعداد مخصص'],
            'button_text': 'ابدأ',
            'is_popular': true,
          },
        ],
      }),
      _variant('جدول أسعار', 'مقارنة أفقية بسيطة', 'table', {
        'layout_style': 'table',
        'has_toggle': false,
        'items': [
          {
            'name': 'الباقة الأساسية',
            'price': '499 EGP',
            'features': ['ميزة 1', 'ميزة 2'],
            'button_text': 'اطلب الآن',
            'is_popular': false,
          },
          {
            'name': 'الباقة المتقدمة',
            'price': '999 EGP',
            'features': ['كل الأساسيات', 'دعم أسرع'],
            'button_text': 'ابدأ',
            'is_popular': true,
          },
        ],
      }),
    ],
  ),
  _section(
    type: 'faq',
    name: 'الأسئلة الشائعة',
    icon: Icons.question_answer_rounded,
    category: 'content',
    desc: 'إجابات على استفسارات العملاء.',
    aiRole: 'objection_handling',
    aiWhenToUse:
        'Use near the end to answer objections about pricing, delivery, refunds, booking, eligibility, or support.',
    variants: [
      _variant('مختصر', '٣ أسئلة أساسية', 'accordion', {
        'layout_style': 'short_faq',
      }),
      _variant('اعتراضات البيع', 'أسئلة تحويل وطمأنة', 'accordion_dense', {
        'layout_style': 'conversion_faq',
        'items': [
          {'question': 'هل يمكن التجربة أولاً؟', 'answer': 'نعم، تواصل معنا وسنرشدك للخطوة المناسبة.'},
          {'question': 'ما مدة التنفيذ؟', 'answer': 'تعتمد على التفاصيل، لكن نبدأ عادة خلال وقت قصير.'},
          {'question': 'هل يوجد دعم بعد الشراء؟', 'answer': 'نعم، نوفر متابعة ودعم حسب الباقة.'},
        ],
      }),
    ],
  ),
  _section(
    type: 'testimonials',
    name: 'آراء العملاء',
    icon: Icons.reviews_rounded,
    category: 'content',
    desc: 'عرض تجارب عملائك الإيجابية.',
    aiRole: 'testimonial_proof',
    aiWhenToUse:
        'Use when the user mentions reviews, clients, success stories, outcomes, or trust-building.',
    variants: [
      _variant('بطاقات', 'آراء مختصرة', 'quotes', {
        'layout_style': 'testimonial_cards',
        'layout_style': 'masonry',
      }),
      _variant('قصص نجاح', 'نصوص أطول ونتائج', 'quotes_dense', {
        'layout_style': 'success_stories',
        'layout_style': 'masonry',
        'items': [
          {'author': 'عميل سعيد', 'role': 'صاحب مشروع', 'quote': 'التجربة كانت واضحة وساعدتنا نزيد الطلبات بسرعة.'},
          {'author': 'مدير تسويق', 'role': 'شركة خدمات', 'quote': 'الصفحة شرحت العرض بشكل بسيط ورفعت جودة العملاء المحتملين.'},
        ],
      }),
      _variant('كاروسيل', 'شريط أفقي متحرك', 'carousel', {
        'layout_style': 'carousel',
        'items': [
          {'author': 'عميل سعيد', 'role': 'صاحب مشروع', 'quote': 'التجربة كانت واضحة وساعدتنا نزيد الطلبات بسرعة.'},
          {'author': 'مدير تسويق', 'role': 'شركة خدمات', 'quote': 'الصفحة شرحت العرض بشكل بسيط ورفعت جودة العملاء المحتملين.'},
        ],
      }),
    ],
  ),
  _section(
    type: 'contact_info',
    name: 'معلومات الاتصال',
    icon: Icons.contact_mail_rounded,
    category: 'contact',
    desc: 'العنوان، الهاتف، والبريد.',
    aiRole: 'contact_details',
    aiWhenToUse:
        'Use for physical businesses, service providers, clinics, offices, and pages that need final contact clarity.',
    variants: [
      _variant('ثلاث بطاقات', 'هاتف وبريد وموقع', 'contact_cards', {
        'layout_style': 'contact_cards',
      }),
      _variant('داكن', 'ختام واضح للصفحة', 'dark', {
        'layout_style': 'dark_contact',
        'bg_overlay_color': '#0F172A',
        'bg_overlay_opacity': 1.0,
      }),
    ],
  ),
  _section(
    type: 'working_hours',
    name: 'مواعيد العمل',
    icon: Icons.schedule_rounded,
    category: 'contact',
    desc: 'أيام وساعات العمل الرسمية.',
    aiRole: 'availability',
    aiWhenToUse:
        'Use for restaurants, clinics, salons, stores, gyms, events, and appointment-based businesses.',
    variants: [
      _variant('أسبوعي', 'مواعيد مختصرة', 'schedule', {
        'layout_style': 'weekly_hours',
      }),
      _variant('عيادة/حجز', 'مواعيد محددة للخدمات', 'schedule_split', {
        'layout_style': 'appointment_hours',
        'schedule': {
          'الأحد - الخميس': '5:00 PM - 10:00 PM',
          'الجمعة': 'مغلق',
        },
      }),
    ],
  ),
  _section(
    type: 'location_map',
    name: 'خريطة الموقع',
    icon: Icons.location_on_rounded,
    category: 'contact',
    desc: 'عرض عنوان النشاط على الخريطة.',
    aiRole: 'physical_location',
    aiWhenToUse:
        'Use when the prompt includes an address, branch, venue, showroom, clinic, restaurant, or event location.',
    variants: [
      _variant('خريطة كاملة', 'عنوان مع خريطة كبيرة', 'map', {
        'layout_style': 'full_map',
      }),
      _variant('فرع رئيسي', 'عنوان واضح قبل الخريطة', 'map_pin', {
        'layout_style': 'branch_map',
        'title': 'زورونا في الفرع الرئيسي',
      }),
    ],
  ),
  _section(
    type: 'video_embed',
    name: 'فيديو (Video)',
    icon: Icons.video_library_rounded,
    category: 'basic',
    desc: 'تضمين فيديو يوتيوب أو فيميو.',
    aiRole: 'video_explainer',
    aiWhenToUse:
        'Use for demos, trailers, course previews, property tours, testimonials, and product explainers.',
    variants: [
      _variant('شرح 16:9', 'فيديو تعريفي عريض', 'video', {
        'layout_style': 'wide_video',
        'aspect_ratio': '16:9',
        'max_width': 900,
      }),
      _variant('فيديو مركز', 'عرض أقصر وأكثر تركيزاً', 'video_compact', {
        'layout_style': 'compact_video',
        'aspect_ratio': '4:3',
        'max_width': 720,
      }),
    ],
  ),
  _section(
    type: 'gallery',
    name: 'معرض الصور',
    icon: Icons.collections_rounded,
    category: 'content',
    desc: 'مجموعة صور لمنتجاتك أو عملك.',
    aiRole: 'visual_showcase',
    aiWhenToUse:
        'Use for portfolios, properties, menus, salon results, event photos, venues, and product detail visuals.',
    variants: [
      _variant('شبكة', '٣ أعمدة للصور', 'gallery_grid', {
        'layout_style': 'gallery_grid',
        'display_mode': 'grid',
        'grid_columns': 3,
      }),
      _variant('Carousel', 'صورة كبيرة قابلة للتنقل', 'gallery_carousel', {
        'layout_style': 'gallery_carousel',
        'display_mode': 'carousel',
      }),
    ],
  ),
  _section(
    type: 'qr_code',
    name: 'QR كود',
    icon: Icons.qr_code_2_rounded,
    category: 'basic',
    desc: 'كود سريع لزيارة الرابط.',
    aiRole: 'offline_to_online',
    aiWhenToUse:
        'Use for events, menus, flyers, storefronts, check-in, registration, and shareable offline access.',
    variants: [
      _variant('قياسي', 'كود واضح للمشاركة', 'qr', {
        'layout_style': 'standard_qr',
        'qr_size': 200.0,
      }),
      _variant('كبير', 'للطباعة أو الفعاليات', 'qr_big', {
        'layout_style': 'large_qr',
        'qr_size': 260.0,
        'bg_overlay_color': '#F8FAFC',
        'bg_overlay_opacity': 1.0,
      }),
    ],
  ),
  _section(
    type: 'social_qr',
    name: 'روابط التواصل',
    icon: Icons.share_rounded,
    category: 'contact',
    desc: 'أيقونات التواصل الاجتماعي.',
    aiRole: 'social_channels',
    aiWhenToUse:
        'Use when the prompt mentions Instagram, TikTok, LinkedIn, Facebook, social follow, or creator profiles.',
    variants: [
      _variant('روابط اجتماعية', 'أيقونات + QR', 'social', {
        'layout_style': 'social_links',
      }),
      _variant('Creator', 'للمؤثرين والحسابات الشخصية', 'social_creator', {
        'layout_style': 'creator_social',
        'title': 'تابعني على المنصات',
        'links': [
          {'platform': 'instagram', 'url': 'https://instagram.com'},
          {'platform': 'tiktok', 'url': 'https://tiktok.com'},
          {'platform': 'youtube', 'url': 'https://youtube.com'},
        ],
      }),
    ],
  ),
  _section(
    type: 'statistics_grid',
    name: 'إحصائيات احترافية',
    icon: Icons.analytics_rounded,
    category: 'trust',
    desc: 'عرض أرقام النجاح بشكل عصري.',
    popular: true,
    aiRole: 'proof_metrics',
    aiWhenToUse: 'Use to showcase company growth, satisfied customers, or project impact.',
    variants: [
      _variant('شبكة 2x2', 'عرض ٤ إحصائيات ببطاقات', 'grid', {
        'layout_style': 'horizontal',
        'items': [
          {'value': '500+', 'label': 'عميل سعيد', 'icon': 'people'},
          {'value': '12', 'label': 'سنة خبرة', 'icon': 'star'},
          {'value': '24/7', 'label': 'دعم فني', 'icon': 'speed'},
          {'value': '100%', 'label': 'جودة مضمونة', 'icon': 'check'},
        ],
      }),
      _variant('مع أيقونات', 'دوائر ملونة مع أيقونات', 'icons', {
        'layout_style': 'withIcons',
        'items': [
          {'value': '500+', 'label': 'عميل سعيد', 'icon': 'people'},
          {'value': '12', 'label': 'سنة خبرة', 'icon': 'star'},
          {'value': '24/7', 'label': 'دعم فني', 'icon': 'speed'},
          {'value': '100%', 'label': 'جودة مضمونة', 'icon': 'check'},
        ],
      }),
    ],
  ),
  _section(
    type: 'team_members',
    name: 'فريق العمل',
    icon: Icons.groups_rounded,
    category: 'trust',
    desc: 'عرض الأشخاص المبدعين خلف المشروع.',
    aiRole: 'team_showcase',
    aiWhenToUse: 'Use for about us pages or to humanize the brand/business.',
    variants: [
      _variant('بطاقات الفريق', 'صور وأسماء الفريق', 'grid', {
        'items': [
          {'name': 'الاسم الكامل', 'role': 'المسمى الوظيفي', 'image_url': 'https://cdn.pixabay.com/photo/2016/11/21/14/53/man-1845814_1280.jpg'},
          {'name': 'الاسم الكامل', 'role': 'المسمى الوظيفي', 'image_url': 'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg'},
        ],
      }),
    ],
  ),
  _section(
    type: 'service_steps',
    name: 'خطوات العمل',
    icon: Icons.account_tree_rounded,
    category: 'content',
    desc: 'شرح مراحل تقديم الخدمة أو الاستخدام.',
    popular: true,
    aiRole: 'process_explainer',
    aiWhenToUse: 'Use to simplify complex services into easy steps (1, 2, 3).',
    variants: [
      _variant('مسار أفقي', 'خطوات مرقمة متصلة', 'split', {
        'items': [
          {'title': 'الخطوة الأولى', 'description': 'اشرح ماذا يحدث هنا.'},
          {'title': 'الخطوة الثانية', 'description': 'انتقل للمرحلة التالية.'},
          {'title': 'الخطوة الثالثة', 'description': 'النتيجة النهائية.'},
        ],
      }),
    ],
  ),
  _section(
    type: 'cta_banner',
    name: 'بانر تحويلي (CTA)',
    icon: Icons.ads_click_rounded,
    category: 'conversion',
    desc: 'بانر ملون وقوي لجذب الانتباه.',
    popular: true,
    aiRole: 'final_conversion',
    aiWhenToUse: 'Use at the end of the page or between sections to drive immediate action.',
    variants: [
      _variant('بانر ملون', 'تدرج لوني مع زر كبير', 'immersive', {
        'layout_style': 'centeredGradient',
        'title': 'هل أنت جاهز للبدء؟',
        'subtitle': 'انضم إلينا اليوم واحصل على عرض خاص.',
        'button_text': 'سجل الآن',
      }),
      _variant('نص + أزرار', 'نص على اليسار وأزرار على اليمين', 'split', {
        'layout_style': 'split',
        'title': 'هل أنت جاهز للبدء؟',
        'subtitle': 'انضم إلينا اليوم واحصل على عرض خاص.',
        'button_text': 'سجل الآن',
      }),
    ],
  ),
  _section(
    type: 'comparison_table',
    name: 'جدول مقارنة',
    icon: Icons.compare_arrows_rounded,
    category: 'ecommerce',
    desc: 'مقارنة دقيقة بين المميزات والخطط.',
    aiRole: 'feature_comparison',
    aiWhenToUse: 'Use to highlight differences between service tiers or product models.',
    variants: [
      _variant('جدول الميزات', 'مقارنة عمودية احترافية', 'list', {
        'plans': [
          {'name': 'الأساسية', 'price': 'مجاني'},
          {'name': 'الاحترافية', 'price': '99\$'},
        ],
        'features': [
          {'name': 'الميزة الأولى', 'values': [true, true]},
          {'name': 'الميزة الثانية', 'values': [false, true]},
          {'name': 'الدعم الفني', 'values': ['بريد', 'هاتف']},
        ],
      }),
    ],
  ),
];


