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

class _HomeHeroSectionState extends State<HomeHeroSection> {
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

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTypewriter() {
    final int delayMs = _isDeleting ? 25 : 60; // Delete fast (25ms), type normal (60ms)
    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      final fullText = _typewriterTexts[_currentIndex];
      
      setState(() {
        if (!_isDeleting) {
          _currentText = fullText.substring(0, _charIndex);
          _charIndex++;
          if (_charIndex > fullText.length) {
            _isDeleting = true;
            // Pause at the end of word
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _startTypewriter();
            });
            return;
          }
        } else {
          _charIndex -= 2; // delete 2 chars at a time to be even faster
          if (_charIndex < 0) _charIndex = 0;
          _currentText = fullText.substring(0, _charIndex);
          if (_charIndex == 0) {
            _isDeleting = false;
            _currentIndex = (_currentIndex + 1) % _typewriterTexts.length;
            // Short pause before starting next word
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
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
                child: Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        "أطلق موقعك في ٥ دقائق فقط 🚀",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "ابنِ صفحة هبوط احترافية متكاملة لخدماتك",
                      style: AppTypography.h1.copyWith(
                        fontSize: isMobile ? 32 : 54,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Text(
                            _currentText,
                            style: AppTypography.h2.copyWith(
                              color: AppColors.secondary,
                              fontSize: isMobile ? 20 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 2,
                            height: isMobile ? 22 : 30,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "بدون الحاجة لخبرة برمجية. اختر قالباً مناسباً، أضف محتواك، انشر موقعك بضغطة زر واحصل على رابط مباشر وكود QR فوري.",
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: widget.onGetStartedPressed,
                          icon: const Icon(Icons.flash_on_rounded, size: 18),
                          label: const Text(
                            "ابدأ الآن مجاناً",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (isMobile) const SizedBox(height: 48) else const SizedBox(width: 48),

              // Interactive Preview
              Expanded(
                flex: isMobile ? 0 : 5,
                child: Center(
                  child: Container(
                    width: 320,
                    height: 580,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: const Color(0xFF475569), width: 8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.25),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Status bar mock
                          Container(
                            height: 24,
                            color: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("9:41", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 10),
                                    SizedBox(width: 4),
                                    Icon(Icons.wifi_rounded, color: Colors.white, size: 10),
                                    SizedBox(width: 4),
                                    Icon(Icons.battery_std_rounded, color: Colors.white, size: 10),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // Renderer showing mock builder dataset
                          SizedBox(
                            height: 548,
                            child: SectionRenderer(
                              pageId: 'demo',
                              theme: const LandingPageTheme(
                                primary: AppColors.secondary,
                                secondary: AppColors.primary,
                                background: Color(0xFF0F172A),
                                textPrimary: Colors.white,
                                textSecondary: Color(0xFF94A3B8),
                                name: 'Demo',
                              ),
                              blocks: const [
                                {
                                  'type': 'hero',
                                  'title': 'مرحباً بك في متجرنا',
                                  'subtitle': 'احصل على أرقى الخدمات بأسعار ممتازة.',
                                  'button_text': 'طلب الخدمة',
                                  'image_url': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=300'
                                },
                                {
                                  'type': 'features',
                                  'title': 'مميزاتنا',
                                  'items': [
                                    {'title': 'جودة فائقة', 'description': 'نلتزم بأعلى معايير الإتقان.'},
                                    {'title': 'دعم مستمر', 'description': 'متواجدون لخدمتكم على مدار الساعة.'}
                                  ]
                                }
                              ],
                            ),
                          ),
                        ],
                      ),
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
