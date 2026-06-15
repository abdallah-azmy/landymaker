import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/preview_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
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
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.translate('warning'),
            style: AppTypography.h3.copyWith(color: AppColors.dangerRed),
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
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onBack();
              },
              child: Text(
                loc.translate('exit'),
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
    return AppBar(
      backgroundColor: AppColors.cardBg,
      elevation: 0,
      centerTitle: !isMobile,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => _handleBack(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobile) ...[
            const Icon(
              Icons.auto_awesome_motion_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.subdomain.toUpperCase(),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.isPublished ? "LIVE" : "DRAFT",
                      style: AppTypography.caption.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: state.isPublished
                            ? AppColors.activeGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 16),
            const VerticalDivider(
              color: AppColors.border,
              indent: 12,
              endIndent: 12,
              width: 16,
            ),
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              color: state.canUndo
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              onPressed: state.canUndo ? cubit.undo : null,
              tooltip: loc.translate('undo'),
            ),
            IconButton(
              icon: const Icon(Icons.redo_rounded),
              color: state.canRedo
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              onPressed: state.canRedo ? cubit.redo : null,
              tooltip: loc.translate('redo'),
            ),
          ],
        ],
      ),
      actions: [
        if (!isMobile)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
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
                        ? AppColors.textPrimary
                        : AppColors.secondary,
                  ),
                  if (!state.isPublished)
                    _buildActionButton(
                      icon: Icons.save_rounded,
                      label: loc.translate('save_draft'),
                      onPressed: state.hasUnsavedChanges
                          ? () => cubit.saveForCurrentUser()
                          : null,
                      color: AppColors.textPrimary,
                    ),
                  const VerticalDivider(
                    color: AppColors.border,
                    indent: 12,
                    endIndent: 12,
                    width: 32,
                  ),
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
                    icon: Icons.font_download_rounded,
                    label: loc.translate('fonts'),
                    onPressed: onShowFonts,
                  ),
                  _buildActionButton(
                    icon: Icons.search_rounded,
                    label: "SEO",
                    onPressed: onShowSeo,
                  ),
                  const VerticalDivider(
                    color: AppColors.border,
                    indent: 12,
                    endIndent: 12,
                    width: 32,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.smartphone_rounded,
                      color: previewMode == PreviewMode.mobile
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => onChangePreview(PreviewMode.mobile),
                    tooltip: "Mobile Preview",
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.desktop_windows_rounded,
                      color: previewMode == PreviewMode.desktop
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => onChangePreview(PreviewMode.desktop),
                    tooltip: "Desktop Preview",
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.visibility_rounded,
                      color: previewMode == PreviewMode.fullscreen
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => onChangePreview(PreviewMode.fullscreen),
                    tooltip: "Full Screen Preview",
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.secondary,
                    ),
                    onPressed: () {
                      html.window.open('/${state.subdomain}', '_blank');
                    },
                    tooltip: loc.translate('view_as_guest'),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: _buildPublishButton(context),
                  ),
                ],
              ),
            ),
          )
        else ...[
          IconButton(
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
            ),
            onPressed: onShowTemplates,
          ),
          IconButton(
            icon: const Icon(
              Icons.color_lens_rounded,
              color: AppColors.secondary,
            ),
            onPressed: onShowDesign,
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.secondary),
            onPressed: onShowSeo,
          ),
        ],
        IconButton(
          icon: const Icon(
            Icons.open_in_new_rounded,
            color: AppColors.secondary,
          ),
          onPressed: () {
            html.window.open('/${state.subdomain}', '_blank');
          },
          tooltip: loc.translate('view_as_guest'),
        ),
        const SizedBox(width: 8),
      ],
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
              color: canSave ? AppColors.activeGreen : AppColors.textMuted,
            ),
          ),
          child: state.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.activeGreen,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      color: canSave
                          ? AppColors.activeGreen
                          : AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.translate('publish'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: canSave
                            ? AppColors.activeGreen
                            : AppColors.textMuted,
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
              ? AppColors.secondary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canSave ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: state.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    color: canSave
                        ? AppColors.secondary
                        : AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canSave
                        ? loc.translate('save_changes')
                        : loc.translate('published'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: canSave
                          ? AppColors.secondary
                          : AppColors.textMuted,
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
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.activeGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.public_rounded, color: AppColors.activeGreen),
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
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 14, color: AppColors.activeGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'landymaker.com/${state.subdomain}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
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
                    color: AppColors.textSecondary,
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
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
      label: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: color ?? AppColors.textPrimary,
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
