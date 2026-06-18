import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/widgets/visibility_observer.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_luxurious_template_slider.dart';
import '../widgets/home_desktop_preview_carousel.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';
import '../models/home_layouts.dart';

class LandyMakerHomeScreen extends StatefulWidget {
  const LandyMakerHomeScreen({super.key});

  static double lastScrollOffset = 0.0;

  static void resetScrollPosition() {
    lastScrollOffset = 0.0;
  }

  @override
  State<LandyMakerHomeScreen> createState() => _LandyMakerHomeScreenState();
}

class _LandyMakerHomeScreenState extends State<LandyMakerHomeScreen> {
  late final ScrollController _scrollController;

  bool _bentoVisible = false;
  bool _templatesVisible = false;
  bool _desktopPreviewVisible = false;
  bool _ctaVisible = false;

  HeroLayout _heroLayout = HeroLayout.split;
  FeatureLayout _featureLayout = FeatureLayout.bentoGrid;
  TemplateSliderLayout _templateSliderLayout = TemplateSliderLayout.horizontalSlider;
  CtaLayout _ctaLayout = CtaLayout.centeredGradient;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: LandyMakerHomeScreen.lastScrollOffset,
    );
    _scrollController.addListener(_saveScrollPosition);
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      LandyMakerHomeScreen.lastScrollOffset = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HomeNavbar(
        onLoginPressed: () => context.go('/login'),
        onGetStartedPressed: () => context.go('/templates'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HomeHeroSection(
              layout: _heroLayout,
              onGetStartedPressed: () => context.go('/templates'),
              parentScrollController: _scrollController,
            ),

            VisibilityObserver(
              onVisible: () {
                if (!_bentoVisible) setState(() => _bentoVisible = true);
              },
              child: HomeFeatureBento(
                isVisible: _bentoVisible,
                layout: _featureLayout,
              ),
            ),

            VisibilityObserver(
              onVisible: () {
                if (!_templatesVisible) setState(() => _templatesVisible = true);
              },
              child: HomeLuxuriousTemplateSlider(
                isVisible: _templatesVisible,
                layout: _templateSliderLayout,
                onGetStartedPressed: (templateId) {
                  TenantRoutingService.pendingTemplateId = templateId;
                  context.go('/register');
                },
              ),
            ),

            VisibilityObserver(
              onVisible: () {
                if (!_desktopPreviewVisible) setState(() => _desktopPreviewVisible = true);
              },
              child: HomeDesktopPreviewCarousel(
                isVisible: _desktopPreviewVisible,
                onGetStartedPressed: (templateId) {
                  TenantRoutingService.pendingTemplateId = templateId;
                  context.go('/register');
                },
              ),
            ),

            VisibilityObserver(
              onVisible: () {
                if (!_ctaVisible) setState(() => _ctaVisible = true);
              },
              child: HomeCtaSection(
                isVisible: _ctaVisible,
                onGetStartedPressed: () => context.go('/templates'),
                layout: _ctaLayout,
              ),
            ),

            const HomeFooter(),
          ],
        ),
      ),
    );
  }
}
