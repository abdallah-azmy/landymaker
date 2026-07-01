import '../models/landing_page_theme.dart';
import 'template_registry_saas.dart';
import 'template_registry_ecommerce.dart';
import 'template_registry_services.dart';
import 'template_registry_comprehensive.dart';

/// TemplateRegistry — Central registry for all landing page templates.
///
/// **Responsibility**: Holds the full list of available templates and provides
/// factory methods to produce initial design JSON and theme palettes by ID.
/// **Used by**: `template_picker_screen.dart`, `builder_cubit.dart`, `create_page_modal.dart`
/// **Depends on**: `LandingPageTheme`, theme-based template design functions
/// **⚠️ AI Warning**: When adding a new template, add its metadata to
/// `availableTemplates`, its design function (in the appropriate theme file),
/// and its theme mapping in `getTemplateTheme()`. The switch case in
/// `getTemplateDesign()` must also be updated.
class TemplateMetadata {
  final String id;
  final String name;
  final String description;
  final String nameAr;
  final String descriptionAr;
  final String imageUrl;
  final String category;
  final List<String> recommendedSections;
  final String aiPromptHint;

  const TemplateMetadata({
    required this.id,
    required this.name,
    required this.description,
    this.nameAr = '',
    this.descriptionAr = '',
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
      nameAr: 'صفحة فارغة',
      description: 'Start from scratch with a blank canvas.',
      descriptionAr: 'ابدأ من الصفر بلوحة بيضاء.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
      category: 'general',
      recommendedSections: ['hero', 'features', 'lead_form'],
      aiPromptHint:
          'Use when the user explicitly wants a blank page or a fully custom layout.',
    ),
    TemplateMetadata(
      id: 'saas_startup',
      name: 'SaaS Startup',
      nameAr: 'شركة ناشئة سحابية',
      description: 'Modern SaaS landing page with features, pricing, and testimonials.',
      descriptionAr: 'صفحة هبوط حديثة للشركات الناشئة مع مميزات، أسعار، وآراء العملاء.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2021/09/23/11/19/dashboard-6649784_1280.jpg',
      category: 'technology',
      recommendedSections: ['hero_saas', 'features', 'pricing', 'testimonials', 'contact_info'],
      aiPromptHint:
          'Use for software startups, SaaS products, mobile apps, tech services, and digital platforms.',
    ),
    TemplateMetadata(
      id: 'store',
      name: 'Modern Store',
      nameAr: 'متجر عصري',
      description: 'E-commerce focused layout for product showcasing.',
      descriptionAr: 'تصميم متخصص للتجارة الإلكترونية لعرض المنتجات.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2017/04/06/12/46/shopping-2153849_1280.jpg',
      category: 'ecommerce',
      recommendedSections: ['hero', 'products', 'features', 'faq', 'whatsapp'],
      aiPromptHint:
          'Use for product catalogs, online stores, dropshipping pages, and WhatsApp commerce.',
    ),
    TemplateMetadata(
      id: 'personal',
      name: 'Personal Brand',
      nameAr: 'علامة شخصية',
      description: 'Showcase your skills and social presence.',
      descriptionAr: 'اعرض مهاراتك وحضورك على وسائل التواصل الاجتماعي.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
      category: 'creator',
      recommendedSections: ['hero', 'features', 'gallery', 'social_qr'],
      aiPromptHint:
          'Use for portfolios, creators, coaches, freelancers, and personal authority pages.',
    ),
    TemplateMetadata(
      id: 'professional',
      name: 'Professional Consulting',
      nameAr: 'استشارات مهنية',
      description: 'Clean lead generation for services and consulting.',
      descriptionAr: 'صفحة نظيفة لتوليد العملاء المحتملين للخدمات والاستشارات.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2017/08/01/01/33/business-1971987_1280.jpg',
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
      nameAr: 'عقارات',
      description: 'Showcase properties with high-quality visuals.',
      descriptionAr: 'اعرض العقارات بصور عالية الجودة.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/11/29/03/53/house-1867187_1280.jpg',
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
      nameAr: 'دورة رقمية',
      description: 'Sell courses with pricing tables and FAQs.',
      descriptionAr: 'بيع الدورات مع جداول الأسعار والأسئلة الشائعة.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2018/03/22/02/37/smart-3248678_1280.png',
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
      nameAr: 'صفحة حدث',
      description: 'Promote events with maps and QR codes.',
      descriptionAr: 'روّج للفعاليات مع الخرائط ورموز QR.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2017/08/06/11/09/concert-2527495_1280.jpg',
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
      nameAr: 'مطعم ومقهى',
      description:
          'Menu-first landing page for restaurants, cafes, and food delivery.',
      descriptionAr: 'صفحة هبوط تركز على قائمة الطعام للمطاعم والمقاهي وتوصيل الطلبات.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2019/07/15/13/22/restaurant-4497194_1280.jpg',
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
      nameAr: 'عيادة ومركز طبي',
      description:
          'Trust-focused healthcare page with appointments and location.',
      descriptionAr: 'صفحة رعاية صحية موثوقة مع مواعيد وموقع.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563428_1280.jpg',
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
      nameAr: 'صالون تجميل',
      description: 'Visual booking page for salons, spas, and beauty services.',
      descriptionAr: 'صفحة حجز بصرية لصالونات التجميل والمنتجعات وخدمات العناية.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/03/23/15/00/massage-1274935_1280.jpg',
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
      nameAr: 'نادي رياضي ولياقة',
      description: 'High-energy landing page for memberships and programs.',
      descriptionAr: 'صفحة هبوط عالية الطاقة للعضوية والبرامج الرياضية.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2017/09/09/16/33/dumbbells-2465478_1280.jpg',
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
      nameAr: 'تطبيق جوال / سحابي',
      description: 'Modern product launch page for apps and software.',
      descriptionAr: 'صفحة إطلاق منتج حديثة للتطبيقات والبرمجيات.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/11/29/05/08/smartphone-1869517_1280.jpg',
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
      nameAr: 'وكالة إبداعية',
      description: 'Portfolio and lead-generation page for creative teams.',
      descriptionAr: 'صفحة محفظة أعمال وتوليد عملاء للفرق الإبداعية.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2018/10/15/12/35/designer-3703431_1280.jpg',
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
      nameAr: 'حملة غير ربحية',
      description:
          'Mission-led campaign page with impact proof and contact CTA.',
      descriptionAr: 'صفحة حملة موجهة بالرسالة مع إثبات الأثر ودعوة للعمل.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2017/04/20/08/21/hands-1838658_1280.jpg',
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
      nameAr: 'كتاب / منتج رقمي',
      description: 'Launch page for books, ebooks, guides, and paid downloads.',
      descriptionAr: 'صفحة إطلاق للكتب والكتب الإلكترونية والأدلة والتحميلات المدفوعة.',
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/03/31/19/42/books-1163695_1280.jpg',
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
      nameAr: 'طاقة شمسية',
      description: 'Clean, sustainable energy solutions for homes and businesses.',
      descriptionAr: 'حلول طاقة نظيفة ومستدامة للمنازل والشركات.',
      imageUrl: 'https://cdn.pixabay.com/photo/2016/08/11/23/48/solar-panels-1477986_1280.jpg',
      category: 'industrial',
      recommendedSections: ['hero', 'statistics_grid', 'service_steps', 'lead_form'],
      aiPromptHint: 'Use for solar panels, green energy, sustainability, and engineering services.',
    ),
    TemplateMetadata(
      id: 'luxury_resort',
      name: 'Luxury Resort',
      nameAr: 'منتجع فاخر',
      description: 'Elegant showcase for hotels, villas, and high-end tourism.',
      descriptionAr: 'عرض أنيق للفنادق والفيلات والسياحة الراقية.',
      imageUrl: 'https://cdn.pixabay.com/photo/2019/03/04/17/30/pool-3962981_1280.jpg',
      category: 'travel',
      recommendedSections: ['hero', 'gallery', 'team_members', 'cta_banner'],
      aiPromptHint: 'Use for luxury hotels, private villas, boutique resorts, and premium hospitality.',
    ),
    TemplateMetadata(
      id: 'fintech_crypto',
      name: 'Fintech / Crypto',
      nameAr: 'تقنية مالية / عملات رقمية',
      description: 'Modern, dark-themed page for digital finance and blockchain.',
      descriptionAr: 'صفحة عصرية داكنة للتمويل الرقمي والبلوكتشين.',
      imageUrl: 'https://cdn.pixabay.com/photo/2017/03/14/12/15/bitcoin-2007769_1280.jpg',
      category: 'technology',
      recommendedSections: ['hero_saas', 'trust_logos', 'comparison_table', 'cta_banner'],
      aiPromptHint: 'Use for crypto wallets, trading platforms, neobanks, and blockchain startups.',
    ),
    TemplateMetadata(
      id: 'architecture',
      name: 'Architecture & Design',
      nameAr: 'هندسة معمارية وتصميم',
      description: 'Minimalist and grid-focused layout for studios and designers.',
      descriptionAr: 'تصميم بسيط يركز على الشبكة للاستوديوهات والمصممين.',
      imageUrl: 'https://cdn.pixabay.com/photo/2016/11/29/05/07/architecture-1857171_1280.jpg',
      category: 'creative',
      recommendedSections: ['hero', 'gallery', 'service_steps', 'team_members'],
      aiPromptHint: 'Use for architecture firms, interior designers, urban planners, and studios.',
    ),
    TemplateMetadata(
      id: 'fashion_store',
      name: 'Fashion Store',
      nameAr: 'متجر أزياء',
      description: 'Editorial-style e-commerce layout for apparel and beauty.',
      descriptionAr: 'تصميم تجارة إلكترونية تحريري للملابس ومستحضرات التجميل.',
      imageUrl: 'https://cdn.pixabay.com/photo/2016/09/21/15/27/clothes-1766891_1280.jpg',
      category: 'ecommerce',
      recommendedSections: ['hero', 'products', 'gallery', 'testimonials', 'cta_banner'],
      aiPromptHint: 'Use for clothing brands, fashion boutiques, accessories, and trendy apparel.',
    ),
    TemplateMetadata(
      id: 'boutique_store',
      name: 'Boutique Collection',
      nameAr: 'مجموعة بوتيك',
      description: 'Premium storefront with featured product spotlight and modern bento grid.',
      descriptionAr: 'واجهة متجر راقية مع عرض مميز للمنتجات وشبكة عصرية.',
      imageUrl: 'https://cdn.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg',
      category: 'ecommerce',
      recommendedSections: ['hero', 'featured_product', 'bento_store', 'testimonials', 'whatsapp'],
      aiPromptHint: 'Use for high-end boutique brands, single-product focus, and modern grid shopping experiences.',
    ),
  ];

