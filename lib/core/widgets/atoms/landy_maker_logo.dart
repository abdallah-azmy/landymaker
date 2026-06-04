import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

class LandyMakerLogo extends StatelessWidget {
  final double fontSize;

  const LandyMakerLogo({
    super.key,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
  }
}
