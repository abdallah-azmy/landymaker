import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../../core/services/action_handler_service.dart';

/// ======================================================
/// FEATURE: Custom Hero Widget
/// PURPOSE: Primary header section for the landing page.
/// ARCHITECTURE: Factory Pattern - Delegates rendering to specific layout 
/// classes based on [_effectiveVariant] and screen size.
/// ======================================================
class CustomHeroWidget extends StatelessWidget {
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
  final int variant;
  final String? layoutStyle;

  const CustomHeroWidget({
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
    this.variant = 0,
    this.layoutStyle,
  });

  int get _effectiveVariant {
    if (variant > 0) return variant;
    if (layoutStyle == null) return 0;
    switch (layoutStyle) {
      case 'split': return 1;
      case 'centered': return 2;
      case 'glass': return 3;
      case 'fullWidthBg': return 4;
      case 'minimal': return 8;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final primaryColor = theme?.primary ?? AppColors.primary;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double defaultPadding = theme?.globalBgImageUrl != null ? 40 : (isMobile ? 40 : 80);

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: defaultPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: _buildLayout(context, constraints, isRtl, isMobile, primaryColor, secondaryColor, textColor, subTextColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayout(
    BuildContext context, 
    BoxConstraints constraints, 
    bool isRtl, 
    bool isMobile, 
    Color primary, 
    Color secondary, 
    Color textColor, 
    Color subTextColor
  ) {
    final commonProps = _HeroProps(
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      imageUrl: imageUrl,
      buttonUrl: buttonUrl,
      pageId: pageId,
      theme: theme,
      primary: primary,
      secondary: secondary,
      textColor: textColor,
      subTextColor: subTextColor,
      isRtl: isRtl,
      isMobile: isMobile,
    );

    switch (_effectiveVariant) {
      case 1: return _HeroSplitLayout(props: commonProps);
      case 2: return _HeroCenteredLayout(props: commonProps);
      case 3: return _HeroGlassLayout(props: commonProps);
      case 4: return _HeroFullWidthBGLayout(props: commonProps);
      case 5: return _HeroReverseLayout(props: commonProps);
      case 8: return _HeroMinimalLayout(props: commonProps);
      default: return _HeroStandardLayout(props: commonProps);
    }
  }
}

/// Data class to pass shared properties to hero sub-layouts.
class _HeroProps {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String? buttonUrl;
  final String pageId;
  final LandingPageTheme? theme;
  final Color primary;
  final Color secondary;
  final Color textColor;
  final Color subTextColor;
  final bool isRtl;
  final bool isMobile;

  const _HeroProps({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    this.buttonUrl,
    required this.pageId,
    this.theme,
    required this.primary,
    required this.secondary,
    required this.textColor,
    required this.subTextColor,
    required this.isRtl,
    required this.isMobile,
  });
}

/// Standard layout: Text on one side, image on the other.
class _HeroStandardLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroStandardLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: _HeroTextContent(props: props, alignment: CrossAxisAlignment.start),
          ),
          SizedBox(width: 48),
          Expanded(
            flex: 5,
            child: _HeroImage(props: props),
          ),
        ],
      ),
      mobile: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HeroTextContent(props: props, alignment: CrossAxisAlignment.center),
          SizedBox(height: 32),
          _HeroImage(props: props),
        ],
      ),
    );
  }
}

/// Split layout with image first on desktop.
class _HeroSplitLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroSplitLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: Row(
        children: [
          Expanded(child: _HeroImage(props: props)),
          SizedBox(width: 48),
          Expanded(child: _HeroTextContent(props: props, alignment: CrossAxisAlignment.start)),
        ],
      ),
      mobile: Column(
        children: [
          _HeroImage(props: props),
          SizedBox(height: 32),
          _HeroTextContent(props: props, alignment: CrossAxisAlignment.center),
        ],
      ),
    );
  }
}

/// Reverse layout (duplicate of split currently in original code).
class _HeroReverseLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroReverseLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return _HeroSplitLayout(props: props);
  }
}

/// Centered layout with text above image.
class _HeroCenteredLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroCenteredLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroTextContent(props: props, alignment: CrossAxisAlignment.center),
        SizedBox(height: 48),
        _HeroImage(props: props),
      ],
    );
  }
}

/// Glassmorphism card layout.
class _HeroGlassLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroGlassLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: _HeroCenteredLayout(props: props),
    );
  }
}

/// Full width background image layout with text overlay.
class _HeroFullWidthBGLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroFullWidthBGLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.3,
          child: _HeroImage(props: props),
        ),
        _HeroTextContent(props: props, alignment: CrossAxisAlignment.center),
      ],
    );
  }
}

/// Minimal layout: Text only.
class _HeroMinimalLayout extends StatelessWidget {
  final _HeroProps props;
  const _HeroMinimalLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return _HeroTextContent(props: props, alignment: CrossAxisAlignment.center);
  }
}

/// Shared Text Content widget.
class _HeroTextContent extends StatelessWidget {
  final _HeroProps props;
  final CrossAxisAlignment alignment;

  const _HeroTextContent({required this.props, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        _HeroPremiumTag(props: props),
        SizedBox(height: 16),
        Text(
          props.title,
          style: AppTypography.h1.copyWith(
            height: 1.1,
            fontSize: props.isMobile ? 32 : 48,
            fontWeight: FontWeight.w900,
            color: props.textColor,
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: 12),
        Text(
          props.subtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: props.subTextColor,
            fontSize: props.isMobile ? 14 : 18,
            height: 1.5,
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: 24),
        _HeroButton(props: props),
      ],
    );
  }
}

/// Shared Premium Tag widget.
class _HeroPremiumTag extends StatelessWidget {
  final _HeroProps props;
  const _HeroPremiumTag({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: props.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: props.secondary.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        props.isRtl ? "شريك نجاحك الرقمي" : "Your Digital Partner",
        style: AppTypography.caption.copyWith(
          color: props.secondary,
          fontWeight: FontWeight.bold,
          fontSize: props.isMobile ? 10 : 12,
          letterSpacing: props.isRtl ? 0 : 1.2,
        ),
      ),
    );
  }
}

/// Shared Hero Button widget.
class _HeroButton extends StatelessWidget {
  final _HeroProps props;
  const _HeroButton({required this.props});

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
            blockType: 'hero',
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: props.secondary,
        foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
        padding: EdgeInsets.symmetric(horizontal: props.isMobile ? 24 : 32, vertical: props.isMobile ? 14 : 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              props.buttonText,
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: props.isMobile ? 14 : 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Icon(props.isRtl ? Icons.arrow_back : Icons.arrow_forward, size: 18),
        ],
      ),
    );
  }
}

/// Shared Hero Image widget.
class _HeroImage extends StatelessWidget {
  final _HeroProps props;
  const _HeroImage({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: props.primary.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomNetworkImage(
        imageUrl: props.imageUrl,
        borderRadius: BorderRadius.circular(20),
        fit: BoxFit.cover,
        height: props.isMobile ? 300 : null,
      ),
    );
  }
}
