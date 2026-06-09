import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomGalleryWidget extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String>? galleryLinks;
  final String displayMode; // 'grid' or 'carousel'
  final int gridColumns;
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
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

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
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 32 : 64),
                  
                  if (widget.displayMode == 'carousel')
                    _buildCarousel(secondaryColor, subTextColor, isMobile)
                  else
                    _buildGrid(context, subTextColor, constraints),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarousel(Color secondaryColor, Color subTextColor, bool isMobile) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: isMobile ? 300 : 500,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final String url = widget.items[index];
                  final String? linkUrl = widget.galleryLinks != null && widget.galleryLinks!.length > index
                      ? widget.galleryLinks![index]
                      : null;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: subTextColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildGalleryImage(url, linkUrl, subTextColor),
                  );
                },
              ),
            ),
            
            // Navigation Buttons
            if (!isMobile) ...[
              Positioned(
                left: 0,
                child: _buildNavButton(Icons.arrow_back_ios_rounded, () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }),
              ),
              Positioned(
                right: 0,
                child: _buildNavButton(Icons.arrow_forward_ios_rounded, () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        
        // Indicators & Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Arrow for Mobile
            if (isMobile)
              _buildNavButton(Icons.arrow_back_ios_rounded, () {
                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }, small: true),
            
            const SizedBox(width: 16),
            
            // Counter and Dots
            Column(
              children: [
                Text(
                  "${_currentIndex + 1} / ${widget.items.length}",
                  style: AppTypography.caption.copyWith(color: secondaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.items.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? secondaryColor : subTextColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Right Arrow for Mobile
            if (isMobile)
              _buildNavButton(Icons.arrow_forward_ios_rounded, () {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }, small: true),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap, {bool small = false}) {
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

  Widget _buildGrid(BuildContext context, Color subTextColor, BoxConstraints constraints) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
          context,
          desktop: widget.gridColumns,
          tablet: widget.gridColumns > 1 ? 2 : 1,
          mobile: 1,
          width: constraints.maxWidth,
        ),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final String url = widget.items[index];
        final String? linkUrl = widget.galleryLinks != null && widget.galleryLinks!.length > index
            ? widget.galleryLinks![index]
            : null;

        return Container(
          decoration: BoxDecoration(
            color: subTextColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildGalleryImage(url, linkUrl, subTextColor),
        );
      },
    );
  }

  Widget _buildGalleryImage(String url, String? linkUrl, Color subTextColor) {
    final bool hasLink = linkUrl != null && linkUrl.isNotEmpty;
    
    if (hasLink) {
      return _HoverableGalleryItem(
        url: url,
        linkUrl: linkUrl,
        subTextColor: subTextColor,
      );
    }
    
    return CustomNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
    );
  }
}

class _HoverableGalleryItem extends StatefulWidget {
  final String url;
  final String linkUrl;
  final Color subTextColor;

  const _HoverableGalleryItem({
    required this.url,
    required this.linkUrl,
    required this.subTextColor,
  });

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
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedScale(
                scale: _isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: CustomNetworkImage(
                  imageUrl: widget.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _isHovered 
                    ? Colors.black.withValues(alpha: 0.35) 
                    : Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.open_in_new_rounded,
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
    );
  }
}
