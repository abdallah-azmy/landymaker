import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../controllers/builder_cubit.dart';

class SectionLibraryModal extends StatefulWidget {
  const SectionLibraryModal({super.key});

  @override
  State<SectionLibraryModal> createState() => _SectionLibraryModalState();
}

class _SectionLibraryModalState extends State<SectionLibraryModal> {
  String _searchQuery = "";
  String _selectedCategory = "all";

  static final List<_SectionDefinition> _sections = [
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
          'variant_style': 'centered',
          'alignment': 'center',
          'logo_height': 48.0,
        }),
        _variant('يمين/بداية', 'مناسب للعلامات الرسمية', 'split', {
          'variant_style': 'edge_aligned',
          'alignment': 'right',
          'logo_height': 42.0,
        }),
        _variant('هيدر داكن', 'شريط واضح أعلى الصفحة', 'dark', {
          'variant_style': 'dark_bar',
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
          'variant_style': 'split_visual',
          'vertical_padding': 88.0,
        }),
        _variant('Hero كثيف', 'مناسب للحملات الإعلانية', 'centered', {
          'variant_style': 'compact_center',
          'vertical_padding': 48.0,
          'bg_overlay_color': '#111827',
          'bg_overlay_opacity': 0.08,
        }),
        _variant('خلفية قوية', 'صورة كاملة مع طبقة داكنة', 'immersive', {
          'variant_style': 'image_backdrop',
          'vertical_padding': 108.0,
          'bg_image_url':
              'https://cdn.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg',
          'bg_overlay_color': '#020617',
          'bg_overlay_opacity': 0.62,
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
          'variant_style': 'vertical_stack',
          'layout_direction': 'column',
          'spacing': 20.0,
          'vertical_padding': 64.0,
        }),
        _variant('صفّي', 'مناسب لمقارنة أو عرض سريع', 'split', {
          'variant_style': 'horizontal_split',
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
          'variant_style': 'dashboard_split',
          'vertical_padding': 86.0,
        }),
        _variant('Launch', 'عرض إطلاق منتج سريع', 'centered', {
          'variant_style': 'launch_center',
          'vertical_padding': 68.0,
          'bg_overlay_color': '#EEF2FF',
          'bg_overlay_opacity': 1.0,
        }),
        _variant('Dark SaaS', 'نمط تقني داكن', 'dark', {
          'variant_style': 'dark_saas',
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
          'variant_style': 'logo_strip',
        }),
        _variant('ثقة داكنة', 'خلفية داكنة للشركات', 'dark', {
          'variant_style': 'dark_trust',
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
          'variant_style': 'three_metrics',
        }),
        _variant('Impact', 'أربعة مؤشرات للحملات', 'metrics4', {
          'variant_style': 'impact_grid',
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
          'variant_style': 'quote_wizard',
          'title': 'طلب تسعير سريع',
        }),
        _variant('حجز موعد', 'مناسب للعيادات والخدمات', 'form_steps', {
          'variant_style': 'appointment_wizard',
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
          'variant_style': 'centered_form',
        }),
        _variant('خلفية صورة', 'نموذج واضح فوق خلفية', 'form_dark', {
          'variant_style': 'image_form',
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
          'variant_style': 'guide_download',
        }),
        _variant('كوبون', 'عرض ترويجي سريع', 'offer', {
          'variant_style': 'coupon_capture',
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
          'variant_style': 'feature_grid',
          'layout_style': 'grid',
        }),
        _variant('Bento', 'بطاقات بأحجام مختلفة', 'bento', {
          'variant_style': 'feature_bento',
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
          'variant_style': 'simple_chat',
        }),
        _variant('حجز سريع', 'نص مناسب للمواعيد', 'cta_dark', {
          'variant_style': 'booking_chat',
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
          'variant_style': 'product_grid_2',
          'layout_style': 'grid_2',
        }),
        _variant('شبكة ٣', 'كاتالوج أكبر', 'grid3', {
          'variant_style': 'product_grid_3',
          'layout_style': 'grid_3',
        }),
        _variant('قائمة', 'قائمة أسعار أو منيو', 'list', {
          'variant_style': 'product_list',
          'layout_style': 'list',
          'show_category_filter': false,
        }),
        _variant('شريط متحرك', 'تصفح أفقي للمنتجات', 'gallery_carousel', {
          'variant_style': 'product_carousel',
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
          'variant_style': 'toggle_pricing',
          'layout_style': 'cards',
          'has_toggle': true,
        }),
        _variant('باقات ثابتة', 'خدمات أو أسعار مباشرة', 'pricing_cards', {
          'variant_style': 'fixed_packages',
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
          'variant_style': 'short_faq',
        }),
        _variant('اعتراضات البيع', 'أسئلة تحويل وطمأنة', 'accordion_dense', {
          'variant_style': 'conversion_faq',
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
          'variant_style': 'testimonial_cards',
          'layout_style': 'masonry',
        }),
        _variant('قصص نجاح', 'نصوص أطول ونتائج', 'quotes_dense', {
          'variant_style': 'success_stories',
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
          'variant_style': 'contact_cards',
        }),
        _variant('داكن', 'ختام واضح للصفحة', 'dark', {
          'variant_style': 'dark_contact',
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
          'variant_style': 'weekly_hours',
        }),
        _variant('عيادة/حجز', 'مواعيد محددة للخدمات', 'schedule_split', {
          'variant_style': 'appointment_hours',
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
          'variant_style': 'full_map',
        }),
        _variant('فرع رئيسي', 'عنوان واضح قبل الخريطة', 'map_pin', {
          'variant_style': 'branch_map',
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
          'variant_style': 'wide_video',
          'aspect_ratio': '16:9',
          'max_width': 900,
        }),
        _variant('فيديو مركز', 'عرض أقصر وأكثر تركيزاً', 'video_compact', {
          'variant_style': 'compact_video',
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
          'variant_style': 'gallery_grid',
          'display_mode': 'grid',
          'grid_columns': 3,
        }),
        _variant('Carousel', 'صورة كبيرة قابلة للتنقل', 'gallery_carousel', {
          'variant_style': 'gallery_carousel',
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
          'variant_style': 'standard_qr',
          'qr_size': 200.0,
        }),
        _variant('كبير', 'للطباعة أو الفعاليات', 'qr_big', {
          'variant_style': 'large_qr',
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
          'variant_style': 'social_links',
        }),
        _variant('Creator', 'للمؤثرين والحسابات الشخصية', 'social_creator', {
          'variant_style': 'creator_social',
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final categories = {
      'all': 'الكل',
      'popular': 'شائع ومهم',
      'basic': 'أساسي',
      'conversion': 'مبيعات',
      'trust': 'ثقة',
      'content': 'محتوى',
      'ecommerce': 'تجارة',
      'contact': 'تواصل',
    };

    final filteredSections = _sections.where((section) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          section.name.toLowerCase().contains(q) ||
          section.desc.toLowerCase().contains(q) ||
          section.variants.any((variant) => variant.name.toLowerCase().contains(q));
      final matchesCategory =
          _selectedCategory == 'all' ||
          section.category == _selectedCategory ||
          (_selectedCategory == 'popular' && section.popular);
      return matchesSearch && matchesCategory;
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text("إضافة قسم جديد", style: AppTypography.h3),
              SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "بحث عن قسم أو شكل...",
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.entries.map((cat) {
                    final isSelected = _selectedCategory == cat.key;
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat.value,
                          style: AppTypography.caption.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat.key),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 18),
              Expanded(
                child: filteredSections.isEmpty
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final bool isSmall = constraints.maxWidth < 600;
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 340,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: isSmall ? 0.62 : 0.70,
                            ),
                            itemCount: filteredSections.length,
                            itemBuilder: (context, index) {
                              final section = filteredSections[index];
                              return _SectionVariantCard(
                                key: ValueKey(
                                  "${section.type}_${_selectedCategory}_${_searchQuery}_$index",
                                ),
                                section: section,
                                cubit: cubit,
                                index: index,
                              );
                            },
                          );
                        },
                      ),
              ),
              SizedBox(height: 14),
              PrimaryButton(
                text: "إغلاق",
                isSecondary: true,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          SizedBox(height: 12),
          Text("لا توجد أقسام تطابق بحثك", style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _SectionVariantCard extends StatefulWidget {
  final _SectionDefinition section;
  final LandingPageBuilderCubit cubit;
  final int index;

  const _SectionVariantCard({
    super.key,
    required this.section,
    required this.cubit,
    required this.index,
  });

  @override
  State<_SectionVariantCard> createState() => _SectionVariantCardState();
}

class _SectionVariantCardState extends State<_SectionVariantCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;
  int _selectedVariantIndex = 0;
  bool _isHovered = false;

  _SectionVariant get _selectedVariant =>
      widget.section.variants[_selectedVariantIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
    Future.delayed(Duration(milliseconds: widget.index * 24), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Transform.translate(
          offset: _slideAnimation.value * 40,
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8) : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.65)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: _isHovered ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 18 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.section.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.section.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.section.desc,
                          style: AppTypography.caption.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: _DualMiniPreview(
                  variant: _selectedVariant,
                  accent: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _selectedVariant.description,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(widget.section.variants.length, (index) {
                  final variant = widget.section.variants[index];
                  final isSelected = index == _selectedVariantIndex;
                  return InkWell(
                    onTap: () => setState(() => _selectedVariantIndex = index),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        variant.name,
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.cubit.addBlock(
                      widget.section.type,
                      presetOverrides: _selectedVariant.overrides,
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.add_rounded, size: 18),
                  label: Text("إضافة ${_selectedVariant.name}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DualMiniPreview extends StatelessWidget {
  final _SectionVariant variant;
  final Color accent;

  const _DualMiniPreview({required this.variant, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: _buildPreview(context, isMobile: true),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 65,
          child: _buildPreview(context, isMobile: false),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context, {required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMobile
              ? accent.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: _buildPattern(),
    );
  }

  Widget _buildPattern() {
    switch (variant.preview) {
      case 'centered':
        return _centeredHero();
      case 'immersive':
      case 'dark':
      case 'cta_dark':
      case 'form_dark':
        return _darkPanel();
      case 'split':
        return _split();
      case 'stack':
        return _stack();
      case 'logos':
        return _logos();
      case 'metrics':
        return _metrics(3);
      case 'metrics4':
        return _metrics(4);
      case 'form':
      case 'form_steps':
        return _form();
      case 'offer':
        return _offer();
      case 'grid':
      case 'gallery_grid':
        return _grid(2);
      case 'grid3':
        return _grid(3);
      case 'bento':
        return _bento();
      case 'list':
        return _list();
      case 'pricing':
      case 'pricing_cards':
        return _pricing();
      case 'accordion':
      case 'accordion_dense':
        return _accordion();
      case 'quotes':
      case 'quotes_dense':
        return _quotes();
      case 'contact_cards':
        return _contact();
      case 'schedule':
      case 'schedule_split':
        return _schedule();
      case 'map':
      case 'map_pin':
        return _map();
      case 'video':
      case 'video_compact':
        return _video();
      case 'gallery_carousel':
        return _carousel();
      case 'qr':
      case 'qr_big':
        return _qr();
      case 'social':
      case 'social_creator':
        return _social();
      default:
        return _split();
    }
  }

  Widget _bar(double width, {double height = 8, Color? color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _box({double? width, double? height, Color? color, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _split() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(74, height: 10, color: accent.withValues(alpha: 0.7)),
              SizedBox(height: 8),
              _bar(92),
              SizedBox(height: 6),
              _bar(58),
              SizedBox(height: 12),
              _box(width: 64, height: 18, color: accent),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(child: _box(height: double.infinity, radius: 12)),
      ],
    );
  }

  Widget _centeredHero() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _bar(96, height: 12, color: accent.withValues(alpha: 0.7)),
        SizedBox(height: 8),
        _bar(124),
        SizedBox(height: 6),
        _bar(82),
        SizedBox(height: 12),
        _box(width: 80, height: 20, color: accent),
      ],
    );
  }

  Widget _darkPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _centeredHero(),
    );
  }

  Widget _stack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _box(width: double.infinity, height: 24),
        SizedBox(height: 8),
        _box(width: double.infinity, height: 24, color: accent.withValues(alpha: 0.34)),
        SizedBox(height: 8),
        _box(width: double.infinity, height: 24),
      ],
    );
  }

  Widget _logos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (_) => _box(width: 26, height: 26, radius: 99)),
    );
  }

  Widget _metrics(int count) {
    return Row(
      children: List.generate(
        count,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == count - 1 ? 0 : 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bar(34, height: 14, color: accent),
                SizedBox(height: 8),
                _bar(42, height: 7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _bar(90, height: 10, color: accent.withValues(alpha: 0.7)),
        SizedBox(height: 10),
        _box(width: double.infinity, height: 22, color: Colors.white.withValues(alpha: 0.12)),
        SizedBox(height: 7),
        _box(width: double.infinity, height: 22, color: Colors.white.withValues(alpha: 0.12)),
        SizedBox(height: 10),
        _box(width: double.infinity, height: 24, color: accent),
      ],
    );
  }

  Widget _offer() {
    return Row(
      children: [
        _box(width: 58, height: double.infinity, color: accent.withValues(alpha: 0.35)),
        SizedBox(width: 10),
        Expanded(child: _form()),
      ],
    );
  }

  Widget _grid(int columns) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 7,
      mainAxisSpacing: 7,
      children: List.generate(columns * 2, (index) => _box()),
    );
  }

  Widget _bento() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(flex: 3, child: _box(color: accent.withValues(alpha: 0.32))),
              SizedBox(width: 7),
              Expanded(flex: 2, child: _box()),
            ],
          ),
        ),
        SizedBox(height: 7),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(flex: 2, child: _box()),
              SizedBox(width: 7),
              Expanded(flex: 3, child: _box(color: accent.withValues(alpha: 0.32))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _list() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              _box(width: 36, height: 28),
              SizedBox(width: 8),
              Expanded(child: _bar(double.infinity)),
              SizedBox(width: 8),
              _box(width: 34, height: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pricing() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 7),
            child: _box(
              height: double.infinity,
              color: index == 1 ? accent.withValues(alpha: 0.45) : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _accordion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: _box(width: double.infinity, height: 22),
        ),
      ),
    );
  }

  Widget _quotes() {
    return Row(
      children: List.generate(
        2,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == 1 ? 0 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(width: double.infinity, height: 52),
                SizedBox(height: 8),
                _bar(48, height: 8, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contact() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(width: 32, height: 32, radius: 99, color: accent.withValues(alpha: 0.4)),
                SizedBox(height: 8),
                _bar(38, height: 7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _schedule() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            children: [
              Expanded(child: _bar(double.infinity)),
              SizedBox(width: 18),
              _bar(50, color: index == 0 ? accent : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _map() {
    return Stack(
      children: [
        Positioned.fill(child: _box(color: Colors.white.withValues(alpha: 0.08))),
        Center(
          child: Icon(Icons.location_on_rounded, color: accent, size: 36),
        ),
      ],
    );
  }

  Widget _video() {
    return Stack(
      children: [
        Positioned.fill(child: _box(color: Colors.white.withValues(alpha: 0.1))),
        Center(
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _carousel() {
    return Row(
      children: [
        _box(width: 24, height: 54, color: Colors.white.withValues(alpha: 0.08)),
        SizedBox(width: 8),
        Expanded(child: _box(height: double.infinity, color: accent.withValues(alpha: 0.32))),
        SizedBox(width: 8),
        _box(width: 24, height: 54, color: Colors.white.withValues(alpha: 0.08)),
      ],
    );
  }

  Widget _qr() {
    return Center(
      child: Container(
        width: variant.preview == 'qr_big' ? 76 : 58,
        height: variant.preview == 'qr_big' ? 76 : 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          children: List.generate(
            16,
            (index) => Container(
              margin: const EdgeInsets.all(1.4),
              color: index.isEven ? Colors.black87 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _social() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(
            4,
            (_) => _box(width: 28, height: 28, radius: 99, color: accent.withValues(alpha: 0.35)),
          ),
        ),
        SizedBox(height: 12),
        _qr(),
      ],
    );
  }
}

class _SectionDefinition {
  final String type;
  final String name;
  final IconData icon;
  final String category;
  final String desc;
  final bool popular;
  final String aiRole;
  final String aiWhenToUse;
  final List<_SectionVariant> variants;

  const _SectionDefinition({
    required this.type,
    required this.name,
    required this.icon,
    required this.category,
    required this.desc,
    required this.popular,
    required this.aiRole,
    required this.aiWhenToUse,
    required this.variants,
  });
}

class _SectionVariant {
  final String name;
  final String description;
  final String preview;
  final Map<String, dynamic> overrides;

  const _SectionVariant({
    required this.name,
    required this.description,
    required this.preview,
    required this.overrides,
  });
}

_SectionDefinition _section({
  required String type,
  required String name,
  required IconData icon,
  required String category,
  required String desc,
  required String aiRole,
  required String aiWhenToUse,
  required List<_SectionVariant> variants,
  bool popular = false,
}) {
  return _SectionDefinition(
    type: type,
    name: name,
    icon: icon,
    category: category,
    desc: desc,
    popular: popular,
    aiRole: aiRole,
    aiWhenToUse: aiWhenToUse,
    variants: variants,
  );
}

_SectionVariant _variant(
  String name,
  String description,
  String preview,
  Map<String, dynamic> overrides,
) {
  return _SectionVariant(
    name: name,
    description: description,
    preview: preview,
    overrides: overrides,
  );
}
