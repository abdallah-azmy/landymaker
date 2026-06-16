/// Testimonials Section — shows customer reviews after Stats section.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';

class HomeTestimonialsSection extends StatefulWidget {
  final bool isVisible;
  const HomeTestimonialsSection({super.key, required this.isVisible});

  @override
  State<HomeTestimonialsSection> createState() => _HomeTestimonialsSectionState();
}

class _HomeTestimonialsSectionState extends State<HomeTestimonialsSection>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late List<Animation<double>> _cardFades;

  static const _testimonials = [
    _TestimonialData(
      name: 'أحمد محمد',
      role: 'صاحب مطعم',
      city: 'القاهرة',
      text: 'في أقل من ١٠ دقائق عملت صفحة لمطعمي وبدأت أستقبل طلبات أونلاين. سهولة الاستخدام لا مثيل لها!',
      rating: 5,
      avatarColor: Color(0xFF6366F1),
      initial: 'أ',
    ),
    _TestimonialData(
      name: 'فاطمة العلي',
      role: 'مصممة أزياء',
      city: 'دبي',
      text: 'صفحتي الشخصية احترافية جداً. العملاء بدأوا يتواصلون معي مباشرة من الرابط. أنصح به بشدة!',
      rating: 5,
      avatarColor: Color(0xFF06B6D4),
      initial: 'ف',
    ),
    _TestimonialData(
      name: 'محمد الشمري',
      role: 'مدرّب لياقة',
      city: 'الرياض',
      text: 'استخدمت لاندي ميكر لعمل صفحة كورساتي. النتيجة؟ تضاعفت مبيعاتي في شهر واحد!',
      rating: 5,
      avatarColor: Color(0xFF10B981),
      initial: 'م',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.fastOutSlowIn),
    );

    _cardFades = List.generate(_testimonials.length, (i) => CurvedAnimation(
      parent: _cardsController,
      curve: Interval((i * 0.2).clamp(0.0, 1.0), ((i * 0.2) + 0.6).clamp(0.0, 1.0), curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(HomeTestimonialsSection oldWidget) {
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
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);
      return Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.symmetric(
          vertical: isMobile ? 32 : 60,
          horizontal: 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '⭐ آراء العملاء',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ماذا يقول عملاؤنا؟',
                          style: AppTypography.h2.copyWith(
                            fontSize: isMobile ? 28 : 42,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'أكثر من ١٥٬٠٠٠ صاحب عمل يثقون بـ Landymaker.',
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
                isMobile
                  ? Column(
                      children: List.generate(_testimonials.length, (i) => Padding(
                        padding: EdgeInsetsDirectional.only(bottom: i < _testimonials.length - 1 ? 16 : 0),
                        child: FadeTransition(
                          opacity: _cardFades[i],
                          child: _TestimonialCard(data: _testimonials[i]),
                        ),
                      )),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_testimonials.length, (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(end: i < _testimonials.length - 1 ? 20 : 0),
                          child: FadeTransition(
                            opacity: _cardFades[i],
                            child: _TestimonialCard(data: _testimonials[i]),
                          ),
                        ),
                      )),
                    ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TestimonialData {
  final String name, role, city, text, initial;
  final int rating;
  final Color avatarColor;
  const _TestimonialData({
    required this.name, required this.role, required this.city,
    required this.text, required this.rating, required this.avatarColor,
    required this.initial,
  });
}

class _TestimonialCard extends StatefulWidget {
  final _TestimonialData data;
  const _TestimonialCard({required this.data});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedSlide(
          offset: _hovered ? const Offset(0, -0.015) : Offset.zero,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsetsDirectional.all(28),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _hovered ? d.avatarColor.withValues(alpha: 0.4) : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(d.rating, (_) => const Padding(
                    padding: EdgeInsetsDirectional.only(end: 2),
                    child: Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                  )),
                ),
                const SizedBox(height: 16),
                Text(
                  '"${d.text}"',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: d.avatarColor,
                      child: Text(
                        d.initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        )),
                        Text(
                          '${d.role} • ${d.city}',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
