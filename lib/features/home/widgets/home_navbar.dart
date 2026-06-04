import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onGetStartedPressed;

  const HomeNavbar({
    super.key,
    required this.onLoginPressed,
    required this.onGetStartedPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.7),
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Landy",
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "Maker",
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00E5FF),
                              fontSize: 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        'assets/images/logo_small.webp',
                        height: 38,
                        width: 38,
                      ),
                    ],
                  ),

                  // Menu / Actions
                  Row(
                    children: [
                      TextButton(
                        onPressed: onLoginPressed,
                        child: Text(
                          "تسجيل الدخول",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: onGetStartedPressed,
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ).copyWith(
                              shadowColor: WidgetStateProperty.all(
                                AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                        child: Text(
                          "ابدأ مجاناً",
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
