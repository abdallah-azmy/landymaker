import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomFeaturesWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle; // 'grid' or 'bento'
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final int variant;

  const CustomFeaturesWidget({
    super.key,
    required this.title,
    required this.items,
    this.layoutStyle = 'grid',
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
    this.variant = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = theme?.background ?? Colors.black;
    final primaryColor = theme?.primary ?? AppColors.primary;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? Colors.white;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 64),
                  _buildContent(context, constraints, isMobile, primaryColor, secondaryColor, textColor, subTextColor, bgColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, BoxConstraints constraints, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor, Color bgColor) {
    // If variant is 1, force bento
    final String effectiveLayoutStyle = variant == 1 ? 'bento' : layoutStyle;

    if (effectiveLayoutStyle == 'bento' && !isMobile) {
      return _buildBentoGrid(context, constraints, items, primary, secondary, textColor, subTextColor, bgColor);
    }

    if (variant == 2 && !isMobile) { // Horizontal Scroll
       return SingleChildScrollView(
         scrollDirection: Axis.horizontal,
         child: Row(
           children: items.asMap().entries.map((entry) {
             return Container(
               width: 300,
               margin: const EdgeInsetsDirectional.only(end: 24),
               child: ConstrainedBox(
                 constraints: const BoxConstraints(minHeight: 200),
                 child: FeatureCard(
                  title: entry.value['title'] ?? '',
                  description: entry.value['description'] ?? '',
                  linkUrl: entry.value['link_url'],
                  iconName: entry.value['icon'],
                  index: entry.key,
                  primary: primary,
                  secondary: secondary,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  bgColor: bgColor,
                  isMobile: isMobile,
                ),
                ),
              );
            }).toList(),
         ),
       );
    }

    final int columnCount = variant == 3 ? 2 : ResponsiveUtils.getContentColumns(
      constraints.maxWidth,
      desktop: 3,
      tablet: 2,
      mobile: 1,
    );

    final List<Widget> rows = [];
    for (int i = 0; i < items.length; i += columnCount) {
      final rowItems = items.sublist(i, (i + columnCount > items.length) ? items.length : i + columnCount);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columnCount, (colIndex) {
            if (colIndex < rowItems.length) {
              final item = rowItems[colIndex];
              final isLastInRow = colIndex == columnCount - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : (isMobile ? 16.0 : 24.0)),
                  child: FeatureCard(
                    title: item['title'] ?? '',
                    description: item['description'] ?? '',
                    linkUrl: item['link_url'],
                    iconName: item['icon'],
                    index: i + colIndex,
                    primary: primary,
                    secondary: secondary,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    bgColor: bgColor,
                    isMobile: isMobile,
                    variant: variant,
                  ),
                ),
              );
            } else {
              return const Expanded(child: SizedBox.shrink());
            }
          }),
        ),
      );
      if (i + columnCount < items.length) {
        rows.add(SizedBox(height: isMobile ? 16 : 24));
      }
    }
    return Column(children: rows);
  }

  Widget _buildBentoGrid(BuildContext context, BoxConstraints constraints, List<Map<String, dynamic>> items, Color primary, Color secondary, Color textColor, Color subTextColor, Color bgColor) {
    if (items.isEmpty) return const SizedBox.shrink();

    final List<Widget> rows = [];
    
    if (items.length >= 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              flex: 3,
              child: FeatureCard(
                title: items[0]['title'] ?? '',
                description: items[0]['description'] ?? '',
                linkUrl: items[0]['link_url'],
                iconName: items[0]['icon'],
                index: 0,
                primary: primary,
                secondary: secondary,
                textColor: textColor,
                subTextColor: subTextColor,
                bgColor: bgColor,
                isMobile: false,
                isBento: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: FeatureCard(
                title: items[1]['title'] ?? '',
                description: items[1]['description'] ?? '',
                linkUrl: items[1]['link_url'],
                iconName: items[1]['icon'],
                index: 1,
                primary: primary,
                secondary: secondary,
                textColor: textColor,
                subTextColor: subTextColor,
                bgColor: bgColor,
                isMobile: false,
                isBento: true,
              ),
            ),
          ],
        )
      );
    }
    
    if (items.length >= 4) {
      rows.add(const SizedBox(height: 24));
      rows.add(
        Row(
          children: [
            Expanded(
              flex: 2,
              child: FeatureCard(
                title: items[2]['title'] ?? '',
                description: items[2]['description'] ?? '',
                linkUrl: items[2]['link_url'],
                iconName: items[2]['icon'],
                index: 2,
                primary: primary,
                secondary: secondary,
                textColor: textColor,
                subTextColor: subTextColor,
                bgColor: bgColor,
                isMobile: false,
                isBento: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: FeatureCard(
                title: items[3]['title'] ?? '',
                description: items[3]['description'] ?? '',
                linkUrl: items[3]['link_url'],
                iconName: items[3]['icon'],
                index: 3,
                primary: primary,
                secondary: secondary,
                textColor: textColor,
                subTextColor: subTextColor,
                bgColor: bgColor,
                isMobile: false,
                isBento: true,
              ),
            ),
          ],
        )
      );
    }

    // Remaining items
    if (items.length > 4) {
      final remaining = items.sublist(4);
      rows.add(const SizedBox(height: 24));
      final int columnCount = ResponsiveUtils.getContentColumns(
        constraints.maxWidth,
        desktop: 3,
        tablet: 2,
        mobile: 1,
      );

      final List<Widget> remainingRows = [];
      for (int i = 0; i < remaining.length; i += columnCount) {
        final rowItems = remaining.sublist(i, (i + columnCount > remaining.length) ? remaining.length : i + columnCount);
        remainingRows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columnCount, (colIndex) {
              if (colIndex < rowItems.length) {
                final item = rowItems[colIndex];
                final isLastInRow = colIndex == columnCount - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : 24.0),
                    child: FeatureCard(
                      title: item['title'] ?? '',
                      description: item['description'] ?? '',
                      linkUrl: item['link_url'],
                      iconName: item['icon'],
                      index: i + colIndex + 4,
                      primary: primary,
                      secondary: secondary,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      bgColor: bgColor,
                      isMobile: false,
                    ),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          ),
        );
        if (i + columnCount < remaining.length) {
          remainingRows.add(const SizedBox(height: 24));
        }
      }
      rows.add(Column(children: remainingRows));
    } else if (items.length == 3) {
       rows.add(const SizedBox(height: 24));
       rows.add(
         FeatureCard(
           title: items[2]['title'] ?? '',
           description: items[2]['description'] ?? '',
           linkUrl: items[2]['link_url'],
           iconName: items[2]['icon'],
           index: 2,
           primary: primary,
           secondary: secondary,
           textColor: textColor,
           subTextColor: subTextColor,
           bgColor: bgColor,
           isMobile: false,
         ),
       );
    } else if (items.length == 1) {
       rows.add(
         FeatureCard(
           title: items[0]['title'] ?? '',
           description: items[0]['description'] ?? '',
           linkUrl: items[0]['link_url'],
           iconName: items[0]['icon'],
           index: 0,
           primary: primary,
           secondary: secondary,
           textColor: textColor,
           subTextColor: subTextColor,
           bgColor: bgColor,
           isMobile: false,
         ),
       );
    }

    return Column(children: rows);
  }
}

