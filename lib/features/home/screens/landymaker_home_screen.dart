import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_template_strip.dart';
import '../widgets/home_stats_section.dart';
import '../widgets/home_cta_section.dart';
import '../widgets/home_footer.dart';

class LandyMakerHomeScreen extends StatefulWidget {
  const LandyMakerHomeScreen({super.key});

  @override
  State<LandyMakerHomeScreen> createState() => _LandyMakerHomeScreenState();
}

class _LandyMakerHomeScreenState extends State<LandyMakerHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  // Keys to measure positions for scroll-triggered animations
  final GlobalKey _bentoKey = GlobalKey();
  final GlobalKey _templatesKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _ctaKey = GlobalKey();

  bool _bentoVisible = false;
  bool _templatesVisible = false;
  bool _statsVisible = false;
  bool _ctaVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Trigger check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final screenH = MediaQuery.of(context).size.height;

    _checkVisibility(_bentoKey, screenH, () {
      if (!_bentoVisible) setState(() => _bentoVisible = true);
    });
    _checkVisibility(_templatesKey, screenH, () {
      if (!_templatesVisible) setState(() => _templatesVisible = true);
    });
    _checkVisibility(_statsKey, screenH, () {
      if (!_statsVisible) setState(() => _statsVisible = true);
    });
    _checkVisibility(_ctaKey, screenH, () {
      if (!_ctaVisible) setState(() => _ctaVisible = true);
    });
  }

  void _checkVisibility(GlobalKey key, double screenH, VoidCallback onVisible) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    if (pos.dy < screenH * 0.92) {
      onVisible();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeNavbar(
        onLoginPressed: () => context.go('/login'),
        onGetStartedPressed: () => context.go('/register'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HomeHeroSection(onGetStartedPressed: () => context.go('/login')),

            HomeFeatureBento(
              key: _bentoKey,
              isVisible: _bentoVisible,
            ),

            HomeTemplateStrip(
              key: _templatesKey,
              isVisible: _templatesVisible,
              onGetStartedPressed: (templateId) {
                TenantRoutingService.pendingTemplateId = templateId;
                context.go('/login');
              },
            ),

            HomeStatsSection(
              key: _statsKey,
              isVisible: _statsVisible,
            ),

            HomeCtaSection(
              key: _ctaKey,
              isVisible: _ctaVisible,
              onGetStartedPressed: () => context.go('/register'),
            ),

            const HomeFooter(),
          ],
        ),
      ),
    );
  }
}
