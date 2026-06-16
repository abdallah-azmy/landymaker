import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

/// ======================================================
/// FEATURE: Custom Gallery Widget
/// PURPOSE: Displays a collection of images in Grid or Carousel layout.
/// ARCHITECTURE: 
/// - State Hoisting: [_currentIndex] and [PageController] for carousel state 
///   are managed in the [CustomGalleryWidget] state.
/// - Layout Delegation: Renders [_DesktopGalleryLayout] or [_MobileGalleryLayout] 
///   based on screen width.
/// ======================================================
class CustomGalleryWidget extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String>? galleryLinks;
  final String displayMode;
  final int gridColumns;
  final int mobileColumns;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomGalleryWidget({
    super.key,
    required this.title,
    required this.items,
    this.galleryLinks,
    this.displayMode = 'grid',
    this.gridColumns = 3,
    this.mobileColumns = 1,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  State<CustomGalleryWidget> createState() => _CustomGalleryWidgetState();
}

class _CustomGalleryWidgetState extends State<CustomGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final secondaryColor = widget.theme?.secondary ?? AppColors.secondary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double verticalPadding = isMobile ? 40 : 80;

        final props = _GalleryProps(
          title: widget.title,
          items: widget.items,
          galleryLinks: widget.galleryLinks,
          displayMode: widget.displayMode,
          gridColumns: widget.gridColumns,
          mobileColumns: widget.mobileColumns,
          textColor: textColor,
          secondaryColor: secondaryColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          currentIndex: _currentIndex,
          pageController: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
        );

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isMobile ? _MobileGalleryLayout(props: props) : _DesktopGalleryLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for Gallery properties.
class _GalleryProps {
  final String title;
  final List<String> items;
  final List<String>? galleryLinks;
  final String displayMode;
  final int gridColumns;
  final int mobileColumns;
  final Color textColor;
  final Color secondaryColor;
  final Color subTextColor;
  final bool isMobile;
  final int currentIndex;
  final PageController pageController;
  final Function(int) onPageChanged;

  const _GalleryProps({
    required this.title,
    required this.items,
    this.galleryLinks,
    required this.displayMode,
    required this.gridColumns,
    required this.mobileColumns,
    required this.textColor,
    required this.secondaryColor,
    required this.subTextColor,
    required this.isMobile,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
  });
}

/// Desktop version of the Gallery layout.
class _DesktopGalleryLayout extends StatelessWidget {
  final _GalleryProps props;
  const _DesktopGalleryLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GalleryHeader(props: props),
        const SizedBox(height: 64),
        if (props.displayMode == 'carousel') _GalleryCarousel(props: props) else _GalleryGrid(props: props),
      ],
    );
  }
}

/// Mobile version of the Gallery layout.
class _MobileGalleryLayout extends StatelessWidget {
  final _GalleryProps props;
  const _MobileGalleryLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GalleryHeader(props: props),
        const SizedBox(height: 32),
        if (props.displayMode == 'carousel') _GalleryCarousel(props: props) else _GalleryGrid(props: props),
      ],
    );
  }
}

/// Shared Gallery Header.
class _GalleryHeader extends StatelessWidget {
  final _GalleryProps props;
  const _GalleryHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Text(
      props.title,
      style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32),
      textAlign: TextAlign.center,
    );
  }
}

/// Grid layout for Gallery.
class _GalleryGrid extends StatelessWidget {
  final _GalleryProps props;
  const _GalleryGrid({required this.props});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columnCount = ResponsiveUtils.getContentColumns(
          constraints.maxWidth,
          desktop: props.gridColumns,
          tablet: props.gridColumns > 1 ? 2 : 1,
          mobile: props.mobileColumns,
        );

