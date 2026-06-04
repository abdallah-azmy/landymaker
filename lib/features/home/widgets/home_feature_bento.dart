import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeFeatureBento extends StatefulWidget {
  final bool isVisible;

  const HomeFeatureBento({
    super.key,
    required this.isVisible,
  });

  @override
  State<HomeFeatureBento> createState() => _HomeFeatureBentoState();
}

class _HomeFeatureBentoState extends State<HomeFeatureBento>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Staggered card animations
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;

  static const _features = [
    _FeatureData(
      icon: Icons.dashboard_customize_rounded,
      title: "محرر مرن وسريع",
      desc: "أضف الأقسام التي تريدها ورتبها بسهولة. تحكم كامل في النصوص والصور والأزرار والروابط.",
      color: Color(0xFF6366F1),
      emoji: "⚡",
    ),
    _FeatureData(
      icon: Icons.palette_rounded,
      title: "قوالب وتصاميم ممتازة",
      desc: "اختر من بين لوحات الألوان والخطوط الجاهزة لتناسب هويتك التجارية في ثوانٍ معدودة.",
      color: Color(0xFF06B6D4),
      emoji: "🎨",
    ),
    _FeatureData(
      icon: Icons.analytics_rounded,
      title: "إحصائيات فورية وتتبع العملاء",
      desc: "اعرف عدد الزوار وتفاعلهم وتابع طلبات العملاء والرسائل الواردة مباشرة من لوحة التحكم.",
      color: Color(0xFF10B981),
      emoji: "📊",
    ),
    _FeatureData(
      icon: Icons.qr_code_2_rounded,
      title: "روابط ذكية وكود QR مخصص",
      desc: "شارك موقعك بروابط مخصصة، نطاق فرعي مميز، وكود QR تفاعلي سهل المسح والمشاركة.",
      color: Color(0xFFF59E0B),
      emoji: "🔗",
    ),
    _FeatureData(
      icon: Icons.smartphone_rounded,
      title: "تجاوب تام مع الجوال",
      desc: "صفحاتك تبدو مثالية على جميع الأجهزة تلقائياً. لا حاجة لأي ضبط إضافي.",
      color: Color(0xFFEC4899),
      emoji: "📱",
    ),
    _FeatureData(
      icon: Icons.rocket_launch_rounded,
      title: "نشر فوري بضغطة زر",
      desc: "انشر موقعك في ثوانٍ واحصل على رابط مباشر يمكنك مشاركته فوراً مع عملائك.",
      color: Color(0xFF8B5CF6),
      emoji: "🚀",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.fastOutSlowIn,
    ));

    // Stagger cards: each gets its own interval
    _cardFades = List.generate(_features.length, (i) {
      return CurvedAnimation(
        parent: _cardsController,
        curve: Interval((i * 0.12).clamp(0.0, 1.0), ((i * 0.12) + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    _cardSlides = List.generate(_features.length, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardsController,
        curve: Interval((i * 0.12).clamp(0.0, 1.0), ((i * 0.12) + 0.6).clamp(0.0, 1.0), curve: Curves.fastOutSlowIn),
      ));
    });
  }

  @override
  void didUpdateWidget(HomeFeatureBento oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _cardsController.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          "✨ المميزات",
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF818CF8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "كل ما تحتاجه للنمو\nفي مكان واحد",
                        style: AppTypography.h2.copyWith(
                          fontSize: isMobile ? 28 : 42,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "أدوات ذكية متكاملة مصممة خصيصاً لمساعدتك على بناء حضورك الرقمي بسرعة واحترافية.",
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 64),

              // Bento Grid
              if (isMobile)
                Column(
                  children: List.generate(_features.length, (i) => Column(
                    children: [
                      FadeTransition(
                        opacity: _cardFades[i],
                        child: SlideTransition(
                          position: _cardSlides[i],
                          child: _BentoCard(feature: _features[i]),
                        ),
                      ),
                      if (i < _features.length - 1) const SizedBox(height: 16),
                    ],
                  )),
                )
              else
                Column(
                  children: [
                    // Row 1: 3/5 + 2/5 (Height fixed at 440 to fit all text and icons beautifully)
                    SizedBox(
                      height: 440,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: FadeTransition(
                              opacity: _cardFades[0],
                              child: SlideTransition(
                                position: _cardSlides[0],
                                child: _BentoCard(feature: _features[0], tall: true),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _cardFades[1],
                                    child: SlideTransition(
                                      position: _cardSlides[1],
                                      child: _BentoCard(feature: _features[1]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _cardFades[2],
                                    child: SlideTransition(
                                      position: _cardSlides[2],
                                      child: _BentoCard(feature: _features[2]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Row 2: 2/5 + 3/5
                    SizedBox(
                      height: 440,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _cardFades[3],
                                    child: SlideTransition(
                                      position: _cardSlides[3],
                                      child: _BentoCard(feature: _features[3]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _cardFades[4],
                                    child: SlideTransition(
                                      position: _cardSlides[4],
                                      child: _BentoCard(feature: _features[4]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: FadeTransition(
                              opacity: _cardFades[5],
                              child: SlideTransition(
                                position: _cardSlides[5],
                                child: _BentoCard(feature: _features[5], tall: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Class
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureData {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final String emoji;
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.emoji,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated Bento Card Widget to prevent rebuilding the entire Bento Section
// ─────────────────────────────────────────────────────────────────────────────
class _BentoCard extends StatefulWidget {
  final _FeatureData feature;
  final bool tall;

  const _BentoCard({required this.feature, this.tall = false});


  @override
  State<_BentoCard> createState() => _BentoCardState();
}

// No TickerProviderStateMixin needed — AnimatedSlide handles animation internally
class _BentoCardState extends State<_BentoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // AnimatedSlide uses Transform internally = GPU compositing, not Dart lerp
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.015) : Offset.zero,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(widget.tall ? 36 : 28),
          constraints: widget.tall ? const BoxConstraints(minHeight: 240) : null,
          // Only animate color + border (cheap). NO boxShadow blur change (expensive).
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovered ? f.color.withValues(alpha: 0.55) : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RepaintBoundary: icon glow changes won't repaint the text below
              RepaintBoundary(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: f.color.withValues(alpha: _hovered ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(f.icon, color: f.color, size: 28),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Text(f.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f.title,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                f.desc,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
              ),

              // Always in tree (no layout jump) — animated via opacity only
              const SizedBox(height: 14),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "اكتشف أكثر",
                      style: AppTypography.caption.copyWith(
                        color: f.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: f.color, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
