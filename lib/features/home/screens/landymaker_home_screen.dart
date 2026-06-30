import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization_cubit.dart';
import '../../../core/utils/js_helper.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/widgets/atoms/animated_cube_mode_toggle.dart';
import '../../../core/widgets/particles/cube_mode_cubit.dart';
import '../../../core/widgets/particles/floating_cube_background.dart';
import '../../../core/widgets/visibility_observer.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../builder/models/landing_page_theme.dart';
import '../models/home_layouts.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_navbar.dart';
import '../widgets/logo_test_dialog.dart';

/// [LandyMakerHomeScreen] — the app's main landing page StatefulWidget.
///
/// **Responsibility**: Configures scroll-position persistence and delegates
/// state management to `_LandyMakerHomeScreenState`.
/// **Used by**: App router as the home/root route.
/// **Key state**: `lastScrollOffset` (static) persists scroll across rebuilds;
/// `_isFirstAppLoad` (static) distinguishes first-ever launch from subsequent
/// navigations.
/// **⚠️ AI Warning**: `_isFirstAppLoad` controls the HTML→Flutter cross-fade
/// animation. Changing its semantics will break the first-load transition.
class LandyMakerHomeScreen extends StatefulWidget {
  const LandyMakerHomeScreen({super.key});

  static bool _isFirstAppLoad = true;

  /// Persists the most recent scroll offset across widget rebuilds so the
  /// user returns to the same position when navigating back.
  static double lastScrollOffset = 0.0;

  /// Resets [lastScrollOffset] to zero. Called when the user navigates to a
  /// new page to prevent automatic scrolling on return.
  static void resetScrollPosition() {
    lastScrollOffset = 0.0;
  }

  @override
  State<LandyMakerHomeScreen> createState() => _LandyMakerHomeScreenState();
}

