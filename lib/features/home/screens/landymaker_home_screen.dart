import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../../core/widgets/visibility_observer.dart';
import '../../../core/widgets/particles/cube_mode_cubit.dart';
import '../../../core/widgets/particles/floating_cube_background.dart';
import '../../../core/services/font_load_notifier.dart';
import '../../../core/localization/localization_cubit.dart';
import '../models/home_layouts.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_section_renderer.dart';

class LandyMakerHomeScreen extends StatefulWidget {
  const LandyMakerHomeScreen({super.key});

  static bool _isFirstAppLoad = true;
  static double lastScrollOffset = 0.0;

  static void resetScrollPosition() {
    lastScrollOffset = 0.0;
  }

  @override
  State<LandyMakerHomeScreen> createState() => _LandyMakerHomeScreenState();
}

class _LandyMakerHomeScreenState extends State<LandyMakerHomeScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  final _cubeController = FloatingCubeBackgroundController();
  double _lastScrollOffsetForDrift = 0.0;

  bool _particlesActive = true;
  int _cubeCount = 50;

  bool _bentoVisible = false;
  bool _ctaVisible = false;

  bool _fontsReady = false;

  late final AnimationController _logoAnimController;
  bool _burstTriggered = false;

  List<Map<String, dynamic>> _sections = [];
  bool _sectionsLoaded = false;
  late final bool _isThisTheFirstLoad;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: LandyMakerHomeScreen.lastScrollOffset,
    );
    _lastScrollOffsetForDrift = LandyMakerHomeScreen.lastScrollOffset;
    _scrollController.addListener(_saveScrollPosition);
    _loadSections();

    if (fontLoadNotifier.ready) {
      _fontsReady = true;
    } else {
      fontLoadNotifier.addListener(_onFontsReady);
    }

    _isThisTheFirstLoad = LandyMakerHomeScreen._isFirstAppLoad;
    LandyMakerHomeScreen._isFirstAppLoad = false;

    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    if (_isThisTheFirstLoad) {
      _logoAnimController.addListener(_onLogoAnimTick);
      _logoAnimController.addStatusListener(_onLogoAnimStatus);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logoAnimController.forward();
      });
    } else {
      _burstTriggered = true;
    }
  }

  void _onLogoAnimTick() {
    // Trigger burst 200ms after Flutter first frame (200 / 1500 = 0.133)
    if (!_burstTriggered && _logoAnimController.value >= 0.133) {
      _burstTriggered = true;
      _cubeController.triggerLogoBurst(const Offset(0.5, 0.5));
    }
    if (_logoAnimController.value < 1.0) {
      setState(() {});
    }
  }

  void _onLogoAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {});
    }
  }

  void _onFontsReady() {
    if (mounted) {
      setState(() => _fontsReady = true);
    }
    fontLoadNotifier.removeListener(_onFontsReady);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    final computed = 50 + ((width - 400) / 10).clamp(0, 80).toInt();
    if (computed != _cubeCount) {
      setState(() => _cubeCount = computed);
    }
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
      final current = _scrollController.offset;
      final delta = current - _lastScrollOffsetForDrift;
      _lastScrollOffsetForDrift = current;
      LandyMakerHomeScreen.lastScrollOffset = current;
      final height = context.size?.height ?? 1.0;
      _cubeController.scrollDrift = delta / height;
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

  void _onPointerDown(PointerDownEvent event) {
    final size = context.size;
    if (size != null && size.width > 0 && size.height > 0) {
      final normalized = Offset(
        event.localPosition.dx / size.width,
        event.localPosition.dy / size.height,
      );
      if (!_cubeController.trySplit(normalized)) {
        _cubeController.burstAt(normalized);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    _logoAnimController.removeListener(_onLogoAnimTick);
    _logoAnimController.removeStatusListener(_onLogoAnimStatus);
    _logoAnimController.dispose();
    fontLoadNotifier.removeListener(_onFontsReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroConfig = _sectionConfig('hero');
    final featuresConfig = _sectionConfig('features');
    final ctaConfig = _sectionConfig('cta');
    final footerConfig = _sectionConfig('footer');
    final navbarConfig = _sectionConfig('navbar');

    const double navbarHeight = 70.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final topExclusion = (navbarHeight / screenHeight).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MouseRegion(
        onHover: _onPointerHover,
        onExit: (_) => _cubeController.repelAt(null),
        child: Listener(
          onPointerDown: _onPointerDown,
          child: Stack(
            children: [
              Positioned.fill(
                child: FloatingCubeBackground(
                  topExclusion: topExclusion,
                  cubeCount: _cubeCount,
                  isActive: _particlesActive,
                  controller: _cubeController,
                  cubeMode: context.watch<CubeModeCubit>().state,
                  initialPreBurst: _isThisTheFirstLoad,
                ),
              ),
              AnimatedOpacity(
                opacity: _burstTriggered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: AnimatedSlide(
                  offset: _fontsReady ? Offset.zero : const Offset(0, -1),
                  duration: const Duration(milliseconds: 600),
                  child: HomeNavbar(
                    config: navbarConfig,
                    cubeCount: _cubeController.cubeCount,
                  ),
                ),
              ),
              if (_fontsReady)
                AnimatedOpacity(
                  opacity: _burstTriggered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Padding(
                    padding: EdgeInsets.only(top: navbarHeight),
                    child: SingleChildScrollView(
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
                              onGetStartedPressed: () =>
                                  context.go('/templates'),
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
                          if (_isSectionVisible('cta'))
                            VisibilityObserver(
                              onVisible: () {
                                if (!_ctaVisible)
                                  setState(() => _ctaVisible = true);
                              },
                              child: HomeCtaSection(
                                isVisible: _ctaVisible,
                                onGetStartedPressed: () =>
                                    context.go('/templates'),
                                layout: _parseCtaLayout(
                                  ctaConfig['layout'] as String?,
                                ),
                                text: _localeValue(ctaConfig, 'title'),
                                buttonText: _localeValue(
                                  ctaConfig,
                                  'button_text',
                                ),
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
