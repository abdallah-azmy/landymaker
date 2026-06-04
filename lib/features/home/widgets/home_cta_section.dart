import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeCtaSection extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onGetStartedPressed;

  const HomeCtaSection({
    super.key,
    required this.isVisible,
    required this.onGetStartedPressed,
  });

  @override
  State<HomeCtaSection> createState() => _HomeCtaSectionState();
}

class _HomeCtaSectionState extends State<HomeCtaSection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bgController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
  }

  @override
  void didUpdateWidget(HomeCtaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final val = _bgController.value;
        return RepaintBoundary(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 60 : 90,
                  horizontal: isMobile ? 28 : 80,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment(-0.8 + 0.4 * val, -0.8),
                    end: Alignment(0.8 - 0.4 * val, 0.8),
                    colors: const [
                      Color(0xFF1E1B4B),
                      Color(0xFF0F172A),
                      Color(0xFF0C1A3A),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3 + 0.1 * val),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1 + 0.05 * val),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "مجاني تماماً • بدون بطاقة ائتمان",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Main heading
              Text(
                "جاهز تطلق موقعك الآن؟",
                style: AppTypography.h1.copyWith(
                  fontSize: isMobile ? 32 : 52,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "انضم لآلاف الأعمال التي تستخدم Landymaker.\nابنِ صفحتك في دقائق وابدأ تستقبل عملاء اليوم.",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Isolated hover CTA Button to prevent rebuilding the text block
              _CtaButton(onPressed: widget.onGetStartedPressed),

              const SizedBox(height: 32),

              // Trust signals
              Wrap(
                spacing: 24,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _TrustChip(icon: Icons.check_circle_rounded, text: "لا يحتاج بطاقة"),
                  _TrustChip(icon: Icons.check_circle_rounded, text: "لا حاجة لخبرة تقنية"),
                  _TrustChip(icon: Icons.check_circle_rounded, text: "نشر فوري"),
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
// Isolated CTA Button widget to prevent rebuilding the entire CTA Section
// ─────────────────────────────────────────────────────────────────────────────
class _CtaButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CtaButton({required this.onPressed});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -0.018) : Offset.zero,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            // Static shadow — no expensive dynamic blur changes
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.flash_on_rounded, size: 20),
            label: const Text(
              "ابدأ مجاناً الآن",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 44,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust Chip widget
// ─────────────────────────────────────────────────────────────────────────────
class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.activeGreen, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
