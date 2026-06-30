import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/atoms/glass_container.dart';
import '../../../core/widgets/block_animation_wrapper.dart';
import '../../builder/models/landing_page_theme.dart';
import '../controllers/cart_cubit.dart';

/// ======================================================
/// FEATURE: Bento Store Widget
/// PURPOSE: A modern, non-uniform grid layout for products.
/// ======================================================
class BentoStoreWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;
  final String? whatsappNumber;

  const BentoStoreWidget({
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
    final items = List<Map<String, dynamic>>.from(block['items'] ?? []);
    final layoutStyle = block['layout_style'] as String? ?? 'modern';
    final bool stagger = block['stagger_animations'] ?? true;
    final String hoverEffect = block['hover_effect'] ?? 'scale';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        final bool isTablet = constraints.maxWidth < 1100 && !isMobile;
        final double paddingValue = (block['vertical_padding'] as num?)?.toDouble() ?? (isMobile ? 40 : 80);

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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  if (block['title'] != null) ...[
                    Text(
                      block['title'],
                      style: AppTypography.h2.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 48),
                  ],
                  _buildBentoGrid(context, items, isMobile, isTablet, secondaryColor, textColor, subTextColor, layoutStyle, stagger, hoverEffect),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBentoGrid(
    BuildContext context,
    List<Map<String, dynamic>> items,
    bool isMobile,
    bool isTablet,
    Color secondary,
    Color textColor,
    Color subTextColor,
    String layoutStyle,
    bool stagger,
    String hoverEffect,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    final double spacing = layoutStyle == 'tight' ? 8 : 20;

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (context, index) {
          final itemWidget = _BentoItem(
            item: items[index],
            secondary: secondary,
            textColor: textColor,
            subTextColor: subTextColor,
            isLarge: false,
            theme: theme,
            whatsappNumber: whatsappNumber,
            layoutStyle: layoutStyle,
            hoverEffect: hoverEffect,
          );
          if (stagger) {
            return BlockAnimationWrapper(
              settings: BlockAnimationSettings(
                type: BlockAnimationType.slideUp,
                delay: Duration(milliseconds: 100 * index),
                duration: const Duration(milliseconds: 600),
              ),
              child: itemWidget,
            );
          }
          return itemWidget;
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final bool isLarge = !isMobile && (index == 0 || index == 4);
        final itemWidget = _BentoItem(
          item: items[index],
          secondary: secondary,
          textColor: textColor,
          subTextColor: subTextColor,
          isLarge: isLarge,
          theme: theme,
          whatsappNumber: whatsappNumber,
          layoutStyle: layoutStyle,
          hoverEffect: hoverEffect,
        );
        if (stagger) {
          return BlockAnimationWrapper(
            settings: BlockAnimationSettings(
              type: BlockAnimationType.slideUp,
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 600),
            ),
            child: itemWidget,
          );
        }
        return itemWidget;
      },
    );
  }
}

class _BentoItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color secondary;
  final Color textColor;
  final Color subTextColor;
  final bool isLarge;
  final LandingPageTheme? theme;
  final String? whatsappNumber;
  final String layoutStyle;
  final String hoverEffect;

  const _BentoItem({
    required this.item,
    required this.secondary,
    required this.textColor,
    required this.subTextColor,
    required this.isLarge,
    this.theme,
    this.whatsappNumber,
    required this.layoutStyle,
    required this.hoverEffect,
  });

  @override
  State<_BentoItem> createState() => _BentoItemState();
}

class _BentoItemState extends State<_BentoItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String name = widget.item['name'] ?? 'منتج';
    final String price = widget.item['price'] ?? '0.00';
    final String imageUrl = widget.item['image_url'] ?? '';
    final double borderRadius = widget.layoutStyle == 'tight' ? 12 : 24;

    final bool applyScale = _isHovered && widget.hoverEffect == 'scale';
    final bool applyElevate = _isHovered && widget.hoverEffect == 'elevate';
    final bool applyGlow = _isHovered && widget.hoverEffect == 'glow';

    Widget content = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: applyScale ? (Matrix4.identity()..scale(1.03, 1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.subTextColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: applyGlow 
              ? widget.secondary 
              : widget.subTextColor.withValues(alpha: 0.1)
          ),
          boxShadow: (applyElevate || applyGlow) ? [
            BoxShadow(
              color: widget.secondary.withValues(alpha: applyGlow ? 0.4 : 0.2),
              blurRadius: applyGlow ? 15 : 20,
              spreadRadius: applyGlow ? 2 : 0,
              offset: applyGlow ? Offset.zero : const Offset(0, 10),
            )
          ] : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 20,
              start: 20,
              end: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: widget.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final cartCubit = context.read<CartCubit>();
                      if (widget.whatsappNumber != null) {
                        cartCubit.setWhatsappNumber(widget.whatsappNumber!);
                      }
                      cartCubit.addItem(widget.item);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.secondary,
                      foregroundColor: widget.theme?.buttonTextColor ?? Colors.white,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "إضافة للسلة",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.layoutStyle == 'glass') {
      return GlassContainer(
        borderRadius: borderRadius,
        child: content,
      );
    }

    return content;
  }
}
