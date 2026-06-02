import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../models/preview_mode.dart';

class BuilderMobileToolbar extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final LocalizationCubit loc;
  final VoidCallback onBack;
  final VoidCallback onShowOptions;
  final VoidCallback onShowColors;
  final VoidCallback onShowFonts;
  final VoidCallback onAddBlock;
  final VoidCallback onPublish;
  final Function(PreviewMode) onChangePreview;

  const BuilderMobileToolbar({
    super.key,
    required this.cubit,
    required this.state,
    required this.loc,
    required this.onBack,
    required this.onShowOptions,
    required this.onShowColors,
    required this.onShowFonts,
    required this.onAddBlock,
    required this.onPublish,
    required this.onChangePreview,
  });

  void _handleBack(BuildContext context) {
    if (state.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.translate('warning') ?? 'تنبيه',
            style: AppTypography.h3.copyWith(color: AppColors.dangerRed),
          ),
          content: Text(
            loc.translate('unsaved_changes_warning') ?? 'لديك تعديلات لم تقم بحفظها. هل أنت متأكد من الخروج دون حفظ؟',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.translate('cancel') ?? 'إلغاء',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onBack();
              },
              child: Text(
                loc.translate('exit') ?? 'خروج',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Navigation
          _buildToolButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => _handleBack(context),
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 4),

          // Center: Tools (Scrollable to fit everything, evenly spaced if space permits)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMoreOptionsButton(context),
                        const SizedBox(width: 4),
                        // Distinct Add Button
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: InkWell(
                            onTap: onAddBlock,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: Icons.undo_rounded,
                          onPressed: state.canUndo ? cubit.undo : null,
                          color: state.canUndo
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: Icons.redo_rounded,
                          onPressed: state.canRedo ? cubit.redo : null,
                          color: state.canRedo
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: Icons.font_download_rounded,
                          onPressed: onShowFonts,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: Icons.color_lens_rounded,
                          onPressed: onShowColors,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: Icons.visibility_rounded,
                          onPressed: () =>
                              onChangePreview(PreviewMode.fullscreen),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 4),

          // Right: Publish (Rocket)
          _buildPublishButton(),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.white, size: 22),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildPublishButton() {
    final bool canPublish = state.hasUnsavedChanges && !state.isSaving;
    return InkWell(
      onTap: canPublish ? () => cubit.saveForCurrentUser() : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: canPublish
              ? AppColors.activeGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canPublish ? AppColors.activeGreen : AppColors.border,
          ),
        ),
        child: state.isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.activeGreen,
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.rocket_launch_rounded,
                    color: canPublish
                        ? AppColors.activeGreen
                        : AppColors.textMuted,
                    size: 20,
                  ),
                  if (canPublish) ...[
                    const SizedBox(width: 6),
                    Text(
                      loc.translate('publish') ?? 'نشر',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.activeGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
        child: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}