/// [_LandyMakerHomeScreenState] — orchestrates the entire home screen lifecycle.
///
/// **Responsibility**: Owns scroll position, cube particle system, section data
/// loading, preview mode, and the first-load HTML→Flutter cross-fade transition.
/// **Used by**: `LandyMakerHomeScreen.createState()`.
/// **Key state**: `_burstTriggered`, `_persistentLogoRemoved`, `_darkBg` control
/// the reveal cascade; `_sections`/`_previewPages` hold CMS data; `_isPreviewMode`
/// toggles the logo-burst overlay; `_cubeController` manages all particle cubes.
/// **⚠️ AI Warning**: The first-load logic in `initState` uses
/// `addPostFrameCallback` to schedule `_transitionToPersistentLogo`,
/// `_removePersistentLogo`, and `_waitForLoadingThenRevealCubes`. Reordering
/// these or changing their timing will break the splash→content handoff.
class _LandyMakerHomeScreenState extends State<LandyMakerHomeScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  final _cubeController = FloatingCubeBackgroundController();
  double _lastScrollOffsetForDrift = 0.0;

  bool _particlesActive = true;
  int _cubeCount = 50;

  bool _bentoVisible = false;
  bool _ctaVisible = false;

  bool _fontsReady = true;
  bool _isPreviewMode = false;

  late final AnimationController _logoAnimController;
  bool _burstTriggered = false;
  bool _persistentLogoRemoved = false;
  bool _gatheringComplete = false;
  bool _darkBg = true;

  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _previewPages = [];
  bool _sectionsLoaded = false;
  late final bool _isThisTheFirstLoad;

  /// Initialises scroll controller, loads CMS sections, and triggers the
  /// first-load HTML→Flutter cross-fade when `_isFirstAppLoad` is true.
  ///
  /// Called once when the State is inserted into the tree. Side effects:
  /// registers scroll listener, wires `_cubeController.onGatherComplete`, and
  /// on first load schedules the background transition, logo fade-out, and
  /// reveal cascade via `addPostFrameCallback`.
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: LandyMakerHomeScreen.lastScrollOffset,
    );
    _lastScrollOffsetForDrift = LandyMakerHomeScreen.lastScrollOffset;
    _scrollController.addListener(_saveScrollPosition);
    _loadSections();

    _isThisTheFirstLoad = LandyMakerHomeScreen._isFirstAppLoad;
    LandyMakerHomeScreen._isFirstAppLoad = false;

    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Wire gather-complete callback (used when entering preview mode)
    _cubeController.onGatherComplete = _onGatherComplete;

    if (_isThisTheFirstLoad) {
      // ── First-load experience ──
      // 1. HTML loader starts with accelerated spawning and smooth lerping.
      // 2. When Flutter first frame is loaded, the loader background transitions to transparent.
      // 3. The Flutter cube starts fully formed (initialPreBurst = true) behind the HTML logo.
      // 4. We trigger a cross-fade transition immediately: HTML logo fades out via _removePersistentLogo()
      //    over 1.5s, while the Flutter cube fades in over 1.5s via _logoAnimController.
      // 5. Once APIs are loaded and the 1.5s cross-fade completes, the Flutter cube explodes and contents fade in.

      _burstTriggered = false; // Content hidden, cubes visible as loading view
      _gatheringComplete = true; // No building to wait for on first load

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Transition the HTML loader background to transparent (revealing Flutter behind it)
        _transitionToPersistentLogo();
        // Start fading the HTML persistent logo immediately (takes 1.5s)
        _removePersistentLogo();
        // Start fading in the fully formed Flutter cube (takes 1.5s)
        _logoAnimController.forward();
        // Wait for APIs and then trigger the burst (enforcing minimum 1.5s delay)
        _waitForLoadingThenRevealCubes();
      });
    } else {
      _burstTriggered = true;
      _darkBg = false;
    }
  }

  /// Waits for CMS sections to load and cubes to gather, then triggers the
  /// content-reveal cascade (burst, dark-bg fade, persistent-logo removal).
  ///
  /// Called once from `initState`'s `addPostFrameCallback` on first load.
  /// Enforces a minimum 1.5 s delay so the HTML→Flutter cross-fade completes.
  /// Side effects: sets `_burstTriggered = true`, `_darkBg = false`, calls
  /// `_cubeController.triggerLogoBurst`.
  Future<void> _waitForLoadingThenRevealCubes() async {
    final startTime = DateTime.now();
    // Wait for sections (API responses) to finish loading, with a safe timeout
    final deadline = DateTime.now().add(const Duration(seconds: 4));
    while (!_sectionsLoaded && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }
    // Also wait for cubes to finish gathering into logo formation
    // (in case sections loaded before gathering completed)
    while (!_gatheringComplete && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }

    // Ensure we wait at least 1500ms on first load for the HTML logo fade-out and Flutter cube fade-in to complete
    if (_isThisTheFirstLoad) {
      final elapsed = DateTime.now().difference(startTime);
      final remaining = const Duration(milliseconds: 1500) - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
    }

    // Loading complete → trigger everything simultaneously for a seamless cascade:
    //   1. Cubes explode (spherical from center)
    //   2. Content starts fading in (_burstTriggered = true)
    //   3. Persistent HTML logo has fully faded out
    if (mounted) {
      _burstTriggered = true;
      _darkBg = false;
      _persistentLogoRemoved = true;
      _cubeController.triggerLogoBurst(const Offset(0.5, 0.5));
      setState(() {});
    }
  }

  /// Callback invoked by `_cubeController` when cubes finish gathering into
  /// logo formation (e.g. after exiting preview mode).
  ///
  /// Sets `_gatheringComplete = true` and triggers a rebuild.
  void _onGatherComplete() {
    // Called when cubes finish gathering into logo formation
    // (e.g., after entering preview mode).
    _gatheringComplete = true;
    if (mounted) {
      setState(() {});
    }
  }

  /// Communicates with the HTML host via JS interop to transition the HTML
  /// loader background to transparent, revealing the Flutter canvas behind it.
  ///
  /// Called during the first-load cross-fade. No-op on non-web platforms.
  void _transitionToPersistentLogo() {
    if (kIsWeb) {
      callJs('transitionToPersistentLogo');
    }
  }

  /// Communicates with the HTML host via JS interop to fade out the
  /// persistent HTML logo overlay, completing the handoff from HTML loading
  /// to Flutter rendering.
  ///
  /// Called during the first-load cross-fade. No-op on non-web platforms.
  void _removePersistentLogo() {
    if (kIsWeb) {
      callJs('removePersistentLogo');
    }
  }

  /// Recomputes the cube count based on screen width whenever dependencies
  /// change. A responsive adjustment: more cubes on wider screens (81–130
  /// range).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    final computed = (50 + ((width - 400) / 10).clamp(0, 80).toInt()).clamp(
      81,
      130,
    );
    if (computed != _cubeCount) {
      setState(() => _cubeCount = computed);
    }
  }

  /// Fetches homepage section configurations from the database service.
  ///
  /// On success sets `_sectionsLoaded = true` and triggers preview-page loading
  /// for the hero section. Catches errors silently to avoid blocking the UI.
  Future<void> _loadSections() async {
    try {
      final sections = await sl<DatabaseService>().getHomepageSections();
      if (mounted) {
        setState(() {
          _sections = sections;
          _sectionsLoaded = true;
        });

        final heroConfig = _sectionConfig('hero');
        final pageIds = heroConfig['preview_page_ids'];
        if (pageIds is List && pageIds.isNotEmpty) {
          final List<String> ids = pageIds.map((e) => e.toString()).toList();
          _loadPreviewPages(ids);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _sectionsLoaded = true);
      }
    }
  }

  /// Fetches landing pages referenced by the hero section's
  /// `preview_page_ids` config, parsing their design JSON into preview models.
  ///
  /// Each page includes id, name, `LandingPageTheme`, and block list.
  Future<void> _loadPreviewPages(List<String> ids) async {
    try {
      final dbPages = await sl<DatabaseService>().getLandingPagesByIds(ids);
      final List<Map<String, dynamic>> parsedPages = [];
      for (final p in dbPages) {
        try {
          final designMap = await parseJsonDesign(p['design_json']);
          final name =
              p['name'] as String? ?? p['subdomain'] as String? ?? 'بدون اسم';
          final theme = designMap['theme'] != null
              ? LandingPageTheme.fromJson(designMap['theme'])
              : LandingPageTheme.palettes.last;
          final blocks = designMap['blocks'] as List<dynamic>? ?? [];

          parsedPages.add({
            'id': p['id'] as String,
            'name': name,
            'theme': theme,
            'blocks': blocks,
          });
        } catch (e) {
          debugPrint("Error parsing homepage preview page: $e");
        }
      }

      if (mounted) {
        setState(() {
          _previewPages = parsedPages;
        });
      }
    } catch (e) {
      debugPrint("Error loading homepage preview pages: $e");
    }
  }

  /// Persists the current scroll offset to `LandyMakerHomeScreen.lastScrollOffset`
  /// and drives cube drift based on scroll velocity.
  ///
  /// Called on every scroll event via `_scrollController` listener.
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

  /// Returns `true` if the section with the given [key] is marked as visible
  /// in the CMS configuration. Defaults to visible when sections aren't loaded.
  bool _isSectionVisible(String key) {
    if (!_sectionsLoaded) return true;
    final section = _sections.where((s) => s['section_key'] == key).firstOrNull;
    return section == null || section['is_visible'] == true;
  }

  /// Returns the config map for a section identified by [key], or an empty map
  /// if the section is not found.
  Map<String, dynamic> _sectionConfig(String key) {
    final section = _sections.where((s) => s['section_key'] == key).firstOrNull;
    if (section == null) return {};
    return (section['config'] as Map<String, dynamic>?) ?? {};
  }

  /// Returns a locale-aware string value from the section config using the
  /// current RTL setting. Falls back to the base key when the locale variant
  /// is absent.
  String? _localeValue(Map<String, dynamic> config, String baseKey) {
    final isArabic = context.isRtl;
    if (isArabic) {
      return (config['${baseKey}_ar'] ?? config[baseKey]) as String?;
    }
    return (config['${baseKey}_en'] ?? config[baseKey]) as String?;
  }

  /// Returns a locale-aware list value from the section config (e.g. typewriter
  /// texts) using the current RTL setting. Returns `null` when absent.
  List<String>? _localeList(Map<String, dynamic> config, String baseKey) {
    final isArabic = context.isRtl;
    final val = isArabic ? config['${baseKey}_ar'] : config['${baseKey}_en'];
    if (val is List) return List<String>.from(val);
    return null;
  }

  /// Parses a hero layout name string into a [HeroLayout] enum value,
  /// defaulting to [HeroLayout.split].
  HeroLayout _parseHeroLayout(String? name) {
    if (name == null) return HeroLayout.split;
    return HeroLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => HeroLayout.split,
    );
  }

  /// Parses a feature layout name string into a [FeatureLayout] enum value,
  /// defaulting to [FeatureLayout.bentoGrid].
  FeatureLayout _parseFeatureLayout(String? name) {
    if (name == null) return FeatureLayout.bentoGrid;
    return FeatureLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FeatureLayout.bentoGrid,
    );
  }

  /// Parses a CTA layout name string into a [CtaLayout] enum value,
  /// defaulting to [CtaLayout.centeredGradient].
  CtaLayout _parseCtaLayout(String? name) {
    if (name == null) return CtaLayout.centeredGradient;
    return CtaLayout.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CtaLayout.centeredGradient,
    );
  }

  /// Repels cubes away from the pointer's normalized position on hover.
  ///
  /// Called by `MouseRegion.onHover`. Passes `null` on exit to clear the
  /// repeller.
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

  /// Handles tap on the background to trigger cube interactions.
  ///
  /// If the logo is fully formed and the persistent HTML logo is removed,
  /// triggers a full logo explosion. Otherwise attempts a split or burst at
  /// the tapped position.
  void _onPointerDown(PointerDownEvent event) {
    final size = context.size;
    if (size != null && size.width > 0 && size.height > 0) {
      final normalized = Offset(
        event.localPosition.dx / size.width,
        event.localPosition.dy / size.height,
      );
      // Only trigger the full logo explosion if:
      // - The cube logo is fully formed (isLogoFormed)
      // - The persistent HTML logo has already been removed (loading complete)
      // On first load, this prevents premature burst during the loading phase
      if (_cubeController.isLogoFormed && _persistentLogoRemoved) {
        _burstTriggered = true;
        _cubeController.triggerLogoBurst(normalized);
      } else if (!_cubeController.trySplit(normalized)) {
        _cubeController.burstAt(normalized);
      }
    }
  }

  /// Enters preview mode: gathers cubes into logo formation and scrolls to top.
  ///
  /// The preview overlay replaces the normal navigation and provides cube-mode
  /// toggling.
  void _enterPreviewMode() {
    setState(() => _isPreviewMode = true);
    _cubeController.gatherIntoLogo();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Exits preview mode, restoring the normal navigation and cube interactions.
  void _exitPreviewMode() {
    setState(() => _isPreviewMode = false);
  }

  /// Disposes the scroll controller, its listener, and the logo animation
  /// controller.
  ///
  /// Called when the State is removed from the tree.
  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    _logoAnimController.dispose();
    super.dispose();
  }

  /// Builds the home screen Scaffold with a stacked layout: dark background,
  /// floating cube particles, scrollable content sections, navbar, and an
  /// optional preview-mode overlay with cube-mode toggling.
  ///
  /// Content sections (hero, features, CTA, footer) fade in after the
  /// first-load cross-fade completes (`_burstTriggered = true`).
  @override
  Widget build(BuildContext context) {
    final heroConfig = _sectionConfig('hero');
    final featuresConfig = _sectionConfig('features');
    final ctaConfig = _sectionConfig('cta');
    final footerConfig = _sectionConfig('footer');
    final navbarConfig = _sectionConfig('navbar');

    const double navbarHeight = 70.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final topExclusion = _isPreviewMode
        ? 0.0
        : (navbarHeight / screenHeight).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: MouseRegion(
        onHover: _onPointerHover,
        onExit: (_) => _cubeController.repelAt(null),
        child: Listener(
          onPointerDown: _onPointerDown,
          child: Stack(
            children: [
              // Dark background matching HTML loader — fades as content appears
              // Prevents harsh color shift between HTML loading and Flutter canvas
              AnimatedOpacity(
                opacity: _darkBg && !_isPreviewMode ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                child: const ColoredBox(color: Color(0xFF0F172A)),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _logoAnimController,
                  builder: (context, child) {
                    final opacity = _isThisTheFirstLoad
                        ? _logoAnimController.value
                        : 1.0;
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: RepaintBoundary(
                    child: FloatingCubeBackground(
                      topExclusion: topExclusion,
                      cubeCount: _cubeCount,
                      isActive: _particlesActive,
                      controller: _cubeController,
                      cubeMode: context.watch<CubeModeCubit>().state,
                      initialPreBurst:
                          _isThisTheFirstLoad &&
                          !_persistentLogoRemoved &&
                          !_isPreviewMode,
                    ),
                  ),
                ),
              ),
              if (_fontsReady)
                AnimatedOpacity(
                  opacity: _burstTriggered && !_isPreviewMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: IgnorePointer(
                    ignoring: _isPreviewMode,
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
                                previewPages: _previewPages,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              AnimatedOpacity(
                opacity: _burstTriggered && !_isPreviewMode ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: AnimatedSlide(
                  offset: _fontsReady ? Offset.zero : const Offset(0, -1),
                  duration: const Duration(milliseconds: 600),
                  child: IgnorePointer(
                    ignoring: _isPreviewMode,
                    child: HomeNavbar(
                      config: navbarConfig,
                      cubeCount: _cubeController.cubeCount,
                      onPreviewTapped: _enterPreviewMode,
                    ),
                  ),
                ),
              ),
              // Preview Mode Overlay
              if (_isPreviewMode)
                Positioned.fill(
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: AnimatedOpacity(
                          opacity: _isPreviewMode ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: _exitPreviewMode,
                                  tooltip: 'Exit Preview',
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                                const SizedBox(width: 16),
                                const AnimatedCubeModeToggle(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isPreviewMode || !kDebugMode
          ? null
          : FloatingActionButton(
              onPressed: () => showLogoTestDialog(context),
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: context.isRtl
                  ? "مقارنة لودينج اللوجو"
                  : "Compare Loading Logos",
              child: Icon(
                Icons.bug_report_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
    );
  }
}
