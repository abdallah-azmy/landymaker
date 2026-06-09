import 'package:uuid/uuid.dart';
import '../models/landing_page_theme.dart';

class TemplateMetadata {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> recommendedSections;
  final String aiPromptHint;

  const TemplateMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.category = 'general',
    this.recommendedSections = const [],
    this.aiPromptHint = '',
  });
}

class TemplateRegistry {
  static const List<TemplateMetadata> availableTemplates = [
    TemplateMetadata(
      id: 'empty',
      name: 'Empty Page',
      description: 'Start from scratch with a blank canvas.',
      imageUrl:
          'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=400',
      category: 'general',
      recommendedSections: ['hero', 'features', 'lead_form'],
      aiPromptHint:
          'Use when the user explicitly wants a blank page or a fully custom layout.',
    ),
    TemplateMetadata(
      id: 'barber_shop',
      name: 'Barber Shop',
      description: 'Classic barber shop layout with pricing and hours.',
      imageUrl:
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      category: 'local_services',
      recommendedSections: ['hero', 'working_hours', 'pricing', 'whatsapp'],
      aiPromptHint:
          'Use for barbers, grooming studios, appointment services, and local walk-in businesses.',
    ),
    TemplateMetadata(
      id: 'store',
      name: 'Modern Store',
      description: 'E-commerce focused layout for product showcasing.',
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
      category: 'ecommerce',
      recommendedSections: ['hero', 'products', 'features', 'faq', 'whatsapp'],
      aiPromptHint:
          'Use for product catalogs, online stores, dropshipping pages, and WhatsApp commerce.',
    ),
    TemplateMetadata(
      id: 'personal',
      name: 'Personal Brand',
      description: 'Showcase your skills and social presence.',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      category: 'creator',
      recommendedSections: ['hero', 'features', 'gallery', 'social_qr'],
      aiPromptHint:
          'Use for portfolios, creators, coaches, freelancers, and personal authority pages.',
    ),
    TemplateMetadata(
      id: 'professional',
      name: 'Professional Consulting',
      description: 'Clean lead generation for services and consulting.',
      imageUrl:
          'https://images.unsplash.com/photo-1454165833767-027ffea9e77b?w=400',
      category: 'professional_services',
      recommendedSections: [
        'hero',
        'features',
        'animated_counter',
        'testimonials',
        'lead_form',
      ],
      aiPromptHint:
          'Use for consultants, agencies, legal, accounting, and B2B service providers.',
    ),
    TemplateMetadata(
      id: 'real_estate',
      name: 'Real Estate',
      description: 'Showcase properties with high-quality visuals.',
      imageUrl:
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400',
      category: 'real_estate',
      recommendedSections: [
        'logo_header',
        'hero',
        'features',
        'gallery',
        'multi_step_lead_form',
        'contact_info',
      ],
      aiPromptHint:
          'Use for compounds, single properties, brokers, property launches, and unit reservation pages.',
    ),
    TemplateMetadata(
      id: 'digital_course',
      name: 'Digital Course',
      description: 'Sell courses with pricing tables and FAQs.',
      imageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
      category: 'education',
      recommendedSections: [
        'hero',
        'video_embed',
        'features',
        'pricing',
        'faq',
        'lead_form',
      ],
      aiPromptHint:
          'Use for online courses, workshops, bootcamps, webinars, and education lead generation.',
    ),
    TemplateMetadata(
      id: 'event',
      name: 'Event Landing',
      description: 'Promote events with maps and QR codes.',
      imageUrl:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
      category: 'events',
      recommendedSections: [
        'hero',
        'animated_counter',
        'qr_code',
        'location_map',
        'faq',
      ],
      aiPromptHint:
          'Use for conferences, workshops, concerts, launches, seminars, and ticketed events.',
    ),
    TemplateMetadata(
      id: 'restaurant',
      name: 'Restaurant & Cafe',
      description:
          'Menu-first landing page for restaurants, cafes, and food delivery.',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      category: 'food',
      recommendedSections: [
        'logo_header',
        'hero',
        'products',
        'gallery',
        'working_hours',
        'location_map',
        'whatsapp',
      ],
      aiPromptHint:
          'Use for restaurants, cafes, cloud kitchens, bakeries, menus, reservations, and delivery via WhatsApp.',
    ),
    TemplateMetadata(
      id: 'clinic',
      name: 'Clinic & Medical',
      description:
          'Trust-focused healthcare page with appointments and location.',
      imageUrl:
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=400',
      category: 'healthcare',
      recommendedSections: [
        'hero',
        'features',
        'animated_counter',
        'testimonials',
        'multi_step_lead_form',
        'working_hours',
        'location_map',
      ],
      aiPromptHint:
          'Use for clinics, doctors, dentists, therapy centers, labs, and healthcare appointment funnels.',
    ),
    TemplateMetadata(
      id: 'beauty_salon',
      name: 'Beauty Salon',
      description: 'Visual booking page for salons, spas, and beauty services.',
      imageUrl:
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      category: 'beauty',
      recommendedSections: [
        'hero',
        'gallery',
        'pricing',
        'testimonials',
        'working_hours',
        'whatsapp',
      ],
      aiPromptHint:
          'Use for beauty salons, spas, makeup artists, skincare clinics, and appointment-driven visual services.',
    ),
    TemplateMetadata(
      id: 'gym_fitness',
      name: 'Gym & Fitness',
      description: 'High-energy landing page for memberships and programs.',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      category: 'fitness',
      recommendedSections: [
        'hero',
        'features',
        'pricing',
        'animated_counter',
        'testimonials',
        'lead_form',
      ],
      aiPromptHint:
          'Use for gyms, personal trainers, fitness challenges, yoga studios, and membership campaigns.',
    ),
    TemplateMetadata(
      id: 'mobile_app_saas',
      name: 'Mobile App / SaaS',
      description: 'Modern product launch page for apps and software.',
      imageUrl:
          'https://images.unsplash.com/photo-1551650975-87deedd944c3?w=400',
      category: 'technology',
      recommendedSections: [
        'hero_saas',
        'trust_logos',
        'features',
        'video_embed',
        'pricing',
        'faq',
        'lead_form',
      ],
      aiPromptHint:
          'Use for SaaS, mobile apps, dashboards, waitlists, software subscriptions, and B2B tools.',
    ),
    TemplateMetadata(
      id: 'creative_agency',
      name: 'Creative Agency',
      description: 'Portfolio and lead-generation page for creative teams.',
      imageUrl:
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=400',
      category: 'agency',
      recommendedSections: [
        'hero',
        'features',
        'gallery',
        'animated_counter',
        'testimonials',
        'lead_form',
      ],
      aiPromptHint:
          'Use for marketing agencies, studios, designers, production houses, and portfolio-led services.',
    ),
    TemplateMetadata(
      id: 'nonprofit_campaign',
      name: 'Nonprofit Campaign',
      description:
          'Mission-led campaign page with impact proof and contact CTA.',
      imageUrl:
          'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=400',
      category: 'nonprofit',
      recommendedSections: [
        'hero',
        'animated_counter',
        'features',
        'gallery',
        'lead_form',
        'faq',
      ],
      aiPromptHint:
          'Use for charities, donation campaigns, volunteering, social impact projects, and community initiatives.',
    ),
    TemplateMetadata(
      id: 'book_launch',
      name: 'Book / Digital Product',
      description: 'Launch page for books, ebooks, guides, and paid downloads.',
      imageUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
      category: 'digital_product',
      recommendedSections: [
        'hero',
        'lead_magnet',
        'features',
        'testimonials',
        'pricing',
        'faq',
      ],
      aiPromptHint:
          'Use for books, ebooks, reports, templates, guides, paid PDFs, and creator digital products.',
    ),
    TemplateMetadata(
      id: 'solar_energy',
      name: 'Solar Energy',
      description: 'Clean, sustainable energy solutions for homes and businesses.',
      imageUrl: 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=600&q=80',
      category: 'industrial',
      recommendedSections: ['hero', 'statistics_grid', 'service_steps', 'lead_form'],
      aiPromptHint: 'Use for solar panels, green energy, sustainability, and engineering services.',
    ),
    TemplateMetadata(
      id: 'luxury_resort',
      name: 'Luxury Resort',
      description: 'Elegant showcase for hotels, villas, and high-end tourism.',
      imageUrl: 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=600&q=80',
      category: 'travel',
      recommendedSections: ['hero', 'gallery', 'team_members', 'cta_banner'],
      aiPromptHint: 'Use for luxury hotels, private villas, boutique resorts, and premium hospitality.',
    ),
    TemplateMetadata(
      id: 'fintech_crypto',
      name: 'Fintech / Crypto',
      description: 'Modern, dark-themed page for digital finance and blockchain.',
      imageUrl: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=600&q=80',
      category: 'technology',
      recommendedSections: ['hero_saas', 'trust_logos', 'comparison_table', 'cta_banner'],
      aiPromptHint: 'Use for crypto wallets, trading platforms, neobanks, and blockchain startups.',
    ),
    TemplateMetadata(
      id: 'architecture',
      name: 'Architecture & Design',
      description: 'Minimalist and grid-focused layout for studios and designers.',
      imageUrl: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=600&q=80',
      category: 'creative',
      recommendedSections: ['hero', 'gallery', 'service_steps', 'team_members'],
      aiPromptHint: 'Use for architecture firms, interior designers, urban planners, and studios.',
    ),
    TemplateMetadata(
      id: 'fashion_store',
      name: 'Fashion Store',
      description: 'Editorial-style e-commerce layout for apparel and beauty.',
      imageUrl: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e12?w=600&q=80',
      category: 'ecommerce',
      recommendedSections: ['hero', 'products', 'gallery', 'testimonials', 'cta_banner'],
      aiPromptHint: 'Use for clothing brands, fashion boutiques, accessories, and trendy apparel.',
    ),
  ];

