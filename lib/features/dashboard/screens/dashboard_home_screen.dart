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

/// ======================================================
/// FEATURE: Dashboard Home Screen
/// PURPOSE: Main overview screen for the user dashboard showing analytics, active pages, and upgrade options.
/// ARCHITECTURE: State is hoisted to [DashboardHomeScreen]. 
/// Renders [_DesktopDashboardHome] or [_MobileDashboardHome] based on width.
/// ======================================================
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<LandingPagesCubit, LandingPagesState>(
        builder: (context, state) {
          if (state is LandingPagesLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),
            );
          }
          if (state is LandingPagesLoaded) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = ResponsiveLayout.isMobile(context, width: constraints.maxWidth);

                if (isMobile) {
                  return _MobileDashboardHome(
                    state: state,
                    onOpenBuilder: widget.onOpenBuilder,
                    showCreatePageModal: () => _showCreatePageModal(context),
                    showUpgradeModal: (plan, price, userId) => 
                        _showUpgradeModal(context, plan, price, userId),
                  );
                }

                return _DesktopDashboardHome(
                  state: state,
                  onOpenBuilder: widget.onOpenBuilder,
                  showCreatePageModal: () => _showCreatePageModal(context),
                  showUpgradeModal: (plan, price, userId) => 
                      _showUpgradeModal(context, plan, price, userId),
                );
              },
            );
          }
          if (state is LandingPagesFailure) {
            return Center(
              child: Text(
                state.message,
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}

/// Desktop version of the Dashboard Home.
class _DesktopDashboardHome extends StatelessWidget {
  final LandingPagesLoaded state;
  final Function(String) onOpenBuilder;
  final VoidCallback showCreatePageModal;
  final Function(String, double, String) showUpgradeModal;

  const _DesktopDashboardHome({
    required this.state,
    required this.onOpenBuilder,
    required this.showCreatePageModal,
    required this.showUpgradeModal,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final pages = state.pages;
    final totalViews = pages.fold<int>(0, (sum, p) => sum + (p['views_count'] as int? ?? 0));
    final totalLeads = pages.fold<int>(0, (sum, p) => sum + (p['purchases_count'] as int? ?? 0));

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<LandingPagesCubit>().loadPages(),
      child: SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(loc: loc, state: state, isMobile: false),
          SizedBox(height: 24),
          AnalyticsOverviewWidget(
            totalViews: totalViews,
            totalLeads: totalLeads,
          ),
          SizedBox(height: 20),
          if (state.currentTier == 'free' && pages.isNotEmpty)
            _UpgradeCard(
              userId: pages.first['user_id'],
              showUpgradeModal: showUpgradeModal,
              isMobile: false,
            ),
          SizedBox(height: 32),
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
                onPressed: showCreatePageModal,
                width: 200,
              ),
            ],
          ),
          SizedBox(height: 16),
          pages.isEmpty ? _EmptyState(loc: loc) : _PagesList(pages: pages, onOpenBuilder: onOpenBuilder),
        ],
      ),
      ),
    );
  }
}

/// Mobile version of the Dashboard Home.
class _MobileDashboardHome extends StatelessWidget {
  final LandingPagesLoaded state;
  final Function(String) onOpenBuilder;
  final VoidCallback showCreatePageModal;
  final Function(String, double, String) showUpgradeModal;

  const _MobileDashboardHome({
    required this.state,
    required this.onOpenBuilder,
    required this.showCreatePageModal,
    required this.showUpgradeModal,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final pages = state.pages;
    final totalViews = pages.fold<int>(0, (sum, p) => sum + (p['views_count'] as int? ?? 0));
    final totalLeads = pages.fold<int>(0, (sum, p) => sum + (p['purchases_count'] as int? ?? 0));

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<LandingPagesCubit>().loadPages(),
      child: SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(loc: loc, state: state, isMobile: true),
          SizedBox(height: 24),
          AnalyticsOverviewWidget(
            totalViews: totalViews,
            totalLeads: totalLeads,
          ),
          SizedBox(height: 20),
          if (state.currentTier == 'free' && pages.isNotEmpty)
            _UpgradeCard(
              userId: pages.first['user_id'],
              showUpgradeModal: showUpgradeModal,
              isMobile: true,
            ),
          SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('your_landing_pages'),
                style: AppTypography.h3,
              ),
              SizedBox(height: 12),
              PrimaryButton(
                text: loc.translate('create_new_page'),
                icon: Icons.add_rounded,
                onPressed: showCreatePageModal,
                width: double.infinity,
              ),
            ],
          ),
          SizedBox(height: 16),
          pages.isEmpty ? _EmptyState(loc: loc) : _PagesList(pages: pages, onOpenBuilder: onOpenBuilder),
        ],
      ),
      ),
    );
  }
}

