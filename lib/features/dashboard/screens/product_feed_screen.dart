import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/core/localization/localization_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/glass_container.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../../services/subscription_service.dart';
import '../../../../services/auth_service.dart';
import '../../../injection_container.dart';
import '../../subscription/widgets/manual_payment_modal.dart';
import '../controllers/active_website_cubit.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';
import '../../../core/widgets/molecules/page_context_banner.dart';
import '../widgets/empty_workspace_state.dart';

class ProductFeedScreen extends StatelessWidget {
  const ProductFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product Feed Sync", style: AppTypography.h1),
              const SizedBox(height: 8),
              Text(
                "Sync your products automatically with Google Shopping, Facebook, and Instagram.",
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const PageContextBanner(
                title: "مزامنة المنتجات (Product Feed)",
                description: "التحكم في مزامنة منتجات متجرك الإلكتروني الحالي مع المنصات الإعلانية مثل Google و Facebook.",
                icon: Icons.rss_feed_rounded,
              ),
              const SizedBox(height: 24),

              if (isLoadingAccess)
                const Center(child: CircularProgressIndicator())
              else if (!hasPremiumAccess)
                _buildUpgradeRequiredState(context, loc)
              else
                _buildFeedContent(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradeRequiredState(
    BuildContext context,
    LocalizationCubit loc,
  ) {
    final userId = sl<AuthService>().currentUserId!;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.lock_rounded,
              size: 64,
              color: AppColors.warningOrange,
            ),
            const SizedBox(height: 24),
            Text(
              "ميزة مزامنة المنتجات متاحة فقط للمشتركين في باقة برو",
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "قم بتصدير منتجاتك آلياً إلى Google Shopping و Facebook لتحقيق مبيعات أكثر.",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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

  Widget _buildFeedContent(BuildContext context) {
    return BlocBuilder<ActiveWebsiteCubit, ActiveWebsiteState>(
      builder: (context, state) {
        final websiteId = state.websiteId;
        final token = state.feedToken;

        // Edge function URL (should be from config ideally)
        const baseUrl =
            "https://zajcnkpcdsvswfmsmqpt.supabase.co/functions/v1/generate-product-feed";
        final feedUrl = "$baseUrl?website_id=$websiteId&token=$token";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),

            Text("Your Feed URL", style: AppTypography.h3),
            const SizedBox(height: 12),
            _buildUrlField(context, feedUrl),

            const SizedBox(height: 40),
            _buildStepsSection(),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rss_feed_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("What is a Product Feed?", style: AppTypography.h3),
                const SizedBox(height: 4),
                Text(
                  "It's a dynamic file that contains all your product data. Major platforms use this URL to keep your product listings updated in real-time.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField(BuildContext context, String url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              url,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          PrimaryButton(
            text: "Copy",
            width: 100,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feed URL copied to clipboard")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Supported Platforms", style: AppTypography.h3),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildPlatformChip(
              "Google Shopping",
              Icons.shopping_basket_rounded,
            ),
            _buildPlatformChip("Facebook Commerce", Icons.facebook_rounded),
            _buildPlatformChip("Instagram Shop", Icons.camera_alt_rounded),
            _buildPlatformChip("TikTok Catalog", Icons.music_note_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformChip(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(name, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
