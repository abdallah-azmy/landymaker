import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/database_service.dart';
import '../../../injection_container.dart';
import '../../builder/registries/template_registry.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';

/// ========================= FACTORY =========================
class HomeDesktopPreviewCarousel extends StatefulWidget {
  final Function(String templateId) onGetStartedPressed;
  final bool isVisible;
  final String? title;
  final String? subtitle;
  final String? description;

  const HomeDesktopPreviewCarousel({
    super.key,
    required this.onGetStartedPressed,
    required this.isVisible,
    this.title,
    this.subtitle,
    this.description,
  });

  @override
  State<HomeDesktopPreviewCarousel> createState() =>
      _HomeDesktopPreviewCarouselState();
}

class _HomeDesktopPreviewCarouselState
    extends State<HomeDesktopPreviewCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _headerController;
  late AnimationController _cardAnimationController;
  int _currentPage = 0;
  List<TemplateMetadata> _templates = [];
  bool _isLoading = true;
  ScrollController? _mobileScrollController;
  int _mobilePage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isVisible) {
      _headerController.forward();
      _cardAnimationController.forward();
    }
    _loadTemplates();
  }

  @override
  void didUpdateWidget(HomeDesktopPreviewCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _headerController.forward();
      _cardAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    _cardAnimationController.dispose();
    _mobileScrollController?.removeListener(_onMobileScroll);
    _mobileScrollController?.dispose();
    super.dispose();
  }

  void _onMobileScroll() {
    if (_mobileScrollController == null ||
        !_mobileScrollController!.hasClients) return;
    const itemWidth = 360.0;
    final page =
        (_mobileScrollController!.offset / itemWidth).round();
    final newPage = page.clamp(0, _templates.length - 1);
    if (newPage != _mobilePage) {
      setState(() => _mobilePage = newPage);
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final db = sl<DatabaseService>();
      final featured = await db.fetchFeaturedTemplates();
      if (featured.isNotEmpty) {
        final mapped = featured.map((t) => TemplateMetadata(
          id: t['id'] ?? '',
          name: t['name'] ?? '',
          description: t['description'] ?? '',
          imageUrl: t['image_url'] ?? '',
          category: t['category'] ?? 'general',
          recommendedSections:
              (t['recommended_sections'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
          aiPromptHint: t['ai_prompt_hint'] ?? '',
        )).toList();
        if (mounted) {
          setState(() {
            _templates = mapped;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _templates = TemplateRegistry.availableTemplates
            .where((t) => t.id != 'empty')
            .toList();
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _templates.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  Animation<double> _staggeredAnimation(int index) {
    final count = _templates.length;
    final start = (0.3 * index / count).clamp(0.0, 0.6);
    final end = (0.6 + 0.3 * index / count).clamp(0.0, 0.9);
    return _cardAnimationController.drive(
      CurveTween(curve: Interval(start, end, curve: Curves.easeOut)),
    );
  }

  Widget _buildSectionHeader(bool isMobile, bool isTablet, loc) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _headerController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _headerController,
              curve: Curves.easeOut,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  loc.isRtl
                      ? "\u{1F5A5}\u{FE0F} معاينة على الديسكتوب"
                      : "\u{1F5A5}\u{FE0F} Desktop Preview",
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: isMobile ? 16 : isTablet ? 32 : 48),
                child: Text(
                  loc.isRtl
                      ? widget.subtitle ?? "شاهد كيف تبدو صفحتك على الشاشة الكبيرة"
                      : widget.subtitle ?? "See How Your Page Looks on Large Screens",
                  style: AppTypography.h1.copyWith(
                    fontSize: isMobile ? 28 : (isTablet ? 42 : 58),
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: isMobile ? 16 : isTablet ? 32 : 48),
                child: Text(
                  loc.isRtl
                      ? widget.description ?? "معاينة حية لكل قالب كما سيظهر لزوارك على أجهزة الكمبيوتر."
                      : widget.description ?? "Live preview of each template as it will appear to your visitors on desktop.",
                  style: AppTypography.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCarousel(bool isMobile) {
    return Column(
      children: [
        SizedBox(
          height: 440,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _staggeredAnimation(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _BrowserMockupCard(
                        template: _templates[index],
                        onGetStartedPressed: widget.onGetStartedPressed,
                        isDesktop: true,
                      ),
                    ),
                  );
                },
              ),
              if (_templates.length > 1)
                PositionedDirectional(
                  start: isMobile ? 4 : 40,
                  child: _NavigationButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: _prevPage,
                    isMobile: isMobile,
                  ),
                ),
              if (_templates.length > 1)
                PositionedDirectional(
                  end: isMobile ? 4 : 40,
                  child: _NavigationButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    onPressed: _nextPage,
                    isMobile: isMobile,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildDotIndicator(_currentPage),
      ],
    );
  }

  Widget _buildMobileCarousel(bool isMobile, double screenWidth) {
    final cardWidth = (screenWidth - 48).clamp(0.0, 360.0);

    _mobileScrollController ??= ScrollController()
      ..addListener(_onMobileScroll);

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: ListView.builder(
            controller: _mobileScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth - cardWidth) / 2,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _staggeredAnimation(index),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: SizedBox(
                    width: cardWidth,
                    child: _BrowserMockupCard(
                      template: _templates[index],
                      onGetStartedPressed: widget.onGetStartedPressed,
                      isDesktop: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildDotIndicator(_mobilePage),
      ],
    );
  }

  Widget _buildDotIndicator(int activePage) {
    if (_templates.length <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_templates.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: activePage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: activePage == index
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final loc = context.read<LocalizationCubit>();
        final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);
        final isTablet = HomeBreakpoint.isTablet(constraints.maxWidth);

        if (_isLoading) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (_templates.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 32 : 60,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildSectionHeader(isMobile, isTablet, loc),
              const SizedBox(height: 48),
              isMobile
                  ? _buildMobileCarousel(isMobile, constraints.maxWidth)
                  : _buildDesktopCarousel(isMobile),
            ],
          ),
        );
      },
    );
  }
}

/// ========================= CARD =========================
class _BrowserMockupCard extends StatefulWidget {
  final TemplateMetadata template;
  final Function(String templateId) onGetStartedPressed;
  final bool isDesktop;

  const _BrowserMockupCard({
    required this.template,
    required this.onGetStartedPressed,
    required this.isDesktop,
  });

  @override
  State<_BrowserMockupCard> createState() => _BrowserMockupCardState();
}

class _BrowserMockupCardState extends State<_BrowserMockupCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardImageHeight = widget.isDesktop ? 320.0 : 200.0;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) {
          if (widget.isDesktop) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (widget.isDesktop) setState(() => _isHovered = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuint,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -4.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBrowserChrome(),
                _buildCardBody(cardImageHeight),
                _buildInfoStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrowserChrome() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: _isHovered
                ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const _TrafficDot(color: Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          const _TrafficDot(color: Color(0xFFFFBD2E)),
          const SizedBox(width: 6),
          const _TrafficDot(color: Color(0xFF28CA41)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 22,
              margin: const EdgeInsetsDirectional.only(end: 48),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  'https://${widget.template.id}.landymaker.com',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody(double imageHeight) {
    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: Image.network(
        widget.template.imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfoStrip() {
    final loc = context.read<LocalizationCubit>();
    return Container(
      padding: const EdgeInsetsDirectional.all(20),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.template.category.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.template.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () =>
                widget.onGetStartedPressed(widget.template.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isHovered
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              loc.isRtl ? "استخدم القالب" : "Use Template",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ========================= HELPERS =========================
class _TrafficDot extends StatelessWidget {
  final Color color;
  const _TrafficDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isMobile;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isMobile ? 44 : 60;
    final double iconSize = isMobile ? 18 : 24;
    final double borderRadius = isMobile ? 14 : 20;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }
}
