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
  final String? userPhotoUrl;
  final VoidCallback onLogout;
  final List<Map<String, dynamic>>? menuItemsOverride;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.isAdmin,
    required this.userEmail,
    this.userPhotoUrl,
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
        'title_key': 'المستخدمين',
        'icon': Icons.people_rounded,
        'route': '/dashboard/super-admin',
        'tab': 'users',
      });
      finalItems.add({
        'title_key': 'الخطط والاشتراكات',
        'icon': Icons.settings_suggest_rounded,
        'route': '/dashboard/super-admin',
        'tab': 'plans',
      });
      finalItems.add({
        'title_key': 'القوالب',
        'icon': Icons.dashboard_customize_rounded,
        'route': '/dashboard/super-admin',
        'tab': 'templates',
      });
      finalItems.add({
        'title_key': 'إدارة الصفحة الرئيسية',
        'icon': Icons.web_rounded,
        'route': '/dashboard/homepage-editor',
      });
      finalItems.add({
        'title_key': 'الإشعارات الجماعية',
        'icon': Icons.campaign_rounded,
        'route': '/dashboard/super-admin',
        'tab': 'broadcast',
      });
      finalItems.add({
        'title_key': 'صفحات الهبوط',
        'icon': Icons.web_asset_rounded,
        'route': '/dashboard/super-admin',
        'tab': 'landing-pages',
      });
      finalItems.add({
        'title_key': 'إعدادات SEO',
        'icon': Icons.travel_explore_rounded,
        'route': '/dashboard/platform-seo',
      });
      finalItems.add({
        'title_key': 'المدونة',
        'icon': Icons.article_rounded,
        'route': '/dashboard/blog-admin',
      });
      finalItems.add({
        'title_key': 'إحصائيات المنصة',
        'icon': Icons.analytics_rounded,
        'route': '/dashboard/super-admin',
        'tab': 'stats',
      });
      finalItems.add({'is_divider': true});
    }

    if (menuItemsOverride != null) {
      finalItems.addAll(menuItemsOverride!);
    } else {
      finalItems.add({'is_header': true, 'title': 'مساحة العمل'});
      finalItems.add({'is_switcher': true});
      finalItems.add({
        'title_key': 'dashboard',
        'icon': Icons.dashboard_rounded,
        'route': '/dashboard',
      });
      finalItems.add({
        'title_key': 'home_website',
        'icon': Icons.home_outlined,
        'route': '/',
      });

      if (activeSiteType == 'store') {
        finalItems.add({
          'title_key': 'Products',
          'icon': Icons.inventory_2_rounded,
          'route': '/dashboard/products',
        });
      }

      finalItems.add({
        'title_key': 'leads',
        'icon': Icons.contacts_rounded,
        'route': '/dashboard/leads',
      });
      finalItems.add({
        'title_key': 'gallery',
        'icon': Icons.collections_rounded,
        'route': '/dashboard/gallery',
      });
      finalItems.add({
        'title_key': 'analytics',
        'icon': Icons.analytics_rounded,
        'route': '/dashboard/analytics',
      });

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
      finalItems.add({
        'title_key': 'hero',
        'icon': Icons.auto_fix_high_rounded,
        'is_builder': true,
        'route': builderRoute,
      });
      finalItems.add({
        'title_key': 'custom_domain_menu',
        'icon': Icons.language_rounded,
        'route': '/dashboard/domain',
      });
      finalItems.add({
        'title_key': 'notifications',
        'icon': Icons.notifications_rounded,
        'route': '/dashboard/notifications',
      });
      finalItems.add({'is_divider': true});
      finalItems.add({
        'title_key': 'settings',
        'icon': Icons.settings_rounded,
        'route': '/dashboard/settings',
      });
    }

    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: loc.isRtl
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1.5,
                ),
          left: loc.isRtl
              ? BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1.5,
                )
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtle top accent
          Container(height: 2, width: double.infinity, color: Theme.of(context).colorScheme.primary),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                Image.asset('assets/images/logo_small.webp', height: 28, width: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.translate('app_title'),
                    style: AppTypography.h2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: finalItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = finalItems[index];

                if (item['is_header'] == true) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8, left: 12, right: 12),
                    child: Text(
                      (item['title'] as String).toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                }

                if (item['is_divider'] == true) {
                  return Divider(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    height: 16,
                  );
                }

                if (item['is_switcher'] == true) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: WebsiteSwitcher(),
                  );
                }

                final String label = ((){
                  final key = item['title_key'] as String? ?? '';
                  final tab = item['tab'] as String?;
                  if (tab != null || key == 'Platform SEO' || key == 'Products' || key == 'Product Feed') return key;
                  return loc.translate(key);
                })();

                final isPremium = item['title_key'] == 'custom_domain_menu';
                final isBuilder = item['is_builder'] == true;
                final isLocked = item['is_locked'] == true;
                final route = item['route'] as String?;
                final tab = item['tab'] as String?;

                final currentPath = GoRouterState.of(context).uri.path;
                final currentTab = GoRouterState.of(context).uri.queryParameters['tab'];
                bool isSelected = false;
                if (!isLocked && route != null) {
                  if (route == '/dashboard') {
                    isSelected = currentPath == '/dashboard';
                  } else if (route == '/') {
                    isSelected = currentPath == '/';
                  } else if (tab != null) {
                    isSelected = currentPath == route && currentTab == tab;
                  } else {
                    isSelected = currentPath.startsWith(route);
                  }
                }

                return _SidebarItem(
                  label: label,
                  icon: item['icon'] as IconData,
                  isSelected: isSelected,
                  isPremium: isPremium,
                  isBuilder: isBuilder,
                  isLocked: isLocked,
                  onTap: () {
                    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) Navigator.pop(context);
                    if (route != null) {
                      if (tab != null) {
                        context.go('$route?tab=$tab');
                      } else {
                        context.go(route);
                      }
                    }
                  },
                );
              },
            ),
          ),
          
          _SidebarFooter(
            userEmail: userEmail,
            userPhotoUrl: userPhotoUrl,
            isAdmin: isAdmin,
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isPremium;
  final bool isBuilder;
  final bool isLocked;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isPremium,
    required this.isBuilder,
    required this.isLocked,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLocked ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: widget.isBuilder && !widget.isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: widget.isBuilder && !widget.isSelected
                  ? null
                  : (widget.isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                      : (_isHovered ? Theme.of(context).colorScheme.surfaceContainerHigh : Colors.transparent)),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: (!context.watch<LocalizationCubit>().isRtl && widget.isSelected)
                    ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                    : BorderSide.none,
                right: (context.watch<LocalizationCubit>().isRtl && widget.isSelected)
                    ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
            ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isLocked
                    ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : (widget.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isLocked
                        ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                        : (widget.isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant),
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              if (widget.isPremium)
                const Icon(Icons.star_rounded, size: 14, color: AppColors.warningOrange),
              if (widget.isLocked)
                Icon(Icons.lock_outline_rounded, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final String userEmail;
  final String? userPhotoUrl;
  final bool isAdmin;
  final VoidCallback onLogout;

  const _SidebarFooter({
    required this.userEmail,
    this.userPhotoUrl,
    required this.isAdmin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UsageSection(isAdmin: isAdmin),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                child: userPhotoUrl == null
                    ? Text(
                        userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail.split('@').first,
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const _PlanBadge(),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLogout,
                icon: Icon(Icons.power_settings_new_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  final bool isAdmin;
  const _UsageSection({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingPagesCubit, LandingPagesState>(
      builder: (context, state) {
        if (state is LandingPagesLoaded) {
          final usage = state.pages.length / state.maxPages;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("الاستخدام", style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text("${state.pages.length} / ${state.maxPages}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: usage,
                  minHeight: 4,
                  backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                  color: usage >= 1.0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingPagesCubit, LandingPagesState>(
      builder: (context, state) {
        String plan = "Free Plan";
        if (state is LandingPagesLoaded) {
          if (state.maxPages > 1) plan = "Pro Plan";
          if (state.maxPages > 5) plan = "Business";
        }
        return Text(
          plan,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
          ),
        );
      },
    );
  }
}
