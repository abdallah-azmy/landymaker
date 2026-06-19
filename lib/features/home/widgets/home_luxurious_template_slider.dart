import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/database_service.dart';
import '../../../injection_container.dart';
import '../../builder/registries/template_registry.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../public_viewer/widgets/section_renderer.dart';
import '../../../core/localization/localization_cubit.dart';
import '../models/home_layouts.dart';

class HomeLuxuriousTemplateSlider extends StatefulWidget {
  final Function(String templateId) onGetStartedPressed;
  final bool isVisible;
  final TemplateSliderLayout layout;
  final String? title;
  final String? subtitle;
  final int? maxToShow;
  final List<String>? templateIds;

  const HomeLuxuriousTemplateSlider({
    super.key,
    required this.onGetStartedPressed,
    required this.isVisible,
    this.layout = TemplateSliderLayout.horizontalSlider,
    this.title,
    this.subtitle,
    this.maxToShow,
    this.templateIds,
  });

  @override
  State<HomeLuxuriousTemplateSlider> createState() =>
      _HomeLuxuriousTemplateSliderState();
}

class _HomeLuxuriousTemplateSliderState
    extends State<HomeLuxuriousTemplateSlider>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _headerController;
  int _currentPage = 0;
  List<TemplateMetadata> _templates = [];
  bool _isLoadingTemplates = true;

  Future<void> _loadTemplates() async {
    try {
      final db = sl<DatabaseService>();
      final featured = await db.fetchFeaturedTemplates();
      if (featured.isNotEmpty) {
        var mapped = featured
            .map(
              (t) => TemplateMetadata(
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
              ),
            )
            .toList();
        if (widget.templateIds != null && widget.templateIds!.isNotEmpty) {
          final ids = widget.templateIds!.toSet();
          mapped = mapped.where((t) => ids.contains(t.id)).toList();
        }
        if (widget.maxToShow != null && mapped.length > widget.maxToShow!) {
          mapped = mapped.sublist(0, widget.maxToShow);
        }
        if (mounted)
          setState(() {
            _templates = mapped;
            _isLoadingTemplates = false;
          });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _templates = TemplateRegistry.availableTemplates
            .where((t) => t.id != 'empty')
            .toList();
        if (widget.templateIds != null && widget.templateIds!.isNotEmpty) {
          final ids = widget.templateIds!.toSet();
          _templates = _templates.where((t) => ids.contains(t.id)).toList();
        }
        if (widget.maxToShow != null && _templates.length > widget.maxToShow!) {
          _templates = _templates.sublist(0, widget.maxToShow);
        }
        _isLoadingTemplates = false;
      });
    }
  }

  void _showTemplatePreview(TemplateMetadata template) {
    final design = TemplateRegistry.getTemplateDesign(template.id);
    final blocks =
        (design['blocks'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    final theme = TemplateRegistry.getTemplateTheme(template.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              template.name,
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onGetStartedPressed(template.id);
                },
                icon: Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                label: Text(
                  context.read<LocalizationCubit>().isRtl
                      ? "استخدم هذا القالب"
                      : "Use this Template",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: SectionRenderer(
              blocks: blocks,
              pageId: 'preview',
              theme: theme,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isVisible) {
      _headerController.forward();
    }
    _loadTemplates();
  }

  @override
  void didUpdateWidget(HomeLuxuriousTemplateSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _headerController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    super.dispose();
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

  Widget _buildSectionHeader(bool isMobile, bool isTablet, loc) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _headerController,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
              .animate(
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
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  loc.isRtl
                      ? widget.title ?? "✨ قوالب عالمية"
                      : widget.title ?? "✨ World-Class Templates",
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                loc.isRtl
                    ? "صمم موقعك بلمسة فنية"
                    : "Design Your Site with an Artistic Touch",
                style: AppTypography.h1.copyWith(
                  fontSize: isMobile
                      ? 32
                      : isTablet
                      ? 44
                      : 58,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                loc.isRtl
                    ? widget.subtitle ??
                          "اختر من بين مجموعة واسعة من القوالب المصممة بعناية لتناسب هويتك."
                    : "Choose from a wide range of carefully designed templates to match your identity.",
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalSlider(bool isMobile, bool isTablet, loc) {
    return RepaintBoundary(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: isMobile ? 450 : 550,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) =>
                      setState(() => _currentPage = page),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
                        } else if (index != 0) {
                          value = 0.75;
                        }
                        return Center(
                          child: Transform.scale(
                            scale: Curves.easeOutQuart.transform(value),
                            child: Opacity(
                              opacity: value.clamp(0.5, 1.0),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _LuxuriousTemplateCard(
                        template: _templates[index],
                        onPressed: () =>
                            widget.onGetStartedPressed(_templates[index].id),
                      ),
                    );
                  },
                ),
              ),
              PositionedDirectional(
                start: isMobile ? 4 : 40,
                child: _NavigationButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: _prevPage,
                  isMobile: isMobile,
                ),
              ),
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
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_templates.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMasonryGrid(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64),
        child: Column(
          children: List.generate(
            _templates.length,
            (i) => Padding(
              padding: EdgeInsets.only(
                bottom: i < _templates.length - 1 ? 16 : 0,
              ),
              child: _GridTemplateCard(
                template: _templates[i],
                onPressed: () => widget.onGetStartedPressed(_templates[i].id),
                onPreview: () => _showTemplatePreview(_templates[i]),
              ),
            ),
          ),
        ),
      );
    }
    final mid = (_templates.length + 1) ~/ 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: List.generate(
                mid,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < mid - 1 ? 20 : 0),
                  child: _GridTemplateCard(
                    template: _templates[i],
                    onPressed: () =>
                        widget.onGetStartedPressed(_templates[i].id),
                    onPreview: () => _showTemplatePreview(_templates[i]),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              children: List.generate(_templates.length - mid, (i) {
                final idx = mid + i;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i < _templates.length - mid - 1 ? 20 : 0,
                  ),
                  child: _GridTemplateCard(
                    template: _templates[idx],
                    onPressed: () =>
                        widget.onGetStartedPressed(_templates[idx].id),
                    onPreview: () => _showTemplatePreview(_templates[idx]),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoColsGrid(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? 16.0
            : isTablet
            ? 32.0
            : 48.0,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          return _GridTemplateCard(
            template: _templates[index],
            onPressed: () => widget.onGetStartedPressed(_templates[index].id),
            onPreview: () => _showTemplatePreview(_templates[index]),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final loc = context.read<LocalizationCubit>();
        final isMobile = constraints.maxWidth < 700;
        final isTablet = !isMobile && constraints.maxWidth < 1200;

        if (_isLoadingTemplates) {
          return SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 60),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              top: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              // _buildSectionHeader(isMobile, isTablet, loc),
              // SizedBox(height: 64),
              // switch (widget.layout) {
              //   TemplateSliderLayout.horizontalSlider => _buildHorizontalSlider(
              //     isMobile,
              //     isTablet,
              //     loc,
              //   ),
              //   TemplateSliderLayout.masonryGrid => _buildMasonryGrid(isMobile, isTablet),
              //   TemplateSliderLayout.twoColsGrid => _buildTwoColsGrid(isMobile, isTablet),
              // },
            ],
          ),
        );
      },
    );
  }
}

