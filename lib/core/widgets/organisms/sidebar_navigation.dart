import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_cubit.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../localization/localization_cubit.dart';
import '../molecules/website_switcher.dart';
import '../../../features/dashboard/controllers/active_website_cubit.dart';

class SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool isAdmin;
  final String userEmail;
  final VoidCallback onLogout;
  final List<Map<String, dynamic>>? menuItemsOverride;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.isAdmin,
    required this.userEmail,
    required this.onLogout,
    this.menuItemsOverride,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final activeSiteType = context
        .watch<ActiveWebsiteCubit>()
        .state
        .websiteType;

    // List of menu configurations (If no override, use default)
    List<Map<String, dynamic>> menuItems =
        menuItemsOverride ??
        [
          {'title_key': 'dashboard', 'icon': Icons.dashboard_rounded},
          {'title_key': 'leads', 'icon': Icons.contacts_rounded},
          {'title_key': 'analytics', 'icon': Icons.analytics_rounded},
          {'title_key': 'hero', 'icon': Icons.construction_rounded}, // Builder
          {'title_key': 'custom_domain_menu', 'icon': Icons.language_rounded},
        ];

    if (menuItemsOverride == null) {
      if (activeSiteType == 'store') {
        menuItems.insert(1, {
          'title_key': 'Products',
          'icon': Icons.inventory_2_rounded,
          'is_store_only': true,
        });
        menuItems.insert(4, {
          'title_key': 'Product Feed',
          'icon': Icons.rss_feed_rounded,
          'is_store_only': true,
        });
      }
      if (isAdmin) {
        menuItems.add({
          'title_key': 'super_admin',
          'icon': Icons.admin_panel_settings_rounded,
        });
      }
    }

    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: loc.isRtl
              ? BorderSide.none
              : const BorderSide(color: AppColors.border, width: 1.5),
          left: loc.isRtl
              ? const BorderSide(color: AppColors.border, width: 1.5)
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo_small.webp',
                height: 32,
                width: 32,
              ),
              const SizedBox(width: 12),
              Text(
                loc.translate('app_title'),
                style: AppTypography.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const WebsiteSwitcher(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final String label = item['is_store_only'] == true
                    ? item['title_key'] as String
                    : loc.translate(item['title_key'] as String);

                final isPremium = item['title_key'] == 'custom_domain_menu';
                final isLocked = item['is_locked'] == true;

                // Sync check: only highlight if the screen index matches
                // For safety when using menuItemsOverride, we rely on the parent's mapping
                // but visually highlight based on current index logic.
                bool isSelected = false;
                if (isLocked != true) {
                  int calcScreenIndex = 0;
                  for (int i = 0; i < index; i++) {
                    if (menuItems[i]['is_locked'] != true) calcScreenIndex++;
                  }
                  isSelected = currentIndex == calcScreenIndex;
                }

                return InkWell(
                  onTap: isLocked ? null : () => onTabSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : (isPremium
                                  ? AppColors.warningOrange.withValues(
                                      alpha: 0.2,
                                    )
                                  : (isLocked
                                        ? AppColors.textMuted.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.transparent)),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: isLocked
                              ? AppColors.textMuted.withValues(alpha: 0.5)
                              : (isSelected
                                    ? AppColors.secondary
                                    : (isPremium
                                          ? AppColors.warningOrange
                                          : AppColors.textSecondary)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            label,
                            style: AppTypography.bodyLarge.copyWith(
                              color: isLocked
                                  ? AppColors.textMuted.withValues(alpha: 0.5)
                                  : (isSelected
                                        ? AppColors.textPrimary
                                        : (isPremium
                                              ? AppColors.warningOrange
                                              : AppColors.textSecondary)),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isPremium)
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warningOrange,
                          ),
                        if (isLocked)
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 12,
                            color: AppColors.textMuted.withValues(alpha: 0.4),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: AppColors.border, height: 24, thickness: 1.2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => loc.toggleLanguage(),
                icon: const Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                label: Text(
                  loc.translate('switch_language'),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.dangerRed,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userEmail,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isAdmin)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.activeGreen.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "SUPER ADMIN",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.activeGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                BlocBuilder<LandingPagesCubit, LandingPagesState>(
                  builder: (context, state) {
                    if (state is LandingPagesLoaded) {
                      final usage = state.pages.length / state.maxPages;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Usage",
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                isAdmin
                                    ? "${state.pages.length} / ${state.maxPages}"
                                    : "${state.pages.length} / ${state.maxPages}",
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: usage,
                              minHeight: 4,
                              backgroundColor: AppColors.border,
                              color: usage >= 1.0
                                  ? AppColors.dangerRed
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
