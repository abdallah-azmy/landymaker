import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/preview_mode.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../molecules/scrollable_toolbar_container.dart';

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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.saveForCurrentUser();
                onBack();
              },
              child: Text(
                loc.translate('save_and_exit'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
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
              Row(
                mainAxisSize: MainAxisSize.min,
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
                  if (state.hasUnsavedChanges) ...[
                    SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
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
                          ? Theme.of(context).colorScheme.primary
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
                          ? Theme.of(context).colorScheme.primary
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
              onPressed: state.canUndo ? () => cubit.undo() : null,
              tooltip: loc.translate('undo'),
            ),
            IconButton(
              icon: const Icon(Icons.redo_rounded),
              color: state.canRedo
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
              onPressed: state.canRedo ? () => cubit.redo() : null,
              tooltip: loc.translate('redo'),
            ),
          ],
          const SizedBox(width: 24),
          if (!isMobile)
            Expanded(
              child: ScrollableToolbarContainer(
                children: [

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
                      Icons.tablet_rounded,
                      color: previewMode == PreviewMode.tablet
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => onChangePreview(PreviewMode.tablet),
                    tooltip: "Tablet Preview",
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
                    child: _buildActionHub(context),
                  ),
                ],
              ),
            )
          else ...[
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

  Widget _buildActionHub(BuildContext context) {
    final bool canSave = state.hasUnsavedChanges && !state.isSaving;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Status Toggle (Draft vs Live Switch)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.isPublished ? "منشور مباشر" : "مسودة",
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: state.isPublished
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: state.isPublished,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: state.isSaving
                    ? null
                    : (val) {
                        if (val) {
                          // Turn Live: Show confirmation
                          _showPublishConfirmation(context, loc, cubit, state);
                        } else {
                          // Turn Draft: Revert and save
                          cubit.updateSettings(isPublished: false);
                          cubit.saveForCurrentUser();
                        }
                      },
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),

        // 2. Action Button (Save Draft / Publish Changes)
        // Disabled if no unsaved changes are present.
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: canSave ? () => cubit.saveForCurrentUser() : null,
          icon: state.isSaving
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Icon(
                  state.isPublished
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_upload_outlined,
                  size: 16,
                ),
          label: Text(
            state.isPublished ? "نشر التغييرات" : "حفظ مسودة",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        // 3. View Live Site Button (Directly visible next to actions if Live)
        if (state.isPublished) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              html.window.open('/${state.subdomain}', '_blank');
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text("زيارة الموقع"),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.public_rounded,
                color: Theme.of(context).colorScheme.primary,
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
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
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
