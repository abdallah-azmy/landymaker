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
import '../../../core/widgets/atoms/animated_cube_mode_toggle.dart';
import '../../../core/widgets/atoms/cube_shimmer.dart';
import '../../../core/widgets/atoms/cube_refresh_indicator.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_section_renderer.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../../../core/widgets/particles/loading_logo_original.dart';
import '../../../core/widgets/particles/cube_loader.dart';

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
  bool _isPreviewMode = false;

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
    // Trigger burst 900ms after Flutter first frame (900 / 1500 = 0.6)
    // This gives the HTML loader time to fade out, and lets the user
    // actually see the fully formed logo cube for a moment before it explodes.
    if (!_burstTriggered && _logoAnimController.value >= 0.6) {
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
      if (_isPreviewMode) {
        _cubeController.triggerLogoBurst(normalized);
        return;
      }
      if (!_cubeController.trySplit(normalized)) {
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

  Widget _buildStateItem(BuildContext context, String label, LoadingLogoState state) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LoadingLogo(size: 60, initialState: state),
      ],
    );
  }

  void _showLogoTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final isRtl = context.isRtl;
        
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                            isRtl ? "معاينة مؤشرات التحميل تفصيليًا" : "Loading Indicator Showcase",
                            style: AppTypography.h3.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRtl 
                                ? "استعراض ومقارنة مؤشرات التحميل ثلاثية الأبعاد المتاحة" 
                                : "Explore and test all active 3D cube-based loaders",
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
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                          // SECTION 1: Brand Logo Comparison
                          _buildSectionHeader(
                            dialogContext,
                            isRtl ? "1. مقارنة الشعار وتأثير الإضاءة ثلاثية الأبعاد" : "1. Logo Comparison & 3D Shading Light",
                            isRtl 
                                ? "مقارنة محاذاة الشعار القديم والجديد مع تعديل انحناء الحواف الفائقة والمسافات وضبط تباين الظلال" 
                                : "Comparing legacy isometric logo vs the brand-aligned loader with high-contrast ambient shading",
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "الشعار الأصلي القديم" : "Original Logo (Legacy)",
                                  desc: isRtl ? "زاوية مائلة، حواف أقل التفافاً، فراغات متباعدة" : "Flat shading, low contrast, wider gaps",
                                  child: const LoadingLogoOriginal(
                                    size: 100,
                                    mode: LoadingLogoOriginalMode.breathing,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "الشعار المعدل (المطابق للهوية)" : "Modified Brand Logo",
                                  desc: isRtl ? "حواف انسيابية مستديرة بالكامل، تباين ظلال قوي وتراص متناسق" : "Squircle capsules, compact gap, deep shadows",
                                  child: const CubeLoader(
                                    size: 100,
                                    variant: CubeLoaderVariant.logo,
                                    initialState: CubeLoaderState.breathing,
                                    showGlow: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // SECTION 2: Standard Variants
                          _buildSectionHeader(
                            dialogContext,
                            isRtl ? "2. المؤشرات الأساسية للنظام" : "2. System Basic Variants",
                            isRtl 
                                ? "مؤشر الزر الفردي الدوار، وحلقة التحميل الدائرية المدارية الثلاثية" 
                                : "Standard small inline spinners and cluster orbit indicators",
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "مؤشر الزر الدوار المفرد" : "Single Cube Spinner",
                                  desc: isRtl ? "مخصص للأزرار والنصوص المدمجة" : "Used for button actions and inline loading",
                                  child: const CubeLoader(
                                    size: 36,
                                    variant: CubeLoaderVariant.single,
                                    initialState: CubeLoaderState.loading,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "التحميل المداري المتراكم" : "Orbital Progress Ring",
                                  desc: isRtl ? "محدد بنسبة التحميل المئوية التفاعلية" : "Determinate loading with percentage overlay",
                                  child: const CubeLoader(
                                    size: 72,
                                    variant: CubeLoaderVariant.cluster,
                                    value: 0.72,
                                    showPercentage: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // SECTION 3: Custom Progressive Indicators
                          _buildSectionHeader(
                            dialogContext,
                            isRtl ? "3. التأثيرات الجديدة المستوحاة" : "3. New Progressive Indicators",
                            isRtl 
                                ? "تموجات خطية متتالية، حلقات مدارية متموجة بالعمق، ومحاكاة القفز الفيزيائي للمكعبات" 
                                : "Custom Linear, Circular, and Physics-bouncing indicators built with 3D cubes",
                          ),
                          const SizedBox(height: 12),
                          _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "تموج المكعبات الخطي (Linear Cube Wave)" : "Linear Cube Wave Progress",
                            desc: isRtl ? "تموج نبضي ثلاثي الأبعاد مستوحى من مؤشر التقدم الخطي" : "3D staggered wave pulse inspired by LinearProgressIndicator",
                            child: const CubeLoader(
                              size: 110,
                              variant: CubeLoaderVariant.linear,
                              initialState: CubeLoaderState.loading,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "الحلقة المتموجة بالعمق (Circular Ring)" : "Circular Depth Ring",
                                  desc: isRtl ? "تموج دائري في الحجم والعمق ملاحق للمدار" : "Chasing circular depth wave tracker",
                                  child: const CubeLoader(
                                    size: 90,
                                    variant: CubeLoaderVariant.circular,
                                    initialState: CubeLoaderState.loading,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildShowcaseCard(
                                  dialogContext,
                                  title: isRtl ? "الارتداد والجاذبية (Gravity Bounce)" : "Gravity Squash Bounce",
                                  desc: isRtl ? "سقوط فيزيائي حر، اصطدام مرن مع انضغاط المكعبات" : "Deterministic bounce with volume-preserving squash",
                                  child: const CubeLoader(
                                    size: 90,
                                    variant: CubeLoaderVariant.physics,
                                    initialState: CubeLoaderState.loading,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // SECTION 4: Advanced Elements
                          _buildSectionHeader(
                            dialogContext,
                            isRtl ? "4. شيمر الهياكل وتحديث السحب التفاعلي" : "4. Skeleton Shimmer & Live Refresh Pull",
                            isRtl 
                                ? "مكعبات الشيمر ثلاثية الأبعاد لتنسيق الهياكل، وواجهة سحب لتجربة مؤشر التحديث المداري" 
                                : "Skeleton loading structures and an interactive pull-to-refresh panel",
                          ),
                          const SizedBox(height: 12),
                          _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "هيكل الشيمر المكعب (Cube Shimmer)" : "Skeleton Cube Shimmer",
                            desc: isRtl ? "تأثير شيمر متلاشي للواجهات تحت البناء" : "Shimmer grids for structural loading mockups",
                            child: const SizedBox(
                              width: double.infinity,
                              height: 80,
                              child: CubeShimmer(borderRadius: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildShowcaseCard(
                            dialogContext,
                            title: isRtl ? "لوحة التحديث بالسحب التفاعلية (Pull-To-Refresh)" : "Interactive Pull-To-Refresh Sandbox",
                            desc: isRtl 
                                ? "اسحب القائمة لأسفل لتنشيط دوران التحديث ثلاثي الأبعاد" 
                                : "Pull down inside the viewport card to activate 3D orbit refresh spinner",
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.outlineVariant),
                              ),
                              child: CubeRefreshIndicator(
                                onRefresh: () async {
                                  await Future.delayed(const Duration(seconds: 2));
                                },
                                color: theme.colorScheme.primary,
                                child: ListView.builder(
                                  itemCount: 4,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: const Icon(Icons.dns_rounded),
                                      title: Text(isRtl ? "تخزين البيانات السحابي رقم ${index + 1}" : "Cloud Storage Node #${index + 1}"),
                                      subtitle: Text(isRtl ? "الحالة: متصل بالخادم الرئيسي" : "Status: Syncing with central server"),
                                      dense: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // SECTION 5: Loader States Grid
                          _buildSectionHeader(
                            dialogContext,
                            isRtl ? "5. حالات الشعار الفردية" : "5. Brand Logo States",
                            isRtl 
                                ? "استعراض جميع حالات تشغيل الشعار المعدل المتاحة" 
                                : "Previewing all operational states of the modified brand loader",
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStateItem(dialogContext, "Idle", LoadingLogoState.idle),
                              _buildStateItem(dialogContext, "Breathing", LoadingLogoState.breathing),
                              _buildStateItem(dialogContext, "Loading", LoadingLogoState.loading),
                              _buildStateItem(dialogContext, "Success", LoadingLogoState.success),
                              _buildStateItem(dialogContext, "Error", LoadingLogoState.error),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
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

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
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
                ),
              AnimatedOpacity(
                opacity: _burstTriggered && !_isPreviewMode ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                                  color: Theme.of(context).colorScheme.outlineVariant,
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
              tooltip: context.isRtl ? "مقارنة لودينج اللوجو" : "Compare Loading Logos",
              child: Icon(
                Icons.bug_report_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
    );
  }
}
