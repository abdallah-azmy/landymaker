import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../builder/registries/template_registry.dart';
import '../../../core/localization/localization_cubit.dart';

class HomeLuxuriousTemplateSlider extends StatefulWidget {
  final Function(String templateId) onGetStartedPressed;
  final bool isVisible;

  const HomeLuxuriousTemplateSlider({
    super.key,
    required this.onGetStartedPressed,
    required this.isVisible,
  });

  @override
  State<HomeLuxuriousTemplateSlider> createState() => _HomeLuxuriousTemplateSliderState();
}

class _HomeLuxuriousTemplateSliderState extends State<HomeLuxuriousTemplateSlider> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _headerController;
  int _currentPage = 0;
  final List<TemplateMetadata> _templates = TemplateRegistry.availableTemplates.where((t) => t.id != 'empty').toList();

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
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuart);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocalizationCubit>();
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          // Header
          FadeTransition(
            opacity: _headerController,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      loc.isRtl ? "✨ قوالب عالمية" : "✨ World-Class Templates",
                      style: AppTypography.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.isRtl ? "صمم موقعك بلمسة فنية" : "Design Your Site with an Artistic Touch",
                    style: AppTypography.h1.copyWith(fontSize: isMobile ? 32 : 48, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.isRtl ? "اختر من بين مجموعة واسعة من القوالب المصممة بعناية لتناسب هويتك." : "Choose from a wide range of carefully designed templates to match your identity.",
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),

          // Slider Area
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: isMobile ? 450 : 550,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) => setState(() => _currentPage = page),
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
                           value = 0.75; // More depth
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
                        onPressed: () => widget.onGetStartedPressed(_templates[index].id),
                      ),
                    );
                  },
                ),
              ),

              // Navigation Buttons (visible on all screen sizes)
              Positioned(
                left: isMobile ? 4 : 40,
                child: _NavigationButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: loc.isRtl ? _nextPage : _prevPage,
                  isMobile: isMobile,
                ),
              ),
              Positioned(
                right: isMobile ? 4 : 40,
                child: _NavigationButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onPressed: loc.isRtl ? _prevPage : _nextPage,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          
          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_templates.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.secondary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LuxuriousTemplateCard extends StatefulWidget {
  final TemplateMetadata template;
  final VoidCallback onPressed;

  const _LuxuriousTemplateCard({required this.template, required this.onPressed});

  @override
  State<_LuxuriousTemplateCard> createState() => _LuxuriousTemplateCardState();
}

class _LuxuriousTemplateCardState extends State<_LuxuriousTemplateCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
              color: (_isHovered ? AppColors.secondary : Colors.black).withValues(alpha: 0.2),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.template.category.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.template.name,
                        style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.template.description,
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: widget.onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.read<LocalizationCubit>().isRtl ? "ابدأ بهذا القالب" : "Start with this Template",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
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
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                      borderRadius: BorderRadius.circular(32),
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
