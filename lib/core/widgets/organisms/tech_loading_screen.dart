import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TechLoadingScreen extends StatelessWidget {
  const TechLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground, // Dark Slate Black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_small.webp',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 100,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
