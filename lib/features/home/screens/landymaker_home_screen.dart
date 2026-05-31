import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        onLoginPressed: () => context.go('/login'),
        onGetStartedPressed: () => context.go('/register'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeroSection(onGetStartedPressed: () => context.go('/login')),
            const HomeFeatureBento(),
            HomeTemplateStrip(
              onGetStartedPressed: (templateId) {
                TenantRoutingService.pendingTemplateId = templateId;
                context.go('/login');
              },
            ),
            const HomeFooter(),
          ],
        ),
      ),
    );
  }
}
