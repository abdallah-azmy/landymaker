import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';

class HomeTemplateStrip extends StatefulWidget {
  final Function(String templateId) onGetStartedPressed;
  final bool isVisible;

  const HomeTemplateStrip({
    super.key,
    required this.onGetStartedPressed,
    required this.isVisible,
  });

  @override
  State<HomeTemplateStrip> createState() => _HomeTemplateStripState();
}

class _HomeTemplateStripState extends State<HomeTemplateStrip>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;

  static const _templates = [
    _TemplateData(
      id: 'restaurant',
      name: 'مطعم وكافيه',
      category: 'Restaurant',
      image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
      tag: '🔥 رائج',
      tagColor: Color(0xFFEF4444),
      color: Color(0xFFF59E0B),
      desc: 'منيو، حجز طاولات، روابط توصيل',
    ),
    _TemplateData(
      id: 'store',
      name: 'متجر إلكتروني',
      category: 'E-Commerce',
      image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600',
      tag: '⭐ الأكثر مبيعاً',
      tagColor: Color(0xFF6366F1),
      color: Color(0xFF6366F1),
      desc: 'عرض المنتجات، أسعار، طلب مباشر',
    ),
    _TemplateData(
      id: 'personal',
      name: 'موقع شخصي',
      category: 'Portfolio',
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
      tag: '🎨 للمصممين',
      tagColor: Color(0xFF06B6D4),
      color: Color(0xFF06B6D4),
      desc: 'أعمال، مهارات، التواصل',
    ),
    _TemplateData(
      id: 'real_estate',
      name: 'عقارات',
      category: 'Real Estate',
      image: 'https://images.unsplash.com/photo-1613977257363-707ba9348227?w=600',
      tag: '🏠 جديد',
      tagColor: Color(0xFF10B981),
      color: Color(0xFF10B981),
      desc: 'عرض وحدات، معلومات، تواصل',
    ),
    _TemplateData(
      id: 'event',
      name: 'فعالية ومؤتمر',
      category: 'Events',
      image: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600',
      tag: '✨ جديد',
      tagColor: Color(0xFF8B5CF6),
      color: Color(0xFF8B5CF6),
      desc: 'تفاصيل الفعالية، تسجيل، خريطة',
    ),
    _TemplateData(
      id: 'clinic',
      name: 'عيادة طبية',
      category: 'Healthcare',
      image: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600',
      tag: '🏥 صحة',
      tagColor: Color(0xFF14B8A6),
      color: Color(0xFF14B8A6),
      desc: 'خدمات، مواعيد، الأطباء',
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
      duration: const Duration(milliseconds: 1400),
    );

    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.fastOutSlowIn));

    _cardFades = List.generate(_templates.length, (i) => CurvedAnimation(
      parent: _cardsController,
      curve: Interval((i * 0.10).clamp(0.0, 1.0), ((i * 0.10) + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
    ));
    _cardSlides = List.generate(_templates.length, (i) =>
        Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardsController,
            curve: Interval((i * 0.10).clamp(0.0, 1.0), ((i * 0.10) + 0.6).clamp(0.0, 1.0), curve: Curves.fastOutSlowIn),
          ),
        ));
  }

  @override
  void didUpdateWidget(HomeTemplateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 250), () {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 60, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          "🗂️ القوالب",
                          style: AppTypography.caption.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "ابدأ بقالب مصمم مسبقاً",
                        style: AppTypography.h2.copyWith(
                          fontSize: isMobile ? 28 : 42,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 14),
                      Text(
                        "جميع القوالب قابلة للتخصيص بالكامل ومتجاوبة مع جميع الأجهزة.",
                        style: AppTypography.bodyLarge
                            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 64),

              // Scrollable Cards
              SizedBox(
                height: isMobile ? 320 : 420,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _templates.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _cardFades[index],
                      child: SlideTransition(
                        position: _cardSlides[index],
                        child: _TemplateCard(
                          template: _templates[index],
                          onPressed: () =>
                              widget.onGetStartedPressed(_templates[index].id),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 40),

              // Browse All CTA
              FadeTransition(
                opacity: _headerFade,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.grid_view_rounded),
                  label: const Text("استعرض جميع القوالب"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Class
// ─────────────────────────────────────────────────────────────────────────────
class _TemplateData {
  final String id;
  final String name;
  final String category;
  final String image;
  final String tag;
  final Color tagColor;
  final Color color;
  final String desc;

  const _TemplateData({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.tag,
    required this.tagColor,
    required this.color,
    required this.desc,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Isolated Template Card Widget to prevent rebuilding the entire strip
// ─────────────────────────────────────────────────────────────────────────────
class _TemplateCard extends StatefulWidget {
  final _TemplateData template;
  final VoidCallback onPressed;

  const _TemplateCard({required this.template, required this.onPressed});


  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);
    final cardW = isMobile ? 240.0 : 300.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // AnimatedSlide = GPU layer transform, not Dart-side lerp
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.02) : Offset.zero,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: cardW,
          margin: const EdgeInsetsDirectional.only(start: 20),
          // Only animate color + border — no boxShadow blur (expensive)
          decoration: BoxDecoration(
            color: _hovered ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8) : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovered
                  ? widget.template.color.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedScale(
                      scale: _hovered ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                      child: Image.network(
                        widget.template.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: widget.template.color.withValues(alpha: 0.1),
                          child: Icon(Icons.image_rounded,
                              color: widget.template.color, size: 48),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: _hovered ? 0.5 : 0.45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.template.tagColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.template.tagColor
                                .withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.template.tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Category label
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        widget.template.category,
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.template.desc,
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      child: ElevatedButton(
                        onPressed: widget.onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hovered
                              ? widget.template.color
                              : Colors.transparent,
                          foregroundColor: _hovered
                              ? Colors.white
                              : widget.template.color,
                          side: BorderSide(
                              color: widget.template.color,
                              width: _hovered ? 0 : 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _hovered ? 6 : 0,
                          shadowColor:
                              widget.template.color.withValues(alpha: 0.4),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "استخدم هذا القالب",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _hovered
                                ? Colors.white
                                : widget.template.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
      },
    );
  }
}


