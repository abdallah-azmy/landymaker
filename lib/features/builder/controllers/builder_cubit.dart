/// ======================================================
/// FEATURE: Builder State Management
/// PURPOSE: Core logic for editing landing pages (Undo/Redo, Auto-save)
/// USED BY: BuilderWorkspaceScreen
/// DEPENDENCIES:
/// - DatabaseService
/// - StorageService
/// - TemplateRegistry
/// ======================================================

import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/subscription_service.dart';
import '../../../../core/error_handler.dart';
import '../models/landing_page_theme.dart';
import '../registries/template_registry.dart';
import 'builder_state.dart';

class LandingPageBuilderCubit extends Cubit<BuilderState> {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final StorageService _storageService;
  final SubscriptionService _subscriptionService;

  final List<String> _history = [];
  int _historyIndex = -1;

  LandingPageBuilderCubit({
    required AuthService authService,
    required DatabaseService databaseService,
    required StorageService storageService,
    required SubscriptionService subscriptionService,
  }) : _authService = authService,
       _databaseService = databaseService,
       _storageService = storageService,
       _subscriptionService = subscriptionService,
       super(BuilderInitial());

  void _saveToHistory(BuilderLoaded state) {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    final newStateStr = jsonEncode({
      'designMap': state.designMap,
      'theme': state.theme.toJson(),
    });

    // Do not add duplicate states if the data hasn't actually changed
    if (_history.isNotEmpty &&
        _historyIndex >= 0 &&
        _historyIndex < _history.length) {
      if (_history[_historyIndex] == newStateStr) {
        return;
      }
    }

    _history.add(newStateStr);
    _historyIndex = _history.length - 1;

    // Limit history to 50 steps
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void _emitDirty(
    BuilderLoaded state, {
    bool isClean = false,
    bool skipHistory = false,
  }) {
    if (!skipHistory) {
      _saveToHistory(state);
    }
    emit(
      state.copyWith(
        hasUnsavedChanges: !isClean,
        canUndo: _historyIndex > 0,
        canRedo: _historyIndex < _history.length - 1,
      ),
    );
  }

  void undo() {
    final currentState = state;
    if (currentState is! BuilderLoaded || _historyIndex <= 0) return;

    _historyIndex--;
    final snapshot = jsonDecode(_history[_historyIndex]);
    _emitDirty(
      currentState.copyWith(
        designMap: snapshot['designMap'],
        theme: LandingPageTheme.fromJson(snapshot['theme']),
      ),
      isClean: false,
      skipHistory: true,
    );
  }

  void redo() {
    final currentState = state;
    if (currentState is! BuilderLoaded || _historyIndex >= _history.length - 1)
      return;

    _historyIndex++;
    final snapshot = jsonDecode(_history[_historyIndex]);
    _emitDirty(
      currentState.copyWith(
        designMap: snapshot['designMap'],
        theme: LandingPageTheme.fromJson(snapshot['theme']),
      ),
      isClean: false,
      skipHistory: true,
    );
  }

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
      _handleLoadedPage(page);
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  Future<void> loadPageById(String pageIdOrSubdomain) async {
    emit(BuilderLoading());
    try {
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );
      Map<String, dynamic>? page;
      if (uuidRegex.hasMatch(pageIdOrSubdomain)) {
        page = await _databaseService.getLandingPageById(pageIdOrSubdomain);
      } else {
        page = await _databaseService.getLandingPageByDomain(
          pageIdOrSubdomain,
          publishedOnly: false,
        );
      }
      _handleLoadedPage(page);
    } catch (e) {
      emit(BuilderFailure(e.toString()));
    }
  }

  void initializeNewPage() {
    _history.clear();
    _historyIndex = -1;

    _emitDirty(
      BuilderLoaded(
        designMap: {'blocks': []},
        subdomain: '',
        isPublished: false,
        websiteType: 'landing_page',
        theme: LandingPageTheme.palettes.last,
      ),
      isClean: true,
    );
  }

