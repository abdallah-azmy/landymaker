import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/injection_container.dart';
import 'package:landymaker/services/auth_service.dart';
import 'package:landymaker/services/subscription_service.dart';

import '../../../core/localization/localization_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/glass_container.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/molecules/website_switcher.dart';
import '../../../core/widgets/molecules/page_context_banner.dart';
import '../../subscription/widgets/manual_payment_modal.dart';
import '../controllers/active_website_cubit.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';
import '../widgets/domain_setup_widget.dart';
import '../widgets/empty_workspace_state.dart';
import '../../../core/widgets/particles/loading_logo_modified.dart';

class DomainSettingsScreen extends StatelessWidget {
  const DomainSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final activeState = context.watch<ActiveWebsiteCubit>().state;
    final pagesState = context.watch<LandingPagesCubit>().state;

    if (pagesState is LandingPagesLoaded && pagesState.pages.isEmpty) {
      return const EmptyWorkspaceState();
    }

    return FutureBuilder<bool>(
      future: sl<SubscriptionService>().canAccessPremiumFeatures(
        sl<AuthService>().currentUserId!,
      ),
      builder: (context, snapshot) {
        final bool hasPremiumAccess = snapshot.data ?? false;
        final bool isLoadingAccess =
            snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageContextBanner(
                  title: "إعدادات الدومين",
                  description: "يمكنك من هنا ربط صفحة الهبوط الحالية بدومين احترافي خاص بعلامتك التجارية لتزيد من ثقة عملائك.",
                  icon: Icons.language_rounded,
                ),
                SizedBox(height: 24),

                if (isLoadingAccess)
                  const Center(child: LoadingLogo())
                else if (activeState.website == null)
                  _buildNoSelectionState(context, loc)
                else if (!hasPremiumAccess)
                  _buildUpgradeRequiredState(
                    context,
                    loc,
                    sl<AuthService>().currentUserId!,
                  )
                else
                  _buildDomainManagementWorkspace(context, loc, activeState),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoSelectionState(BuildContext context, LocalizationCubit loc) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 24),
            Text(
              "يرجى اختيار الصفحة التي تريد تخصيص نطاق مستقل لها أولاً",
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(width: 300, child: WebsiteSwitcher()),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeRequiredState(
    BuildContext context,
    LocalizationCubit loc,
    String userId,
  ) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.lock_rounded,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 24),
            Text(
              "ميزة النطاقات الخاصة متاحة فقط للمشتركين في باقة برو",
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "اربط موقعك بدومين خاص مثل (yourbrand.com) لتعزيز احترافية علامتك التجارية.",
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            PrimaryButton(
              text: "اشترك الآن في باقة برو",
              icon: Icons.star_rounded,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ManualPaymentModal(
                    planName: "Pro",
                    price: 299.0,
                    userId: userId,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainManagementWorkspace(
    BuildContext context,
    LocalizationCubit loc,
    ActiveWebsiteState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.language_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إعدادات الدومين لصفحة: ${state.subdomain}",
                  style: AppTypography.h3,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 40),
        const DomainSetupWidget(),
      ],
    );
  }
}