/// Shared Header for both layouts.
class _DashboardHeader extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPagesLoaded state;
  final bool isMobile;

  const _DashboardHeader({
    required this.loc,
    required this.state,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    tier.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${state.pages.length} / ${state.maxPages} ${loc.translate('active_pages')}",
                  style: AppTypography.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          loc.translate('track_performance_msg'),
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Shared Upgrade Card.
class _UpgradeCard extends StatelessWidget {
  final String userId;
  final Function(String, double, String) showUpgradeModal;
  final bool isMobile;

  const _UpgradeCard({
    required this.userId,
    required this.showUpgradeModal,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocalizationCubit>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      loc.translate('upgrade_to_pro'),
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  loc.translate('upgrade_msg'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => showUpgradeModal("Pro", 299.0, userId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      loc.translate('upgrade_now'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.white, size: 40),
                SizedBox(width: 24),
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
                SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () => showUpgradeModal("Pro", 299.0, userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    loc.translate('upgrade_now'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Shared Empty State.
class _EmptyState extends StatelessWidget {
  final LocalizationCubit loc;

  const _EmptyState({required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_motion_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(loc.translate('no_pages_created'), style: AppTypography.h3),
          SizedBox(height: 8),
          Text(
            loc.translate('start_building_msg'),
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Shared Pages List.
class _PagesList extends StatelessWidget {
  final List<Map<String, dynamic>> pages;
  final Function(String) onOpenBuilder;

  const _PagesList({required this.pages, required this.onOpenBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pages.length,
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final page = pages[index];
        return _PageItemCard(page: page, onOpenBuilder: onOpenBuilder);
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
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => widget.onOpenBuilder(page['id']),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _PageAvatar(isActive: isActive, isPublished: isPublished),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page['subdomain'] ?? "Unnamed Page",
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        _CopyableUrlWidget(
                          url: "https://landymaker.com/${page['subdomain'] ?? 'landymaker.com'}",
                          subdomain: page['subdomain'] ?? '',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildPublishToggle(page['id'], isPublished, isActive),
                  SizedBox(width: 16),
                  _EditButton(onPressed: () => widget.onOpenBuilder(page['id'])),
                ],
              ),
            ),
          ),
          if (_isLoading)
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
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
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.error),
        ),
        child: Text(
          "معطلة",
          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 10, fontWeight: FontWeight.bold),
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
            activeThumbColor: Colors.green,
            onChanged: _isLoading
                ? null
                : (val) async {
                    setState(() => _isLoading = true);
                    await context.read<LandingPagesCubit>().togglePublishStatus(pageId, val);
                    if (mounted) setState(() => _isLoading = false);
                  },
          ),
        ),
        Text(
          isPublished ? "نشط" : "غير نشط",
          style: TextStyle(
            color: isPublished ? Colors.green : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PageAvatar extends StatelessWidget {
  final bool isActive;
  final bool isPublished;

  const _PageAvatar({required this.isActive, required this.isPublished});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.language_rounded, color: Theme.of(context).colorScheme.primary),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: !isActive
                  ? Theme.of(context).colorScheme.error
                  : (isPublished ? Colors.green : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
      ),
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
    ToastService.showSuccess(context, message: loc.translate('link_copied_success'));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            onTap: () => html.window.open('/${widget.subdomain}', '_blank'),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                widget.url,
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
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
                color: _isCopied ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
