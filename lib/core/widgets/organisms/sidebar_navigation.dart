import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_cubit.dart';
import 'package:landymaker/features/dashboard/controllers/landing_pages_state.dart';
import 'package:go_router/go_router.dart';
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
    final activeWebsite = context.watch<ActiveWebsiteCubit>().state;
    final activeSiteType = activeWebsite.websiteType;
    final activeSubdomain = activeWebsite.subdomain;

    // Build sections
    final List<Map<String, dynamic>> finalItems = [];

    if (isAdmin && menuItemsOverride == null) {
      finalItems.add({'is_header': true, 'title': 'إدارة المنصة'});
      finalItems.add({
        'title_key': 'super_admin',
        'icon': Icons.admin_panel_settings_rounded,
        'route': '/dashboard/super-admin',
      });
      finalItems.add({
        'title_key': 'إعدادات المنصة (SEO)', // We can hardcode Arabic here or add it to localization. 'Platform SEO' is fine.
        'icon': Icons.travel_explore_rounded,
        'route': '/dashboard/platform-seo',
      });
      finalItems.add({
        'title_key': 'blog_management',
        'icon': Icons.article_rounded,
        'route': '/dashboard/blog-admin',
      });
      finalItems.add({'is_divider': true});
    }

    if (menuItemsOverride != null) {
      finalItems.addAll(menuItemsOverride!);
    } else {
      finalItems.add({'is_header': true, 'title': 'مساحة العمل الخاصة بك'});
      finalItems.add({'is_switcher': true});
      finalItems.add({'title_key': 'dashboard', 'icon': Icons.dashboard_rounded, 'route': '/dashboard'});
      
      if (activeSiteType == 'store') {
        finalItems.add({
          'title_key': 'Products',
          'icon': Icons.inventory_2_rounded,
          'route': '/dashboard/products',
        });
      }

      finalItems.add({'title_key': 'leads', 'icon': Icons.contacts_rounded, 'route': '/dashboard/leads'});
      finalItems.add({'title_key': 'analytics', 'icon': Icons.analytics_rounded, 'route': '/dashboard/analytics'});

      if (activeSiteType == 'store') {
        finalItems.add({
          'title_key': 'Product Feed',
          'icon': Icons.rss_feed_rounded,
          'route': '/dashboard/feed',
        });
      }

      final builderRoute = activeSubdomain != null && activeSubdomain.isNotEmpty 
          ? '/builder/$activeSubdomain' 
          : '/builder';
      finalItems.add({'title_key': 'hero', 'icon': Icons.construction_rounded, 'is_builder': true, 'route': builderRoute});
      finalItems.add({'title_key': 'custom_domain_menu', 'icon': Icons.language_rounded, 'route': '/dashboard/domain'});
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
          Expanded(
            child: ListView.separated(
              itemCount: finalItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = finalItems[index];

                if (item['is_header'] == true) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
                    child: Text(
                      item['title'] as String,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }

                if (item['is_divider'] == true) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: AppColors.border, thickness: 1.2),
                  );
                }

                if (item['is_switcher'] == true) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: WebsiteSwitcher(),
                  );
                }

                final String label = item['title_key'] == 'Platform SEO' || item['title_key'] == 'إعدادات المنصة (SEO)' || item['title_key'] == 'Products' || item['title_key'] == 'Product Feed'
                    ? item['title_key'] as String
                    : loc.translate(item['title_key'] as String);

                final isPremium = item['title_key'] == 'custom_domain_menu';
                final isLocked = item['is_locked'] == true;
                final route = item['route'] as String?;

                final currentPath = GoRouterState.of(context).uri.path;
                bool isSelected = false;
                if (!isLocked && route != null) {
                  if (route == '/dashboard') {
                     isSelected = currentPath == '/dashboard';
                  } else {
                     isSelected = currentPath.startsWith(route);
                  }
                }

                return InkWell(
                  onTap: isLocked ? null : () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                      Navigator.pop(context);
                    }
                    if (item['is_builder'] == true) {
                      context.go('/builder');
                    } else if (route != null) {
                      context.go(route);
                    }
                  },
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