  /// Returns the localized name based on the locale code ('ar' or 'en').
  static String localizedName(TemplateMetadata t, String localeCode) {
    if (localeCode == 'ar' && t.nameAr.isNotEmpty) return t.nameAr;
    return t.name;
  }

  /// Returns the localized description based on the locale code.
  static String localizedDescription(TemplateMetadata t, String localeCode) {
    if (localeCode == 'ar' && t.descriptionAr.isNotEmpty) return t.descriptionAr;
    return t.description;
  }

  static Map<String, dynamic> getTemplateDesign(String templateType) {
    switch (templateType) {
      case 'comprehensive':
        return comprehensiveDesign();
      case 'saas_startup':
        return saasStartupDesign();
      case 'store':
        return storeDesign();
      case 'personal':
        return personalDesign();
      case 'professional':
        return professionalDesign();
      case 'real_estate':
        return realEstateDesign();
      case 'digital_course':
        return digitalCourseDesign();
      case 'event':
        return eventDesign();
      case 'restaurant':
        return restaurantDesign();
      case 'clinic':
        return clinicDesign();
      case 'beauty_salon':
        return beautySalonDesign();
      case 'gym_fitness':
        return gymFitnessDesign();
      case 'mobile_app_saas':
        return mobileAppSaasDesign();
      case 'creative_agency':
        return creativeAgencyDesign();
      case 'nonprofit_campaign':
        return nonprofitCampaignDesign();
      case 'book_launch':
        return bookLaunchDesign();
      case 'solar_energy':
        return solarEnergyDesign();
      case 'luxury_resort':
        return luxuryResortDesign();
      case 'fintech_crypto':
        return fintechCryptoDesign();
      case 'architecture':
        return architectureDesign();
      case 'fashion_store':
        return fashionStoreDesign();
      case 'boutique_store':
        return boutiqueStoreDesign();
      default:
        return {'blocks': []};
    }
  }

  static LandingPageTheme getTemplateTheme(String templateType) {
    switch (templateType) {
      case 'comprehensive':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Tech Indigo',
        );
      case 'saas_startup':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Tech Indigo',
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
      case 'boutique_store':
        return LandingPageTheme.palettes.firstWhere(
          (e) => e.name == 'Midnight Ocean',
        );
      default:
        return LandingPageTheme.palettes.last;
    }
  }
}
