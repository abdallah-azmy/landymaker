import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/widgets/visibility_observer.dart';
import '../../../core/widgets/particles/floating_cube_background.dart';
import '../../../core/localization/localization_cubit.dart';
import '../models/home_layouts.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_luxurious_template_slider.dart';
import '../widgets/home_desktop_preview_carousel.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_section_renderer.dart';

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
  final _cubeController = FloatingCubeBackgroundController();

  bool _particlesActive = true;
  int _cubeCount = 50;

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

  String? _localeValue(Map<String, dynamic> config, String baseKey) {
    final isArabic = context.isRtl;
    if (isArabic) {
      return (config['${baseKey}_ar'] ?? config[baseKey]) as String?;
    }
    return (config['${baseKey}_en'] ?? config[baseKey]) as String?;
  }

  List<String>? _localeList(Map<String, dynamic> config, String baseKey) {
    final isArabic = context.isRtl;
    final val = isArabic ? config['${baseKey}_ar'] : config['${baseKey}_en'];
    if (val is List) return List<String>.from(val);
    return null;
  }

  Map<String, dynamic>? _localeLinks(
    Map<String, dynamic> config,
    String baseKey,
  ) {
    final isArabic = context.isRtl;
    final links = isArabic ? config['${baseKey}_ar'] : config['${baseKey}_en'];
    if (links is List) {
      final list = List<Map<String, dynamic>>.from(
        links.map((e) => Map<String, dynamic>.from(e)),
      );
      return {'links': list};
    }
    return null;
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

  void _onPointerHover(PointerHoverEvent event) {
    final size = context.size;
    if (size != null && size.width > 0 && size.height > 0) {
      _cubeController.repelAt(
        Offset(
          event.localPosition.dx / size.width,
          event.localPosition.dy / size.height,
        ),
      );
    }
  }

  void _onTapDown(TapDownDetails details) {
    final size = context.size;
    if (size != null && size.width > 0 && size.height > 0) {
      _cubeController.burstAt(
        Offset(
          details.localPosition.dx / size.width,
          details.localPosition.dy / size.height,
        ),
      );
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
    final heroConfig = _sectionConfig('hero');
    final featuresConfig = _sectionConfig('features');
    final templatesConfig = _sectionConfig('templates');
    final desktopConfig = _sectionConfig('desktop_preview');
    final ctaConfig = _sectionConfig('cta');
    final footerConfig = _sectionConfig('footer');
    final navbarConfig = _sectionConfig('navbar');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HomeNavbar(config: navbarConfig),
      body: MouseRegion(
        onHover: _onPointerHover,
        onExit: (_) => _cubeController.repelAt(null),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: _onTapDown,
          child: Stack(
            children: [
              Positioned.fill(
                child: FloatingCubeBackground(
                  cubeCount: _cubeCount,
                  baseColor: Theme.of(context).colorScheme.primary,
                  isActive: _particlesActive,
                  controller: _cubeController,
                ),
              ),
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    if (_isSectionVisible('hero'))
                      HomeHeroSection(
                        layout: _parseHeroLayout(
                          heroConfig['layout'] as String?,
                        ),
                        title: _localeValue(heroConfig, 'title'),
                        subtitle: _localeValue(heroConfig, 'subtitle'),
                        ctaText: _localeValue(heroConfig, 'cta_text'),
                        typewriterTexts: _localeList(
                          heroConfig,
                          'typewriter_texts',
                        ),
                        onGetStartedPressed: () => context.go('/templates'),
                        parentScrollController: _scrollController,
                      ),
                    if (_isSectionVisible('features'))
                      VisibilityObserver(
                        onVisible: () {
                          if (!_bentoVisible)
                            setState(() => _bentoVisible = true);
                        },
                        child: HomeFeatureBento(
                          isVisible: _bentoVisible,
                          layout: _parseFeatureLayout(
                            featuresConfig['layout'] as String?,
                          ),
                          title: _localeValue(featuresConfig, 'title'),
                        ),
                      ),
                    if (_isSectionVisible('templates'))
                      VisibilityObserver(
                        onVisible: () {
                          if (!_templatesVisible)
                            setState(() => _templatesVisible = true);
                        },
                        child: HomeLuxuriousTemplateSlider(
                          isVisible: _templatesVisible,
                          layout: _parseTemplateSliderLayout(
                            templatesConfig['layout'] as String?,
                          ),
                          title: _localeValue(templatesConfig, 'title'),
                          subtitle: _localeValue(templatesConfig, 'subtitle'),
                          maxToShow: templatesConfig['max_to_show'] as int?,
                          templateIds: templatesConfig['template_ids'] != null
                              ? List<String>.from(
                                  templatesConfig['template_ids'] as List,
                                )
                              : null,
                          onGetStartedPressed: (templateId) {
                            TenantRoutingService.pendingTemplateId = templateId;
                            context.go('/register');
                          },
                        ),
                      ),
                    if (_isSectionVisible('desktop_preview'))
                      VisibilityObserver(
                        onVisible: () {
                          if (!_desktopPreviewVisible)
                            setState(() => _desktopPreviewVisible = true);
                        },
                        child: HomeDesktopPreviewCarousel(
                          isVisible: _desktopPreviewVisible,
                          title: _localeValue(desktopConfig, 'title'),
                          subtitle: _localeValue(desktopConfig, 'subtitle'),
                          description: _localeValue(
                            desktopConfig,
                            'description',
                          ),
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
                          layout: _parseCtaLayout(
                            ctaConfig['layout'] as String?,
                          ),
                          text: _localeValue(ctaConfig, 'title'),
                          buttonText: _localeValue(ctaConfig, 'button_text'),
                        ),
                      ),
                    if (_isSectionVisible('footer'))
                      HomeFooter(
                        copyrightText: _localeValue(
                          footerConfig,
                          'copyright_text',
                        ),
                      ),
                    if (_isSectionVisible('section_renderer'))
                      HomeSectionRenderer(
                        landingPageId:
                            _sectionConfig(
                                  'section_renderer',
                                )['landing_page_id']
                                as String? ??
                            '',
                        displayTitle: _localeValue(
                          _sectionConfig('section_renderer'),
                          'display',
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
  }
}
