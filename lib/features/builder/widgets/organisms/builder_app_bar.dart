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
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBg,
      title: Text(isMobile ? loc.translate('workspace') : loc.translate('workspace_full'), style: AppTypography.h3),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack,
      ),
      actions: [
        if (isMobile) ...[
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary),
            onPressed: onShowTemplates,
            tooltip: loc.translate('templates'),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_rounded, color: AppColors.secondary),
            onPressed: onShowDesign,
            tooltip: loc.translate('design'),
          ),
        ],
        if (!isMobile)
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.smartphone_rounded, color: isMobilePreview ? AppColors.secondary : AppColors.textSecondary),
                onPressed: onTogglePreview,
                tooltip: "Mobile Preview",
              ),
              IconButton(
                icon: Icon(Icons.desktop_windows_rounded, color: !isMobilePreview ? AppColors.secondary : AppColors.textSecondary),
                onPressed: onTogglePreview,
                tooltip: "Desktop Preview",
              ),
            ],
          ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: PrimaryButton(
            text: isMobile ? "Save" : "Save & Deploy",
            icon: Icons.rocket_launch_rounded,
            onPressed: () => cubit.saveForCurrentUser(),
            isLoading: state.isSaving,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
