import 'package:uuid/uuid.dart';
import '../models/landing_page_theme.dart';

class TemplateMetadata {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const TemplateMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class TemplateRegistry {
  static const List<TemplateMetadata> availableTemplates = [
    TemplateMetadata(
      id: 'empty',
      name: 'Empty Page',
      description: 'Start from scratch with a blank canvas.',
      imageUrl: 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=400',
    ),
    TemplateMetadata(
      id: 'barber_shop',
      name: 'Barber Shop',
      description: 'Classic barber shop layout with pricing and hours.',
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
    ),
    TemplateMetadata(
      id: 'store',
      name: 'Modern Store',
      description: 'E-commerce focused layout for product showcasing.',
      imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
    ),
    TemplateMetadata(
      id: 'personal',
      name: 'Personal Brand',
      description: 'Showcase your skills and social presence.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    ),
    TemplateMetadata(
      id: 'professional',
      name: 'Professional Consulting',
      description: 'Clean lead generation for services and consulting.',
      imageUrl: 'https://images.unsplash.com/photo-1454165833767-027ffea9e77b?w=400',
    ),
    TemplateMetadata(
      id: 'real_estate',
      name: 'Real Estate',
      description: 'Showcase properties with high-quality visuals.',
      imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400',
    ),
    TemplateMetadata(
      id: 'digital_course',
      name: 'Digital Course',
      description: 'Sell courses with pricing tables and FAQs.',
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
    ),
    TemplateMetadata(
      id: 'event',
      name: 'Event Landing',
      description: 'Promote events with maps and QR codes.',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
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
      default:
        return LandingPageTheme.palettes.last; // Default Dark with Cairo
    }
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
        },
        {
          'type': 'working_hours',
          'title': 'مواعيد العمل الرسمية',
          'schedule': {
            'السبت - الخميس': '10:00 AM - 11:00 PM',
            'الجمعة': '2:00 PM - 12:00 AM',
          },
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
}
