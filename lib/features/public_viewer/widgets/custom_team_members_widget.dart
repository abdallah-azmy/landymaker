import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomTeamMembersWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomTeamMembersWidget({
    super.key,
    required this.block,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final accentColor = theme?.secondary ?? AppColors.secondary;
    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final List items = block['items'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        final props = _TeamMembersProps(
          title: title,
          subtitle: subtitle,
          items: items,
          accentColor: accentColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          constraintsWidth: constraints.maxWidth,
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
        );

        return SectionBackground(
          theme: theme,
          bgImageUrl: props.bgImageUrl,
          bgOverlayColor: props.bgOverlayColor,
          bgOverlayOpacity: props.bgOverlayOpacity,
          bgBlur: props.bgBlur,
          padding: EdgeInsetsDirectional.symmetric(vertical: props.isMobile ? 40 : 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  if (props.title.isNotEmpty) ...[
                    Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32), textAlign: TextAlign.center),
                    SizedBox(height: 12),
                  ],
                  if (props.subtitle.isNotEmpty) ...[
                    Text(props.subtitle, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 16 : 18), textAlign: TextAlign.center),
                    SizedBox(height: 48),
                  ],
                  if (props.isMobile)
                    _MobileTeamMembersLayout(props: props)
                  else
                    _DesktopTeamMembersLayout(props: props),
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
class _TeamMembersProps {
  final String title;
  final String subtitle;
  final List items;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final double constraintsWidth;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _TeamMembersProps({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.constraintsWidth,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the Team Members layout.
class _DesktopTeamMembersLayout extends StatelessWidget {
  final _TeamMembersProps props;
  const _DesktopTeamMembersLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return SizedBox.shrink();

    final int columnCount = ResponsiveUtils.getContentColumns(
      props.constraintsWidth,
      desktop: props.items.length >= 3 ? 3 : props.items.length,
      tablet: 2,
      mobile: 1,
    );

    final List<Widget> rows = [];
    for (int i = 0; i < props.items.length; i += columnCount) {
      final rowItems = props.items.sublist(i, (i + columnCount > props.items.length) ? props.items.length : i + columnCount);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columnCount, (colIndex) {
            if (colIndex < rowItems.length) {
              final item = rowItems[colIndex];
              final isLastInRow = colIndex == columnCount - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : 32.0),
                  child: _TeamMemberCard(item: item, props: props),
                ),
              );
            } else {
              return const Expanded(child: SizedBox.shrink());
            }
          }),
        ),
      );
      if (i + columnCount < props.items.length) rows.add(SizedBox(height: 32));
    }
    return Column(children: rows);
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Team Members layout.
class _MobileTeamMembersLayout extends StatelessWidget {
  final _TeamMembersProps props;
  const _MobileTeamMembersLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return SizedBox.shrink();
    return Column(
      children: List.generate(props.items.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < props.items.length - 1 ? 24 : 0),
          child: _TeamMemberCard(item: props.items[index], props: props),
        );
      }),
    );
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Team Member Card.
class _TeamMemberCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final _TeamMembersProps props;
  const _TeamMemberCard({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: CustomNetworkImage(imageUrl: item['image_url'] ?? '', borderRadius: BorderRadius.circular(20), fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 16),
        Text(item['name'] ?? '', style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 20), textAlign: TextAlign.center),
        SizedBox(height: 4),
        Text(item['role'] ?? '', style: AppTypography.bodyMedium.copyWith(color: props.accentColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        if (item['bio'] != null && (item['bio'] as String).isNotEmpty) ...[
          SizedBox(height: 8),
          Text(item['bio'], style: AppTypography.caption.copyWith(color: props.subTextColor), textAlign: TextAlign.center),
        ],
        SizedBox(height: 16),
        _TeamSocialLinks(socials: item['socials'], accentColor: props.accentColor),
      ],
    );
  }
}

/// Shared Team Social Links row.
class _TeamSocialLinks extends StatelessWidget {
  final dynamic socials;
  final Color accentColor;
  const _TeamSocialLinks({required this.socials, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (socials == null || socials is! List) return SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socials.map<Widget>((s) {
        return IconButton(
          icon: Icon(_getSocialIcon(s['platform']), size: 18),
          color: accentColor.withValues(alpha: 0.7),
          onPressed: () => _launchUrl(s['url']),
        );
      }).toList(),
    );
  }

  IconData _getSocialIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'twitter':
      case 'x': return Icons.close;
      case 'linkedin': return Icons.link;
      case 'instagram': return Icons.camera_alt_rounded;
      case 'facebook': return Icons.facebook;
      default: return Icons.language;
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri);
  }
}