  void _handleLoadedPage(Map<String, dynamic>? page) {
    _history.clear();
    _historyIndex = -1;

    if (page == null) {
      emit(BuilderEmptyWorkspace());
      return;
    }

    final currentUserId = _authService.currentUserId;
    if (page['user_id'] != null &&
        currentUserId != null &&
        page['user_id'] != currentUserId) {
      emit(BuilderFailure("You do not have permission to access this page."));
      return;
    }

    Map<String, dynamic> designMap = {'blocks': []};
    String subdomain = page['subdomain'] ?? '';
    String? customDomain = page['custom_domain'];
    bool isPublished = page['is_published'] ?? false;
    String? pageId = page['id'] as String?;
    final String websiteType = page['website_type'] ?? 'landing_page';

    final dynamic rawDesign = page['design_json'];
    if (rawDesign != null) {
      if (rawDesign is String) {
        designMap = Map<String, dynamic>.from(jsonDecode(rawDesign));
      } else {
        designMap = Map<String, dynamic>.from(rawDesign);
      }
    }

    _emitDirty(
      BuilderLoaded(
        pageId: pageId,
        designMap: designMap,
        subdomain: subdomain,
        customDomain: customDomain,
        isPublished: isPublished,
        websiteType: websiteType,
        theme: designMap['theme'] != null
            ? LandingPageTheme.fromJson(designMap['theme'])
            : LandingPageTheme.palettes.last,
      ),
      isClean: true,
    );
  }

  Future<void> savePage(String userId) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final String sanitizedSubdomain = currentState.subdomain
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    if (sanitizedSubdomain.isEmpty) {
      _emitDirty(
        currentState.copyWith(
          isSaving: false,
          errorMessage: "يرجى إدخال اسم براند صالح.",
        ),
      );
      return;
    }

