import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';

class BuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final bool isMobilePreview;
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final VoidCallback onBack;
  final VoidCallback onTogglePreview;
  final VoidCallback onShowTemplates;
  final VoidCallback onShowDesign;
  final VoidCallback onShowSeo;

  const BuilderAppBar({
    super.key,
    required this.isMobile,
    required this.isMobilePreview,
    required this.loc,
    required this.cubit,
    required this.state,
    required this.onBack,
    required this.onTogglePreview,
    required this.onShowTemplates,
    required this.onShowDesign,
    required this.onShowSeo,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBg,
      elevation: 0,
      centerTitle: !isMobile,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobile) ...[
            const Icon(Icons.auto_awesome_motion_rounded, color: AppColors.secondary, size: 20),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              state.subdomain.toUpperCase(),
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          _buildActionButton(
            icon: Icons.auto_awesome_rounded,
            label: loc.translate('templates'),
            onPressed: onShowTemplates,
          ),
          _buildActionButton(
            icon: Icons.color_lens_rounded,
            label: loc.translate('design'),
            onPressed: onShowDesign,
          ),
          _buildActionButton(
            icon: Icons.search_rounded,
            label: "SEO",
            onPressed: onShowSeo,
          ),
          const VerticalDivider(color: AppColors.border, indent: 12, endIndent: 12, width: 32),
          IconButton(
            icon: Icon(Icons.smartphone_rounded, color: isMobilePreview ? AppColors.secondary : AppColors.textSecondary),
            onPressed: isMobilePreview ? null : onTogglePreview,
            tooltip: "Mobile Preview",
          ),
          IconButton(
            icon: Icon(Icons.desktop_windows_rounded, color: !isMobilePreview ? AppColors.secondary : AppColors.textSecondary),
            onPressed: !isMobilePreview ? null : onTogglePreview,
            tooltip: "Desktop Preview",
          ),
          const SizedBox(width: 16),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary),
            onPressed: onShowTemplates,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_rounded, color: AppColors.secondary),
            onPressed: onShowDesign,
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.secondary),
            onPressed: onShowSeo,
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: PrimaryButton(
            text: isMobile ? loc.translate('save') : loc.translate('save_changes'),
            icon: Icons.cloud_done_rounded,
            onPressed: state.isSaving ? null : () => cubit.saveForCurrentUser(),
            isLoading: state.isSaving,
            width: isMobile ? 100 : 160,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: AppColors.textPrimary),
      label: Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
