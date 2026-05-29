import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CustomLogoHeaderWidget extends StatelessWidget {
  final String title;
  final String? logoUrl;
  final double logoHeight;
  final String alignment;

  const CustomLogoHeaderWidget({
    super.key,
    required this.title,
    this.logoUrl,
    this.logoHeight = 40.0,
    this.alignment = 'center',
  });

  @override
  Widget build(BuildContext context) {
    MainAxisAlignment mainAxisAlignment;
    CrossAxisAlignment crossAxisAlignment;
    TextAlign textAlign;

    switch (alignment) {
      case 'left':
        mainAxisAlignment = MainAxisAlignment.start;
        crossAxisAlignment = CrossAxisAlignment.start;
        textAlign = TextAlign.left;
        break;
      case 'right':
        mainAxisAlignment = MainAxisAlignment.end;
        crossAxisAlignment = CrossAxisAlignment.end;
        textAlign = TextAlign.right;
        break;
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        crossAxisAlignment = CrossAxisAlignment.center;
        textAlign = TextAlign.center;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              if (logoUrl != null && logoUrl!.isNotEmpty)
                Image.network(logoUrl!, height: logoHeight, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
              if (logoUrl != null && logoUrl!.isNotEmpty && title.isNotEmpty)
                const SizedBox(width: 12),
              if (title.isNotEmpty)
                Text(title, style: AppTypography.h3.copyWith(fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }
}
