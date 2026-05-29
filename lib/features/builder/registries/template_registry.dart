import 'package:uuid/uuid.dart';
import '../models/landing_page_theme.dart';

class TemplateRegistry {
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
      default:
        return {'blocks': []};
    }
  }

  /// Get recommended theme palette for a template
  static LandingPageTheme getTemplateTheme(String templateType) {
    switch (templateType) {
      case 'barber_shop':
        return LandingPageTheme.palettes.firstWhere((e) => e.name == 'Midnight Ocean');
      case 'store':
        return LandingPageTheme.palettes.firstWhere((e) => e.name == 'Lux-Earth');
      case 'personal':
        return LandingPageTheme.palettes.firstWhere((e) => e.name == 'Butter & Sky');
      case 'professional':
        return LandingPageTheme.palettes.firstWhere((e) => e.name == 'Midnight Ocean');
      default:
        return LandingPageTheme.palettes.last;
    }
  }

  static Map<String, dynamic> _getBarberShopTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'أناقة وفخامة تليق بك',
          'subtitle': 'نحن لا نقص الشعر فقط، بل نصنع الثقة والمظهر المثالي الذي تستحقه بأحدث القصات العالمية.',
          'button_text': 'احجز مقعدك الآن عبر واتساب',
          'image_url': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800'
        },
        {
          'type': 'working_hours',
          'title': 'مواعيد العمل الرسمية',
          'schedule': {
            'السبت - الخميس': '10:00 AM - 11:00 PM',
            'الجمعة': '2:00 PM - 12:00 AM'
          }
        },
        {
          'type': 'pricing',
          'title': 'قائمة خدماتنا وأسعارنا',
          'items': [
            {
              'name': 'قص شعر ستايل عالي الجودة',
              'price': '200 EGP',
              'features': ['غسيل شعر بشامبو طبي', 'استشوار وتصفيف سيروم'],
              'is_popular': true
            },
            {
              'name': 'تحديد وحلاقة ذقن ملكي بالبخار',
              'price': '150 EGP',
              'features': ['فوطة ساخنة مرطبة', 'ماسك الصبار الطبيعي'],
              'is_popular': false
            }
          ]
        },
        {
          'type': 'whatsapp',
          'title': 'تواصل مباشر مع الإدارة',
          'phone_number': '201000000000',
          'message': 'مرحباً، أود الاستفسار عن المواعيد المتاحة اليوم للحجز.',
          'button_text': 'تواصل معنا الآن'
        }
      ]
    };
  }

  static Map<String, dynamic> _getStoreTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'أفضل المنتجات بين يديك',
          'subtitle': 'اكتشف مجموعتنا الحصرية من المنتجات عالية الجودة التي تناسب ذوقك الرفيع.',
          'button_text': 'تسوق الآن',
          'image_url': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800'
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
              'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
              'button_text': 'اشترِ الآن'
            }
          ]
        }
      ]
    };
  }

  static Map<String, dynamic> _getPersonalTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'مرحباً، أنا مصمم مبدع',
          'subtitle': 'أساعد الشركات على بناء هويات بصرية مذهلة وتجارب مستخدم فريدة.',
          'button_text': 'شاهد أعمالي',
          'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800'
        },
        {
          'type': 'social_qr',
          'title': 'تواصل معي',
          'subtitle': 'تابعني على المنصات التالية',
          'links': [
            {'platform': 'instagram', 'url': 'https://instagram.com'},
            {'platform': 'linkedin', 'url': 'https://linkedin.com'}
          ]
        }
      ]
    };
  }

  static Map<String, dynamic> _getProfessionalTemplate() {
    return {
      'blocks': [
        {
          'type': 'hero',
          'title': 'حلول استشارية لنمو عملك',
          'subtitle': 'نقدم استشارات مبنية على البيانات لتحقيق أهدافك التجارية.',
          'button_text': 'احجز استشارة مجانية',
          'image_url': 'https://images.unsplash.com/photo-1454165833767-027ffea9e77b?w=800'
        },
        {
          'type': 'lead_form',
          'title': 'تواصل مع فريق الخبراء',
          'button_text': 'إرسال الطلب'
        }
      ]
    };
  }
}