    emit(currentState.copyWith(isSaving: true));
    try {
      // 1. Check Route Availability
      final isAvailable = await _databaseService.isRouteAvailable(
        sanitizedSubdomain,
        excludePageId: currentState.pageId,
      );

      if (!isAvailable) {
        _emitDirty(
          currentState.copyWith(
            isSaving: false,
            errorMessage:
                "اسم الرابط ($sanitizedSubdomain) محجوز بالفعل. يرجى اختيار اسم آخر.",
          ),
        );
        return;
      }

      // 2. Check Multi-Page Guard with Super Admin Bypass
      if (currentState.pageId == null) {
        final profile = await _databaseService.getProfile(userId);
        final String tier = profile?['tier'] ?? 'free';
        final bool reachedLimit = await _subscriptionService.hasReachedLimit(
          userId,
        );

        if (reachedLimit) {
          _emitDirty(
            currentState.copyWith(
              isSaving: false,
              errorMessage:
                  "لقد وصلت للحد الأقصى لعدد الصفحات المسموح به في خطتك الحالية ($tier).",
            ),
          );
          return;
        }
      }

      final Map<String, dynamic> finalDesign = Map<String, dynamic>.from(
        currentState.designMap,
      );
      finalDesign['theme'] = currentState.theme.toJson();

      final savedPageId = await _databaseService.saveLandingPage(
        userId: userId,
        subdomain: sanitizedSubdomain,
        customDomain: currentState.customDomain,
        designMap: finalDesign,
        isPublished: currentState.isPublished,
        websiteType: currentState.websiteType,
        pageId: currentState.pageId,
      );

      _emitDirty(
        currentState.copyWith(
          pageId: savedPageId ?? currentState.pageId,
          subdomain: sanitizedSubdomain,
          isSaving: false,
          successMessage: "تم الحفظ والنشر بنجاح!",
        ),
        isClean: true,
      );
    } catch (e) {
      _emitDirty(
        currentState.copyWith(
          isSaving: false,
          errorMessage:
              "فشل الحفظ: ${e.toString().replaceAll('Exception: ', '')}",
        ),
      );
    }
  }

  void updateSettings({
    String? subdomain,
    String? customDomain,
    bool? isPublished,
  }) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final shouldClear = customDomain == '';
    _emitDirty(
      currentState.copyWith(
        subdomain: subdomain ?? currentState.subdomain,
        customDomain: shouldClear
            ? null
            : (customDomain ?? currentState.customDomain),
        clearCustomDomain: shouldClear,
        isPublished: isPublished ?? currentState.isPublished,
      ),
    );
  }

  void updateTheme(LandingPageTheme theme) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    _emitDirty(currentState.copyWith(theme: theme));
  }

  void updateThemeProperty(String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    LandingPageTheme newTheme;

    if (value is Color) {
      switch (key) {
        case 'primary':
          newTheme = currentState.theme.copyWith(primary: value);
          break;
        case 'secondary':
          newTheme = currentState.theme.copyWith(secondary: value);
          break;
        case 'background':
          newTheme = currentState.theme.copyWith(background: value);
          break;
        case 'textPrimary':
          newTheme = currentState.theme.copyWith(textPrimary: value);
          break;
        case 'textSecondary':
          newTheme = currentState.theme.copyWith(textSecondary: value);
          break;
        default:
          return;
      }
    } else if (value is String || value == null) {
      switch (key) {
        case 'defaultFont':
          newTheme = currentState.theme.copyWith(defaultFont: value as String?);
          break;
        case 'globalBgImageUrl':
          newTheme = currentState.theme.copyWith(
            globalBgImageUrl: value as String?,
            clearBgImage: value == null,
          );
          break;
        case 'globalBgColorHex':
          newTheme = currentState.theme.copyWith(
            globalBgColorHex: value as String?,
            clearBgColor: value == null,
          );
          break;
        default:
          return;
      }
    } else {
      return;
    }

    _emitDirty(currentState.copyWith(theme: newTheme));
  }

  void applyTemplate(String templateType) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final newDesign = TemplateRegistry.getTemplateDesign(templateType);
    final newTheme = TemplateRegistry.getTemplateTheme(templateType);

    _emitDirty(
      currentState.copyWith(
        designMap: newDesign,
        theme: newTheme,
        successMessage: "تم تطبيق القالب بنجاح!",
      ),
    );
  }

  void addBlock(String type) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);

    if (type == 'hero' || type == 'hero_saas') {
      blocks.add({
        'type': type,
        'title': type == 'hero_saas'
            ? 'منصتك الشاملة لإدارة الأعمال'
            : 'عنوان القسم الرئيسي الجديد',
        'subtitle': type == 'hero_saas'
            ? 'نظام متكامل يجمع كل ما تحتاجه لإدارة مشروعك بكفاءة.'
            : 'اكتب هنا عرض القيمة الأساسي لخدمتك أو منتجك.',
        'button_text': 'ابدأ الآن مجاناً',
        'image_url': type == 'hero_saas'
            ? 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1200'
            : 'https://images.unsplash.com/photo-1542744094-3a31f103e35f?w=800',
      });
    } else if (type == 'logo_header') {
      blocks.add({
        'type': 'logo_header',
        'title': 'اسم العلامة التجارية',
        'alignment': 'center',
        'logo_height': 48.0,
      });
    } else if (type == 'features') {
      blocks.add({
        'type': 'features',
        'title': 'لماذا نحن؟',
        'layout_style': 'grid',
        'items': [
          {'title': 'ميزة 1', 'description': 'اشرح فوائد هذه الميزة هنا.'},
          {'title': 'ميزة 2', 'description': 'سلط الضوء على أهمية هذا البند.'},
        ],
      });
    } else if (type == 'lead_form') {
      blocks.add({
        'type': 'lead_form',
        'title': 'تواصل معنا اليوم',
        'button_text': 'إرسال',
      });
    } else if (type == 'lead_magnet') {
      blocks.add({
        'type': 'lead_magnet',
        'title': 'احصل على دليلك المجاني',
        'subtitle':
            'سجل الآن لتحصل على نسخة مجانية من الدليل الشامل لزيادة مبيعاتك بنسبة 300%.',
        'button_text': 'أرسل الدليل الآن',
        'image_url':
            'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=800',
      });
    } else if (type == 'whatsapp') {
      blocks.add({
        'type': 'whatsapp',
        'title': 'تواصل معنا عبر واتساب',
        'phone_number': '',
        'message': 'أهلاً بك! أريد الاستفسار عن...',
        'button_text': 'إرسال رسالة',
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
            'image_url':
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
            'button_text': 'اشترِ الآن',
          },
        ],
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
          {'platform': 'whatsapp', 'url': 'https://wa.me/'},
        ],
      });
    } else if (type == 'pricing') {
      blocks.add({
        'type': 'pricing',
        'schema_version': 2,
        'title': 'خطط الأسعار',
        'subtitle': 'اختر الخطة التي تناسب أعمالك',
        'has_toggle': true,
        'toggle_labels': {'monthly': 'شهري', 'yearly': 'سنوي'},
        'items': [
          {
            'plan_id': const Uuid().v4(),
            'name': 'الخطة الأساسية',
            'prices': {'monthly': 100, 'yearly': 1000},
            'billing_ids': {'monthly': '', 'yearly': ''},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'discount_mode': 'auto',
            'features': ['ميزة أساسية 1', 'ميزة أساسية 2'],
            'button_text': 'ابدأ الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': false,
          },
          {
            'plan_id': const Uuid().v4(),
            'name': 'خطة المحترفين',
            'prices': {'monthly': 250, 'yearly': 2500},
            'billing_ids': {'monthly': '', 'yearly': ''},
            'currency': 'ج.م',
            'periods': {'monthly': '/ شهر', 'yearly': '/ سنة'},
            'discount_mode': 'manual',
            'manual_discount_text': 'الأكثر توفيراً',
            'features': ['كل المزايا الأساسية', 'ميزة احترافية', 'دعم أولوية'],
            'button_text': 'اشترك الآن',
            'button_action_type': 'link',
            'button_action_value': '',
            'is_popular': true,
          },
        ],
      });
    } else if (type == 'faq') {
      blocks.add({
        'type': 'faq',
        'title': 'الأسئلة الشائعة',
        'items': [
          {'question': 'سؤال؟', 'answer': 'إجابة مفصلة.'},
        ],
      });
    } else if (type == 'testimonials') {
      blocks.add({
        'type': 'testimonials',
        'title': 'قالوا عنا',
        'items': [
          {'author': 'الاسم', 'role': 'الوظيفة', 'quote': 'رأيه هنا.'},
        ],
      });
    } else if (type == 'contact_info') {
      blocks.add({
        'type': 'contact_info',
        'title': 'تواصل معنا',
        'email': 'contact@example.com',
        'phone': '+20',
        'location': 'القاهرة، مصر',
      });
    } else if (type == 'working_hours') {
      blocks.add({
        'type': 'working_hours',
        'title': 'مواعيد العمل',
        'schedule': {
          'السبت - الخميس': '10:00 AM - 10:00 PM',
          'الجمعة': '2:00 PM - 10:00 PM',
        },
      });
    } else if (type == 'location_map') {
      blocks.add({
        'type': 'location_map',
        'title': 'موقعنا',
        'address': 'القاهرة، مصر',
        'map_iframe_url':
            'https://maps.google.com/maps?q=Cairo&t=&z=13&ie=UTF8&iwloc=&output=embed',
      });
    } else if (type == 'gallery') {
      blocks.add({
        'type': 'gallery',
        'title': 'معرض الصور',
        'items': [
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800',
        ],
      });
    } else if (type == 'multi_step_lead_form') {
      blocks.add({
        'type': 'multi_step_lead_form',
        'schema_version': 1,
        'title': 'طلب تسعير',
        'subtitle': 'أجب على الأسئلة للحصول على عرض سعر دقيق',
        'success_message': 'تم الإرسال بنجاح!',
        'enable_local_save': true,
        'steps': [
          {
            'step_id': const Uuid().v4(),
            'step_title': 'البيانات الأساسية',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'text',
                'label': 'الاسم الكامل',
                'placeholder': 'أدخل اسمك ثلاثياً',
                'is_required': true,
                'validation': {'min_length': 3},
              },
              {
                'field_id': const Uuid().v4(),
                'field_type': 'radio',
                'label': 'نوع الحساب',
                'options': [
                  {'value': 'individual', 'label': 'فرد'},
                  {'value': 'business', 'label': 'شركة'},
                ],
                'is_required': true,
              },
            ],
          },
          {
            'step_id': const Uuid().v4(),
            'step_title': 'معلومات الاتصال',
            'fields': [
              {
                'field_id': const Uuid().v4(),
                'field_type': 'phone',
                'label': 'رقم الهاتف',
                'placeholder': '+201xxxxxxxxx',
                'is_required': true,
              },
            ],
          },
        ],
      });
    } else if (type == 'video_embed') {
      blocks.add({
        'type': 'video_embed',
        'title': 'شاهد كيف نعمل',
        'subtitle': 'فيديو تعريفي قصير يوضح مزايا المنصة.',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'aspect_ratio': '16:9',
        'max_width': 900,
        'use_thumbnail': true,
        'autoplay': false,
        'show_controls': true,
      });
    } else if (type == 'trust_logos') {
      blocks.add({
        'type': 'trust_logos',
        'title': 'شركاء نعتز بهم',
        'items': [
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
        ],
      });
    } else if (type == 'animated_counter') {
      blocks.add({
        'type': 'animated_counter',
        'title': 'أرقام تتحدث عن نفسها',
        'items': [
          {'value': '150', 'label': 'عميل سعيد', 'prefix': '+', 'suffix': ''},
          {'value': '99', 'label': 'نسبة الرضا', 'prefix': '', 'suffix': '%'},
          {'value': '24', 'label': 'ساعة دعم', 'prefix': '', 'suffix': '/7'},
        ],
      });
    } else if (type == 'basic_section') {
      blocks.add({
        'type': 'basic_section',
        'title': 'قسم مرن جديد',
        'layout_direction': 'column',
        'main_axis_alignment': 'center',
        'cross_axis_alignment': 'center',
        'spacing': 20.0,
      });
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateStickyCta(String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final Map<String, dynamic> stickyCta = Map<String, dynamic>.from(
      newDesign['sticky_cta'] ?? {},
    );

    stickyCta[key] = value;
    newDesign['sticky_cta'] = stickyCta;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addPricingPlan(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
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
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deletePricingPlan(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updatePricingPlan(
    int blockIndex,
    int itemIndex,
    String key,
    dynamic value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addFaqItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({'question': 'سؤال جديد؟', 'answer': 'الإجابة هنا.'});
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteFaqItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateFaqItem(int blockIndex, int itemIndex, String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addTestimonialItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({
        'author': 'عميل جديد',
        'role': 'وظيفة',
        'quote': 'رأي العميل هنا.',
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteTestimonialItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateTestimonialItem(
    int blockIndex,
    int itemIndex,
    String key,
    String value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addGalleryImage(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add(
        'https://images.unsplash.com/photo-1542744094-3a31f103e35f?w=800',
      );
      updatedBlock['items'] = items;

      // Sync parallel gallery_links list
      final List galleryLinks = List.from(updatedBlock['gallery_links'] ?? []);
      galleryLinks.add('');
      updatedBlock['gallery_links'] = galleryLinks;

      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteGalleryImage(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;

      // Sync parallel gallery_links list
      final List galleryLinks = List.from(updatedBlock['gallery_links'] ?? []);
      if (itemIndex >= 0 && itemIndex < galleryLinks.length) {
        galleryLinks.removeAt(itemIndex);
      }
      updatedBlock['gallery_links'] = galleryLinks;

      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateGalleryImage(int blockIndex, int itemIndex, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items[itemIndex] = value;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteBlock(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      blocks.removeAt(index);
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void reorderBlocks(int oldIndex, int newIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final blocks = List<Map<String, dynamic>>.from(
      currentState.designMap['blocks'],
    );
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    newDesign['blocks'] = blocks;

    _emitDirty(
      currentState.copyWith(
        designMap: newDesign,
        focusedSectionIndex: newIndex,
      ),
    );
  }

  void moveBlock(int index, bool up) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    final targetIndex = up ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= blocks.length) return;

    final temp = blocks[index];
    blocks[index] = blocks[targetIndex];
    blocks[targetIndex] = temp;

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateBlockProperty(int index, String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[index],
      );

      // Support nested updates like 'layout_config.direction'
      if (key.contains('.')) {
        final parts = key.split('.');
        final parentKey = parts[0];
        final childKey = parts[1];
        final Map<String, dynamic> parent = Map<String, dynamic>.from(
          updatedBlock[parentKey] ?? {},
        );
        parent[childKey] = value;
        updatedBlock[parentKey] = parent;
      } else {
        updatedBlock[key] = value;
      }

      blocks[index] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateFeatureItem(
    int blockIndex,
    int itemIndex,
    String key,
    String value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void addProductItem(int blockIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      items.add({
        'id': const Uuid().v4(),
        'name': 'منتج جديد',
        'price': '0.00 EGP',
        'description': 'وصف قصير للمنتج.',
        'image_url':
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        'button_text': 'اشترِ الآن',
      });
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void deleteProductItem(int blockIndex, int itemIndex) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        items.removeAt(itemIndex);
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateProductItem(
    int blockIndex,
    int itemIndex,
    String key,
    String value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (blockIndex >= 0 && blockIndex < blocks.length) {
      final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
        blocks[blockIndex],
      );
      final List items = List.from(updatedBlock['items'] ?? []);
      if (itemIndex >= 0 && itemIndex < items.length) {
        final Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
          items[itemIndex],
        );
        updatedItem[key] = value;
        items[itemIndex] = updatedItem;
      }
      updatedBlock['items'] = items;
      blocks[blockIndex] = updatedBlock;
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateMetadata(String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    newDesign[key] = value;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void selectSection(int? index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    _emitDirty(
      currentState.copyWith(
        focusedSectionIndex: index,
        clearFocusedElement: index == null,
      ),
    );
  }

  void focusElement(int sectionIndex, String elementId) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    _emitDirty(
      currentState.copyWith(
        focusedSectionIndex: sectionIndex,
        focusedElementId: elementId,
      ),
    );
  }

  void duplicateBlock(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);
    if (index >= 0 && index < blocks.length) {
      final duplicate = Map<String, dynamic>.from(blocks[index]);
      blocks.insert(index + 1, duplicate);
    }

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void toggleBlockVisibility(int index) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final blocks = List<Map<String, dynamic>>.from(
      currentState.designMap['blocks'],
    );
    final block = Map<String, dynamic>.from(blocks[index]);

    final bool isVisible = block['is_visible'] ?? true;
    block['is_visible'] = !isVisible;
    blocks[index] = block;

    final newDesign = Map<String, dynamic>.from(currentState.designMap);
    newDesign['blocks'] = blocks;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  void updateElementProperty(
    int sectionIndex,
    String elementId,
    String key,
    dynamic value,
  ) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);

    if (sectionIndex >= 0 && sectionIndex < blocks.length) {
      final Map<String, dynamic> block = Map<String, dynamic>.from(
        blocks[sectionIndex],
      );
      final List elements = List.from(block['elements'] ?? []);

      final int elementIndex = elements.indexWhere((e) => e['id'] == elementId);
      if (elementIndex != -1) {
        final Map<String, dynamic> element = Map<String, dynamic>.from(
          elements[elementIndex],
        );
        final Map<String, dynamic> styles = Map<String, dynamic>.from(
          element['style_overrides'] ?? {},
        );

        styles[key] = value;
        element['style_overrides'] = styles;
        elements[elementIndex] = element;
        block['elements'] = elements;
        blocks[sectionIndex] = block;
        newDesign['blocks'] = blocks;

        _emitDirty(currentState.copyWith(designMap: newDesign));
      }
    }
  }

  void clearMessages() {
    final currentState = state;
    if (currentState is BuilderLoaded) {
      _emitDirty(
        currentState.copyWith(errorMessage: null, successMessage: null),
      );
    }
  }

  Future<void> uploadBlockImage(int index, PlatformFile file) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    _emitDirty(currentState.copyWith(isSaving: true, errorMessage: null));
    try {
      final publicUrl = await _storageService.uploadImage(file);
      if (publicUrl != null) {
        final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
          currentState.designMap,
        );
        final List blocks = List.from(newDesign['blocks'] ?? []);
        if (index >= 0 && index < blocks.length) {
          final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
            blocks[index],
          );
          updatedBlock['image_url'] = publicUrl;
          blocks[index] = updatedBlock;
        }
        newDesign['blocks'] = blocks;
        _emitDirty(
          currentState.copyWith(
            designMap: newDesign,
            isSaving: false,
            successMessage: "تم رفع الصورة بنجاح!",
          ),
        );
      } else {
        _emitDirty(
          currentState.copyWith(
            isSaving: false,
            errorMessage: "فشل رفع الصورة.",
          ),
        );
      }
    } catch (e) {
      final humanError = ErrorHandler.getHumanReadableError(e);
      _emitDirty(
        currentState.copyWith(isSaving: false, errorMessage: humanError),
      );
    }
  }

  Future<void> uploadBlockBackgroundImage(int index, PlatformFile file) async {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    _emitDirty(currentState.copyWith(isSaving: true, errorMessage: null));
    try {
      final publicUrl = await _storageService.uploadImage(file);
      if (publicUrl != null) {
        final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
          currentState.designMap,
        );
        final List blocks = List.from(newDesign['blocks'] ?? []);
        if (index >= 0 && index < blocks.length) {
          final Map<String, dynamic> updatedBlock = Map<String, dynamic>.from(
            blocks[index],
          );
          updatedBlock['bg_image_url'] = publicUrl;
          blocks[index] = updatedBlock;
        }
        newDesign['blocks'] = blocks;
        _emitDirty(
          currentState.copyWith(
            designMap: newDesign,
            isSaving: false,
            successMessage: "تم رفع صورة الخلفية بنجاح!",
          ),
        );
      } else {
        _emitDirty(
          currentState.copyWith(
            isSaving: false,
            errorMessage: "فشل رفع صورة الخلفية.",
          ),
        );
      }
    } catch (e) {
      final humanError = ErrorHandler.getHumanReadableError(e);
      _emitDirty(
        currentState.copyWith(isSaving: false, errorMessage: humanError),
      );
    }
  }
}
