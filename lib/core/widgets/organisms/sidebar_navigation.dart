import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../localization/localization_cubit.dart';

class SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool isAdmin;
  final String userEmail;
  final VoidCallback onLogout;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.isAdmin,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    // List of menu configurations
    final List<Map<String, dynamic>> menuItems = [
      {'title_key': 'dashboard', 'icon': Icons.dashboard_rounded},
      {'title_key': 'leads', 'icon': Icons.contacts_rounded},
      {'title_key': 'analytics', 'icon': Icons.analytics_rounded},
      {'title_key': 'hero', 'icon': Icons.construction_rounded}, // Builder
    ];

    if (isAdmin) {
      menuItems.add({'title_key': 'super_admin', 'icon': Icons.admin_panel_settings_rounded});
    }

    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: loc.isRtl ? BorderSide.none : const BorderSide(color: AppColors.border, width: 1.5),
          left: loc.isRtl ? const BorderSide(color: AppColors.border, width: 1.5) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Brand Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
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
          const SizedBox(height: 32),

          // Menu list items
          Expanded(
            child: ListView.separated(
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = currentIndex == index;
                final String label = loc.translate(item['title_key'] as String);

                return InkWell(
                  onTap: () => onTabSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          label,
                          style: AppTypography.bodyLarge.copyWith(
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider
          const Divider(color: AppColors.border, height: 24, thickness: 1.2),

          // Language Toggle & Logout actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => loc.toggleLanguage(),
                icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.secondary),
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
                icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.dangerRed, size: 20),
                tooltip: loc.translate('logout'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom Account profile summary card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Row(
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
                  child: Text(
                    userEmail,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