  /// Get initial design JSON for a template type
  static Map<String, dynamic> getTemplateDesign(String templateType) {
    switch (templateType) {
      case 'barber_shop':
        return _getBarberShopTemplate();
      case 'store':
        return _getStoreTemplate();
      case 'personal':
        return _getPersonalTemplate();
      case 'professional':
        return _getProfessionalTemplate();
      case 'real_estate':
        return _getRealEstateTemplate();
      case 'digital_course':
        return _getDigitalCourseTemplate();
      case 'event':
        return _getEventTemplate();
      case 'restaurant':
        return _getRestaurantTemplate();
      case 'clinic':
        return _getClinicTemplate();
      case 'beauty_salon':
        return _getBeautySalonTemplate();
      case 'gym_fitness':
        return _getGymFitnessTemplate();
      case 'mobile_app_saas':
        return _getMobileAppSaasTemplate();
      case 'creative_agency':
        return _getCreativeAgencyTemplate();
      case 'nonprofit_campaign':
        return _getNonprofitCampaignTemplate();
      case 'book_launch':
        return _getBookLaunchTemplate();
      case 'solar_energy':
        return _getSolarEnergyTemplate();
      case 'luxury_resort':
        return _getLuxuryResortTemplate();
      case 'fintech_crypto':
        return _getFintechCryptoTemplate();
      case 'architecture':
        return _getArchitectureTemplate();
      case 'fashion_store':
        return _getFashionStoreTemplate();
      default:
        return {'blocks': []};
    }
  }

