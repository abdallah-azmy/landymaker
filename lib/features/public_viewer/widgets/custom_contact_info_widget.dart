import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomContactInfoWidget extends StatelessWidget {
  final String title;
  final String? email;
  final String? phone;
  final String? location;
  final LandingPageTheme? theme;

  const CustomContactInfoWidget({
    super.key,
    required this.title,
    this.email,
    this.phone,
    this.location,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = theme?.background ?? AppColors.background;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
          color: bgColor,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 32 : 64),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      if (phone != null && phone!.isNotEmpty)
                        _buildContactCard(Icons.phone_rounded, "Phone", phone!, secondaryColor, textColor, subTextColor, isMobile),
                      if (email != null && email!.isNotEmpty)
                        _buildContactCard(Icons.email_rounded, "Email", email!, secondaryColor, textColor, subTextColor, isMobile),
                      if (location != null && location!.isNotEmpty)
                        _buildContactCard(Icons.location_on_rounded, "Address", location!, secondaryColor, textColor, subTextColor, isMobile),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: secondary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(label, style: AppTypography.caption.copyWith(color: subTextColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
