import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/blur_effect.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/animations/entrance_animation_mixin.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../public_viewer/widgets/section_renderer.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../builder/widgets/modals/ai_chat_modal.dart';
import '../models/home_layouts.dart';

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

  final List<Map<String, dynamic>> _previewPages = [
    {
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
                _PhonePreview(
                  isMobile: isMobile,
                  previewPages: _previewPages,
                  parentScrollController: widget.parentScrollController,
                )
              else
                Expanded(
                  flex: 5,
                  child: _PhonePreview(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBadge(),
                  const SizedBox(height: 24),
                  Text(
                    widget.title ?? 'ابنِ صفحة هبوط احترافية متكاملة لخدماتك',
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
                    child: _TypewriterText(
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
        ],
      ),
    );
  }

  // ── Layout: gradientOnly ─────────────────────────────────────────────────
  Widget _buildGradientOnlyLayout(BuildContext context, bool isMobile) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: _TypewriterText(
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
        );
      },
    );
  }

  // ── Layout: fullWidthImage (edge-to-edge bg image) ───────────────────────
  Widget _buildFullWidthImageLayout(BuildContext context, bool isMobile) {
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
                  child: Column(
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
                        child: _TypewriterText(
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
    final isTablet =
        MediaQuery.of(context).size.width >= 700 &&
        MediaQuery.of(context).size.width < 1200;
    return FadeTransition(
      opacity: entranceFade,
      child: Column(
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
            child: _TypewriterText(texts: _typewriterTexts, isMobile: isMobile),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated Typewriter Widget to prevent rebuilding the entire Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class _TypewriterText extends StatefulWidget {
  final List<String> texts;
  final bool isMobile;

  /// Optional color override for use on bright backgrounds.
  /// Defaults to [Theme.of(context).colorScheme.secondary] when null.
  final Color? colorOverride;

  const _TypewriterText({
    required this.texts,
    required this.isMobile,
    this.colorOverride,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _currentText = "";
  Timer? _timer;
  bool _isDeleting = false;
  int _charIndex = 0;
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _startTypewriter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  void _startTypewriter() {
    final int delayMs = _isDeleting ? 25 : 60;
    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      final fullText = widget.texts[_currentIndex];

      setState(() {
        if (!_isDeleting) {
          _currentText = fullText.substring(0, _charIndex);
          _charIndex++;
          if (_charIndex > fullText.length) {
            _isDeleting = true;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _startTypewriter();
            });
            return;
          }
        } else {
          _charIndex -= 2;
          if (_charIndex < 0) _charIndex = 0;
          _currentText = fullText.substring(0, _charIndex);
          if (_charIndex == 0) {
            _isDeleting = false;
            _currentIndex = (_currentIndex + 1) % widget.texts.length;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startTypewriter();
            });
            return;
          }
        }
        _startTypewriter();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        widget.colorOverride ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: widget.isMobile
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _currentText,
          style: AppTypography.h2.copyWith(
            color: textColor,
            fontSize: widget.isMobile ? 22 : 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 6),
        FadeTransition(
          opacity: _cursorController,
          child: Container(
            width: 3,
            height: widget.isMobile ? 24 : 32,
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated Phone Preview Widget to prevent rebuilding the entire Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class _PhonePreview extends StatefulWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> previewPages;
  final ScrollController? parentScrollController;

  const _PhonePreview({
    required this.isMobile,
    required this.previewPages,
    this.parentScrollController,
  });

  @override
  State<_PhonePreview> createState() => _PhonePreviewState();
}

class _PhonePreviewState extends State<_PhonePreview> {
  int _activePreviewIndex = 0;
  Timer? _previewCycleTimer;
  late ScrollController _innerScrollController;

  @override
  void initState() {
    super.initState();
    _innerScrollController = ScrollController();
    _startPreviewCycling();
  }

  @override
  void dispose() {
    _previewCycleTimer?.cancel();
    _innerScrollController.dispose();
    super.dispose();
  }

  void _startPreviewCycling() {
    _previewCycleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _activePreviewIndex =
              (_activePreviewIndex + 1) % widget.previewPages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic sizing: mobile gets slightly smaller mockup to leave comfortable scroll margins on sides
    final mockupWidth = widget.isMobile ? 260.0 : 320.0;
    final mockupHeight = widget.isMobile ? 470.0 : 580.0;
    final outerRadius = widget.isMobile ? 32.0 : 38.0;
    final innerRadius = widget.isMobile ? 24.0 : 30.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left cycle button (desktop only)
          // if (!widget.isMobile)
          Semantics(
            label: 'Previous template',
            button: true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _previewCycleTimer?.cancel();
                  setState(() {
                    _activePreviewIndex =
                        (_activePreviewIndex - 1 + widget.previewPages.length) %
                        widget.previewPages.length;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white60,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
          // if (!widget.isMobile)
          SizedBox(width: 16),

          // Phone Frame
          Semantics(
            label: 'Template preview',
            container: true,
            child: Container(
              width: mockupWidth,
              height: mockupHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(outerRadius),
                border: Border.all(color: const Color(0xFF475569), width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(innerRadius),
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Status bar mock
                          Container(
                            height: 24,
                            color: Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "9:41",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.signal_cellular_alt_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.wifi_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.battery_std_rounded,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Scrollable Preview with dynamic propagation on overscroll
                          Expanded(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification notification) {
                                if (notification is ScrollUpdateNotification) {
                                  final parent = widget.parentScrollController;
                                  if (parent != null && parent.hasClients) {
                                    final double delta =
                                        notification.scrollDelta ?? 0;
                                    final pos = _innerScrollController.position;

                                    // Overscroll Down: inner view is at bottom, drag down -> scroll parent
                                    if (pos.pixels >= pos.maxScrollExtent &&
                                        delta > 0) {
                                      parent.position.jumpTo(
                                        (parent.offset + delta).clamp(
                                          0.0,
                                          parent.position.maxScrollExtent,
                                        ),
                                      );
                                    }
                                    // Overscroll Up: inner view is at top, drag up -> scroll parent
                                    else if (pos.pixels <= 0 && delta < 0) {
                                      parent.position.jumpTo(
                                        (parent.offset + delta).clamp(
                                          0.0,
                                          parent.position.maxScrollExtent,
                                        ),
                                      );
                                    }
                                  }
                                }
                                return false;
                              },
                              child: SingleChildScrollView(
                                controller: _innerScrollController,
                                physics:
                                    const ClampingScrollPhysics(), // Clamping prevents rubber-banding blocks
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  transitionBuilder:
                                      (
                                        Widget child,
                                        Animation<double> animation,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  child: KeyedSubtree(
                                    key: ValueKey<int>(_activePreviewIndex),
                                    child: Container(
                                      color: widget
                                          .previewPages[_activePreviewIndex]['theme']
                                          .background,
                                      child: SectionRenderer(
                                        pageId: 'demo',
                                        theme: widget
                                            .previewPages[_activePreviewIndex]['theme'],
                                        blocks: List<Map<String, dynamic>>.from(
                                          widget
                                              .previewPages[_activePreviewIndex]['blocks'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Floating page indicator dots
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.previewPages.length, (
                            index,
                          ) {
                            final isActive = index == _activePreviewIndex;
                            return Semantics(
                              label: 'Template ${index + 1}',
                              button: true,
                              child: GestureDetector(
                                onTap: () {
                                  _previewCycleTimer?.cancel();
                                  setState(() {
                                    _activePreviewIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: isActive ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right cycle button (desktop only)
          // if (!widget.isMobile)
          SizedBox(width: 16),
          // if (!widget.isMobile)
          Semantics(
            label: 'Next template',
            button: true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _previewCycleTimer?.cancel();
                  setState(() {
                    _activePreviewIndex =
                        (_activePreviewIndex + 1) % widget.previewPages.length;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white60,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
