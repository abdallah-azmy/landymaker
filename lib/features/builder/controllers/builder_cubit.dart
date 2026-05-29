import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../core/error_handler.dart';
import '../models/landing_page_theme.dart';
import 'builder_state.dart';

class LandingPageBuilderCubit extends Cubit<BuilderState> {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;

  LandingPageBuilderCubit({
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
  })  : _authService = authService,
        _databaseService = databaseService,
        _storageService = storageService,
        super(BuilderInitial());

  Future<void> loadForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) {
      emit(BuilderFailure("No authenticated user found."));
      return;
    }
    await loadPageForUser(userId);
  }

  Future<void> saveForCurrentUser() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;
    await savePage(userId);
  }

  Future<void> loadPageForUser(String userId) async {
    emit(BuilderLoading());
    try {
      final page = await _databaseService.getLandingPageByUserId(userId);
      Map<String, dynamic> designMap = {'blocks': []};
      String subdomain = '';
      String? customDomain;
      bool isPublished = false;
      String? pageId;

      if (page != null) {
        pageId = page['id'] as String?;
        subdomain = page['subdomain'] ?? '';
        customDomain = page['custom_domain'];
        isPublished = page['is_published'] ?? false;

        final dynamic rawDesign = page['design_json'];
        if (rawDesign != null) {
          if (rawDesign is String) {
            designMap = Map<String, dynamic>.from(jsonDecode(rawDesign));
          } else {
            designMap = Map<String, dynamic>.from(rawDesign);
          }
        }
      }

      final theme = designMap['theme'] != null
          ? LandingPageTheme.fromJson(designMap['theme'])
          : LandingPageTheme.palettes.last;

      if (designMap['blocks'] == null || (designMap['blocks'] as List).isEmpty) {
        designMap['blocks'] = [
          {
            'type': 'hero',
            'title': 'ابنِ صفحتك الاحترافية في دقائق',
            'subtitle': 'منصة ماي لاندي توفر لك كل الأدوات التي تحتاجها للنمو.',
            'button_text': 'ابدأ الآن',
            'image_url': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800'
          }
        ];
      }

      emit(BuilderLoaded(
        pageId: pageId,
        designMap: designMap,
        subdomain: subdomain,
        customDomain: customDomain,
        isPublished: isPublished,
        theme: theme,
      ));
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  Future<void> savePage(String userId) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    if (currentState.subdomain.trim().isEmpty) {
      emit(currentState.copyWith(
        errorMessage: "يرجى إدخال اسم البراند (subdomain) قبل الحفظ.",
      ));
      return;
    }

    emit(currentState.copyWith(isSaving: true));
    try {
      final Map<String, dynamic> finalDesign = Map<String, dynamic>.from(currentState.designMap);
      finalDesign['theme'] = currentState.theme.toJson();

      final savedPageId = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: currentState.subdomain,
        customDomain: currentState.customDomain,
        designMap: finalDesign,
        isPublished: currentState.isPublished,
        pageId: currentState.pageId,
      );

      emit(currentState.copyWith(
        pageId: savedPageId ?? currentState.pageId,
        isSaving: false,
        successMessage: "تم الحفظ والنشر بنجاح!",
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSaving: false,
        errorMessage: "فشل الحفظ: ${e.toString().replaceAll('Exception: ', '')}",
      ));
    }
  }

  void updateSettings({String? subdomain, String? customDomain, bool? isPublished}) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final shouldClear = customDomain == '';
    emit(currentState.copyWith(
      subdomain: subdomain ?? currentState.subdomain,
      customDomain: shouldClear ? null : (customDomain ?? currentState.customDomain),
      clearCustomDomain: shouldClear,
      isPublished: isPublished ?? currentState.isPublished,
    ));
  }

  void updateTheme(LandingPageTheme theme) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    emit(currentState.copyWith(theme: theme));
  }

  void updateThemeProperty(String key, Color color) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    LandingPageTheme newTheme;
    switch (key) {
      case 'primary':
        newTheme = currentState.theme.copyWith(primary: color);
        break;
      case 'secondary':
        newTheme = currentState.theme.copyWith(secondary: color);
        break;
      case 'background':
        newTheme = currentState.theme.copyWith(background: color);
        break;
      case 'textPrimary':
        newTheme = currentState.theme.copyWith(textPrimary: color);
        break;
      case 'textSecondary':
        newTheme = currentState.theme.copyWith(textSecondary: color);
        break;
      default:
        return;
    }
    emit(currentState.copyWith(theme: newTheme));
  }

  void applyTemplate(String templateType) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    Map<String, dynamic> newDesign = {'blocks': []};
    LandingPageTheme newTheme = currentState.theme;

    switch (templateType) {
      case 'store':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Lux-Earth');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'أفضل المنتجات بين يديك',
            'subtitle': 'اكتشف مجموعتنا الحصرية من المنتجات عالية الجودة التي تناسب ذوقك الرفيع.',
            'button_text': 'تسوق الآن',
            'image_url': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800'
          },
          {
            'type': 'features',
            'title': 'لماذا نحن الأفضل؟',
            'layout_style': 'bento',
            'items': [
              {'title': 'شحن سريع', 'description': 'نصلك أينما كنت في أسرع وقت ممكن مع تغليف آمن.'},
              {'title': 'جودة مضمونة', 'description': 'جميع منتجاتنا تخضع لأعلى معايير الجودة العالمية.'},
              {'title': 'دعم 24/7', 'description': 'فريقنا متواجد دائماً لمساعدتك في أي استفسار.'},
              {'title': 'إرجاع سهل', 'description': 'سياسة إرجاع مرنة تضمن لك تجربة شراء خالية من القلق.'}
            ]
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
              },
              {
                'id': const Uuid().v4(),
                'name': 'سماعات لاسلكية',
                'price': '850 EGP',
                'description': 'صوت نقي وتصميم مريح للاستخدام الطويل.',
                'image_url': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
                'button_text': 'اشترِ الآن'
              }
            ]
          },
          {
            'type': 'testimonials',
            'title': 'آراء عملائنا',
            'items': [
              {'author': 'سارة أحمد', 'role': 'مصممة أزياء', 'quote': 'تجربة شراء رائعة، المنتجات فاخرة وتستحق كل قرش.'},
              {'author': 'محمد علي', 'role': 'رائد أعمال', 'quote': 'سرعة في التوصيل وجودة لم أتوقعها، شكراً لكم.'}
            ]
          }
        ];
        break;

      case 'personal':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Butter & Sky');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'مرحباً، أنا مصمم مبدع',
            'subtitle': 'أساعد الشركات على بناء هويات بصرية مذهلة وتجارب مستخدم فريدة تترك انطباعاً دائماً.',
            'button_text': 'شاهد أعمالي',
            'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800'
          },
          {
            'type': 'gallery',
            'title': 'معرض أعمالي المختارة',
            'display_mode': 'grid',
            'grid_columns': 3,
            'items': [
              'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800',
              'https://images.unsplash.com/photo-1534158914592-062992fbe900?w=800',
              'https://images.unsplash.com/photo-1574096079513-d8259312b785?w=800'
            ]
          },
          {
            'type': 'features',
            'title': 'ماذا أقدم؟',
            'layout_style': 'grid',
            'items': [
              {'title': 'تصميم واجهات', 'description': 'بناء واجهات سهلة الاستخدام وجذابة تزيد من تفاعل المستخدمين.'},
              {'title': 'تطوير تطبيقات', 'description': 'تحويل الأفكار المعقدة إلى تطبيقات واقعية تعمل بسلاسة.'}
            ]
          },
          {
            'type': 'social_qr',
            'title': 'تواصل معي',
            'subtitle': 'تابعني على المنصات التالية لمشاهدة آخر التحديثات',
            'links': [
              {'platform': 'instagram', 'url': 'https://instagram.com'},
              {'platform': 'linkedin', 'url': 'https://linkedin.com'},
              {'platform': 'website', 'url': 'https://portfolio.com'}
            ]
          }
        ];
        break;

      case 'professional':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Midnight Ocean');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'حلول استشارية لنمو عملك',
            'subtitle': 'نقدم استشارات مبنية على البيانات لتحقيق أهدافك التجارية وزيادة إنتاجية فريقك.',
            'button_text': 'احجز استشارة مجانية',
            'image_url': 'https://images.unsplash.com/photo-1454165833767-027ffea9e77b?w=800'
          },
          {
            'type': 'features',
            'title': 'خدماتنا الاستراتيجية',
            'layout_style': 'bento',
            'items': [
              {'title': 'تحليل السوق', 'description': 'دراسة متعمقة للمنافسين والفرص المتاحة في السوق.'},
              {'title': 'استراتيجيات النمو', 'description': 'خطط عمل مدروسة تضمن توسع نطاق عملك بشكل مستدام.'},
              {'title': 'إدارة الموارد', 'description': 'تحسين استخدام الموارد البشرية والمالية لزيادة الكفاءة.'},
              {'title': 'التحول الرقمي', 'description': 'دمج أحدث التقنيات في عملياتك التجارية اليومية.'}
            ]
          },
          {
            'type': 'faq',
            'title': 'أسئلة شائعة',
            'items': [
              {'question': 'كيف يمكنني البدء؟', 'answer': 'يمكنك حجز مكالمة أولية مجانية لنناقش فيها احتياجات مشروعك.'},
              {'question': 'كم تستغرق الاستشارة؟', 'answer': 'تعتمد المدة على حجم المشروع، ولكن عادة ما تبدأ من جلسة واحدة.'}
            ]
          },
          {
            'type': 'lead_form',
            'title': 'تواصل مع فريق الخبراء',
            'button_text': 'إرسال الطلب'
          }
        ];
        break;

      case 'tv_bar':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Stadium Neon');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'الأجواء الأفضل للمشاهدة',
            'subtitle': 'استمتع بأهم المباريات العالمية مع أشهى الوجبات والمشروبات في مكانك المفضل.',
            'button_text': 'احجز طاولتك',
            'image_url': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800'
          },
          {
            'type': 'pricing',
            'title': 'عروض المجموعات',
            'items': [
              {
                'name': 'عرض الأصدقاء',
                'price': '199 EGP',
                'features': ['٤ مشروبات غازية', 'بيتزا حجم كبير', 'مقبلات متنوعة'],
                'button_text': 'احجز العرض',
                'is_popular': true
              },
              {
                'name': 'عرض العائلة',
                'price': '350 EGP',
                'features': ['وجبة كاملة لـ ٤ أفراد', 'مشروبات مفتوحة', 'حلوى مجانية'],
                'button_text': 'احجز الآن',
                'is_popular': false
              }
            ]
          },
          {
            'type': 'whatsapp',
            'title': 'اطلب الآن عبر واتساب',
            'phone_number': '201000000000',
            'message': 'أهلاً بك! أريد حجز طاولة لمشاهدة المباراة...',
            'button_text': 'إرسال رسالة'
          },
          {
            'type': 'contact_info',
            'title': 'زرنا اليوم',
            'phone': '+201000000000',
            'email': 'info@stadiumbar.com',
            'location': 'شارع جامعة الدول، المهندسين'
          }
        ];
        break;

      case 'real_estate':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Royal Gold');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'فيلا الأحلام بانتظارك',
            'subtitle': 'احصل على فيلا فاخرة بتصميم عصري وفي أرقى أحياء المدينة مع تسهيلات سداد ممتازة تناسب ميزانيتك.',
            'button_text': 'احجز معاينة الآن',
            'image_url': 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=800'
          },
          {
            'type': 'products',
            'title': 'الوحدات المتاحة للبيع',
            'layout_style': 'grid_2',
            'items': [
              {
                'id': const Uuid().v4(),
                'name': 'فيلا تاون هاوس',
                'price': '8,500,000 EGP',
                'category': 'تاون هاوس',
                'description': '٤ غرف نوم، حديقة خاصة، مسبح عائلي.',
                'image_url': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
                'button_text': 'تفاصيل الوحدة'
              },
              {
                'id': const Uuid().v4(),
                'name': 'شقة بنتهاوس فاخرة',
                'price': '4,200,000 EGP',
                'category': 'شقق بنتهاوس',
                'description': 'إطلالة بانورامية ساحرة وتراس واسع.',
                'image_url': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
                'button_text': 'تفاصيل الوحدة'
              }
            ]
          },
          {
            'type': 'features',
            'title': 'خدمات ومميزات المجمع',
            'layout_style': 'grid',
            'items': [
              {'title': 'أمن وحراسة', 'description': 'أنظمة مراقبة متكاملة لحمايتك وحماية عائلتك على مدار الساعة.'},
              {'title': 'مساحات خضراء', 'description': 'حدائق وممشى مخصص لممارسة الرياضة في بيئة نقية.'}
            ]
          },
          {
            'type': 'contact_info',
            'title': 'تواصل مع مستشارنا العقاري',
            'phone': '+201100000000',
            'email': 'sales@mylandyestate.com',
            'location': 'التجمع الخامس، القاهرة الجديدة'
          }
        ];
        break;

      case 'event':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Cyber Slate');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'مؤتمر تكنو-فلو ٢٠٢٦',
            'subtitle': 'الحدث السنوي الأكبر لمطوري التكنولوجيا والذكاء الاصطناعي في الشرق الأوسط. انضم إلينا الآن.',
            'button_text': 'سجل لحضور المؤتمر',
            'image_url': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800'
          },
          {
            'type': 'pricing',
            'title': 'تذاكر الحضور',
            'items': [
              {
                'name': 'تذكرة عادية',
                'price': '300 EGP',
                'features': ['حضور الجلسات الرئيسية', 'شهادة حضور إلكترونية'],
                'button_text': 'احجز الآن',
                'is_popular': false
              },
              {
                'name': 'تذكرة VIP',
                'price': '1000 EGP',
                'features': ['مقاعد أمامية', 'ولوج لغرفة التشبيك', 'غداء عمل'],
                'button_text': 'احجز الآن',
                'is_popular': true
              }
            ]
          },
          {
            'type': 'qr_code',
            'title': 'امسح الكود للتسجيل السريع',
            'subtitle': 'شارك الصفحة مع فريقك وسجلوا معاً بضغطة زر.',
            'qr_size': 200.0,
          },
          {
            'type': 'social_qr',
            'title': 'تابعنا للمزيد',
            'subtitle': 'احصل على آخر التحديثات وجدول الفعاليات',
            'links': [
              {'platform': 'instagram', 'url': 'https://instagram.com'},
              {'platform': 'facebook', 'url': 'https://facebook.com'}
            ]
          }
        ];
        break;

      case 'digital_course':
        newTheme = LandingPageTheme.palettes.firstWhere((e) => e.name == 'Deep Forest');
        newDesign['blocks'] = [
          {
            'type': 'hero',
            'title': 'احترف تطوير الويب في ١٢ أسبوعاً',
            'subtitle': 'كورس عملي مكثف من الصفر للتطبيق والتوظيف. ابدأ الآن مسيرتك المهنية مع خبراء المجال.',
            'button_text': 'اشترك بالدورة الآن',
            'image_url': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800'
          },
          {
            'type': 'features',
            'title': 'ماذا ستتعلم؟',
            'layout_style': 'bento',
            'items': [
              {'title': 'أساسيات الويب', 'description': 'تعلم بناء وتنسيق صفحات الويب باحترافية وتناسق تام.'},
              {'title': 'جافا سكريبت', 'description': 'إضافة التفاعل والمنطق لصفحات الويب وبناء تطبيقات ديناميكية.'},
              {'title': 'React & Node.js', 'description': 'بناء تطبيقات ويب كاملة متكاملة Front-end & Back-end.'},
              {'title': 'مشروع التخرج', 'description': 'بناء مشروع حقيقي يضاف إلى معرض أعمالك المهني.'}
            ]
          },
          {
            'type': 'testimonials',
            'title': 'ماذا قال طلابنا؟',
            'items': [
              {'author': 'أحمد علي', 'role': 'مطور ويب', 'quote': 'هذا الكورس غير مسار حياتي المهنية تماماً، التطبيق العملي كان مذهلاً.'},
              {'author': 'سارة محمد', 'role': 'مطور واجهات', 'quote': 'المحتوى مرتب جداً والمتابعة الفردية ساعدتني كثيراً.'}
            ]
          },
          {
            'type': 'pricing',
            'title': 'باقات الاشتراك',
            'items': [
              {
                'name': 'الباقة التفاعلية',
                'price': '3500 EGP',
                'features': ['جلسات أسبوعية مباشرة', 'تقييم الكود', 'دعم توظيف'],
                'button_text': 'سجل الآن',
                'is_popular': true
              }
            ]
          }
        ];
        break;
    }

    emit(currentState.copyWith(
      designMap: newDesign,
      theme: newTheme,
      successMessage: "تم تطبيق القالب بنجاح!",
    ));
  }

  void addBlock(String type) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);

    if (type == 'hero') {
      blocks.add({
        'type': 'hero',
        'title': 'عنوان القسم الرئيسي الجديد',
        'subtitle': 'اكتب هنا عرض القيمة الأساسي لخدمتك أو منتجك.',
        'button_text': 'ابدأ الآن',
        'image_url': 'https://images.unsplash.com/photo-1542744094-3a31f103e35f?w=800'
      });
    } else if (type == 'features') {
      blocks.add({
        'type': 'features',
        'title': 'لماذا نحن؟',
        'layout_style': 'grid',
        'items': [
          {'title': 'ميزة 1', 'description': 'اشرح فوائد هذه الميزة هنا.'},
          {'title': 'ميزة 2', 'description': 'سلط الضوء على أهمية هذا البند.'}
        ]
      });
    } else if (type == 'lead_form') {
      blocks.add({
        'type': 'lead_form',
        'title': 'تواصل معنا اليوم',
        'button_text': 'إرسال'
      });
    } else if (type == 'whatsapp') {
      blocks.add({
        'type': 'whatsapp',
        'title': 'تواصل معنا عبر واتساب',
        'phone_number': '',
        'message': 'أهلاً بك! أريد الاستفسار عن...',
        'button_text': 'إرسال رسالة'
      });
    } else if (type == 'products') {
      blocks.add({
        'type': 'products',
        'title': 'منتجاتنا',
        'layout_style': 'grid_2',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'اسم المنتج',
            'price': '0 EGP',
            'category': 'عام',
            'description': 'وصف مختصر للمنتج.',
            'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
            'button_text': 'اشترِ الآن'
          }
        ]
      });
    } else if (type == 'qr_code') {
      blocks.add({
        'type': 'qr_code',
        'title': 'امسح الكود لزيارة موقعنا',
        'subtitle': 'شارك الصفحة بسهولة.',
        'qr_size': 200.0,
      });
    } else if (type == 'social_qr') {
      blocks.add({
        'type': 'social_qr',
        'title': 'تواصل معنا',
        'subtitle': 'تابعنا على منصات التواصل',
        'links': [
          {'platform': 'instagram', 'url': 'https://instagram.com'},
          {'platform': 'whatsapp', 'url': 'https://wa.me/'}
        ]
      });
    } else if (type == 'pricing') {
      blocks.add({
        'type': 'pricing',
        'title': 'خطط الأسعار',
        'items': [
          {
            'name': 'الخطة الأساسية',
            'price': '0 EGP',
            'features': ['ميزة 1'],
            'button_text': 'ابدأ الآن',
            'is_popular': false,
          }
        ]
      });
    } else if (type == 'faq') {
      blocks.add({
        'type': 'faq',
        'title': 'الأسئلة الشائعة',
        'items': [
          {'question': 'سؤال؟', 'answer': 'إجابة مفصلة.'}
        ]
      });
    } else if (type == 'testimonials') {
      blocks.add({
        'type': 'testimonials',
        'title': 'قالوا عنا',
        'items': [
          {'author': 'الاسم', 'role': 'الوظيفة', 'quote': 'رأيه هنا.'}
        ]
      });
    } else if (type == 'contact_info') {
      blocks.add({
        'type': 'contact_info',
        'title': 'تواصل معنا',
        'email': 'contact@example.com',
        'phone': '+20',
        'location': 'القاهرة، مصر',
      });
    } else if (type == 'gallery') {
      blocks.add({
        'type': 'gallery',
        'title': 'معرض الصور',
        'items': [
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800'
        ]
      });
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void addPricingPlan(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({
        'name': 'خطة جديدة',
        'price': '0.00 EGP',
        'features': ['ميزة 1', 'ميزة 2'],
        'button_text': 'ابدأ الآن',
        'is_popular': false,
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deletePricingPlan(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updatePricingPlan(int blockIndex, int itemIndex, String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(items[itemIndex]);
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void addFaqItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({'question': 'سؤال جديد؟', 'answer': 'الإجابة هنا.'});
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deleteFaqItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateFaqItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(items[itemIndex]);
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void addTestimonialItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({'author': 'عميل جديد', 'role': 'وظيفة', 'quote': 'رأي العميل هنا.'});
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deleteTestimonialItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateTestimonialItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(items[itemIndex]);
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void addGalleryImage(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add('https://images.unsplash.com/photo-1542744094-3a31f103e35f?w=800');
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deleteGalleryImage(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateGalleryImage(int blockIndex, int itemIndex, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items[itemIndex] = value;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deleteBlock(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void moveBlock(int index, bool up) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    final targetIndex = up ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= blocks.length) return;

    final temp = blocks[index];
    blocks[index] = blocks[targetIndex];
    blocks[targetIndex] = temp;

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateBlockProperty(int index, String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[index]);
      updatedBlock[key] = value;
      blocks[index] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateFeatureItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(items[itemIndex]);
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void addProductItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({
        'id': const Uuid().v4(),
        'name': 'منتج جديد',
        'price': '0.00 EGP',
        'description': 'وصف قصير للمنتج.',
        'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        'button_text': 'اشترِ الآن'
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void deleteProductItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void updateProductItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[blockIndex]);
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(items[itemIndex]);
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    emit(currentState.copyWith(designMap: newDesign));
  }

  void clearMessages() {
    final currentState = state;
    if (currentState is BuilderLoaded) {
      emit(currentState.copyWith(errorMessage: null, successMessage: null));
    }
  }

  Future<void> uploadBlockImage(int index, PlatformFile file) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    emit(currentState.copyWith(isSaving: true, errorMessage: null));
    try {
      final publicUrl = await _storageService.uploadImage(file);
      if (publicUrl != null) {
        final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
        final List blocks = List.from(newDesign['blocks'] ?? []);
        if (index >= 0 && index < blocks.length) {
          final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[index]);
          updatedBlock['image_url'] = publicUrl;
          blocks[index] = updatedBlock;
        }
        newDesign['blocks'] = blocks;
        emit(currentState.copyWith(
          designMap: newDesign, 
          isSaving: false,
          successMessage: "تم رفع الصورة بنجاح!"
        ));
      } else {
        emit(currentState.copyWith(isSaving: false, errorMessage: "فشل رفع الصورة."));
      }
    } catch (e) {
      final humanError = ErrorHandler.getHumanReadableError(e);
      emit(currentState.copyWith(isSaving: false, errorMessage: humanError));
    }
  }

  Future<void> uploadBlockBackgroundImage(int index, PlatformFile file) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    emit(currentState.copyWith(isSaving: true, errorMessage: null));
    try {
      final publicUrl = await _storageService.uploadImage(file);
      if (publicUrl != null) {
        final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
        final List blocks = List.from(newDesign['blocks'] ?? []);
        if (index >= 0 && index < blocks.length) {
          final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(blocks[index]);
          updatedBlock['bg_image_url'] = publicUrl;
          blocks[index] = updatedBlock;
        }
        newDesign['blocks'] = blocks;
        emit(currentState.copyWith(
          designMap: newDesign, 
          isSaving: false,
          successMessage: "تم رفع صورة الخلفية بنجاح!"
        ));
      } else {
        emit(currentState.copyWith(isSaving: false, errorMessage: "فشل رفع صورة الخلفية."));
      }
    } catch (e) {
      final humanError = ErrorHandler.getHumanReadableError(e);
      emit(currentState.copyWith(isSaving: false, errorMessage: humanError));
    }
  }
}