class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final String? linkUrl;
  final String? iconName;
  final int index;
  final Color primary;
  final Color secondary;
  final Color textColor;
  final Color subTextColor;
  final Color bgColor;
  final bool isMobile;
  final bool isBento;
  final int variant;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.linkUrl,
    this.iconName,
    required this.index,
    required this.primary,
    required this.secondary,
    required this.textColor,
    required this.subTextColor,
    required this.bgColor,
    required this.isMobile,
    this.isBento = false,
    this.variant = 0,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.index % 2 == 0 ? widget.secondary : widget.primary;
    final bool hasLink = widget.linkUrl != null && widget.linkUrl!.isNotEmpty;

    // Variant 4: Alternating Row Style
    if (widget.variant == 4) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(_resolveIcon(widget.iconName, widget.index), color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: widget.textColor)),
                  Text(widget.description, style: AppTypography.bodySmall.copyWith(color: widget.subTextColor)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Variant 6: Bordered Style
    final bool isBordered = widget.variant == 6;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isBordered ? Colors.transparent : (_isHovered && hasLink 
            ? widget.subTextColor.withValues(alpha: 0.08)
            : widget.subTextColor.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(widget.isMobile ? 12 : 20),
        border: Border.all(
          color: isBordered 
              ? accent.withValues(alpha: 0.3)
              : (_isHovered && hasLink 
                  ? accent.withValues(alpha: 0.5) 
                  : widget.subTextColor.withValues(alpha: 0.1)),
          width: isBordered ? 2 : (_isHovered && hasLink ? 1.5 : 1),
        ),
        boxShadow: [
          if (!isBordered && (widget.isBento || (_isHovered && hasLink)))
            BoxShadow(
              color: accent.withValues(alpha: _isHovered && hasLink ? 0.08 : 0.03),
              blurRadius: _isHovered && hasLink ? 25 : 20,
              spreadRadius: 2,
              offset: Offset(0, _isHovered && hasLink ? 4 : 0),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _resolveIcon(widget.iconName, widget.index),
                  color: accent,
                  size: widget.isMobile ? 20 : 24,
                ),
              ),
              if (hasLink)
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: _isHovered ? accent : widget.subTextColor.withValues(alpha: 0.3),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: widget.isMobile ? 15 : 18,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.description,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.subTextColor,
              height: 1.3,
              fontSize: widget.isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );

    if (hasLink) {
      cardContent = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.tryParse(widget.linkUrl!);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: cardContent,
          ),
        ),
      );
    }

    return cardContent;
  }

  IconData _resolveIcon(String? iconName, int index) {
    if (iconName != null && iconName.isNotEmpty) {
      // Basic mapping for common icons
      switch (iconName.toLowerCase()) {
        case 'bolt': return Icons.bolt_rounded;
        case 'graph': return Icons.auto_graph_rounded;
        case 'security': return Icons.security_rounded;
        case 'star': return Icons.star_rounded;
        case 'check': return Icons.check_circle_rounded;
        case 'cloud': return Icons.cloud_rounded;
        case 'code': return Icons.code_rounded;
        case 'design': return Icons.brush_rounded;
        case 'speed': return Icons.speed_rounded;
        case 'support': return Icons.support_agent_rounded;
        case 'mobile': return Icons.phone_iphone_rounded;
        case 'web': return Icons.language_rounded;
        case 'settings': return Icons.settings_rounded;
      }
    }
    return _getFeatureIcon(index);
  }

  IconData _getFeatureIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.bolt_rounded;
      case 1:
        return Icons.auto_graph_rounded;
      case 2:
        return Icons.security_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
