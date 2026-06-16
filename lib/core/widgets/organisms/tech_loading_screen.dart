import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../atoms/custom_loader.dart';

class TechLoadingScreen extends StatelessWidget {
  const TechLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Background for Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Main Logo
                Image.asset(
                  'assets/images/logo.webp',
                  width: 100,
                  height: 100,
                ),
                // Glowing Progress Indicator
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48),
            const CustomLoader(size: 24),
          ],
        ),
      ),
    );
  }
}
