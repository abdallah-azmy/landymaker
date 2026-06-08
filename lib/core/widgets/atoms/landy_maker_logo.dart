import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_typography.dart';

class LandyMakerLogo extends StatelessWidget {
  final double fontSize;
  final bool isClickable;

  const LandyMakerLogo({
    super.key,
    this.fontSize = 22,
    this.isClickable = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Landy',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Maker',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00E5FF),
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );

    if (!isClickable) return logo;

    return InkWell(
      onTap: () => context.go('/'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: logo,
      ),
    );
  }
}
