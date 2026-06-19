import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';
import '../controllers/cart_cubit.dart';

/// ======================================================
/// FEATURE: Featured Product Widget
/// PURPOSE: High-impact section to showcase a single "star" product.
/// ======================================================
class FeaturedProductWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;
  final String? whatsappNumber;

  const FeaturedProductWidget({
    super.key,
    required this.block,
    this.theme,
    this.whatsappNumber,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final layoutStyle = block['layout_style'] as String? ?? 'split';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;
        final double paddingValue = (block['vertical_padding'] as num?)?.toDouble() ?? (isMobile ? 40 : 80);

        final props = _FeaturedProductProps(
          block: block,
          theme: theme,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          whatsappNumber: whatsappNumber,
        );

        return SectionBackground(
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble() ?? 0.0,
          backgroundColorHex: block['bg_color'] ?? block['background_color'],
          verticalPaddingOverride: (block['vertical_padding'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(
              vertical: paddingValue, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: layoutStyle == 'centered'
                  ? _CenteredFeaturedLayout(props: props)
                  : (layoutStyle == 'reversed'
                      ? (isMobile
                          ? _MobileFeaturedSplitLayout(props: props)
                          : _DesktopFeaturedSplitLayout(
                              props: props, isReversed: true))
                      : (isMobile
                          ? _MobileFeaturedSplitLayout(props: props)
                          : _DesktopFeaturedSplitLayout(props: props))),
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedProductProps {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final String? whatsappNumber;

  const _FeaturedProductProps({
    required this.block,
    this.theme,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    this.whatsappNumber,
  });

  String get name => block['name'] ?? 'اسم المنتج المميز';
  String get price => block['price'] ?? '0.00';
  String get description => block['description'] ?? 'وصف مختصر للمنتج يبرز أهم مميزاته وفوائده للعميل.';
  String get imageUrl => block['image_url'] ?? 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800';
  String get buttonText => block['button_text'] ?? 'إضافة للسلة';
  String? get badgeText => block['badge_text'];
}

class _DesktopFeaturedSplitLayout extends StatelessWidget {
  final _FeaturedProductProps props;
  final bool isReversed;
  const _DesktopFeaturedSplitLayout(
      {required this.props, this.isReversed = false});

  @override
  Widget build(BuildContext context) {
    final children = [
      Expanded(
        flex: 5,
        child: _ProductImage(props: props),
      ),
      const SizedBox(width: 64),
      Expanded(
        flex: 5,
        child: _ProductContent(props: props),
      ),
    ];

    return Row(
      children: isReversed ? children.reversed.toList() : children,
    );
  }
}

class _MobileFeaturedSplitLayout extends StatelessWidget {
  final _FeaturedProductProps props;
  const _MobileFeaturedSplitLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProductImage(props: props),
        const SizedBox(height: 32),
        _ProductContent(props: props),
      ],
    );
  }
}

class _CenteredFeaturedLayout extends StatelessWidget {
  final _FeaturedProductProps props;
  const _CenteredFeaturedLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _ProductImage(props: props),
        ),
        const SizedBox(height: 40),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ProductContent(props: props, isCentered: true),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  final _FeaturedProductProps props;
  const _ProductImage({required this.props});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomNetworkImage(
              imageUrl: props.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (props.badgeText != null && props.badgeText!.isNotEmpty)
          PositionedDirectional(
            top: 20,
            end: 20,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: props.secondaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: props.secondaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                props.badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductContent extends StatelessWidget {
  final _FeaturedProductProps props;
  final bool isCentered;
  const _ProductContent({required this.props, this.isCentered = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: props.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            props.price,
            style: TextStyle(
              color: props.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          props.name,
          style: AppTypography.h1.copyWith(
            color: props.textColor,
            fontSize: props.isMobile ? 32 : 48,
            fontWeight: FontWeight.w900,
          ),
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 16),
        Text(
          props.description,
          style: AppTypography.bodyLarge.copyWith(
            color: props.subTextColor,
            height: 1.6,
          ),
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: props.isMobile ? double.infinity : null,
          child: ElevatedButton(
            onPressed: () {
              final cartCubit = context.read<CartCubit>();
              if (props.whatsappNumber != null) {
                cartCubit.setWhatsappNumber(props.whatsappNumber!);
              }
              cartCubit.addItem(props.block);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: props.secondaryColor,
              foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              props.buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
