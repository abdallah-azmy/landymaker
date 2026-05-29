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
import '../registries/template_registry.dart';
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
            'subtitle': 'منصة لاندي ميكر توفر لك كل الأدوات التي تحتاجها للنمو.',
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
      // 1. Check Multi-Page Guard (SPEC 3)
      if (currentState.pageId == null) {
        final profile = await _databaseService.getProfile(userId);
        final existingPages = await _databaseService.getLandingPagesByUserId(userId);
        final String tier = profile?['tier'] ?? 'free';
        final int limit = profile?['custom_max_pages'] ?? (tier == 'pro' ? 5 : (tier == 'enterprise' ? 999 : 1));

        if (existingPages.length >= limit) {
          emit(currentState.copyWith(
            isSaving: false,
            errorMessage: "لقد وصلت للحد الأقصى لعدد الصفحات المسموح به في خطتك الحالية (\$tier).",
          ));
          return;
        }
      }

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

    final newDesign = TemplateRegistry.getTemplateDesign(templateType);
    final newTheme = TemplateRegistry.getTemplateTheme(templateType);

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

  void updateMetadata(String key, String value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    newDesign[key] = value;

    emit(currentState.copyWith(designMap: newDesign));
  }

  void focusElement(int sectionIndex, String? elementId) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;
    
    emit(currentState.copyWith(
      focusedSectionIndex: sectionIndex,
      focusedElementId: elementId,
    ));
  }

  void updateElementProperty(int sectionIndex, String elementId, String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(currentState.designMap);
    final List blocks = List.from(newDesign['blocks'] ?? []);
    
    if (sectionIndex >= 0 && sectionIndex < blocks.length) {
      final Map<String, dynamic> block = Map<String, dynamic>.from(blocks[sectionIndex]);
      final List elements = List.from(block['elements'] ?? []);
      
      final int elementIndex = elements.indexWhere((e) => e['id'] == elementId);
      if (elementIndex != -1) {
        final Map<String, dynamic> element = Map<String, dynamic>.from(elements[elementIndex]);
        final Map<String, dynamic> styles = Map<String, dynamic>.from(element['style_overrides'] ?? {});
        
        styles[key] = value;
        element['style_overrides'] = styles;
        elements[elementIndex] = element;
        block['elements'] = elements;
        blocks[sectionIndex] = block;
        newDesign['blocks'] = blocks;
        
        emit(currentState.copyWith(designMap: newDesign));
      }
    }
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
