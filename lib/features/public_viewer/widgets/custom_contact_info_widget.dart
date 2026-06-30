import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomContactInfoWidget extends StatelessWidget {
  final String title;
  final String? email;
  final String? phone;
  final String? location;
  final String? phoneIcon;
  final String? emailIcon;
  final String? locationIcon;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const CustomContactInfoWidget({
    super.key,
    required this.title,
    this.email,
    this.phone,
    this.location,
    this.phoneIcon,
    this.emailIcon,
    this.locationIcon,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
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

        final props = _ContactProps(
          title: title,
          email: email,
          phone: phone,
          location: location,
          phoneIcon: phoneIcon,
          emailIcon: emailIcon,
          locationIcon: locationIcon,
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
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isMobile ? _MobileContactLayout(props: props) : _DesktopContactLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

class _ContactProps {
  final String title;
  final String? email;
  final String? phone;
  final String? location;
  final String? phoneIcon;
  final String? emailIcon;
  final String? locationIcon;
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

  const _ContactProps({
    required this.title,
    this.email,
    this.phone,
    this.location,
    this.phoneIcon,
    this.emailIcon,
    this.locationIcon,
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

class _DesktopContactLayout extends StatelessWidget {
  final _ContactProps props;
  const _DesktopContactLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContactHeader(props: props),
        const SizedBox(height: 64),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (props.email != null) Expanded(child: _ContactCard(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: props.email!, props: props)),
            const SizedBox(width: 20),
            if (props.phone != null) Expanded(child: _ContactCard(icon: Icons.phone_outlined, label: 'رقم الهاتف', value: props.phone!, props: props)),
            const SizedBox(width: 20),
            if (props.location != null) Expanded(child: _ContactCard(icon: Icons.location_on_outlined, label: 'الموقع', value: props.location!, props: props)),
          ],
        ),
      ],
    );
  }
}

class _MobileContactLayout extends StatelessWidget {
  final _ContactProps props;
  const _MobileContactLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContactHeader(props: props),
        const SizedBox(height: 32),
        if (props.email != null) _ContactCard(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: props.email!, props: props),
        const SizedBox(height: 16),
        if (props.phone != null) _ContactCard(icon: Icons.phone_outlined, label: 'رقم الهاتف', value: props.phone!, props: props),
        const SizedBox(height: 16),
        if (props.location != null) _ContactCard(icon: Icons.location_on_outlined, label: 'الموقع', value: props.location!, props: props),
      ],
    );
  }
}

class _ContactHeader extends StatelessWidget {
  final _ContactProps props;
  const _ContactHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    return Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis);
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _ContactProps props;

  const _ContactCard({required this.icon, required this.label, required this.value, required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: props.secondaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: props.secondaryColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(label, style: AppTypography.bodySmall.copyWith(color: props.subTextColor)),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
