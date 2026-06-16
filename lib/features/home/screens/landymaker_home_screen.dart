import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_trust_logos.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_luxurious_template_slider.dart';
import '../widgets/home_stats_section.dart';
import '../widgets/home_testimonials_section.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';
import '../models/home_layouts.dart';

class LandyMakerHomeScreen extends StatefulWidget {
  const LandyMakerHomeScreen({super.key});

  @override
  State<LandyMakerHomeScreen> createState() => _LandyMakerHomeScreenState();
}

class _LandyMakerHomeScreenState extends State<LandyMakerHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _trustLogosKey = GlobalKey();
  final GlobalKey _bentoKey = GlobalKey();
  final GlobalKey _templatesKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();
  final GlobalKey _ctaKey = GlobalKey();

  bool _trustLogosVisible = false;
  bool _bentoVisible = false;
  bool _templatesVisible = false;
  bool _statsVisible = false;
  bool _testimonialsVisible = false;
  bool _ctaVisible = false;

  HeroLayout _heroLayout = HeroLayout.split;
  FeatureLayout _featureLayout = FeatureLayout.bentoGrid;
  TemplateSliderLayout _templateSliderLayout = TemplateSliderLayout.horizontalSlider;
  StatsLayout _statsLayout = StatsLayout.horizontal;
  CtaLayout _ctaLayout = CtaLayout.centeredGradient;

  // Track how many sections are still waiting — stop listening once all visible
  int get _pendingCount =>
      (_trustLogosVisible ? 0 : 1) +
      (_bentoVisible ? 0 : 1) +
      (_templatesVisible ? 0 : 1) +
      (_statsVisible ? 0 : 1) +
      (_testimonialsVisible ? 0 : 1) +
      (_ctaVisible ? 0 : 1);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Stop listening once all sections revealed — no more wasted work
    if (_pendingCount == 0) {
      _scrollController.removeListener(_onScroll);
      return;
    }
    if (!mounted) return;
    final screenH = MediaQuery.of(context).size.height;

    // Each check is guarded: skip if already visible
    if (!_trustLogosVisible) _checkAndReveal(_trustLogosKey, screenH, () => _trustLogosVisible = true);
    if (!_bentoVisible) _checkAndReveal(_bentoKey, screenH, () => _bentoVisible = true);
    if (!_templatesVisible) _checkAndReveal(_templatesKey, screenH, () => _templatesVisible = true);
    if (!_statsVisible) _checkAndReveal(_statsKey, screenH, () => _statsVisible = true);
    if (!_testimonialsVisible) _checkAndReveal(_testimonialsKey, screenH, () => _testimonialsVisible = true);
    if (!_ctaVisible) _checkAndReveal(_ctaKey, screenH, () => _ctaVisible = true);
  }

  void _checkAndReveal(GlobalKey key, double screenH, VoidCallback setFlag) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos = box.localToGlobal(Offset.zero);
    if (pos.dy < screenH * 0.90) {
      setState(setFlag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeNavbar(
        onLoginPressed: () => context.go('/login'),
        onGetStartedPressed: () => context.go('/templates'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero doesn't need scroll-trigger — it's above the fold
            HomeHeroSection(
              layout: _heroLayout,
              onGetStartedPressed: () => context.go('/templates'),
              parentScrollController: _scrollController,
            ),

            HomeTrustLogos(
              key: _trustLogosKey,
              isVisible: _trustLogosVisible,
            ),

            HomeFeatureBento(
              key: _bentoKey,
              isVisible: _bentoVisible,
              layout: _featureLayout,
            ),

            HomeLuxuriousTemplateSlider(
              key: _templatesKey,
              isVisible: _templatesVisible,
              layout: _templateSliderLayout,
              onGetStartedPressed: (templateId) {
                TenantRoutingService.pendingTemplateId = templateId;
                context.go('/register');
              },
            ),

            HomeStatsSection(
              key: _statsKey,
              isVisible: _statsVisible,
              layout: _statsLayout,
            ),

            HomeTestimonialsSection(
              key: _testimonialsKey,
              isVisible: _testimonialsVisible,
            ),

            HomeCtaSection(
              key: _ctaKey,
              isVisible: _ctaVisible,
              onGetStartedPressed: () => context.go('/templates'),
              layout: _ctaLayout,
            ),

            const HomeFooter(),
          ],
        ),
      ),
    );
  }
}
