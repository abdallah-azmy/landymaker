import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../../core/services/action_handler_service.dart';

/// A specialized hero section for SaaS products with variant-specific layouts,
/// tech logos, and dynamic badge text.
/// Variants: dashboardSplit (default), launchCenter, darkSaas.
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
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;
  final String? buttonUrl;
  final String? layoutStyle;
  final String? badgeText;
  final List<String>? techLogos;

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
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
    this.buttonUrl,
    this.layoutStyle,
    this.badgeText,
    this.techLogos,
  });

  int get _effectiveVariant {
    switch (layoutStyle) {
      case 'launchCenter': return 1;
      case 'darkSaas': return 2;
      default: return 0;
    }
  }

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
          badgeText: badgeText,
          techLogos: techLogos,
        );

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          backgroundColorHex: backgroundColorHex,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.only(
            top: verticalPadding ?? (isMobile ? 60 : 100),
            bottom: verticalPadding ?? (isMobile ? 40 : 60),
            start: 24,
            end: 24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _buildLayout(context, props, isMobile),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayout(BuildContext context, _HeroSaasProps props, bool isMobile) {
    switch (_effectiveVariant) {
      case 1: return _SaasLaunchCenterLayout(props: props, isMobile: isMobile);
      case 2: return _SaasDarkSaasLayout(props: props, isMobile: isMobile);
      default: return _SaasDashboardSplitLayout(props: props, isMobile: isMobile);
    }
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
  final String? badgeText;
  final List<String>? techLogos;

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
    this.badgeText,
    this.techLogos,
  });
}

/// Dashboard split variant (default): centered content with large dashboard image.
class _SaasDashboardSplitLayout extends StatelessWidget {
  final _HeroSaasProps props;
  final bool isMobile;
  const _SaasDashboardSplitLayout({required this.props, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SaasUpdateTag(props: props),
        SizedBox(height: 24),
        _SaasTitle(props: props, fontSize: isMobile ? 32 : 56),
        SizedBox(height: 16),
        _SaasSubtitle(props: props, fontSize: isMobile ? 16 : 20),
        SizedBox(height: 40),
        _SaasActionButton(props: props),
        if (props.techLogos != null && props.techLogos!.isNotEmpty) ...[
          SizedBox(height: 48),
          _SaasTechLogos(props: props),
        ],
        SizedBox(height: 64),
        _SaasImage(props: props),
      ],
    );
  }
}

/// Launch center variant: compact, focused on launch messaging with smaller image.
class _SaasLaunchCenterLayout extends StatelessWidget {
  final _HeroSaasProps props;
  final bool isMobile;
  const _SaasLaunchCenterLayout({required this.props, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SaasUpdateTag(props: props),
        SizedBox(height: 20),
        _SaasTitle(props: props, fontSize: isMobile ? 28 : 48),
        SizedBox(height: 12),
        _SaasSubtitle(props: props, fontSize: isMobile ? 14 : 18),
        SizedBox(height: 32),
        _SaasActionButton(props: props),
        if (props.techLogos != null && props.techLogos!.isNotEmpty) ...[
          SizedBox(height: 40),
          _SaasTechLogos(props: props),
        ],
        SizedBox(height: 48),
        if (props.imageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 40),
            child: _SaasImage(props: props),
          ),
      ],
    );
  }
}

/// Dark SaaS variant: dark background gradient + prominent image, lighter text.
class _SaasDarkSaasLayout extends StatelessWidget {
  final _HeroSaasProps props;
  final bool isMobile;
  const _SaasDarkSaasLayout({required this.props, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            props.primaryColor.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsetsDirectional.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: isMobile ? 16 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (props.badgeText != null && props.badgeText!.isNotEmpty) ...[
            _SaasUpdateTag(props: props),
            SizedBox(height: 20),
          ],
          _SaasTitle(props: props, fontSize: isMobile ? 30 : 48, useLightText: true),
          SizedBox(height: 12),
          _SaasSubtitle(props: props, fontSize: isMobile ? 14 : 18, useLightText: true),
          SizedBox(height: 32),
          _SaasActionButton(props: props),
          if (props.techLogos != null && props.techLogos!.isNotEmpty) ...[
            SizedBox(height: 40),
            _SaasTechLogos(props: props, useLightText: true),
          ],
          SizedBox(height: 48),
          if (props.imageUrl.isNotEmpty)
            _SaasImage(props: props),
        ],
      ),
    );
  }
}

/// Shared SaaS Badge Tag. Reads [badgeText] from props; shows hardcoded fallback if null.
class _SaasUpdateTag extends StatelessWidget {
  final _HeroSaasProps props;
  const _SaasUpdateTag({required this.props});

  @override
  Widget build(BuildContext context) {
    final badge = props.badgeText ??
        (props.isRtl ? "🔥 تحديث جديد متاح الآن" : "🔥 New Update Available");
    if (badge.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: props.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: props.secondaryColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        badge,
        style: AppTypography.caption.copyWith(
          color: props.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Shared SaaS Title. When [useLightText] is true, applies textColor override.
class _SaasTitle extends StatelessWidget {
  final _HeroSaasProps props;
  final double fontSize;
  final bool useLightText;

  const _SaasTitle({
    required this.props,
    required this.fontSize,
    this.useLightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = useLightText ? Colors.white : props.textColor;
    return Text(
      props.title,
      style: AppTypography.h1.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Shared SaaS Subtitle. When [useLightText] is true, applies lighter color.
class _SaasSubtitle extends StatelessWidget {
  final _HeroSaasProps props;
  final double fontSize;
  final bool useLightText;

  const _SaasSubtitle({
    required this.props,
    required this.fontSize,
    this.useLightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = useLightText ? Colors.white70 : props.subTextColor;
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Text(
        props.subtitle,
        style: AppTypography.bodyLarge.copyWith(
          color: color,
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

/// Renders a row of tech logo images from [techLogos] URLs.
class _SaasTechLogos extends StatelessWidget {
  final _HeroSaasProps props;
  final bool useLightText;

  const _SaasTechLogos({required this.props, this.useLightText = false});

  @override
  Widget build(BuildContext context) {
    final logos = props.techLogos ?? [];
    if (logos.isEmpty) return const SizedBox.shrink();

    final labelColor = useLightText ? Colors.white60 : props.subTextColor;

    return Column(
      children: [
        Text(
          props.isRtl ? "يعمل مع" : "Works with",
          style: AppTypography.caption.copyWith(color: labelColor),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: logos.map((url) {
            return SizedBox(
              width: 40,
              height: 40,
              child: CustomNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
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
