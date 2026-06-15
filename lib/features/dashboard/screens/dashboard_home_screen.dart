import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../subscription/widgets/manual_payment_modal.dart';
import '../widgets/create_page_modal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../widgets/analytics_overview_widget.dart';
import '../controllers/landing_pages_cubit.dart';
import '../controllers/landing_pages_state.dart';
import '../../../core/utils/toast_service.dart';

class DashboardHomeScreen extends StatefulWidget {
  final Function(String) onOpenBuilder;
  const DashboardHomeScreen({super.key, required this.onOpenBuilder});
  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  void _showCreatePageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CreatePageModal(onPageCreated: () => widget.onOpenBuilder('new')),
    );
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
            return _buildContent(context, loc, state);
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
    LandingPagesLoaded state,
  ) {
    final pages = state.pages;
    final totalViews = pages.fold<int>(
      0,
      (sum, p) => sum + (p['views_count'] as int? ?? 0),
    );
    final totalLeads = pages.fold<int>(
      0,
      (sum, p) => sum + (p['purchases_count'] as int? ?? 0),
    );

    // Aggregate stats from pages list; uniqueVisitors fetched via LeadsAnalyticsCubit.

    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(loc, state, isMobile),
          const SizedBox(height: 32),
          AnalyticsOverviewWidget(
            totalViews: totalViews,
            totalLeads: totalLeads,
          ),
          const SizedBox(height: 24),
          if (state.currentTier == 'free' && pages.isNotEmpty)
            _buildUpgradeCard(context, state.pages.first['user_id'], isMobile),
          const SizedBox(height: 40),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('your_landing_pages'),
                  style: AppTypography.h3,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: loc.translate('create_new_page'),
                  icon: Icons.add_rounded,
                  onPressed: () => _showCreatePageModal(context),
                  width: double.infinity,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('your_landing_pages'),
                  style: AppTypography.h2,
                ),
                PrimaryButton(
                  text: loc.translate('create_new_page'),
                  icon: Icons.add_rounded,
                  onPressed: () => _showCreatePageModal(context),
                  width: 200,
                ),
              ],
            ),
          const SizedBox(height: 20),
          pages.isEmpty ? _buildEmptyState(loc) : _buildPagesList(pages),
        ],
      ),
    );
  }

  Widget _buildHeader(LocalizationCubit loc, LandingPagesLoaded state, bool isMobile) {
    final tier = state.currentTier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.translate('dashboard'),
              style: AppTypography.h1.copyWith(fontSize: isMobile ? 28 : 32),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    tier.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${state.pages.length} / ${state.maxPages} ${loc.translate('active_pages')}",
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          loc.translate('track_performance_msg'),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeCard(BuildContext context, String userId, bool isMobile) {
    final loc = context.read<LocalizationCubit>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc.translate('upgrade_to_pro'),
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.translate('upgrade_msg'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        _showUpgradeModal(context, "Pro", 299.0, userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      loc.translate('upgrade_now'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('upgrade_to_pro'),
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                      Text(
                        loc.translate('upgrade_msg'),
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () =>
                      _showUpgradeModal(context, "Pro", 299.0, userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc.translate('upgrade_now'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(LocalizationCubit loc) {
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
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(loc.translate('no_pages_created'), style: AppTypography.h3),
          const SizedBox(height: 8),
          Text(
            loc.translate('start_building_msg'),
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
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
        return _PageItemCard(page: page, onOpenBuilder: widget.onOpenBuilder);
      },
    );
  }
}

class _PageItemCard extends StatefulWidget {
  final Map<String, dynamic> page;
  final Function(String) onOpenBuilder;

  const _PageItemCard({required this.page, required this.onOpenBuilder});

  @override
  State<_PageItemCard> createState() => _PageItemCardState();
}

class _PageItemCardState extends State<_PageItemCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final bool isPublished = page['is_published'] ?? false;
    final bool isActive = page['is_active'] ?? true;


    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.cardBg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              widget.onOpenBuilder(page['id']);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.language_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: !isActive
                                ? AppColors.dangerRed
                                : (isPublished
                                      ? AppColors.activeGreen
                                      : AppColors.textMuted),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cardBg,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        _CopyableUrlWidget(
                          url:
                              "https://landymaker.com/${page['subdomain'] ?? 'landymaker.com'}",
                          subdomain: page['subdomain'] ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPublishToggle(page['id'], isPublished, isActive),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      widget.onOpenBuilder(page['id']);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildPublishToggle(String pageId, bool isPublished, bool isActive) {
    if (!isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.dangerRed),
        ),
        child: const Text(
          "معطلة",
          style: TextStyle(
            color: AppColors.dangerRed,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isPublished,
            activeThumbColor: AppColors.activeGreen,
            onChanged: _isLoading
                ? null
                : (val) async {
                    setState(() => _isLoading = true);
                    await context.read<LandingPagesCubit>().togglePublishStatus(
                      pageId,
                      val,
                    );
                    if (mounted) setState(() => _isLoading = false);
                  },
          ),
        ),
        Text(
          isPublished ? "نشط" : "غير نشط",
          style: TextStyle(
            color: isPublished ? AppColors.activeGreen : AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CopyableUrlWidget extends StatefulWidget {
  final String url;
  final String subdomain;

  const _CopyableUrlWidget({required this.url, required this.subdomain});

  @override
  State<_CopyableUrlWidget> createState() => _CopyableUrlWidgetState();
}

class _CopyableUrlWidgetState extends State<_CopyableUrlWidget> {
  bool _isCopied = false;

  void _copyToClipboard(BuildContext context) {
    final loc = context.read<LocalizationCubit>();
    Clipboard.setData(ClipboardData(text: widget.url));
    setState(() => _isCopied = true);
    ToastService.showSuccess(
      context,
      message: loc.translate('link_copied_success'),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: () {
              html.window.open('/${widget.subdomain}', '_blank');
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                widget.url,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _copyToClipboard(context),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                key: ValueKey(_isCopied),
                size: 16,
                color: _isCopied
                    ? AppColors.activeGreen
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
