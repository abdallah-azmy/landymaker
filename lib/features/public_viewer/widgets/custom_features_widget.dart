import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/responsive/card_layout_mode.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ======================================================
/// FEATURE: Custom Features Widget
/// PURPOSE: Displays a list of features in various layouts (Grid, Bento, Horizontal).
/// ARCHITECTURE: Factory Pattern - Delegates rendering to specific layout 
/// classes based on variant, layoutStyle, and screen size.
/// ======================================================
class CustomFeaturesWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle; // 'grid' or 'bento'
  final CardLayoutMode cardLayoutMode;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;
  final int variant;

  const CustomFeaturesWidget({
    super.key,
    required this.title,
    required this.items,
    this.layoutStyle = 'grid',
    this.cardLayoutMode = CardLayoutMode.auto,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
    this.variant = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = theme?.background ?? Colors.black;
    final primaryColor = theme?.primary ?? Theme.of(context).colorScheme.primary;
    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Colors.white;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);

        final props = _FeaturesProps(
          title: title,
          items: items,
          layoutStyle: layoutStyle,
          cardLayoutMode: cardLayoutMode,
          theme: theme,
          primary: primaryColor,
          secondary: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          bgColor: bgColor,
          isMobile: isMobile,
          variant: variant,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _FeaturesHeader(title: title, textColor: textColor, secondary: secondaryColor, isMobile: isMobile),
                  SizedBox(height: isMobile ? 32 : 64),
                  _buildContent(props, constraints),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(_FeaturesProps props, BoxConstraints constraints) {
    final String effectiveLayoutStyle = props.variant == 1 ? 'bento' : props.layoutStyle;

    if (effectiveLayoutStyle == 'bento' && !props.isMobile) {
      return _FeaturesBentoLayout(props: props);
    }

    if (props.variant == 2 && !props.isMobile) {
      return _FeaturesHorizontalLayout(props: props);
    }

    return _FeaturesGridLayout(props: props, constraints: constraints);
  }
}

/// Data class for Features properties.
class _FeaturesProps {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle;
  final CardLayoutMode cardLayoutMode;
  final LandingPageTheme? theme;
  final Color primary;
  final Color secondary;
  final Color textColor;
  final Color subTextColor;
  final Color bgColor;
  final bool isMobile;
  final int variant;

  const _FeaturesProps({
    required this.title,
    required this.items,
    required this.layoutStyle,
    required this.cardLayoutMode,
    this.theme,
    required this.primary,
    required this.secondary,
    required this.textColor,
    required this.subTextColor,
    required this.bgColor,
    required this.isMobile,
    required this.variant,
  });
}

/// Shared Header for Features section.
class _FeaturesHeader extends StatelessWidget {
  final String title;
  final Color textColor;
  final Color secondary;
  final bool isMobile;

  const _FeaturesHeader({
    required this.title,
    required this.textColor,
    required this.secondary,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        SizedBox(height: 12),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Grid layout for Features.
class _FeaturesGridLayout extends StatelessWidget {
  final _FeaturesProps props;
  final BoxConstraints constraints;

  const _FeaturesGridLayout({required this.props, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final int columnCount = props.variant == 3 ? 2 : ResponsiveUtils.getContentColumns(
      constraints.maxWidth,
      desktop: 3,
      tablet: 2,
      mobile: 1,
    );

    final List<Widget> rows = [];
    for (int i = 0; i < props.items.length; i += columnCount) {
      final rowItems = props.items.sublist(i, (i + columnCount > props.items.length) ? props.items.length : i + columnCount);
      
      Widget rowWidget = Row(
        crossAxisAlignment: props.cardLayoutMode == CardLayoutMode.equal ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: List.generate(columnCount, (colIndex) {
          if (colIndex < rowItems.length) {
            final item = rowItems[colIndex];
            final isLastInRow = colIndex == columnCount - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : (props.isMobile ? 16.0 : 24.0)),
                child: FeatureCard(
                  title: item['title'] ?? '',
                  description: item['description'] ?? '',
                  linkUrl: item['link_url'],
                  iconName: item['icon'],
                  index: i + colIndex,
                  props: props,
                ),
              ),
            );
          } else {
            return const Expanded(child: SizedBox.shrink());
          }
        }),
      );

      rows.add(props.cardLayoutMode == CardLayoutMode.equal ? IntrinsicHeight(child: rowWidget) : rowWidget);

      if (i + columnCount < props.items.length) {
        rows.add(SizedBox(height: props.isMobile ? 16 : 24));
      }
    }
    return Column(children: rows);
  }
}

/// Bento grid layout for Features (Desktop only).
class _FeaturesBentoLayout extends StatelessWidget {
  final _FeaturesProps props;
  const _FeaturesBentoLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return SizedBox.shrink();

    final List<Widget> rows = [];
    
    if (props.items.length >= 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              flex: 3,
              child: FeatureCard(
                title: props.items[0]['title'] ?? '',
                description: props.items[0]['description'] ?? '',
                linkUrl: props.items[0]['link_url'],
                iconName: props.items[0]['icon'],
                index: 0,
                props: props,
                isBento: true,
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: FeatureCard(
                title: props.items[1]['title'] ?? '',
                description: props.items[1]['description'] ?? '',
                linkUrl: props.items[1]['link_url'],
                iconName: props.items[1]['icon'],
                index: 1,
                props: props,
                isBento: true,
              ),
            ),
          ],
        )
      );
    }
    
    if (props.items.length >= 4) {
      rows.add(SizedBox(height: 24));
      rows.add(
        Row(
          children: [
            Expanded(
              flex: 2,
              child: FeatureCard(
                title: props.items[2]['title'] ?? '',
                description: props.items[2]['description'] ?? '',
                linkUrl: props.items[2]['link_url'],
                iconName: props.items[2]['icon'],
                index: 2,
                props: props,
                isBento: true,
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: FeatureCard(
                title: props.items[3]['title'] ?? '',
                description: props.items[3]['description'] ?? '',
                linkUrl: props.items[3]['link_url'],
                iconName: props.items[3]['icon'],
                index: 3,
                props: props,
                isBento: true,
              ),
            ),
          ],
        )
      );
    }

    // Handle remaining or fewer items... (simplified for brevity here but keeping logic same)
    if (props.items.length > 4) {
      // For more than 4, just add them as a grid below
      final remaining = props.items.sublist(4);
      rows.add(SizedBox(height: 24));
      rows.add(_FeaturesGridLayout(props: props, constraints: const BoxConstraints(maxWidth: 1100)));
    } else if (props.items.length == 3) {
       rows.add(SizedBox(height: 24));
       rows.add(FeatureCard(title: props.items[2]['title'] ?? '', description: props.items[2]['description'] ?? '', linkUrl: props.items[2]['link_url'], iconName: props.items[2]['icon'], index: 2, props: props));
    }

    return Column(children: rows);
  }
}

