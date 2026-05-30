import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../subscription/widgets/manual_payment_modal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/molecules/page_stat_card.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';
import '../../builder/controllers/builder_cubit.dart';

class DashboardHomeScreen extends StatefulWidget {
  final VoidCallback onOpenBuilder;
  const DashboardHomeScreen({super.key, required this.onOpenBuilder});
  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LandingPagesCubit>().loadPages();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<LandingPagesCubit, LandingPagesState>(
        builder: (context, state) {
          if (state is LandingPagesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          if (state is LandingPagesLoaded) {
            return _buildContent(context, loc, state.pages);
          }
          if (state is LandingPagesFailure) {
            return Center(
              child: Text(
                state.message,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.dangerRed,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showUpgradeModal(
    BuildContext context,
    String plan,
    double price,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ManualPaymentModal(planName: plan, price: price, userId: userId),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LocalizationCubit loc,
    List<Map<String, dynamic>> pages,
  ) {
    final state = context.read<LandingPagesCubit>().state as LandingPagesLoaded;
    final totalViews = pages.fold<int>(
      0,
      (sum, p) => sum + (p['views_count'] as int? ?? 0),
    );
    final totalLeads = pages.fold<int>(
      0,
      (sum, p) => sum + (p['purchases_count'] as int? ?? 0),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(loc, state.currentTier),
          const SizedBox(height: 32),
          _buildStatsOverview(totalViews, totalLeads),
          const SizedBox(height: 24),
          if (state.currentTier == 'free')
            _buildUpgradeCard(context, state.pages.first['user_id']),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Your Landing Pages", style: AppTypography.h2),
              PrimaryButton(
                text: "Create New Page",
                icon: Icons.add_rounded,
                onPressed: () {
                  // Initialize builder with empty/new state
                  context.read<LandingPageBuilderCubit>().loadPageForUser(
                    "",
                  ); // Triggers new page flow
                  widget.onOpenBuilder();
                },
                width: 180,
              ),
            ],
          ),
          const SizedBox(height: 20),
          pages.isEmpty ? _buildEmptyState() : _buildPagesList(pages),
        ],
      ),
    );
  }

  Widget _buildHeader(LocalizationCubit loc, String tier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('dashboard'),
                style: AppTypography.h1.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                "Track performance and manage your active landing pages.",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            "Tier: ${tier.toUpperCase()}",
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(BuildContext context, String userId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upgrade to Pro",
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                Text(
                  "Get 5 landing pages, custom domains, and more.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () => _showUpgradeModal(context, "Pro", 299.0, userId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Upgrade Now",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(int views, int leads) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        SizedBox(
          width: 280,
          child: PageStatCard(
            title: "Total Page Views",
            value: views.toString(),
            icon: Icons.visibility_rounded,
            color: AppColors.secondary,
          ),
        ),
        SizedBox(
          width: 280,
          child: PageStatCard(
            title: "Total Conversions",
            value: leads.toString(),
            icon: Icons.shopping_bag_rounded,
            color: AppColors.activeGreen,
          ),
        ),
        SizedBox(
          width: 280,
          child: PageStatCard(
            title: "Avg. Conversion Rate",
            value: views == 0
                ? "0%"
                : "${((leads / views) * 100).toStringAsFixed(1)}%",
            icon: Icons.analytics_rounded,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_motion_rounded,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text("No pages created yet", style: AppTypography.h3),
          const SizedBox(height: 8),
          Text(
            "Start building your first high-conversion landing page now.",
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPagesList(List<Map<String, dynamic>> pages) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final page = pages[index];
        return _buildPageItem(page);
      },
    );
  }

  Widget _buildPageItem(Map<String, dynamic> page) {
    final bool isPublished = page['is_published'] ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.language_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page['subdomain'] ?? "Unnamed Page",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Created on ${page['created_at'].toString().split('T').first}",
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          _buildStatusChip(isPublished),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.secondary,
            ),
            onPressed: () {
              context.read<LandingPageBuilderCubit>().loadPageForUser(
                page['user_id'],
              ); // This is wrong, should be pageId but existing logic uses userId. Need to fix later.
              widget.onOpenBuilder();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPublished ? AppColors.activeGreen : AppColors.textMuted)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPublished ? AppColors.activeGreen : AppColors.textMuted,
        ),
      ),
      child: Text(
        isPublished ? "Active" : "Draft",
        style: AppTypography.caption.copyWith(
          color: isPublished ? AppColors.activeGreen : AppColors.textMuted,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
