import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';

class BuilderMobileToolbar extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final VoidCallback onBack;
  final VoidCallback onShowOptions;
  final VoidCallback onShowColors;
  final VoidCallback onAddBlock;
  final VoidCallback onPublish;

  const BuilderMobileToolbar({
    super.key,
    required this.cubit,
    required this.state,
    required this.loc,
    required this.onBack,
    required this.onShowOptions,
    required this.onShowColors,
    required this.onAddBlock,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Navigation
          Row(
            children: [
              _buildToolButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          
          // Center: Tools
          Row(
            children: [
              _buildToolButton(
                icon: Icons.color_lens_rounded,
                onPressed: onShowColors,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              _buildToolButton(
                icon: Icons.add_rounded,
                onPressed: onAddBlock,
                color: Colors.white,
                isLarge: true,
              ),
              const SizedBox(width: 8),
              _buildMoreOptionsButton(context),
            ],
          ),

          // Right: Save
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    bool isLarge = false,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.white, size: isLarge ? 28 : 22),
      onPressed: onPressed,
      constraints: BoxConstraints(minWidth: isLarge ? 48 : 40, minHeight: isLarge ? 48 : 40),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: state.isSaving ? null : () => cubit.saveForCurrentUser(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.activeGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.activeGreen),
        ),
        child: state.isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.activeGreen),
              )
            : Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded, color: AppColors.activeGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    loc.translate('save'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.activeGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    return InkWell(
      onTap: onShowOptions,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary, size: 24),
      ),
    );
  }
}