/// Horizontal scroll layout for Features (Desktop only).
class _FeaturesHorizontalLayout extends StatelessWidget {
  final _FeaturesProps props;
  const _FeaturesHorizontalLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: props.items.asMap().entries.map((entry) {
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
                props: props,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Modular Feature Card.
class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final String? linkUrl;
  final String? iconName;
  final int index;
  final _FeaturesProps props;
  final bool isBento;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.linkUrl,
    this.iconName,
    required this.index,
    required this.props,
    this.isBento = false,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.index % 2 == 0 ? widget.props.secondary : widget.props.primary;
    final bool hasLink = widget.linkUrl != null && widget.linkUrl!.isNotEmpty;

    // Variant 4: Alternating Row Style
    if (widget.props.variant == 4) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(_resolveIcon(widget.iconName, widget.index), color: accent),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: widget.props.textColor)),
                  Text(widget.description, style: AppTypography.bodySmall.copyWith(color: widget.props.subTextColor)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final bool isBordered = widget.props.variant == 6;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(widget.props.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: isBordered ? Colors.transparent : (_isHovered && hasLink 
            ? widget.props.subTextColor.withValues(alpha: 0.08)
            : widget.props.subTextColor.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(widget.props.isMobile ? 12 : 20),
        border: Border.all(
          color: isBordered 
              ? accent.withValues(alpha: 0.3)
              : (_isHovered && hasLink 
                  ? accent.withValues(alpha: 0.5) 
                  : widget.props.subTextColor.withValues(alpha: 0.1)),
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
                  size: widget.props.isMobile ? 20 : 24,
                ),
              ),
              if (hasLink)
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: _isHovered ? accent : widget.props.subTextColor.withValues(alpha: 0.3),
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            widget.title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: widget.props.isMobile ? 15 : 18,
              color: widget.props.textColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            widget.description,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.props.subTextColor,
              height: 1.3,
              fontSize: widget.props.isMobile ? 12 : 14,
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
      case 0: return Icons.bolt_rounded;
      case 1: return Icons.auto_graph_rounded;
      case 2: return Icons.security_rounded;
      default: return Icons.star_rounded;
    }
  }
}
