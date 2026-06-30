import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/block_animation_wrapper.dart';
import '../../../core/responsive/card_layout_mode.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomStatisticsGridWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomStatisticsGridWidget({
    super.key,
    required this.block,
    this.theme,
  });

  CardLayoutMode get _layoutMode {
    final raw = block['card_layout_mode'];
    if (raw == null) return CardLayoutMode.auto;
    return CardLayoutModeExt.fromString(raw);
  }

  String get _layoutStyle => block['layout_style'] as String? ?? 'horizontal';

  @override
  Widget build(BuildContext context) {
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final accentColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final List items = block['items'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double paddingValue = (block['vertical_padding'] as num?)?.toDouble() ?? (isMobile ? 40 : 80);

        final props = _StatisticsGridProps(
          title: title,
          subtitle: subtitle,
          items: items,
          accentColor: accentColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          constraintsWidth: constraints.maxWidth,
          layoutStyle: _layoutStyle,
          layoutMode: _layoutMode,
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble(),
          backgroundColorHex: block['bg_color'] ?? block['background_color'],
          verticalPadding: (block['vertical_padding'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
        );

        return SectionBackground(
          theme: theme,
          bgImageUrl: props.bgImageUrl,
          bgOverlayColor: props.bgOverlayColor,
          bgOverlayOpacity: props.bgOverlayOpacity,
          backgroundColorHex: props.backgroundColorHex,
          verticalPaddingOverride: props.verticalPadding,
          bgBlur: props.bgBlur,
          padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  if (props.title.isNotEmpty) ...[
                    Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 12),
                  ],
                  if (props.subtitle.isNotEmpty) ...[
                    Text(props.subtitle, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 16 : 18), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 48),
                  ],
                  if (props.isMobile)
                    _MobileStatisticsGridLayout(props: props)
                  else
                    _DesktopStatisticsGridLayout(props: props),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _StatisticsGridProps {
  final String title;
  final String subtitle;
  final List items;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final double constraintsWidth;
  final String layoutStyle;
  final CardLayoutMode layoutMode;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final String? backgroundColorHex;
  final double? verticalPadding;

  const _StatisticsGridProps({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.constraintsWidth,
    required this.layoutStyle,
    required this.layoutMode,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
    this.backgroundColorHex,
    this.verticalPadding,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the Statistics Grid layout.
class _DesktopStatisticsGridLayout extends StatelessWidget {
  final _StatisticsGridProps props;
  const _DesktopStatisticsGridLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return SizedBox.shrink();

    final int columnCount = ResponsiveUtils.getContentColumns(
      props.constraintsWidth,
      desktop: props.items.length >= 4 ? 4 : (props.items.length >= 3 ? 3 : props.items.length),
      tablet: 2,
      mobile: 1,
    );

    final List<Widget> rows = [];
    for (int i = 0; i < props.items.length; i += columnCount) {
      final rowItems = props.items.sublist(i, (i + columnCount > props.items.length) ? props.items.length : i + columnCount);

      Widget rowWidget = Row(
        crossAxisAlignment: props.layoutMode == CardLayoutMode.equal ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: List.generate(columnCount, (colIndex) {
          if (colIndex < rowItems.length) {
            final item = rowItems[colIndex];
            final isLastInRow = colIndex == columnCount - 1;
            final itemIndex = i + colIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : 24.0),
                child: BlockAnimationWrapper(
                  settings: BlockAnimationSettings(
                    type: BlockAnimationType.fadeIn,
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: itemIndex * 150),
                  ),
                  child: _StatCard(item: item, props: props),
                ),
              ),
            );
          } else {
            return const Expanded(child: SizedBox.shrink());
          }
        }),
      );

      rows.add(props.layoutMode == CardLayoutMode.equal ? IntrinsicHeight(child: rowWidget) : rowWidget);
      if (i + columnCount < props.items.length) rows.add(SizedBox(height: 24));
    }
    return Column(children: rows);
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Statistics Grid layout.
class _MobileStatisticsGridLayout extends StatelessWidget {
  final _StatisticsGridProps props;
  const _MobileStatisticsGridLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return SizedBox.shrink();
    return Column(
      children: List.generate(props.items.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < props.items.length - 1 ? 16 : 0),
          child: _StatCard(item: props.items[index], props: props),
        );
      }),
    );
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Statistics Card.
class _StatCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final _StatisticsGridProps props;
  const _StatCard({required this.item, required this.props});

  IconData _getIconData(String name) {
    switch (name) {
      case 'people': return Icons.people_rounded;
      case 'star': return Icons.star_rounded;
      case 'check': return Icons.check_circle_rounded;
      case 'trending': return Icons.trending_up_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'thumb_up': return Icons.thumb_up_rounded;
      case 'public': return Icons.public_rounded;
      case 'speed': return Icons.speed_rounded;
      case 'favorite': return Icons.favorite_rounded;
      default: return Icons.bar_chart_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showIcon = props.layoutStyle == 'withIcons';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: props.textColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: props.textColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: props.accentColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(_getIconData(item['icon']), color: props.accentColor, size: 28),
            ),
            SizedBox(height: 16),
          ] else if (item['icon'] != null) ...[
            Icon(_getIconData(item['icon']), color: props.accentColor, size: 32),
            SizedBox(height: 12),
          ],
          Text(item['value'] ?? '0', style: AppTypography.h1.copyWith(color: props.accentColor, fontSize: props.isMobile ? 28 : 36, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text(item['label'] ?? '', style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
