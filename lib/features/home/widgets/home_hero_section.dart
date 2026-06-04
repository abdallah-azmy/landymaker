import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../public_viewer/widgets/section_renderer.dart';
import '../../builder/models/landing_page_theme.dart';

class HomeHeroSection extends StatefulWidget {
  final VoidCallback onGetStartedPressed;
  final ScrollController? parentScrollController;

  const HomeHeroSection({
    super.key,
    required this.onGetStartedPressed,
    this.parentScrollController,
  });

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> with TickerProviderStateMixin {
  late AnimationController _bgAnimationController;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<double> _entranceSlide;

  bool _btnHovered = false;

  final List<String> _typewriterTexts = [
    "منيو مطعم إلكتروني تفاعلي",
    "معرض أعمال شخصي للمستقلين",
    "صفحة هبوط تسويقية لخدماتك",
    "متجر إلكتروني لمنتجاتك الخاصة",
  ];

  final List<Map<String, dynamic>> _previewPages = [
    {
      'name': 'Midnight Ocean',
      'theme': const LandingPageTheme(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF60A5FA),
        background: Color(0xFF030712),
        textPrimary: Colors.white,
        textSecondary: Color(0xFF9CA3AF),
        name: 'Midnight Ocean',
      ),
      'blocks': [
        {
          'type': 'hero',
          'title': 'أناقة وفخامة تليق بك',
          'subtitle': 'نحن لا نقص الشعر فقط، بل نصنع الثقة والمظهر المثالي الذي تستحقه بأحدث القصات العالمية.',
          'button_text': 'احجز مقعدك الآن',
          'image_url': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400'
        },
        {
          'type': 'features',
          'title': 'خدماتنا المميزة',
          'items': [
            {'title': 'قص وتصفيف احترافي', 'description': 'أحدث القصات والستايلات العالمية.'},
            {'title': 'حلاقة ذقن بالبخار', 'description': 'جلسة تنظيف ذقن متكاملة بالبخار.'}
          ]
        }
      ]
    },
    {
      'name': 'Lux-Earth',
      'theme': const LandingPageTheme(
        primary: Color(0xFFD97706),
        secondary: Color(0xFFF59E0B),
        background: Color(0xFF0F172A),
        textPrimary: Colors.white,
        textSecondary: Color(0xFF94A3B8),
        name: 'Lux-Earth',
      ),
      'blocks': [
        {
          'type': 'hero',
          'title': 'ساعات ذكية فاخرة',
          'subtitle': 'اكتشف مجموعتنا الحصرية من الساعات الذكية والأجهزة التقنية الراقية.',
          'button_text': 'تسوق الآن',
          'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400'
        },
        {
          'type': 'products',
          'title': 'المنتجات الأكثر مبيعاً',
          'items': [
            {
              'name': 'ساعة ذكية فاخرة Pro',
              'price': '1200 EGP',
              'description': 'تتبع نشاطك وصحتك بكل سهولة مع تصميم عصري.',
              'image_url': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
              'button_text': 'طلب مباشر',
            }
          ]
        }
      ]
    },
    {
      'name': 'Butter & Sky',
      'theme': const LandingPageTheme(
        primary: Color(0xFF0EA5E9),
        secondary: Color(0xFF38BDF8),
        background: Color(0xFF0F172A),
        textPrimary: Colors.white,
        textSecondary: Color(0xFF94A3B8),
        name: 'Butter & Sky',
      ),
      'blocks': [
        {
          'type': 'hero',
          'title': 'تصميم هويات بصرية مذهلة',
          'subtitle': 'نساعد الشركات الناشئة على بناء هويات وتجارب مستخدم فريدة للويب والهاتف.',
          'button_text': 'شاهد أعمالي',
          'image_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'
        },
        {
          'type': 'social_qr',
          'title': 'تابع منصاتي',
          'subtitle': 'تابعني على حساباتي الرسمية لمزيد من التصاميم اليومية',
          'links': [
            {'platform': 'instagram', 'url': 'https://instagram.com'},
            {'platform': 'linkedin', 'url': 'https://linkedin.com'},
          ]
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();

    // Background gradient pulse animation
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _entranceSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Stack(
      children: [
        // Mesh Gradient background spot effect 1
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
                        AppColors.primary.withValues(alpha: 0.15),
                        const Color(0xFF030712).withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Mesh Gradient background spot effect 2
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
                        AppColors.secondary.withValues(alpha: 0.1),
                        const Color(0xFF030712).withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Core Hero Layout
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text and CTA
                  if (isMobile)
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _entranceSlide.value),
                          child: Opacity(
                            opacity: _entranceFade.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.secondary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "أطلق موقعك في ٥ دقائق فقط 🚀",
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "ابنِ صفحة هبوط احترافية متكاملة لخدماتك",
                            style: AppTypography.h1.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 50,
                            child: _TypewriterText(
                              texts: _typewriterTexts,
                              isMobile: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر واحصل على رابط مباشر وكود QR فوري.",
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 36),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) => setState(() => _btnHovered = true),
                            onExit: (_) => setState(() => _btnHovered = false),
                            child: AnimatedScale(
                              scale: _btnHovered ? 1.04 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: ElevatedButton.icon(
                                onPressed: widget.onGetStartedPressed,
                                icon: const Icon(
                                  Icons.flash_on_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  "ابدأ الآن مجاناً",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      AppColors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      flex: 6,
                      child: AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _entranceSlide.value),
                            child: Opacity(
                              opacity: _entranceFade.value,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.2),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.secondary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "أطلق موقعك في ٥ دقائق فقط 🚀",
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "ابنِ صفحة هبوط احترافية متكاملة لخدماتك",
                              style: AppTypography.h1.copyWith(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 50,
                              child: _TypewriterText(
                                texts: _typewriterTexts,
                                isMobile: false,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر واحصل على رابط مباشر وكود QR فوري.",
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 36),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => _btnHovered = true),
                              onExit: (_) => setState(() => _btnHovered = false),
                              child: AnimatedScale(
                                scale: _btnHovered ? 1.04 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: ElevatedButton.icon(
                                  onPressed: widget.onGetStartedPressed,
                                  icon: const Icon(
                                    Icons.flash_on_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    "ابدأ الآن مجاناً",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 36,
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor:
                                        AppColors.primary.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (isMobile)
                    const SizedBox(height: 64)
                  else
                    const SizedBox(width: 64),

                  // Phone Preview container with auto-cycling templates
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
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated Typewriter Widget to prevent rebuilding the entire Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class _TypewriterText extends StatefulWidget {
  final List<String> texts;
  final bool isMobile;

  const _TypewriterText({
    required this.texts,
    required this.isMobile,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> with SingleTickerProviderStateMixin {
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
    return Row(
      mainAxisAlignment: widget.isMobile
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _currentText,
          style: AppTypography.h2.copyWith(
            color: AppColors.secondary,
            fontSize: widget.isMobile ? 22 : 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        FadeTransition(
          opacity: _cursorController,
          child: Container(
            width: 3,
            height: widget.isMobile ? 24 : 32,
            decoration: BoxDecoration(
              color: AppColors.secondary,
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
          _activePreviewIndex = (_activePreviewIndex + 1) % widget.previewPages.length;
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left cycle button (desktop only)
        if (!widget.isMobile)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _previewCycleTimer?.cancel();
                setState(() {
                  _activePreviewIndex = (_activePreviewIndex - 1 + widget.previewPages.length) % widget.previewPages.length;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white60, size: 14),
              ),
            ),
          ),
        if (!widget.isMobile) const SizedBox(width: 16),

        // Phone Frame
        Container(
          width: mockupWidth,
          height: mockupHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(outerRadius),
            border: Border.all(
              color: const Color(0xFF475569),
              width: 8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: Container(
              color: const Color(0xFF0F172A),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Status bar mock
                      Container(
                        height: 24,
                        color: const Color(0xFF0F172A),
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
                            )
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
                                final double delta = notification.scrollDelta ?? 0;
                                final pos = _innerScrollController.position;

                                // Overscroll Down: inner view is at bottom, drag down -> scroll parent
                                if (pos.pixels >= pos.maxScrollExtent && delta > 0) {
                                  parent.position.jumpTo((parent.offset + delta).clamp(0.0, parent.position.maxScrollExtent));
                                }
                                // Overscroll Up: inner view is at top, drag up -> scroll parent
                                else if (pos.pixels <= 0 && delta < 0) {
                                  parent.position.jumpTo((parent.offset + delta).clamp(0.0, parent.position.maxScrollExtent));
                                }
                              }
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: _innerScrollController,
                            physics: const ClampingScrollPhysics(), // Clamping prevents rubber-banding blocks
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(_activePreviewIndex),
                                child: Container(
                                  color: widget.previewPages[_activePreviewIndex]['theme'].background,
                                  child: SectionRenderer(
                                    pageId: 'demo',
                                    theme: widget.previewPages[_activePreviewIndex]['theme'],
                                    blocks: List<Map<String, dynamic>>.from(
                                      widget.previewPages[_activePreviewIndex]['blocks'],
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
                      children: List.generate(widget.previewPages.length, (index) {
                        final isActive = index == _activePreviewIndex;
                        return GestureDetector(
                          onTap: () {
                            _previewCycleTimer?.cancel();
                            setState(() {
                              _activePreviewIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.secondary
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
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

        // Right cycle button (desktop only)
        if (!widget.isMobile) const SizedBox(width: 16),
        if (!widget.isMobile)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _previewCycleTimer?.cancel();
                setState(() {
                  _activePreviewIndex = (_activePreviewIndex + 1) % widget.previewPages.length;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 14),
              ),
            ),
          ),
      ],
    );
  }
}
