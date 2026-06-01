import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/preview_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
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
                        : Icons.language_rounded, // Better icon for live status
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
                    child: _buildPublishButton(),
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
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: _buildPublishButton(),
          ),
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

  Widget _buildPublishButton() {
    final bool canPublish = state.hasUnsavedChanges && !state.isSaving;
    return InkWell(
      onTap: canPublish ? () => cubit.saveForCurrentUser() : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                width: 20,
                height: 20,
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
                    size: 18,
                  ),
                  if (canPublish) ...[
                    const SizedBox(width: 8),
                    Text(
                      loc.translate('publish'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.activeGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Text(
                      loc.translate('published'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
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
