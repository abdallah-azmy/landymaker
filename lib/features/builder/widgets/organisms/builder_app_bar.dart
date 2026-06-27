import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/preview_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
// import '../../../../core/widgets/atoms/animated_theme_toggle.dart';
import '../../../../core/widgets/atoms/cube_spinner.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';

class BuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final PreviewMode previewMode;
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;
  final VoidCallback onBack;
  final Function(PreviewMode) onChangePreview;
  final VoidCallback onShowTemplates;
  final VoidCallback onShowDesign;
  final VoidCallback onShowFonts;
  final VoidCallback onShowSeo;

  const BuilderAppBar({
    super.key,
    required this.isMobile,
    required this.previewMode,
    required this.loc,
    required this.cubit,
    required this.state,
    required this.onBack,
    required this.onChangePreview,
    required this.onShowTemplates,
    required this.onShowDesign,
    required this.onShowFonts,
    required this.onShowSeo,
  });

  void _handleBack(BuildContext context) {
    if (state.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            loc.translate('warning'),
            style: AppTypography.h3.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Text(
            loc.translate('unsaved_changes_warning'),
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                loc.translate('cancel'),
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onBack();
              },
              child: Text(
                loc.translate('exit'),
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
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
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      centerTitle: !isMobile,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => _handleBack(context),
      ),
      titleSpacing: 16,
      title: Row(
        children: [
          if (!isMobile) ...[
            Icon(
              Icons.auto_awesome_motion_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 12),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.subdomain.toUpperCase(),
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.isPublished
                          ? AppColors.activeGreen
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    state.isPublished ? "LIVE" : "DRAFT",
                    style: AppTypography.caption.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: state.isPublished
                          ? AppColors.activeGreen
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isMobile) ...[
            SizedBox(width: 16),
            VerticalDivider(
              color: Theme.of(context).colorScheme.outlineVariant,
              indent: 12,
              endIndent: 12,
              width: 16,
            ),
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              color: state.canUndo
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
              onPressed: state.canUndo ? cubit.undo : null,
              tooltip: loc.translate('undo'),
            ),
            IconButton(
              icon: const Icon(Icons.redo_rounded),
              color: state.canRedo
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
              onPressed: state.canRedo ? cubit.redo : null,
              tooltip: loc.translate('redo'),
            ),
          ],
          Expanded(child: SizedBox(width: 16)),
          if (!isMobile)
            Flexible(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      context,
                      icon: state.isPublished
                          ? Icons.visibility_off_rounded
                          : Icons.language_rounded,
                      label: state.isPublished
                          ? loc.translate('draft')
                          : loc.translate('go_live'),
                      onPressed: () {
                        cubit.updateSettings(isPublished: !state.isPublished);
                        cubit.saveForCurrentUser();
                      },
                      color: state.isPublished
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.primary,
                    ),
                    if (!state.isPublished)
                      _buildActionButton(
                        context,
                        icon: Icons.save_rounded,
                        label: loc.translate('save_draft'),
                        onPressed: state.hasUnsavedChanges
                            ? () => cubit.saveForCurrentUser()
                            : null,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    VerticalDivider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      indent: 12,
                      endIndent: 12,
                      width: 32,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.auto_awesome_rounded,
                      label: loc.translate('templates'),
                      onPressed: onShowTemplates,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.color_lens_rounded,
                      label: loc.translate('design'),
                      onPressed: onShowDesign,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.font_download_rounded,
                      label: loc.translate('fonts'),
                      onPressed: onShowFonts,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.search_rounded,
                      label: "SEO",
                      onPressed: onShowSeo,
                    ),
                    // Theme toggle is hidden for now
                    /*
                    VerticalDivider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      indent: 12,
                      endIndent: 12,
                      width: 32,
                    ),
                    const AnimatedThemeToggle(size: 40),
                    */
                    VerticalDivider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      indent: 12,
                      endIndent: 12,
                      width: 32,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.smartphone_rounded,
                        color: previewMode == PreviewMode.mobile
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => onChangePreview(PreviewMode.mobile),
                      tooltip: "Mobile Preview",
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.desktop_windows_rounded,
                        color: previewMode == PreviewMode.desktop
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => onChangePreview(PreviewMode.desktop),
                      tooltip: "Desktop Preview",
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.visibility_rounded,
                        color: previewMode == PreviewMode.fullscreen
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => onChangePreview(PreviewMode.fullscreen),
                      tooltip: "Full Screen Preview",
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        html.window.open('/${state.subdomain}', '_blank');
                      },
                      tooltip: loc.translate('view_as_guest'),
                    ),
                    SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: _buildPublishButton(context),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // const AnimatedThemeToggle(size: 36),
            // const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.auto_awesome_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onShowTemplates,
            ),
            IconButton(
              icon: Icon(
                Icons.color_lens_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onShowDesign,
            ),
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onShowSeo,
            ),
            IconButton(
              icon: Icon(
                Icons.open_in_new_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                html.window.open('/${state.subdomain}', '_blank');
              },
              tooltip: loc.translate('view_as_guest'),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildPublishButton(BuildContext context) {
    final bool canSave = state.hasUnsavedChanges && !state.isSaving;
    final bool isDraft = !state.isPublished;

    if (isDraft) {
      return InkWell(
        onTap: canSave
            ? () => _showPublishConfirmation(context, loc, cubit, state)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: canSave
                ? AppColors.activeGreen.withValues(alpha: 0.15)
                : AppColors.activeGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canSave
                  ? AppColors.activeGreen
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          child: state.isSaving
              ? CubeSpinner(size: 20, color: AppColors.activeGreen)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      color: canSave
                          ? AppColors.activeGreen
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      loc.translate('publish'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: canSave
                            ? AppColors.activeGreen
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    // Published state — show Save Changes
    return InkWell(
      onTap: canSave ? () => cubit.saveForCurrentUser() : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: canSave
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canSave
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: state.isSaving
            ? CubeSpinner(size: 20, color: Theme.of(context).colorScheme.primary)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    color: canSave
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    canSave
                        ? loc.translate('save_changes')
                        : loc.translate('published'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: canSave
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: canSave ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showPublishConfirmation(
    BuildContext context,
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    BuilderLoaded state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.activeGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.public_rounded,
                color: AppColors.activeGreen,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              loc.translate('publish_confirm_title'),
              style: AppTypography.h3,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('publish_confirm_desc'),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock,
                    size: 14,
                    color: AppColors.activeGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'landymaker.com/${state.subdomain}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    onPressed: () {
                      html.window.open('/${state.subdomain}', '_blank');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.translate('cancel'),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.updateSettings(isPublished: true);
              cubit.saveForCurrentUser();
            },
            child: Text(
              loc.translate('publish_confirm_go'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
      label: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
