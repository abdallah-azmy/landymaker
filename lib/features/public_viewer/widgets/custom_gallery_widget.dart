import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomGalleryWidget extends StatefulWidget {
  final String title;
  final List<String> items;
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
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
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
                    _buildGrid(context, subTextColor),
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
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: subTextColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.items[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: subTextColor, size: 64),
                    ),
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

  Widget _buildGrid(BuildContext context, Color subTextColor) {
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
        ),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: subTextColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            widget.items[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: subTextColor),
          ),
        );
      },
    );
  }
}