        final List<Widget> rows = [];
        for (int i = 0; i < props.items.length; i += columnCount) {
          final rowItems = props.items.sublist(i, (i + columnCount > props.items.length) ? props.items.length : i + columnCount);

          Widget rowWidget = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columnCount, (colIndex) {
              if (colIndex < rowItems.length) {
                final String url = rowItems[colIndex];
                final String? linkUrl = props.galleryLinks != null && props.galleryLinks!.length > (i + colIndex) ? props.galleryLinks![i + colIndex] : null;
                final isLastInRow = colIndex == columnCount - 1;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : 16.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(color: props.subTextColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        child: _GalleryImage(url: url, linkUrl: linkUrl, subTextColor: props.subTextColor),
                      ),
                    ),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          );

          rows.add(rowWidget);
          if (i + columnCount < props.items.length) rows.add(const SizedBox(height: 16));
        }
        return Column(children: rows);
      },
    );
  }
}

/// Carousel layout for Gallery.
class _GalleryCarousel extends StatelessWidget {
  final _GalleryProps props;
  const _GalleryCarousel({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: props.isMobile ? 4 / 3 : 16 / 9,
              child: PageView.builder(
                controller: props.pageController,
                itemCount: props.items.length,
                onPageChanged: props.onPageChanged,
                itemBuilder: (context, index) {
                  final String url = props.items[index];
                  final String? linkUrl = props.galleryLinks != null && props.galleryLinks!.length > index ? props.galleryLinks![index] : null;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: props.subTextColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
                    clipBehavior: Clip.antiAlias,
                    child: _GalleryImage(url: url, linkUrl: linkUrl, subTextColor: props.subTextColor),
                  );
                },
              ),
            ),
            if (!props.isMobile) ...[
              PositionedDirectional(start: 0, child: _NavButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => props.pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut))),
              PositionedDirectional(end: 0, child: _NavButton(icon: Icons.arrow_forward_ios_rounded, onTap: () => props.pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut))),
            ],
          ],
        ),
        const SizedBox(height: 24),
        _CarouselIndicators(props: props),
      ],
    );
  }
}

/// Carousel indicators and navigation row.
class _CarouselIndicators extends StatelessWidget {
  final _GalleryProps props;
  const _CarouselIndicators({required this.props});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (props.isMobile) _NavButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => props.pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), small: true),
        const SizedBox(width: 16),
        Column(
          children: [
            Text("${props.currentIndex + 1} / ${props.items.length}", style: AppTypography.caption.copyWith(color: props.secondaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(props.items.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: props.currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: props.currentIndex == index ? props.secondaryColor : props.subTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(width: 16),
        if (props.isMobile) _NavButton(icon: Icons.arrow_forward_ios_rounded, onTap: () => props.pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), small: true),
      ],
    );
  }
}

/// Navigation button for Carousel.
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool small;

  const _NavButton({required this.icon, required this.onTap, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(small ? 12 : 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(small ? 12 : 16),
        child: Container(
          padding: EdgeInsets.all(small ? 8 : 12),
          child: Icon(icon, color: Colors.white, size: small ? 18 : 24),
        ),
      ),
    );
  }
}

/// Modular Gallery Image with Hover effect.
class _GalleryImage extends StatelessWidget {
  final String url;
  final String? linkUrl;
  final Color subTextColor;

  const _GalleryImage({required this.url, this.linkUrl, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    final bool hasLink = linkUrl != null && linkUrl!.isNotEmpty;
    if (hasLink) return _HoverableGalleryItem(url: url, linkUrl: linkUrl!, subTextColor: subTextColor);
    return CustomNetworkImage(imageUrl: url, fit: BoxFit.cover);
  }
}

class _HoverableGalleryItem extends StatefulWidget {
  final String url;
  final String linkUrl;
  final Color subTextColor;

  const _HoverableGalleryItem({required this.url, required this.linkUrl, required this.subTextColor});

  @override
  State<_HoverableGalleryItem> createState() => _HoverableGalleryItemState();
}

class _HoverableGalleryItemState extends State<_HoverableGalleryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.tryParse(widget.linkUrl);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: CustomNetworkImage(imageUrl: widget.url, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _isHovered ? Colors.black.withValues(alpha: 0.35) : Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
