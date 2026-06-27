import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../../core/widgets/visibility_observer.dart';
import '../../../core/widgets/particles/cube_mode_cubit.dart';
import '../../../core/widgets/particles/floating_cube_background.dart';
import '../../../core/utils/js_helper.dart';

import '../../../core/localization/localization_cubit.dart';
import '../models/home_layouts.dart';
import '../../../core/widgets/atoms/animated_cube_mode_toggle.dart';
import '../../../core/widgets/atoms/cube_shimmer.dart';
import '../../../core/widgets/atoms/cube_refresh_indicator.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/particles/cube_loader.dart';
import '../../builder/models/landing_page_theme.dart';

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

  void _onGatherComplete() {
    // Called when cubes finish gathering into logo formation
    // (e.g., after entering preview mode).
    _gatheringComplete = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _transitionToPersistentLogo() {
    if (kIsWeb) {
      callJs('transitionToPersistentLogo');
    }
  }

  void _removePersistentLogo() {
    if (kIsWeb) {
      callJs('removePersistentLogo');
    }
  }

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

  Future<void> _loadPreviewPages(List<String> ids) async {
    try {
      final dbPages = await sl<DatabaseService>().getLandingPagesByIds(ids);
      final List<Map<String, dynamic>> parsedPages = [];
      for (final p in dbPages) {
        try {
          Map<String, dynamic> designMap = {'blocks': []};
          final rawDesign = p['design_json'];
          if (rawDesign != null) {
            if (rawDesign is String) {
              designMap = Map<String, dynamic>.from(jsonDecode(rawDesign));
            } else {
              designMap = Map<String, dynamic>.from(rawDesign as Map);
            }
          }
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

  void _exitPreviewMode() {
    setState(() => _isPreviewMode = false);
  }

  void _showLogoTestDialog(BuildContext context) {
    final variants = CubeLoaderVariant.values;
    final isRtl = context.isRtl;
    final variantLabels = {
      CubeLoaderVariant.logo: isRtl ? "الشعار" : "Brand Logo",
      CubeLoaderVariant.single: isRtl ? "مفرد" : "Single Cube",
      CubeLoaderVariant.cluster: isRtl ? "مجموعة" : "Cluster Orbit",
      CubeLoaderVariant.linear: isRtl ? "خطي" : "Linear Wave",
      CubeLoaderVariant.circular: isRtl ? "دائري" : "Circular Ring",
      CubeLoaderVariant.physics: isRtl ? "فيزيائي" : "Physics Bounce",
      CubeLoaderVariant.logoCornerAxis: isRtl
          ? "شعار زاوية محورية"
          : "Logo Corner Axis",
      CubeLoaderVariant.logoWave: isRtl ? "موجة الشعار" : "Logo Cascade Wave",
      CubeLoaderVariant.singleWobble: isRtl ? "ترنح مفرد" : "Single Wobble",
      CubeLoaderVariant.clusterSpiral: isRtl
          ? "دوامة المجموعة"
          : "Cluster Spiral",
      CubeLoaderVariant.linearBidi: isRtl
          ? "موجة ثنائية الاتجاه"
          : "Bidirectional Wave",
      CubeLoaderVariant.circularDouble: isRtl ? "حلقة مزدوجة" : "Double Ring",
      CubeLoaderVariant.logoPremium: isRtl ? "شعار بريميوم" : "Premium Logo",
      CubeLoaderVariant.logoPremiumCornerAxis: isRtl
          ? "شعار زاوية محور بريميوم"
          : "Premium Corner Axis",
      CubeLoaderVariant.logoPremiumFloat: isRtl ? "شعار عائم" : "Premium Float",
      CubeLoaderVariant.logoPremiumWave: isRtl ? "موجة الشعار" : "Premium Wave",
      CubeLoaderVariant.logoPremiumCorePulse: isRtl
          ? "نبض مركز الشعار"
          : "Premium Core Pulse",
      CubeLoaderVariant.logoPremiumRotate: isRtl
          ? "دوران الشعار"
          : "Premium Rotate",
      CubeLoaderVariant.logoPremiumAura: isRtl ? "هالة الشعار" : "Premium Aura",
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 700,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRtl
                                ? "معاينة مؤشرات التحميل"
                                : "Loading Indicator Showcase",
                            style: AppTypography.h3.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRtl
                                ? "جميع أنواع CubeLoader داخل أزرار تفاعلية"
                                : "All CubeLoader variants rendered inside interactive buttons",
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        hoverColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SECTION 1: Standalone Variant Showcase
                        _buildSectionHeader(
                          dialogContext,
                          isRtl
                              ? "1. عرض الأنواع بشكل منفصل"
                              : "1. Standalone Variant Preview",
                          isRtl
                              ? "كل شكل معروض بحجمه الطبيعي مع وصف مختصر"
                              : "Each variant shown at its natural size with a short description",
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.logo] ?? "Logo",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "شعار العلامة التجارية"
                                : "Brand Logo",
                            desc: isRtl
                                ? "27 مكعباً في شبكة 3×3×3 بإسقاط متساوي القياس وزوايا دائرية"
                                : "27 cubes in 3×3×3 isometric grid with rounded corners",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logo,
                              initialState: CubeLoaderState.breathing,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message:
                                    variantLabels[CubeLoaderVariant.single] ??
                                    "Single",
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl
                                      ? "مؤشر زر مفرد"
                                      : "Single Cube Spinner",
                                  desc: isRtl
                                      ? "مكعب دوار مخصص للأزرار"
                                      : "Rotating cube for button loading states",
                                  child: const CubeLoader(
                                    size: 36,
                                    variant: CubeLoaderVariant.single,
                                    initialState: CubeLoaderState.loading,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Tooltip(
                                message:
                                    variantLabels[CubeLoaderVariant.cluster] ??
                                    "Cluster",
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl
                                      ? "مجموعة مدارية"
                                      : "Orbital Cluster",
                                  desc: isRtl
                                      ? "3 مكعبات تدور في مدار مع نسبة مئوية"
                                      : "3 orbiting cubes with progress percentage",
                                  child: const CubeLoader(
                                    size: 72,
                                    variant: CubeLoaderVariant.cluster,
                                    value: 0.72,
                                    showPercentage: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message:
                                    variantLabels[CubeLoaderVariant.linear] ??
                                    "Linear",
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "تموج خطي" : "Linear Wave",
                                  desc: isRtl
                                      ? "5 مكعبات بنبض متدرج"
                                      : "5 cubes in a staggered wave pulse",
                                  child: const CubeLoader(
                                    size: 110,
                                    variant: CubeLoaderVariant.linear,
                                    initialState: CubeLoaderState.loading,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Tooltip(
                                message:
                                    variantLabels[CubeLoaderVariant.circular] ??
                                    "Circular",
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl
                                      ? "حلقة دائرية"
                                      : "Circular Ring",
                                  desc: isRtl
                                      ? "8 مكعبات في مسار دائري بعمق"
                                      : "8 cubes in a circular depth wave",
                                  child: const CubeLoader(
                                    size: 90,
                                    variant: CubeLoaderVariant.circular,
                                    initialState: CubeLoaderState.loading,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.physics] ??
                              "Physics",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "ارتداد فيزيائي" : "Physics Bounce",
                            desc: isRtl
                                ? "سقوط حر وارتداد مع انضغاط"
                                : "Free-fall bounce with squash and stretch",
                            child: const CubeLoader(
                              size: 90,
                              variant: CubeLoaderVariant.physics,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // New logo-corner-axis standalone card
                        _buildSectionHeader(
                          dialogContext,
                          isRtl ? "إضافات جديدة" : "New Additions",
                          isRtl
                              ? "خيارات دوران وزاوية جديدة لكل نوع"
                              : "New rotation and angle options per variant",
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.logoCornerAxis] ??
                              "Logo Corner Axis",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "دوران زاوية الشعار"
                                : "Logo Corner-Axis Rotation",
                            desc: isRtl
                                ? "دوران حول المحور القطري — 3 أوجه مرئية متساوية"
                                : "Body-diagonal axis rotation — 3 equal visible faces",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoCornerAxis,
                              initialState: CubeLoaderState.loading,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.logoWave] ??
                              "Logo Cascade Wave",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "موجة الشعار المتتالية"
                                : "Logo Cascade Wave",
                            desc: isRtl
                                ? "تموج متدرج من المركز عبر 27 مكعباً"
                                : "Wave ripple from center through all 27 cubes",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoWave,
                              initialState: CubeLoaderState.loading,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.singleWobble] ??
                              "Single Wobble",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "ترنح المكعب المفرد"
                                : "Single Cube Wobble",
                            desc: isRtl
                                ? "ترنح على زاوية واحدة بحركة عشوائية"
                                : "Wobbling on one corner with organic motion",
                            child: const CubeLoader(
                              size: 72,
                              variant: CubeLoaderVariant.singleWobble,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.clusterSpiral] ??
                              "Cluster Spiral",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "دوامة المجموعات" : "Cluster Spiral",
                            desc: isRtl
                                ? "8 مكعبات في مسار حلزوني حلزوني"
                                : "8 cubes in a helical spiral orbit",
                            child: const CubeLoader(
                              size: 90,
                              variant: CubeLoaderVariant.clusterSpiral,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.linearBidi] ??
                              "Bidirectional Wave",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "موجة ثنائية الاتجاه"
                                : "Bidirectional Linear Wave",
                            desc: isRtl
                                ? "موجتان تلتقيان في المنتصف من كلا الجانبين"
                                : "Two waves meeting in the middle from both sides",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.linearBidi,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.circularDouble] ??
                              "Double Ring",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "حلقة مزدوجة الدوران"
                                : "Double Counter-Rotating Ring",
                            desc: isRtl
                                ? "حلقتان تدوران بعكس الاتجاه بترددات مختلفة"
                                : "Two rings counter-rotating at different frequencies",
                            child: const CubeLoader(
                              size: 90,
                              variant: CubeLoaderVariant.circularDouble,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SECTION: Premium Logo Variants
                        _buildSectionHeader(
                          dialogContext,
                          isRtl
                              ? "إصدارات الشعار الفاخرة"
                              : "Premium Logo Variants",
                          isRtl
                              ? "إصدارات بريميوم مستوحاة من مكعب روبيك بهندسة محسّنة"
                              : "Premium Rubik-style cube variants with enhanced geometry",
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant.logoPremium] ??
                              "Premium Logo",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "شعار بريميوم" : "Premium Logo",
                            desc: isRtl
                                ? "شعار 3×3×3 مع تنفس خفيف وزوايا محسّنة وحدود داكنة"
                                : "3×3×3 logo with subtle breathing, enhanced spacing, dark Rubik-style borders",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremium,
                              initialState: CubeLoaderState.breathing,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant
                                  .logoPremiumCornerAxis] ??
                              "Premium Corner Axis",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl
                                ? "دوران زاوية محور بريميوم"
                                : "Premium Corner Axis",
                            desc: isRtl
                                ? "دوران حول المحور القطري للمكعب مع حواف بلون أساسي"
                                : "Corner-diagonal axis rotation with primary color edges",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremiumCornerAxis,
                              initialState: CubeLoaderState.loading,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant
                                  .logoPremiumFloat] ??
                              "Premium Float",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "شعار عائم" : "Premium Float",
                            desc: isRtl
                                ? "حركة طفو خفيفة جداً للمجموعة بأكملها"
                                : "Very gentle floating motion of the entire cube group",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremiumFloat,
                              initialState: CubeLoaderState.breathing,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant
                                  .logoPremiumWave] ??
                              "Premium Wave",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "موجة بريميوم" : "Premium Wave",
                            desc: isRtl
                                ? "موجة تمر عبر المكعبات مع الحفاظ على الهيكل"
                                : "Wave passing through cubes while maintaining the outer silhouette",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremiumWave,
                              initialState: CubeLoaderState.loading,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant
                                  .logoPremiumCorePulse] ??
                              "Premium Core Pulse",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "نبض المركز" : "Premium Core Pulse",
                            desc: isRtl
                                ? "نبض أنيق في المكعبات الداخلية مع الحفاظ على الثبات"
                                : "Elegant pulse of the inner core cubes while outer layer stays stable",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremiumCorePulse,
                              initialState: CubeLoaderState.breathing,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant
                                  .logoPremiumRotate] ??
                              "Premium Rotate",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "دوران بطيء" : "Premium Slow Rotate",
                            desc: isRtl
                                ? "دوران بطيء جداً حول المحور القطري — دورة كاملة كل 30 ثانية"
                                : "Very slow body-diagonal rotation — one full revolution per ~30 seconds",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremiumRotate,
                              initialState: CubeLoaderState.loading,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Tooltip(
                          message:
                              variantLabels[CubeLoaderVariant
                                  .logoPremiumAura] ??
                              "Premium Aura",
                          child: _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "هالة الشعار" : "Premium Aura",
                            desc: isRtl
                                ? "طبقات تتنفس في طور متعاكس لتأثير هالة ثلاثي الأبعاد"
                                : "Layers breathe in alternating phase for a subtle 3D aura effect",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.logoPremiumAura,
                              initialState: CubeLoaderState.breathing,
                              showGlow: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // SECTION 2: Variants Inside Primary Buttons
                        _buildSectionHeader(
                          dialogContext,
                          isRtl
                              ? "2. الأنواع داخل الأزرار الرئيسية"
                              : "2. Variants Inside Primary Buttons",
                          isRtl
                              ? "كل نوع داخل زر PrimaryButton مع التحميل — اختر ما يناسب موقعك"
                              : "Each variant rendered inside a PrimaryButton with loading — pick your site-wide loader",
                        ),
                        const SizedBox(height: 12),
                        ...variants.map((v) {
                          final double cubeSize = switch (v) {
                            CubeLoaderVariant.logo => 22,
                            CubeLoaderVariant.single => 16,
                            _ => 18,
                          };
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: PrimaryButton(
                              text: variantLabels[v] ?? v.name,
                              isLoading: true,
                              width: double.infinity,
                              loadingWidget: CubeLoader(
                                size: cubeSize,
                                variant: v,
                                initialState: CubeLoaderState.loading,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // SECTION 3: Determinate Percentage Variants
                        _buildSectionHeader(
                          dialogContext,
                          isRtl
                              ? "3. مؤشرات النسبة المئوية"
                              : "3. Determinate Progress Variants",
                          isRtl
                              ? "Cluster و Linear مع نسبة مئوية داخل زر"
                              : "Cluster & Linear with percentage overlay",
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final v in [
                              CubeLoaderVariant.cluster,
                              CubeLoaderVariant.linear,
                            ])
                              for (final pct in [0.33, 0.72])
                                PrimaryButton(
                                  text: "${(pct * 100).toInt()}%",
                                  isLoading: true,
                                  loadingWidget: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CubeLoader(
                                      size: 22,
                                      variant: v,
                                      value: pct,
                                      showPercentage: true,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // SECTION 4: Advanced Elements
                        _buildSectionHeader(
                          dialogContext,
                          isRtl ? "4. عناصر إضافية" : "4. Additional Elements",
                          isRtl
                              ? "هيكل الشيمر وسحب التحديث"
                              : "Cube shimmer skeleton and pull-to-refresh",
                        ),
                        const SizedBox(height: 12),
                        _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "هيكل الشيمر المكعب (Cube Shimmer)"
                              : "Skeleton Cube Shimmer",
                          desc: isRtl
                              ? "تأثير شيمر متلاشي للواجهات تحت البناء"
                              : "Shimmer grids for structural loading mockups",
                          child: const SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: CubeShimmer(borderRadius: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildShowcaseCard(
                          dialogContext,
                          title: isRtl
                              ? "لوحة التحديث بالسحب (Pull-To-Refresh)"
                              : "Interactive Pull-To-Refresh Sandbox",
                          desc: isRtl
                              ? "اسحب القائمة لأسفل لتنشيط دوران التحديث ثلاثي الأبعاد"
                              : "Pull down inside the card to activate 3D orbit refresh spinner",
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: CubeRefreshIndicator(
                              onRefresh: () async {
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );
                              },
                              color: theme.colorScheme.primary,
                              child: ListView.builder(
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: const Icon(Icons.dns_rounded),
                                    title: Text(
                                      isRtl
                                          ? "تخزين البيانات السحابي رقم ${index + 1}"
                                          : "Cloud Storage Node #${index + 1}",
                                    ),
                                    subtitle: Text(
                                      isRtl
                                          ? "الحالة: متصل بالخادم الرئيسي"
                                          : "Status: Syncing with central server",
                                    ),
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseCard(
    BuildContext context, {
    required Widget child,
    required String title,
    String? desc,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (desc != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: AppTypography.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: child),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveScrollPosition);
    _scrollController.dispose();
    _logoAnimController.dispose();
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
                child: const ColoredBox(color: Color(0xFF060A12)),
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
                  child: FloatingCubeBackground(
                    topExclusion: topExclusion,
                    cubeCount: _cubeCount,
                    isActive: _particlesActive,
                    controller: _cubeController,
                    cubeMode: context.watch<CubeModeCubit>().state,
                    initialPreBurst: _isThisTheFirstLoad,
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
      floatingActionButton: _isPreviewMode
          ? null
          : FloatingActionButton(
              onPressed: () => _showLogoTestDialog(context),
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
