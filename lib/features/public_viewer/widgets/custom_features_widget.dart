import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final primaryColor = theme?.primary ?? Theme.of(context).colorScheme.primary;
    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);

        final props = _FeaturesProps(
          title: title,
          items: items,
          layoutStyle: layoutStyle,
          cardLayoutMode: cardLayoutMode,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          variant: variant,
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildLayout(props, constraints),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayout(_FeaturesProps props, BoxConstraints constraints) {
    if (props.layoutStyle == 'bento' && !props.isMobile) {
      return _BentoFeaturesLayout(props: props);
    }
    return _GridFeaturesLayout(props: props, constraints: constraints);
  }
}

class _FeaturesProps {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle;
  final CardLayoutMode cardLayoutMode;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final int variant;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const _FeaturesProps({
    required this.title,
    required this.items,
    required this.layoutStyle,
    required this.cardLayoutMode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.variant,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

class _GridFeaturesLayout extends StatelessWidget {
  final _FeaturesProps props;
  final BoxConstraints constraints;

  const _GridFeaturesLayout({required this.props, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final int columnCount = ResponsiveUtils.getContentColumns(
      constraints.maxWidth,
      desktop: 3,
      tablet: 2,
      mobile: 1,
    );

    final List<List<Map<String, dynamic>>> rows = [];
    for (var i = 0; i < props.items.length; i += columnCount) {
      rows.add(props.items.sublist(i, (i + columnCount).clamp(0, props.items.length)));
    }

    return Column(
      children: [
        if (props.title.isNotEmpty) ...[
          _FeaturesHeader(props: props),
          const SizedBox(height: 64),
        ],
        ...rows.asMap().entries.map((rowEntry) {
          final isLastRow = rowEntry.key == rows.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLastRow ? 0 : 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowEntry.value.asMap().entries.map((itemEntry) {
                final isLastItem = itemEntry.key == rowEntry.value.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: isLastItem ? 0 : 24.0),
                    child: _FeatureCard(item: itemEntry.value, props: props),
                  ),
                );
              }).toList() + List.generate(columnCount - rowEntry.value.length, (_) => const Expanded(child: SizedBox.shrink())),
            ),
          );
        }),
      ],
    );
  }
}

class _BentoFeaturesLayout extends StatelessWidget {
  final _FeaturesProps props;
  const _BentoFeaturesLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (props.title.isNotEmpty) ...[
          _FeaturesHeader(props: props),
          const SizedBox(height: 64),
        ],
        SizedBox(
          height: 600,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _FeatureCard(item: props.items[0], props: props, isLarge: true),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    if (props.items.length > 1) Expanded(child: _FeatureCard(item: props.items[1], props: props)),
                    if (props.items.length > 2) ...[
                      const SizedBox(height: 20),
                      Expanded(child: _FeatureCard(item: props.items[2], props: props)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturesHeader extends StatelessWidget {
  final _FeaturesProps props;
  const _FeaturesHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Text(
      props.title,
      style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 36),
      textAlign: TextAlign.center,
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final _FeaturesProps props;
  final bool isLarge;

  const _FeatureCard({required this.item, required this.props, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    final String title = item['title'] ?? 'Feature';
    final String desc = item['description'] ?? 'Description';
    final String? url = item['button_url'];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: props.secondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.flash_on_rounded, color: props.secondaryColor, size: 24),
          ),
          const SizedBox(height: 24),
          Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor, fontSize: isLarge ? 24 : 18)),
          const SizedBox(height: 12),
          Text(desc, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, height: 1.5)),
          if (url != null && url.isNotEmpty) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => launchUrl(Uri.parse(url)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('المزيد', style: TextStyle(color: props.secondaryColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: props.secondaryColor),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
