import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../../core/services/action_handler_service.dart';

/// ======================================================
/// FEATURE: Custom Hero SaaS Widget
/// PURPOSE: A specialized hero section for SaaS products with feature tags and center-aligned design.
/// ARCHITECTURE: Factory Pattern - Renders [_HeroSaasDesktop] or [_HeroSaasMobile] 
/// based on responsive constraints.
/// ======================================================
class CustomHeroSaasWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String pageId;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final String? buttonUrl;
  final double? verticalPadding;
  final String? layoutStyle;

  const CustomHeroSaasWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
    this.buttonUrl,
    this.verticalPadding,
    this.layoutStyle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = theme?.primary ?? Theme.of(context).colorScheme.primary;
    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _HeroSaasProps(
          title: title,
          subtitle: subtitle,
          buttonText: buttonText,
          imageUrl: imageUrl,
          pageId: pageId,
          theme: theme,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isRtl: isRtl,
          isMobile: isMobile,
          buttonUrl: buttonUrl,
        );

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.only(
            top: isMobile ? 60 : 100,
            bottom: isMobile ? 40 : 60,
            start: 24,
            end: 24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isMobile 
                ? _HeroSaasMobile(props: props) 
                : _HeroSaasDesktop(props: props),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for SaaS Hero properties.
class _HeroSaasProps {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String pageId;
  final LandingPageTheme? theme;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isRtl;
  final bool isMobile;
  final String? buttonUrl;

  const _HeroSaasProps({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.pageId,
    this.theme,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isRtl,
    required this.isMobile,
    this.buttonUrl,
  });
}

/// Desktop version of the SaaS Hero.
class _HeroSaasDesktop extends StatelessWidget {
  final _HeroSaasProps props;
  const _HeroSaasDesktop({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SaasUpdateTag(props: props),
        SizedBox(height: 24),
        _SaasTitle(props: props, fontSize: 56),
        SizedBox(height: 16),
        _SaasSubtitle(props: props, fontSize: 20),
        SizedBox(height: 40),
        _SaasActionButton(props: props),
        SizedBox(height: 64),
        _SaasImage(props: props),
      ],
    );
  }
}

/// Mobile version of the SaaS Hero.
class _HeroSaasMobile extends StatelessWidget {
  final _HeroSaasProps props;
  const _HeroSaasMobile({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SaasUpdateTag(props: props),
        SizedBox(height: 24),
        _SaasTitle(props: props, fontSize: 32),
        SizedBox(height: 16),
        _SaasSubtitle(props: props, fontSize: 16),
        SizedBox(height: 40),
        _SaasActionButton(props: props),
        SizedBox(height: 64),
        _SaasImage(props: props),
      ],
    );
  }
}

/// Shared SaaS Update Tag.
class _SaasUpdateTag extends StatelessWidget {
  final _HeroSaasProps props;
  const _SaasUpdateTag({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: props.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: props.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        props.isRtl ? "🔥 تحديث جديد متاح الآن" : "🔥 New Update Available",
        style: AppTypography.caption.copyWith(
          color: props.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Shared SaaS Title.
class _SaasTitle extends StatelessWidget {
  final _HeroSaasProps props;
  final double fontSize;

  const _SaasTitle({required this.props, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      props.title,
      style: AppTypography.h1.copyWith(
        color: props.textColor,
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Shared SaaS Subtitle.
class _SaasSubtitle extends StatelessWidget {
  final _HeroSaasProps props;
  final double fontSize;

  const _SaasSubtitle({required this.props, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Text(
        props.subtitle,
        style: AppTypography.bodyLarge.copyWith(
          color: props.subTextColor,
          fontSize: fontSize,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Shared SaaS Action Button.
class _SaasActionButton extends StatelessWidget {
  final _HeroSaasProps props;
  const _SaasActionButton({required this.props});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (props.buttonUrl != null && props.buttonUrl!.isNotEmpty) {
          await ActionHandlerService.executeAction(
            context,
            actionType: 'link',
            actionValue: props.buttonUrl!,
            pageId: props.pageId,
            buttonText: props.buttonText,
            blockType: 'hero_saas',
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: props.secondaryColor,
        foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: props.isMobile ? 24 : 32,
          vertical: props.isMobile ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),
      child: Text(props.buttonText, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

/// Shared SaaS Hero Image.
class _SaasImage extends StatelessWidget {
  final _HeroSaasProps props;
  const _SaasImage({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: props.primaryColor.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CustomNetworkImage(
          imageUrl: props.imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
