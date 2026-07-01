part of 'builder_cubit.dart';

/// Mixin containing block CRUD operations for [LandingPageBuilderCubit].
mixin BuilderCubitBlocks on Cubit<BuilderState> {
  // Satisfied by LandingPageBuilderCubit._emitDirty
  void _emitDirty(
    BuilderLoaded state);

  void importTemplateAssets(UploadManagerCubit uploadManager);

  /// Creates and appends a new block of [type] to the design.
  ///
  /// Each type has a default preset (hero, features, pricing, faq, gallery, etc.).
  /// Optional [presetOverrides] are deep-merged into the default preset via
  /// `_mergeBlockPreset`. Triggers `importTemplateAssets` for any override images.
  /// Called from the block-picker panel.
  void addBlock(String type, {Map<String, dynamic>? presetOverrides}) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    final List blocks = List.from(newDesign['blocks'] ?? []);

    Map<String, dynamic>? blockToAdd;

    if (type == 'hero' || type == 'hero_saas') {
      blockToAdd = {
        'type': type,
        'title': type == 'hero_saas'
            ? 'منصتك الشاملة لإدارة الأعمال'
            : 'عنوان القسم الرئيسي الجديد',
        'subtitle': type == 'hero_saas'
            ? 'نظام متكامل يجمع كل ما تحتاجه لإدارة مشروعك بكفاءة.'
            : 'اكتب هنا عرض القيمة الأساسي لخدمتك أو منتجك.',
        'button_text': 'ابدأ الآن مجاناً',
        'image_url': AppConstants.placeholderLargeImageUrl,
        'badge_text': type == 'hero_saas' ? 'مميز' : 'جديد',
        if (type == 'hero_saas')
          'tech_logos': [
            'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
            'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          ],
      };
    } else if (type == 'logo_header') {
      blockToAdd = {
        'type': 'logo_header',
        'title': 'اسم العلامة التجارية',
        'logo_url': AppConstants.placeholderImageUrl,
        'alignment': 'center',
        'logo_height': 48.0,
      };
    } else if (type == 'features') {
      blockToAdd = {
        'type': 'features',
        'title': 'لماذا نحن؟',
        'layout_style': 'grid',
        'items': [
          {'title': 'ميزة 1', 'description': 'اشرح فوائد هذه الميزة هنا.', 'image_url': AppConstants.placeholderImageUrl},
          {'title': 'ميزة 2', 'description': 'سلط الضوء على أهمية هذا البند.', 'image_url': AppConstants.placeholderImageUrl},
        ],
      };
    } else if (type == 'lead_form') {
      blockToAdd = {
        'type': 'lead_form',
        'title': 'تواصل معنا اليوم',
        'button_text': 'إرسال',
        'fields': [
          {
            'field_id': 'name',
            'field_type': 'text',
            'label': 'الاسم الكامل',
            'placeholder': 'أدخل اسمك',
            'is_required': true,
          },
          {
            'field_id': 'phone',
            'field_type': 'text',
            'label': 'رقم الجوال',
            'placeholder': '05xxxxxxxx',
            'is_required': true,
          },
          {
            'field_id': 'message',
            'field_type': 'textarea',
            'label': 'رسالتك',
            'placeholder': 'كيف يمكننا مساعدتك؟',
            'is_required': false,
          },
        ],
      };
    } else if (type == 'lead_magnet') {
      blockToAdd = {
        'type': 'lead_magnet',
        'title': 'احصل على دليلك المجاني',
        'subtitle':
            'سجل الآن لتحصل على نسخة مجانية من الدليل الشامل لزيادة مبيعاتك بنسبة 300%.',
        'button_text': 'أرسل الدليل الآن',
        'image_url':
            AppConstants.placeholderLargeImageUrl,
        'fields': [
          {
            'field_id': 'name',
            'field_type': 'text',
            'label': 'الاسم الكامل',
            'placeholder': 'أدخل اسمك',
            'is_required': true,
          },
          {
            'field_id': 'email',
            'field_type': 'email',
            'label': 'البريد الإلكتروني',
            'placeholder': 'example@domain.com',
            'is_required': true,
          },
          {
            'field_id': 'phone',
            'field_type': 'text',
            'label': 'رقم الجوال',
            'placeholder': '05xxxxxxxx',
            'is_required': false,
          },
        ],
      };
    } else if (type == 'whatsapp') {
      blockToAdd = {
        'type': 'whatsapp',
        'title': 'تواصل معنا عبر واتساب',
        'phone_number': '+201234567890',
        'message': 'أهلاً بك! أريد الاستفسار عن...',
        'button_text': 'إرسال رسالة',
      };
    } else if (type == 'products') {
      blockToAdd = {
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
                AppConstants.placeholderImageUrl,
            'button_text': 'اشترِ الآن',
          },
        ],
      };
    } else if (type == 'qr_code') {
      blockToAdd = {
        'type': 'qr_code',
        'title': 'امسح الكود لزيارة موقعنا',
        'subtitle': 'شارك الصفحة بسهولة.',
        'qr_size': 200.0,
      };
    } else if (type == 'social_qr') {
      blockToAdd = {
        'type': 'social_qr',
        'title': 'تواصل معنا',
        'subtitle': 'تابعنا على منصات التواصل',
        'links': [
          {'platform': 'instagram', 'url': 'https://instagram.com'},
          {'platform': 'whatsapp', 'url': 'https://wa.me/'},
        ],
      };
    } else if (type == 'pricing') {
      blockToAdd = {
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
      };
    } else if (type == 'featured_product') {
      blockToAdd = {
        'type': 'featured_product',
        'name': 'اسم المنتج المميز',
        'price': '0.00',
        'description': 'وصف مختصر للمنتج يبرز أهم مميزاته.',
        'image_url':
            AppConstants.placeholderLargeImageUrl,
        'button_text': 'إضافة للسلة',
        'layout_style': 'split',
      };
    } else if (type == 'bento_store') {
      blockToAdd = {
        'type': 'bento_store',
        'title': 'مجموعاتنا المختارة',
        'items': [
          {
            'id': const Uuid().v4(),
            'name': 'منتج 1',
            'price': '0 EGP',
            'image_url':
                AppConstants.placeholderLargeImageUrl,
          },
          {
            'id': const Uuid().v4(),
            'name': 'منتج 2',
            'price': '0 EGP',
            'image_url':
                AppConstants.placeholderLargeImageUrl,
          },
        ],
        'layout_style': 'modern',
      };
    } else if (type == 'faq') {
      blockToAdd = {
        'type': 'faq',
        'title': 'الأسئلة الشائعة',
        'items': [
          {'question': 'سؤال؟', 'answer': 'إجابة مفصلة.'},
        ],
      };
    } else if (type == 'testimonials') {
      blockToAdd = {
        'type': 'testimonials',
        'title': 'قالوا عنا',
        'items': [
          {'author': 'الاسم', 'role': 'الوظيفة', 'quote': 'رأيه هنا.', 'image_url': AppConstants.placeholderImageUrl},
        ],
      };
    } else if (type == 'contact_info') {
      blockToAdd = {
        'type': 'contact_info',
        'title': 'تواصل معنا',
        'email': 'contact@example.com',
        'phone': '+20',
        'location': 'القاهرة، مصر',
      };
    } else if (type == 'working_hours') {
      blockToAdd = {
        'type': 'working_hours',
        'title': 'مواعيد العمل',
        'schedule': {
          'السبت - الخميس': '10:00 AM - 10:00 PM',
          'الجمعة': '2:00 PM - 10:00 PM',
        },
      };
    } else if (type == 'location_map') {
      blockToAdd = {
        'type': 'location_map',
        'title': 'موقعنا',
        'address': 'القاهرة، مصر',
        'map_iframe_url':
            'https://maps.google.com/maps?q=Cairo&t=&z=13&ie=UTF8&iwloc=&output=embed',
      };
    } else if (type == 'gallery') {
      blockToAdd = {
        'type': 'gallery',
        'title': 'معرض الصور',
        'items': [
          AppConstants.placeholderLargeImageUrl,
        ],
      };
    } else if (type == 'multi_step_lead_form') {
      blockToAdd = {
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
      };
    } else if (type == 'video_embed') {
      blockToAdd = {
        'type': 'video_embed',
        'title': 'شاهد كيف نعمل',
        'subtitle': 'فيديو تعريفي قصير يوضح مزايا المنصة.',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'aspect_ratio': '16:9',
        'max_width': 900,
        'use_thumbnail': true,
        'autoplay': false,
        'show_controls': true,
      };
    } else if (type == 'trust_logos') {
      blockToAdd = {
        'type': 'trust_logos',
        'title': 'شركاء نعتز بهم',
        'items': [
          'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/5/51/IBM_logo.svg',
          'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
        ],
      };
    } else if (type == 'animated_counter') {
      blockToAdd = {
        'type': 'animated_counter',
        'title': 'أرقام تتحدث عن نفسها',
        'items': [
          {'value': '150', 'label': 'عميل سعيد', 'prefix': '+', 'suffix': ''},
          {'value': '99', 'label': 'نسبة الرضا', 'prefix': '', 'suffix': '%'},
          {'value': '24', 'label': 'ساعة دعم', 'prefix': '', 'suffix': '/7'},
        ],
      };
    } else if (type == 'basic_section') {
      blockToAdd = {
        'type': 'basic_section',
        'title': 'قسم مرن جديد',
        'layout_direction': 'column',
        'main_axis_alignment': 'center',
        'cross_axis_alignment': 'center',
        'spacing': 20.0,
        'elements': [
          {
            'id': const Uuid().v4(),
            'type': 'text',
            'content': 'اكتب النص هنا',
          },
          {
            'id': const Uuid().v4(),
            'type': 'text',
            'content': 'نص إضافي يمكنك تعديله',
          },
        ],
      };
    } else if (type == 'team_members') {
      blockToAdd = {
        'type': 'team_members',
        'title': 'فريق العمل',
        'subtitle': 'تعرف على المبدعين خلف نجاح هذا المشروع.',
        'layout_style': 'grid',
        'items': [
          {
            'name': 'الاسم الكامل',
            'role': 'المسمى الوظيفي',
            'bio': 'نبذة مختصرة توضح دور هذا الشخص وخبرته.',
            'image_url': AppConstants.placeholderImageUrl,
          },
        ],
      };
    } else if (type == 'statistics_grid') {
      blockToAdd = {
        'type': 'statistics_grid',
        'title': 'إحصائياتنا',
        'subtitle': 'أرقام تتحدث عن نجاحنا',
        'layout_style': 'horizontal',
        'items': [
          {'value': '500+', 'label': 'عميل سعيد', 'icon': 'people'},
          {'value': '12', 'label': 'سنة خبرة', 'icon': 'star'},
          {'value': '24/7', 'label': 'دعم فني', 'icon': 'speed'},
          {'value': '100%', 'label': 'جودة مضمونة', 'icon': 'check'},
        ],
      };
    } else if (type == 'service_steps') {
      blockToAdd = {
        'type': 'service_steps',
        'title': 'خطوات العمل',
        'subtitle': 'ثلاث خطوات بسيطة للبدء',
        'items': [
          {'title': 'الخطوة الأولى', 'description': 'تواصل معنا وسجل طلبك'},
          {'title': 'الخطوة الثانية', 'description': 'اختر الباقة المناسبة لاحتياجك'},
          {'title': 'الخطوة الثالثة', 'description': 'استلم خدمتك وانطلق'},
        ],
      };
    } else if (type == 'cta_banner') {
      blockToAdd = {
        'type': 'cta_banner',
        'title': 'هل أنت جاهز للبدء؟',
        'subtitle': 'انضم إلينا اليوم واحصل على عرض خاص.',
        'button_text': 'سجل الآن',
        'layout_style': 'centeredGradient',
      };
    } else if (type == 'comparison_table') {
      blockToAdd = {
        'type': 'comparison_table',
        'title': 'جدول المقارنة',
        'subtitle': 'قارن بين الباقات واختر الأنسب لك',
        'plans': [
          {'name': 'الباقة الأساسية', 'price': 'مجاني'},
          {'name': 'الباقة الاحترافية', 'price': '99\$'},
        ],
        'features': [
          {'name': 'الميزة الأولى', 'values': [true, true]},
          {'name': 'الميزة الثانية', 'values': [false, true]},
          {'name': 'الدعم الفني', 'values': ['بريد إلكتروني', 'دعم هاتفي']},
        ],
      };
    }

    if (blockToAdd == null) return;
    if (presetOverrides != null && presetOverrides.isNotEmpty) {
      blockToAdd = _mergeBlockPreset(blockToAdd, presetOverrides);
    }
    blocks.add(blockToAdd);

    newDesign['blocks'] = blocks;
    _emitDirty(currentState.copyWith(designMap: newDesign));

    // Trigger import for new block assets (background images, etc. in overrides)
    // importTemplateAssets(sl<UploadManagerCubit>());
  }

  /// Deep-merges [overrides] into [base] map (recursive for nested maps).
  ///
  /// Lists are replaced entirely (not merged). Used by `addBlock` to apply
  /// preset overrides onto a block default.
  Map<String, dynamic> _mergeBlockPreset(
    Map<String, dynamic> base,
    Map<String, dynamic> overrides,
  ) {
    final merged = Map<String, dynamic>.from(base);
    overrides.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          merged[key] is Map<String, dynamic>) {
        merged[key] = _mergeBlockPreset(
          Map<String, dynamic>.from(merged[key] as Map<String, dynamic>),
          value,
        );
      } else if (value is List) {
        merged[key] = List.from(value);
      } else {
        merged[key] = value;
      }
    });
    return merged;
  }

  /// Updates a single property of the sticky CTA (`sticky_cta` in designMap).
  ///
  /// Called when the user edits the floating action button settings.
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

  /// Updates a specific field [key] on a pricing plan [itemIndex] inside the
  /// pricing block at [blockIndex].
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

  // (addFaqItem, deleteFaqItem, updateFaqItem, addTestimonialItem, etc. moved to
  //  BuilderCubitBlocksItems in builder_cubit_blocks_items.dart)

  /// Removes the block at [index] from the blocks list.
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

  /// Moves a block from [oldIndex] to [newIndex] in the blocks list.
  ///
  /// Also sets `focusedSectionIndex` to the new position.
  /// Called from drag-and-drop reorder in the workspace.
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

  /// Moves the block at [index] one step up or down.
  ///
  /// [up] = true moves toward index 0, false moves toward the end.
  /// No-op if the block is already at the edge.
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

  /// Updates a single property [key] on the block at [index].
  ///
  /// Supports dot-notation nested keys (e.g. `'layout_config.direction'`).
  /// This is the workhorse method for most property-panel edits.
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

  // (updateFeatureItem, addProductItem, deleteProductItem, updateProductItem moved to
  //  BuilderCubitBlocksItems in builder_cubit_blocks_items.dart)

  /// Sets a top-level key in `designMap` (e.g. `business_name`, `meta_description`).
  void updateMetadata(String key, dynamic value) {
    final currentState = state;
    if (currentState is! BuilderLoaded) return;

    final Map<String, dynamic> newDesign = Map<String, dynamic>.from(
      currentState.designMap,
    );
    newDesign[key] = value;

    _emitDirty(currentState.copyWith(designMap: newDesign));
  }

  /// Sets the currently focused/selected section index.
  ///
  /// Passing `null` deselects (clears focus).
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

  /// Focuses a specific element (by [elementId]) inside the section at [sectionIndex].
  ///
  /// Used for long-press element selection in the canvas.
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

  /// Deep-copies the block at [index] and inserts the copy right after it.
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

  /// Toggles the `is_visible` flag on the block at [index].
  ///
  /// Hidden blocks remain in the design but are not rendered on the published page.
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

  /// Updates a `style_overrides` property on a sub-element (identified by [elementId])
  /// inside the section at [sectionIndex].
  ///
  /// Used for granular element-level style editing (e.g. font size, colour of a heading).
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
}
