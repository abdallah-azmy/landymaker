/// Trust Logos Section — shows brand/partner logos below the Hero.
/// Builds trust quickly. Uses RepaintBoundary for animation isolation.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';

class HomeTrustLogos extends StatefulWidget {
  final bool isVisible;

  const HomeTrustLogos({super.key, required this.isVisible});

  @override
  State<HomeTrustLogos> createState() => _HomeTrustLogosState();
}

class _HomeTrustLogosState extends State<HomeTrustLogos>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  static const _brands = [
    _BrandData(name: 'Zara', icon: Icons.shopping_bag_rounded),
    _BrandData(name: 'Noon', icon: Icons.storefront_rounded),
    _BrandData(name: 'Careem', icon: Icons.directions_car_rounded),
    _BrandData(name: 'Talabat', icon: Icons.fastfood_rounded),
    _BrandData(name: 'Namshi', icon: Icons.checkroom_rounded),
    _BrandData(name: 'Jumia', icon: Icons.local_mall_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(HomeTrustLogos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = HomeBreakpoint.isMobile(constraints.maxWidth);
      return FadeTransition(
        opacity: _fade,
        child: Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.symmetric(
            vertical: isMobile ? 32 : 48,
            horizontal: 24,
          ),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Text(
                    'يثق بنا آلاف الأعمال في المنطقة العربية',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isMobile ? 20 : 40,
                    runSpacing: 16,
                    children: _brands.map((b) => _BrandChip(brand: b)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _BrandData {
  final String name;
  final IconData icon;
  const _BrandData({required this.name, required this.icon});
}

class _BrandChip extends StatefulWidget {
  final _BrandData brand;
  const _BrandChip({required this.brand});

  @override
  State<_BrandChip> createState() => _BrandChipState();
}

class _BrandChipState extends State<_BrandChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        opacity: _hovered ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.brand.icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              widget.brand.name,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