class _LuxuriousTemplateCard extends StatefulWidget {
  final TemplateMetadata template;
  final VoidCallback onPressed;

  const _LuxuriousTemplateCard({
    required this.template,
    required this.onPressed,
  });

  @override
  State<_LuxuriousTemplateCard> createState() => _LuxuriousTemplateCardState();
}

class _LuxuriousTemplateCardState extends State<_LuxuriousTemplateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuint,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color:
                    (_isHovered
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.black)
                        .withValues(alpha: 0.2),
                blurRadius: _isHovered ? 40 : 20,
                offset: Offset(0, _isHovered ? 20 : 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Image
                Positioned.fill(
                  child: AnimatedScale(
                    scale: _isHovered ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    child: Image.network(
                      widget.template.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.template.category.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.template.name,
                          style: AppTypography.h3.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.template.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.read<LocalizationCubit>().isRtl
                                          ? "ابدأ بهذا القالب"
                                          : "Start with this Template",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_rounded, size: 14),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {
                                final state = context
                                    .findAncestorStateOfType<
                                      _HomeLuxuriousTemplateSliderState
                                    >();
                                state?._showTemplatePreview(widget.template);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white38),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_outlined, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    context.read<LocalizationCubit>().isRtl
                                        ? "معاينة"
                                        : "Preview",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Glass Border Overlay on Hover
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridTemplateCard extends StatefulWidget {
  final TemplateMetadata template;
  final VoidCallback onPressed;
  final VoidCallback onPreview;

  const _GridTemplateCard({
    required this.template,
    required this.onPressed,
    required this.onPreview,
  });

  @override
  State<_GridTemplateCard> createState() => _GridTemplateCardState();
}

class _GridTemplateCardState extends State<_GridTemplateCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedScale(
                          scale: _hovered ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          child: Image.network(
                            widget.template.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.template.category.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      if (_hovered)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.2),
                            child: Center(
                              child: IconButton(
                                onPressed: widget.onPreview,
                                icon: Icon(
                                  Icons.visibility_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.template.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.template.description,
                          style: AppTypography.caption.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              context.read<LocalizationCubit>().isRtl
                                  ? "استخدم القالب"
                                  : "Use Template",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }
}
