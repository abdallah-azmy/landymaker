import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/blur_effect.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/animations/entrance_animation_mixin.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../builder/widgets/modals/ai_chat_modal.dart';
import '../models/home_layouts.dart';
import 'hero/typewriter_text.dart';
import 'hero/phone_preview.dart';

/// Pixabay background image used in the [HeroLayout.fullWidthImage] layout.
const _kHeroBgImage =
    'https://cdn.pixabay.com/photo/2017/08/30/01/05/milky-way-2695569_1280.jpg';

class HomeHeroSection extends StatefulWidget {
  final VoidCallback onGetStartedPressed;
  final ScrollController? parentScrollController;
  final HeroLayout layout;
  final double overlayOpacity;
  final String? title;
  final String? subtitle;
  final String? ctaText;
  final List<String>? typewriterTexts;
  final List<Map<String, dynamic>>? previewPages;

  const HomeHeroSection({
    super.key,
    required this.onGetStartedPressed,
    this.parentScrollController,
    this.layout = HeroLayout.split,
    this.overlayOpacity = 0.6,
    this.title,
    this.subtitle,
    this.ctaText,
    this.typewriterTexts,
    this.previewPages,
  });

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection>
    with TickerProviderStateMixin, EntranceAnimationMixin {
  late AnimationController _bgAnimationController;

  List<String> get _typewriterTexts =>
      widget.typewriterTexts ??
      [
        "منيو مطعم إلكتروني تفاعلي",
        "معرض أعمال شخصي للمستقلين",
        "صفحة هبوط تسويقية لخدماتك",
        "متجر إلكتروني لمنتجاتك الخاصة",
      ];

  List<Map<String, dynamic>> get _previewPages =>
      widget.previewPages != null && widget.previewPages!.isNotEmpty
      ? widget.previewPages!
      : _hardcodedPreviewPages;

  final List<Map<String, dynamic>> _hardcodedPreviewPages = [
    {
      'id': 'midnight_ocean',
      'name': 'Midnight Ocean',
      'theme': LandingPageTheme(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF60A5FA),
        background: Color(0xFF030712),
        textPrimary: Colors.white,
        textSecondary: Color(0xFF9CA3AF),
        buttonTextColor: Colors.white,
        name: 'Midnight Ocean',
      ),
      'blocks': [
        {
          'type': 'hero',
          'title': 'أناقة وفخامة تليق بك',
          'subtitle':
              'نحن لا نقص الشعر فقط، بل نصنع الثقة والمظهر المثالي الذي تستحقه بأحدث القصات العالمية.',
          'button_text': 'احجز مقعدك الآن',
          'image_url':
              'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
        },
        {
          'type': 'features',
          'title': 'خدماتنا المميزة',
          'items': [
            {
              'title': 'قص وتصفيف احترافي',
              'description': 'أحدث القصات والستايلات العالمية.',
            },
            {
              'title': 'حلاقة ذقن بالبخار',
              'description': 'جلسة تنظيف ذقن متكاملة بالبخار.',
            },
          ],
        },
      ],
    },
    {
      'id': 'lux_earth',
      'name': 'Lux-Earth',
      'theme': LandingPageTheme(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        background: Color(0xFF0F172A),
        textPrimary: Colors.white,
        textSecondary: Color(0xFF94A3B8),
        buttonTextColor: Colors.white,
        name: 'Lux-Earth',
      ),
      'blocks': [
        {
          'type': 'hero',
          'title': 'ساعات ذكية فاخرة',
          'subtitle':
              'اكتشف مجموعتنا الحصرية من الساعات الذكية والأجهزة التقنية الراقية.',
          'button_text': 'تسوق الآن',
          'image_url':
              'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        },
        {
          'type': 'products',
          'title': 'المنتجات الأكثر مبيعاً',
          'items': [
            {
              'name': 'ساعة ذكية فاخرة Pro',
              'price': '1200 EGP',
              'description': 'تتبع نشاطك وصحتك بكل سهولة مع تصميم عصري.',
              'image_url':
                  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
              'button_text': 'طلب مباشر',
            },
          ],
        },
      ],
    },
    {
      'id': 'butter_sky',
      'name': 'Butter & Sky',
      'theme': LandingPageTheme(
        primary: Color(0xFF0EA5E9),
        secondary: Color(0xFF38BDF8),
        background: Color(0xFF0F172A),
        textPrimary: Colors.white,
        textSecondary: Color(0xFF94A3B8),
        buttonTextColor: Color(0xFF0F172A),
        name: 'Butter & Sky',
      ),
      'blocks': [
        {
          'type': 'hero',
          'title': 'تصميم هويات بصرية مذهلة',
          'subtitle':
              'نساعد الشركات الناشئة على بناء هويات وتجارب مستخدم فريدة للويب والهاتف.',
          'button_text': 'شاهد أعمالي',
          'image_url':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        },
        {
          'type': 'social_qr',
          'title': 'تابع منصاتي',
          'subtitle': 'تابعني على حساباتي الرسمية لمزيد من التصاميم اليومية',
          'links': [
            {'platform': 'instagram', 'url': 'https://instagram.com'},
            {'platform': 'linkedin', 'url': 'https://linkedin.com'},
          ],
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    startEntrance();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _showAiWizard(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIChatModal(currentPath: currentPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);
        switch (widget.layout) {
          case HeroLayout.centered:
            return _buildCenteredLayout(context, isMobile, constraints);
          case HeroLayout.gradientOnly:
            return _buildGradientOnlyLayout(context, isMobile);
          case HeroLayout.split:
            return _buildSplitLayout(context, isMobile, constraints);
          case HeroLayout.fullWidthImage:
            return _buildFullWidthImageLayout(context, isMobile);
        }
      },
    );
  }

  Widget _buildSplitLayout(
    BuildContext context,
    bool isMobile,
    BoxConstraints constraints,
  ) {
    final isTablet = HomeBreakpoint.isTablet(constraints.maxWidth);
    final hp = isMobile ? 16.0 : (isTablet ? 32.0 : 64.0);
    final vp = isMobile ? 32.0 : 60.0;
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                final val = _bgAnimationController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -0.5 + 0.3 * (1.0 - val),
                        -0.3 + 0.4 * val,
                      ),
                      radius: 1.2,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                final val = _bgAnimationController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.6 - 0.2 * val,
                        0.5 - 0.3 * (1.0 - val),
                      ),
                      radius: 1.0,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            vertical: vp,
            horizontal: hp,
          ),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isMobile)
                buildEntranceAnimation(_buildTextContent(context, isMobile))
              else
                Expanded(
                  flex: 7,
                  child: buildEntranceAnimation(
                    _buildTextContent(context, isMobile),
                  ),
                ),
              if (isMobile) SizedBox(height: 48) else SizedBox(width: 48),
              if (isMobile)
                PhonePreview(
                  isMobile: isMobile,
                  previewPages: _previewPages,
                  parentScrollController: widget.parentScrollController,
                )
              else
                Expanded(
                  flex: 5,
                  child: PhonePreview(
                    isMobile: isMobile,
                    previewPages: _previewPages,
                    parentScrollController: widget.parentScrollController,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Layout: centered (full-width bg with overlay) ────────────────────────
  Widget _buildCenteredLayout(
    BuildContext context,
    bool isMobile,
    BoxConstraints constraints,
  ) {
    final isTablet = HomeBreakpoint.isTablet(constraints.maxWidth);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgAnimationController,
                builder: (context, child) {
                  final val = _bgAnimationController.value;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.8 + 0.4 * val, -0.8),
                        end: Alignment(0.8 - 0.4 * val, 0.8),
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.15),
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.0),
                          Theme.of(context).colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.15),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Centered content
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: isMobile ? 32 : 60,
              horizontal: isMobile ? 16 : (isTablet ? 32 : 64),
            ),
            child: FadeTransition(
              opacity: entranceFade,
              child: AppBlurEffect(
                blur: isLight ? 25.0 : 12.0,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  padding: const EdgeInsetsDirectional.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildBadge(),
                      const SizedBox(height: 24),
                      Text(
                        widget.title ??
                            'ابنِ صفحة هبوط احترافية متكاملة لخدماتك',
                        style: AppTypography.h1.copyWith(
                          fontSize: isMobile
                              ? 32
                              : isTablet
                              ? 44
                              : 58,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: TypewriterText(
                          texts: _typewriterTexts,
                          isMobile: isMobile,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.subtitle ??
                            'بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildCTAButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layout: gradientOnly ─────────────────────────────────────────────────
  Widget _buildGradientOnlyLayout(BuildContext context, bool isMobile) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = HomeBreakpoint.isTablet(constraints.maxWidth);
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final val = _bgAnimationController.value;
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + 0.6 * val, -1.0),
                    end: Alignment(1.0 - 0.6 * val, 1.0),
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.25),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.15),
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                vertical: isMobile ? 32 : 60,
                horizontal: isMobile ? 16 : 64,
              ),
              child: FadeTransition(
                opacity: entranceFade,
                child: AppBlurEffect(
                  blur: isLight ? 25.0 : 12.0,
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildBadge(),
                        const SizedBox(height: 24),
                        Text(
                          widget.title ??
                              'ابنِ صفحة هبوط احترافية متكاملة لخدماتك',
                          style: AppTypography.h1.copyWith(
                            fontSize: isMobile
                                ? 30
                                : isTablet
                                ? 44
                                : 58,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: TypewriterText(
                            texts: _typewriterTexts,
                            isMobile: isMobile,
                            colorOverride: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.subtitle ??
                              'بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر.',
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildCTAButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Layout: fullWidthImage (edge-to-edge bg image) ───────────────────────
  Widget _buildFullWidthImageLayout(BuildContext context, bool isMobile) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = HomeBreakpoint.isTablet(constraints.maxWidth);
        return SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomNetworkImage(
                    imageUrl: _kHeroBgImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: widget.overlayOpacity),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: isMobile ? 32 : 60,
                  horizontal: isMobile ? 16 : 64,
                ),
                child: FadeTransition(
                  opacity: entranceFade,
                  child: AppBlurEffect(
                    blur: isLight ? 25.0 : 12.0,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      padding: const EdgeInsetsDirectional.all(32),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildBadge(),
                          const SizedBox(height: 24),
                          Text(
                            widget.title ??
                                'ابنِ صفحة هبوط احترافية متكاملة لخدماتك',
                            style: AppTypography.h1.copyWith(
                              fontSize: isMobile
                                  ? 30
                                  : isTablet
                                  ? 44
                                  : 58,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 50),
                            child: TypewriterText(
                              texts: _typewriterTexts,
                              isMobile: isMobile,
                              colorOverride: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.subtitle ??
                                'بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر.',
                            style: AppTypography.bodyLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          _buildCTAButtons(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Shared sub-widgets ───────────────────────────────────────────────────

  Widget _buildBadge({Color? textColor}) {
    final effectiveColor = textColor ?? Theme.of(context).colorScheme.secondary;
    return AppBlurEffect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: effectiveColor, size: 16),
            SizedBox(width: 8),
            Text(
              'أطلق موقعك في ٥ دقائق فقط 🚀',
              style: AppTypography.caption.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    final isDark = (Theme.of(context).brightness == Brightness.dark);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        AppBlurEffect(
          borderRadius: BorderRadius.circular(16),
          child: ElevatedButton.icon(
            onPressed: widget.onGetStartedPressed,
            icon: Icon(
              Icons.flash_on_rounded,
              color: isDark
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            label: Text(
              widget.ctaText ?? 'ابدأ الآن مجاناً',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12)
                  : Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.12),
              side: BorderSide(
                color: isDark
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4)
                    : Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.4),
                width: 1.8,
              ),
              minimumSize: const Size(220, 58),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
        AppBlurEffect(
          borderRadius: BorderRadius.circular(16),
          child: OutlinedButton.icon(
            onPressed: () => _showAiWizard(context),
            icon: Icon(
              Icons.auto_awesome_rounded,
              color: isDark
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            label: Text(
              'المنشئ الذكي (AI)',
              style: TextStyle(
                color: isDark
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: isDark
                  ? Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.12)
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
              side: BorderSide(
                color: isDark
                    ? Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.4)
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                width: 1.8,
              ),
              minimumSize: const Size(220, 58),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context, bool isMobile) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet =
        MediaQuery.of(context).size.width >= 700 &&
        MediaQuery.of(context).size.width < 1200;
    return FadeTransition(
      opacity: entranceFade,
      child: AppBlurEffect(
        blur: isLight ? 25.0 : 12.0,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsetsDirectional.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _buildBadge(),
              const SizedBox(height: 24),
              Text(
                widget.title ?? 'ابنِ صفحة هبوط احترافية متكاملة لخدماتك',
                style: AppTypography.h1.copyWith(
                  fontSize: isMobile
                      ? 30
                      : isTablet
                      ? 44
                      : 58,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: TypewriterText(
                  texts: _typewriterTexts,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.subtitle ??
                    'بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر واحصل على رابط مباشر وكود QR فوري.',
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                  fontSize: 15,
                ),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 28),
              _buildCTAButtons(context),
            ],
          ),
        ),
      ),
    );
  }
}