  /// Get recommended theme palette for a template
  static LandingPageTheme getTemplateTheme(String templateType) {
    switch (templateType) {
      case 'barber_shop':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Midnight Ocean',
        );
      case 'store':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Lux-Earth',
        );
      case 'personal':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Butter & Sky',
        );
      case 'professional':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Midnight Ocean',
        );
      case 'real_estate':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Royal Gold',
        );
      case 'digital_course':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Deep Forest',
        );
      case 'event':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Stadium Neon',
        );
      case 'restaurant':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Fresh Mint',
        );
      case 'clinic':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Minimal Slate',
        );
      case 'beauty_salon':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Coral Dream',
        );
      case 'gym_fitness':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Cyber Slate',
        );
      case 'mobile_app_saas':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Tech Indigo',
        );
      case 'creative_agency':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Butter & Sky',
        );
      case 'nonprofit_campaign':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Deep Forest',
        );
      case 'book_launch':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Royal Gold',
        );
      case 'solar_energy':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Deep Forest',
        );
      case 'luxury_resort':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Lux-Earth',
        );
      case 'fintech_crypto':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Cyber Slate',
        );
      case 'architecture':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Minimal Slate',
        );
      case 'fashion_store':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Coral Dream',
        );
      default:
        return LandingPageTheme.palettes.last; // Default Dark with Cairo
    }
  }

  static Map<String, dynamic> _getSolarEnergyTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'مستقبل الطاقة بين يديك',
          'subtitle': 'وفر في فواتير الكهرباء وساهم في حماية البيئة مع أنظمة الطاقة الشمسية الأكثر كفاءة.',
          'button_text': 'احصل على عرض سعر مجاني',
          'image_url': 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=1000&q=80',
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

  static Map<String, dynamic> _getLuxuryResortTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'variant': 7, // Soft Premium Gradient
          'title': 'ملاذ الفخامة والهدوء',
          'subtitle': 'استمتع بتجربة إقامة استثنائية في قلب الطبيعة الخلابة مع أرقى الخدمات العالمية.',
          'button_text': 'احجز جناحك الآن',
          'image_url': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=1000&q=80',
          'animation': {'type': 'slideInLeft', 'duration': 1000},
        },
        {
          'type': 'gallery',
          'title': 'اكتشف عالمنا',
          'display_mode': 'masonry',
          'items': [
            'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80',
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
            'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80',
          ],
        },
        {
          'type': 'team_members',
          'title': 'فريق الضيافة بانتظارك',
          'items': [
            {'name': 'مارك دو', 'role': 'مدير المنتجع', 'image_url': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&q=80'},
            {'name': 'سارة لين', 'role': 'كبير الطهاة', 'image_url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&q=80'},
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

  static Map<String, dynamic> _getFintechCryptoTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero_saas',
          'variant': 8, // Dark Contrast Card
          'title': 'إدارة أصولك الرقمية بذكاء',
          'subtitle': 'منصة آمنة، سريعة، وسهلة الاستخدام لتداول وإدارة محفظتك المالية الحديثة.',
          'button_text': 'ابدأ الآن مجانًا',
          'image_url': 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=1000&q=80',
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

  static Map<String, dynamic> _getArchitectureTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'نصمم المساحات، لنلهم الحياة',
          'subtitle': 'استوديو عمارة وتصميم داخلي يدمج بين الوظيفة والجمال لخلق بيئات فريدة.',
          'button_text': 'استشرنا في مشروعك',
          'image_url': 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=1000&q=80',
        },
        {
          'type': 'gallery',
          'title': 'من مشاريعنا الأخيرة',
          'display_mode': 'grid',
          'items': [
            'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80',
            'https://images.unsplash.com/photo-1503387762-592be5a52680?w=800&q=80',
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80',
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
            {'name': 'م. عمر كمال', 'role': 'كبير المعماريين', 'image_url': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&q=80'},
          ],
        },
      ],
    };
  }

  static Map<String, dynamic> _getFashionStoreTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'تألقي بأسلوب يعبر عنك',
          'subtitle': 'أحدث صيحات الموضة العالمية المختارة بعناية لتناسب ذوقك الرفيع.',
          'button_text': 'تسوقي المجموعة الجديدة',
          'image_url': 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e12?w=1000&q=80',
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
              'image_url': 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?w=600&q=80',
              'button_text': 'شراء الآن',
            },
            {
              'id': const Uuid().v4(),
              'name': 'حقيبة جلد طبيعي',
              'price': '1200 EGP',
              'image_url': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80',
              'button_text': 'شراء الآن',
            },
          ],
        },
        {
          'type': 'gallery',
          'title': 'على الإنستغرام',
          'items': [
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&q=80',
            'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&q=80',
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

  static Map<String, dynamic> _getBarberShopTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'أناقة وفخامة تليق بك',
          'subtitle':
              'نحن لا نقص الشعر فقط، بل نصنع الثقة والمظهر المثالي الذي تستحقه بأحدث القصات العالمية.',
          'button_text': 'احجز مقعدك الآن عبر واتساب',
          'image_url':
              'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
          'animation': {'type': 'fadeIn', 'duration': 1000},
        },
        {
          'type': 'working_hours',
          'title': 'مواعيد العمل الرسمية',
          'schedule': {
            'السبت - الخميس': '10:00 AM - 11:00 PM',
            'الجمعة': '2:00 PM - 12:00 AM',
          },
          'animation': {'type': 'slideInRight', 'duration': 800},
        },
        {
          'type': 'pricing',
          'title': 'قائمة خدماتنا وأسعارنا',
          'items': [
            {
              'name': 'قص شعر ستايل عالي الجودة',
              'price': '200 EGP',
              'features': ['غسيل شعر بشامبو طبي', 'استشوار وتصفيف سيروم'],
              'is_popular': true,
            },
            {
              'name': 'تحديد وحلاقة ذقن ملكي بالبخار',
              'price': '150 EGP',
              'features': ['فوطة ساخنة مرطبة', 'ماسك الصبار الطبيعي'],
              'is_popular': false,
            },
          ],
          'animation': {'type': 'zoomIn', 'duration': 800},
        },
        {
          'type': 'whatsapp',
          'title': 'تواصل مباشر مع الإدارة',
          'phone_number': '201000000000',
          'message': 'مرحباً، أود الاستفسار عن المواعيد المتاحة اليوم للحجز.',
          'button_text': 'تواصل معنا الآن',
        },
      ],
    };
  }

  static Map<String, dynamic> _getStoreTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'أفضل المنتجات بين يديك',
          'subtitle':
              'اكتشف مجموعتنا الحصرية من المنتجات عالية الجودة التي تناسب ذوقك الرفيع.',
          'button_text': 'تسوق الآن',
          'image_url':
              'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
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
                  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
              'button_text': 'اشترِ الآن',
            },
          ],
        },
      ],
    };
  }

  static Map<String, dynamic> _getPersonalTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'مرحباً، أنا مصمم مبدع',
          'subtitle':
              'أساعد الشركات على بناء هويات بصرية مذهلة وتجارب مستخدم فريدة.',
          'button_text': 'شاهد أعمالي',
          'image_url':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
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

  static Map<String, dynamic> _getProfessionalTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'حلول استشارية لنمو عملك',
          'subtitle':
              'نقدم استشارات مبنية على البيانات لتحقيق أهدافك التجارية.',
          'button_text': 'احجز استشارة مجانية',
          'image_url':
              'https://images.unsplash.com/photo-1454165833767-027ffea9e77b?w=800',
        },
        {
          'type': 'lead_form',
          'title': 'تواصل مع فريق الخبراء',
          'button_text': 'إرسال الطلب',
        },
      ],
    };
  }

  static Map<String, dynamic> _getRealEstateTemplate() {
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
              'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
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

  static Map<String, dynamic> _getDigitalCourseTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'Master Modern Web Development',
          'subtitle':
              'An intensive, hands-on course to take you from zero to pro in 12 weeks.',
          'button_text': 'Enroll Now',
          'image_url':
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800',
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

  static Map<String, dynamic> _getEventTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'TechFlow 2026 Conference',
          'subtitle':
              'The biggest annual gathering for developers and AI enthusiasts in the region.',
          'button_text': 'Get Your Ticket',
          'image_url':
              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
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

  static Map<String, dynamic> _getRestaurantTemplate() {
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
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
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
                  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
              'button_text': 'اطلب الآن',
            },
            {
              'id': const Uuid().v4(),
              'name': 'قهوة لاتيه مثلجة',
              'price': '95 EGP',
              'category': 'مشروبات',
              'description': 'قهوة مختصة بلمسة كريمية منعشة.',
              'image_url':
                  'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800',
              'button_text': 'أضف للطلب',
            },
          ],
        },
        {
          'type': 'gallery',
          'title': 'أجواء المكان',
          'display_mode': 'grid',
          'items': [
            'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
            'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800',
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
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

  static Map<String, dynamic> _getClinicTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'رعاية طبية موثوقة لك ولأسرتك',
          'subtitle':
              'فريق متخصص، متابعة دقيقة، وحجز مواعيد سريع بدون انتظار طويل.',
          'button_text': 'احجز موعدك',
          'image_url':
              'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=800',
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
              'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            },
            {
              'author': 'سارة ع.',
              'role': 'مريضة متابعة',
              'quote': 'التجربة كانت مريحة من الحجز حتى المتابعة.',
              'image_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
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

  static Map<String, dynamic> _getBeautySalonTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'جمالك يبدأ من تجربة مريحة',
          'subtitle': 'خدمات شعر، عناية بالبشرة، ومكياج احترافي بمواعيد مرنة.',
          'button_text': 'احجزي موعدك',
          'button_url': 'https://wa.me/201000000000',
          'image_url':
              'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
          'ai_intent': 'beauty_booking_offer',
        },
        {
          'type': 'gallery',
          'title': 'نتائج نفتخر بها',
          'display_mode': 'masonry',
          'items': [
            'https://images.unsplash.com/photo-1522337660859-02fbefca4702?w=800',
            'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
            'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=800',
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

  static Map<String, dynamic> _getGymFitnessTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'ابدأ تحولك خلال 30 يوم',
          'subtitle': 'برامج تدريب، تغذية، ومتابعة مستمرة لتصل لهدفك بثقة.',
          'button_text': 'اشترك الآن',
          'image_url':
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
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

  static Map<String, dynamic> _getMobileAppSaasTemplate() {
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
              'https://pixabay.com/get/g6e5b0e0c0f0e0d0c0b0a09080706050403020100_1280.png', // Simulation: will be imported
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

  static Map<String, dynamic> _getCreativeAgencyTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'نصمم حملات تترك أثراً',
          'subtitle': 'استراتيجية، تصميم، ومحتوى يساعد علامتك على الظهور بثقة.',
          'button_text': 'ابدأ مشروعك',
          'image_url':
              'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=800',
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
            'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=800',
            'https://images.unsplash.com/photo-1558655146-9f40138edfeb?w=800',
            'https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=800',
          ],
        },
        {
          'type': 'animated_counter',
          'title': 'أثر يمكن قياسه',
          'items': [
            {
              'value': '120',
              'label': 'مشروع مكتمل',
              'prefix': '+',
              'suffix': '',
            },
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

  static Map<String, dynamic> _getNonprofitCampaignTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'ساهم في تغيير حقيقي اليوم',
          'subtitle':
              'حملة مجتمعية لدعم الأسر الأكثر احتياجاً عبر مبادرات شفافة وقابلة للقياس.',
          'button_text': 'انضم للحملة',
          'image_url':
              'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
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
            'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800',
            'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=800',
            'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800',
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

  static Map<String, dynamic> _getBookLaunchTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'كتاب عملي لبناء عادة مربحة',
          'subtitle':
              'دليل واضح يساعدك على تحويل الأفكار إلى خطة قابلة للتنفيذ خلال 30 يوم.',
          'button_text': 'احصل على الفصل الأول',
          'image_url':
              'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800',
          'ai_intent': 'digital_product_launch',
        },
        {
          'type': 'lead_magnet',
          'title': 'حمّل الفصل الأول مجاناً',
          'subtitle': 'اترك بريدك لتحصل على نسخة تجريبية وقائمة تطبيق عملية.',
          'button_text': 'أرسل النسخة',
          'image_url':
              'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800',
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
}
