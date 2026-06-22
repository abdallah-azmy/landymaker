import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

/// ======================================================
/// FEATURE: Custom Testimonials Widget
/// PURPOSE: Displays customer reviews in Masonry or Carousel layouts.
/// ARCHITECTURE: Factory Pattern - Delegates rendering to specific layout 
/// classes based on [layoutStyle] and screen size.
/// ======================================================
class CustomTestimonialsWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;
  final String? layoutStyle;

  const CustomTestimonialsWidget({
    super.key,
    required this.title,
    required this.items,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
    this.layoutStyle,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);

        final props = _TestimonialsProps(
          title: title,
          items: items,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          backgroundColorHex: backgroundColorHex,
          verticalPadding: verticalPadding,
          bgBlur: bgBlur,
        );

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          backgroundColorHex: backgroundColorHex,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: layoutStyle == 'carousel' 
                ? _TestimonialsCarouselLayout(props: props, constraints: constraints) 
                : _TestimonialsMasonryLayout(props: props, constraints: constraints),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for Testimonials properties.
class _TestimonialsProps {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const _TestimonialsProps({
    required this.title,
    required this.items,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

/// Shared Testimonials Header.
class _TestimonialsHeader extends StatelessWidget {
  final _TestimonialsProps props;
  const _TestimonialsHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Text(
      props.title,
      style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32),
      textAlign: TextAlign.center,
    );
  }
}

/// Masonry grid layout for Testimonials.
class _TestimonialsMasonryLayout extends StatelessWidget {
  final _TestimonialsProps props;
  final BoxConstraints constraints;

  const _TestimonialsMasonryLayout({required this.props, required this.constraints});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return SizedBox.shrink();

    final int columnCount = ResponsiveUtils.getContentColumns(
      constraints.maxWidth,
      desktop: 3,
      tablet: 2,
      mobile: 1,
    );

    final List<List<Map<String, dynamic>>> columns = List.generate(columnCount, (_) => []);
    for (int i = 0; i < props.items.length; i++) {
      columns[i % columnCount].add(props.items[i]);
    }

    return Column(
      children: [
        _TestimonialsHeader(props: props),
        SizedBox(height: props.isMobile ? 32 : 64),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columnCount, (colIndex) {
            final isLastColumn = colIndex == columnCount - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: isLastColumn ? 0 : 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: columns[colIndex].asMap().entries.map((entry) {
                    final isLastItem = entry.key == columns[colIndex].length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLastItem ? 0 : 20.0),
                      child: _TestimonialCard(item: entry.value, props: props),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Carousel horizontal layout for Testimonials.
class _TestimonialsCarouselLayout extends StatelessWidget {
  final _TestimonialsProps props;
  final BoxConstraints constraints;

  const _TestimonialsCarouselLayout({required this.props, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TestimonialsHeader(props: props),
        SizedBox(height: props.isMobile ? 24 : 40),
        if (props.items.isEmpty)
          SizedBox.shrink()
        else
          SizedBox(
            height: props.isMobile ? 300 : 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(end: 24),
              itemCount: props.items.length,
              separatorBuilder: (_, __) => SizedBox(width: 20),
              itemBuilder: (_, index) {
                return SizedBox(
                  width: props.isMobile ? constraints.maxWidth * 0.75 : 340,
                  child: _TestimonialCard(item: props.items[index], props: props),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Modular Testimonial Card.
class _TestimonialCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final _TestimonialsProps props;

  const _TestimonialCard({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(props.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => Icon(Icons.star_rounded, color: props.secondaryColor, size: props.isMobile ? 14 : 16)),
          ),
          SizedBox(height: 12),
          Text(
            item['quote'] ?? 'Testimonial quote goes here.',
            style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontStyle: FontStyle.italic, fontSize: props.isMobile ? 12 : 14, height: 1.4),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _AuthorAvatar(imageUrl: item['image_url'], authorName: item['author'], props: props),
              SizedBox(width: 10),
              _AuthorInfo(authorName: item['author'], role: item['role'], props: props),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared Author Avatar widget.
class _AuthorAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? authorName;
  final _TestimonialsProps props;

  const _AuthorAvatar({this.imageUrl, this.authorName, required this.props});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: props.isMobile ? 32 : 40,
        height: props.isMobile ? 32 : 40,
        decoration: BoxDecoration(color: props.secondaryColor.withValues(alpha: 0.2), shape: BoxShape.circle),
        child: imageUrl != null && imageUrl!.isNotEmpty
          ? CustomNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
          : Center(child: Text((authorName ?? 'A')[0].toUpperCase(), style: TextStyle(color: props.secondaryColor, fontWeight: FontWeight.bold, fontSize: props.isMobile ? 12 : 14))),
      ),
    );
  }
}

/// Shared Author Info widget.
class _AuthorInfo extends StatelessWidget {
  final String? authorName;
  final String? role;
  final _TestimonialsProps props;

  const _AuthorInfo({this.authorName, this.role, required this.props});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            authorName ?? 'Author Name', 
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: props.textColor, fontSize: props.isMobile ? 13 : 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            role ?? 'Position', 
            style: AppTypography.caption.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 10 : 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
