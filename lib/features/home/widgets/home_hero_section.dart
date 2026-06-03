import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../public_viewer/widgets/section_renderer.dart';
import '../../builder/models/landing_page_theme.dart';

class HomeHeroSection extends StatefulWidget {
  final VoidCallback onGetStartedPressed;

  const HomeHeroSection({
    super.key,
    required this.onGetStartedPressed,
  });

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> with TickerProviderStateMixin {
  final List<String> _typewriterTexts = [
    "منيو مطعم إلكتروني تفاعلي",
    "معرض أعمال شخصي للمستقلين",
    "صفحة هبوط تسويقية لخدماتك",
    "متجر إلكتروني لمنتجاتك الخاصة",
  ];
  int _currentIndex = 0;
  String _currentText = "";
  Timer? _timer;
  bool _isDeleting = false;
  int _charIndex = 0;

  // Animation controllers for mesh background and elements
  late AnimationController _bgAnimationController;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<double> _entranceSlide;

  // Mobile Mockup cycling state
  int _activePreviewIndex = 0;
  Timer? _previewCycleTimer;

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
    _startTypewriter();

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

    // Start cycling previews
    _startPreviewCycling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _previewCycleTimer?.cancel();
    _bgAnimationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _startTypewriter() {
    final int delayMs = _isDeleting ? 25 : 60;
    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      final fullText = _typewriterTexts[_currentIndex];

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
            _currentIndex = (_currentIndex + 1) % _typewriterTexts.length;
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

  void _startPreviewCycling() {
    _previewCycleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _activePreviewIndex = (_activePreviewIndex + 1) % _previewPages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Stack(
      children: [
        // Mesh Gradient background spot effect
        Positioned.fill(
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
        Positioned.fill(
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
                  Expanded(
                    flex: isMobile ? 0 : 6,
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
                        crossAxisAlignment: isMobile
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
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
                              fontSize: isMobile ? 36 : 56,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -1,
                            ),
                            textAlign:
                                isMobile ? TextAlign.center : TextAlign.start,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: isMobile
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                Text(
                                  _currentText,
                                  style: AppTypography.h2.copyWith(
                                    color: AppColors.secondary,
                                    fontSize: isMobile ? 22 : 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: isMobile ? 24 : 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
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
                            textAlign:
                                isMobile ? TextAlign.center : TextAlign.start,
                          ),
                          const SizedBox(height: 36),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 1.0, end: 1.05),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, scale, child) {
                                return ElevatedButton.icon(
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
                                );
                              },
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
                  Expanded(
                    flex: isMobile ? 0 : 5,
                    child: Center(
                      child: Container(
                        width: 320,
                        height: 580,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(38),
                          border: Border.all(
                            color: const Color(0xFF475569),
                            width: 8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.25),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Status bar mock
                            Container(
                              height: 24,
                              color: const Color(0xFF0F172A),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            // Cycling Renderer with cross-fade animation
                            Expanded(
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
                                    color: _previewPages[_activePreviewIndex]['theme'].background,
                                    child: SectionRenderer(
                                      pageId: 'demo',
                                      theme: _previewPages[_activePreviewIndex]['theme'],
                                      blocks: List<Map<String, dynamic>>.from(
                                        _previewPages[_activePreviewIndex]['blocks'],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
