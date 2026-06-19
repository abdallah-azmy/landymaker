import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/widgets/visibility_observer.dart';
import '../../../core/widgets/particles/floating_cube_background.dart';
import '../models/home_layouts.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_luxurious_template_slider.dart';
import '../widgets/home_desktop_preview_carousel.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';

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

  bool _particlesActive = true;
  int _cubeCount = 30;

  bool _bentoVisible = false;
  bool _templatesVisible = false;
  bool _desktopPreviewVisible = false;
  bool _ctaVisible = false;

  List<Map<String, dynamic>> _sections = [];
  bool _sectionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: LandyMakerHomeScreen.lastScrollOffset,
    );
    _scrollController.addListener(_saveScrollPosition);
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final sections = await sl<DatabaseService>().getHomepageSections();
      if (mounted) {
        setState(() {
          _sections = sections;
          _sectionsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _sectionsLoaded = true);
      }
    }
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      LandyMakerHomeScreen.lastScrollOffset = _scrollController.offset;
    }
  }

  bool _isSectionVisible(String key) {
    if (!_sectionsLoaded) return true;
    final section = _sections.where((s) => s['section_key'] == key).firstOrNull;
    return section == null || section['is_visible'] == true;
  }

  Map<String, dynamic> _sectionConfig(String key) {
    final section = _sections.where((s) => s['section_key'] == key).firstOrNull;
    if (section == null) return {};
    return (section['config'] as Map<String, dynamic>?) ?? {};
  }

  HeroLayout _parseHeroLayout(String? name) {
    if (name == null) return HeroLayout.split;
    return HeroLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => HeroLayout.split,
    );
  }

  FeatureLayout _parseFeatureLayout(String? name) {
    if (name == null) return FeatureLayout.bentoGrid;
    return FeatureLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FeatureLayout.bentoGrid,
    );
  }

  CtaLayout _parseCtaLayout(String? name) {
    if (name == null) return CtaLayout.centeredGradient;
    return CtaLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CtaLayout.centeredGradient,
    );
  }

  TemplateSliderLayout _parseTemplateSliderLayout(String? name) {
    if (name == null) return TemplateSliderLayout.horizontalSlider;
    return TemplateSliderLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TemplateSliderLayout.horizontalSlider,
    );
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
      body: Stack(
        children: [
          Positioned.fill(
            child: FloatingCubeBackground(
              cubeCount: _cubeCount,
              baseColor: Theme.of(context).colorScheme.primary,
              isActive: _particlesActive,
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                if (_isSectionVisible('hero'))
                  HomeHeroSection(
                    layout: _parseHeroLayout(_sectionConfig('hero')['layout'] as String?),
                    title: _sectionConfig('hero')['title'] as String?,
                    subtitle: _sectionConfig('hero')['subtitle'] as String?,
                    ctaText: _sectionConfig('hero')['cta_text'] as String?,
                    typewriterTexts: _sectionConfig('hero')['typewriter_texts'] != null
                        ? List<String>.from(_sectionConfig('hero')['typewriter_texts'] as List)
                        : null,
                    onGetStartedPressed: () => context.go('/templates'),
                    parentScrollController: _scrollController,
                  ),
                if (_isSectionVisible('features'))
                  VisibilityObserver(
                    onVisible: () {
                      if (!_bentoVisible) setState(() => _bentoVisible = true);
                    },
                    child: HomeFeatureBento(
                      isVisible: _bentoVisible,
                      layout: _parseFeatureLayout(_sectionConfig('features')['layout'] as String?),
                      title: _sectionConfig('features')['title'] as String?,
                    ),
                  ),
                if (_isSectionVisible('templates'))
                  VisibilityObserver(
                    onVisible: () {
                      if (!_templatesVisible) setState(() => _templatesVisible = true);
                    },
                    child: HomeLuxuriousTemplateSlider(
                      isVisible: _templatesVisible,
                      layout: _parseTemplateSliderLayout(_sectionConfig('templates')['layout'] as String?),
                      title: _sectionConfig('templates')['title'] as String?,
                      subtitle: _sectionConfig('templates')['subtitle'] as String?,
                      maxToShow: _sectionConfig('templates')['max_to_show'] as int?,
                      onGetStartedPressed: (templateId) {
                        TenantRoutingService.pendingTemplateId = templateId;
                        context.go('/register');
                      },
                    ),
                  ),
                if (_isSectionVisible('desktop_preview'))
                  VisibilityObserver(
                    onVisible: () {
                      if (!_desktopPreviewVisible) setState(() => _desktopPreviewVisible = true);
                    },
                    child: HomeDesktopPreviewCarousel(
                      isVisible: _desktopPreviewVisible,
                      title: _sectionConfig('desktop_preview')['title'] as String?,
                      subtitle: _sectionConfig('desktop_preview')['subtitle'] as String?,
                      description: _sectionConfig('desktop_preview')['description'] as String?,
                      onGetStartedPressed: (templateId) {
                        TenantRoutingService.pendingTemplateId = templateId;
                        context.go('/register');
                      },
                    ),
                  ),
                if (_isSectionVisible('cta'))
                  VisibilityObserver(
                    onVisible: () {
                      if (!_ctaVisible) setState(() => _ctaVisible = true);
                    },
                    child: HomeCtaSection(
                      isVisible: _ctaVisible,
                      onGetStartedPressed: () => context.go('/templates'),
                      layout: _parseCtaLayout(_sectionConfig('cta')['layout'] as String?),
                      text: _sectionConfig('cta')['title'] as String?,
                      buttonText: _sectionConfig('cta')['button_text'] as String?,
                    ),
                  ),
                if (_isSectionVisible('footer'))
                  HomeFooter(
                    copyrightText: _sectionConfig('footer')['copyright_text'] as String?,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
