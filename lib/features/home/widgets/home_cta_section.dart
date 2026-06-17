import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/animations/entrance_animation_mixin.dart';
import '../models/home_layouts.dart';

/// Pixabay background image used in the [CtaLayout.fullWidthImage] layout.
const _kCtaBgImage =
    'https://cdn.pixabay.com/photo/2016/11/29/13/14/attractive-1869761_1280.jpg';

class HomeCtaSection extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onGetStartedPressed;
  final CtaLayout layout;
  final double overlayOpacity;

  const HomeCtaSection({
    super.key,
    required this.isVisible,
    required this.onGetStartedPressed,
    this.layout = CtaLayout.centeredGradient,
    this.overlayOpacity = 0.6,
  });

  @override
  State<HomeCtaSection> createState() => _HomeCtaSectionState();
}

class _HomeCtaSectionState extends State<HomeCtaSection>
    with TickerProviderStateMixin, EntranceAnimationMixin {
  late AnimationController _bgController;

  @override
  Duration get entranceDuration => const Duration(milliseconds: 900);

  @override
  Offset get entranceSlideBegin => const Offset(0, 0.25);

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HomeCtaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      startEntrance();
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        switch (widget.layout) {
          case CtaLayout.split:
            return _buildSplitLayout(context, isMobile);
          case CtaLayout.centeredGradient:
            return _buildCenteredGradientLayout(context, isMobile);
          case CtaLayout.fullWidthImage:
            return _buildFullWidthImageLayout(context, isMobile);
        }
      },
    );
  }

  Widget _buildCenteredGradientLayout(BuildContext context, bool isMobile) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final val = _bgController.value;
        return RepaintBoundary(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: isMobile ? 32 : 60),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 48 : 72,
                  horizontal: isMobile ? 28 : 64,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment(-0.8 + 0.4 * val, -0.8),
                    end: Alignment(0.8 - 0.4 * val, 0.8),
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3 + 0.1 * val),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1 + 0.05 * val),
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
        opacity: entranceFade,
        child: SlideTransition(
          position: entranceSlide,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 14,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "مجاني تماماً • بدون بطاقة ائتمان",
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                "جاهز تطلق موقعك الآن؟",
                style: AppTypography.h1.copyWith(
                  fontSize: isMobile ? 32 : 52,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "انضم لآلاف الأعمال التي تستخدم Landymaker.\nابنِ صفحتك في دقائق وابدأ تستقبل عملاء اليوم.",
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              _CtaButton(onPressed: widget.onGetStartedPressed),
              SizedBox(height: 32),
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

  Widget _buildFullWidthImageLayout(BuildContext context, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomNetworkImage(
                imageUrl: _kCtaBgImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: widget.overlayOpacity)),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: EdgeInsetsDirectional.symmetric(
                vertical: isMobile ? 32 : 60,
                horizontal: 24,
              ),
              child: FadeTransition(
                opacity: entranceFade,
                child: SlideTransition(
                  position: entranceSlide,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 14,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "مجاني تماماً • بدون بطاقة ائتمان",
                              style: AppTypography.caption.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 28),
                      Text(
                        "جاهز تطلق موقعك الآن؟",
                        style: AppTypography.h1.copyWith(
                          fontSize: isMobile ? 32 : 52,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "انضم لآلاف الأعمال التي تستخدم Landymaker.\nابنِ صفحتك في دقائق وابدأ تستقبل عملاء اليوم.",
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.65,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      _CtaButton(onPressed: widget.onGetStartedPressed),
                      SizedBox(height: 32),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitLayout(BuildContext context, bool isMobile) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final val = _bgController.value;
        return RepaintBoundary(
            child: Container(
             width: double.infinity,
             padding: EdgeInsets.symmetric(
               vertical: isMobile ? 32 : 60,
               horizontal: 24,
             ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: isMobile ? 48 : 72,
                  horizontal: isMobile ? 24 : 60,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment(-0.8 + 0.4 * val, -0.8),
                    end: Alignment(0.8 - 0.4 * val, 0.8),
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3 + 0.1 * val),
                    width: 1.5,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: entranceFade,
        child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'جاهز تطلق موقعك الآن؟',
                  style: AppTypography.h2.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'ابنِ صفحتك في دقائق وابدأ تستقبل عملاء اليوم.',
                  style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                _CtaButton(onPressed: widget.onGetStartedPressed),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جاهز تطلق موقعك الآن؟',
                        style: AppTypography.h2.copyWith(fontSize: 38, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'ابنِ صفحتك في دقائق وابدأ تستقبل عملاء اليوم.',
                        style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.6),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 48),
                _CtaButton(onPressed: widget.onGetStartedPressed),
              ],
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
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedSlide(
          offset: _hovered ? const Offset(0, -0.018) : Offset.zero,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.secondary, const Color(0xFF0C1A3A)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(Icons.flash_on_rounded, size: 20),
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
        Icon(icon, color: Colors.green, size: 16),
        SizedBox(width: 6),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
