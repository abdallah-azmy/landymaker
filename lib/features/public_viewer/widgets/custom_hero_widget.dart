import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';

class CustomHeroWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;

  const CustomHeroWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.cardBg.withOpacity(0.4),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ResponsiveLayout(
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildTextContent(context, isRtl, CrossAxisAlignment.start),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 5,
                  child: _buildHeroImage(),
                ),
              ],
            ),
            mobile: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTextContent(context, isRtl, CrossAxisAlignment.center),
                const SizedBox(height: 40),
                _buildHeroImage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isRtl, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Premium accent tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1),
          ),
          child: Text(
            isRtl ? "شريك نجاحك الرقمي" : "Your Digital Partner",
            style: AppTypography.caption.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: isRtl ? 0 : 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: AppTypography.h1.copyWith(
            height: 1.2,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppColors.textPrimary, AppColors.secondary],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
            height: 1.6,
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: AppColors.secondary.withOpacity(0.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                buttonText,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isRtl ? Icons.arrow_back : Icons.arrow_forward,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300,
              color: AppColors.cardBg,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              color: AppColors.cardBg,
              child: const Icon(
                Icons.image_not_supported_rounded,
                color: AppColors.textSecondary,
                size: 64,
              ),
            );
          },
        ),
      ),
    );
  }
}
