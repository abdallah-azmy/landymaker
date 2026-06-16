import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ======================================================
/// FEATURE: Custom FAQ Widget
/// PURPOSE: Displays frequently asked questions in an accordion layout.
/// ARCHITECTURE: Factory Pattern - Renders [_DesktopFaqLayout] or [_MobileFaqLayout] 
/// based on responsive constraints.
/// ======================================================
class CustomFaqWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomFaqWidget({
    super.key,
    required this.title,
    required this.items,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double verticalPadding = isMobile ? 40 : 80;

        final props = _FaqProps(
          title: title,
          items: items,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          theme: theme,
        );

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: isMobile ? _MobileFaqLayout(props: props) : _DesktopFaqLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for FAQ properties.
class _FaqProps {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final LandingPageTheme? theme;

  const _FaqProps({
    required this.title,
    required this.items,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    this.theme,
  });
}

/// Desktop version of the FAQ layout.
class _DesktopFaqLayout extends StatelessWidget {
  final _FaqProps props;
  const _DesktopFaqLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FaqHeader(props: props),
        SizedBox(height: 48),
        ...props.items.map((item) => _FaqItem(item: item, props: props)),
      ],
    );
  }
}

/// Mobile version of the FAQ layout.
class _MobileFaqLayout extends StatelessWidget {
  final _FaqProps props;
  const _MobileFaqLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FaqHeader(props: props),
        SizedBox(height: 24),
        ...props.items.map((item) => _FaqItem(item: item, props: props)),
      ],
    );
  }
}

/// Shared FAQ Header.
class _FaqHeader extends StatelessWidget {
  final _FaqProps props;
  const _FaqHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Text(
      props.title,
      style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32),
      textAlign: TextAlign.center,
    );
  }
}

/// Modular FAQ Item (Accordion).
class _FaqItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final _FaqProps props;

  const _FaqItem({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: props.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(props.isMobile ? 12 : 16),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: props.isMobile ? 12 : 20, vertical: props.isMobile ? 4 : 8),
        title: Text(
          item['question'] ?? 'Question',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold, 
            color: props.textColor,
            fontSize: props.isMobile ? 14 : 16,
          ),
        ),
        iconColor: props.secondaryColor,
        collapsedIconColor: props.subTextColor,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(props.isMobile ? 12 : 16, 0, props.isMobile ? 12 : 16, props.isMobile ? 12 : 16),
            child: Text(
              item['answer'] ?? 'Answer goes here.',
              style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, height: 1.4, fontSize: props.isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
