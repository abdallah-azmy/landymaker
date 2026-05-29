import 'package:flutter/material.dart';
import '../../../features/auth/screens/login_screen.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/home_navbar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_feature_bento.dart';
import '../widgets/home_template_strip.dart';
import '../widgets/home_footer.dart';

class LandyMakerHomeScreen extends StatelessWidget {
  const LandyMakerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeNavbar(
        onLoginPressed: () => _navigateToLogin(context),
        onGetStartedPressed: () => _navigateToLogin(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeroSection(
              onGetStartedPressed: () => _navigateToLogin(context),
            ),
            const HomeFeatureBento(),
            HomeTemplateStrip(
              onGetStartedPressed: (templateId) {
                TenantRoutingService.pendingTemplateId = templateId;
                _navigateToLogin(context);
              },
            ),
            const HomeFooter(),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onLoginSuccess: () {
            Navigator.of(context).pop(); // pop login screen so root router handles auth state
          },
        ),
      ),
    );
  }
}
