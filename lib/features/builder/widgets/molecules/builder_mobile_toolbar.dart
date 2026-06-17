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
  final VoidCallback onShowAi;
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
    required this.onShowAi,
    required this.onPublish,
    required this.onChangePreview,
  });

  void _handleBack(BuildContext context) {
    if (state.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.translate('warning'),
            style: AppTypography.h3.copyWith(color: Theme.of(context).colorScheme.error),
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
                style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onBack();
              },
              child: Text(
                loc.translate('exit'),
                style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1.5),
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
            context: context,
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => _handleBack(context),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: Theme.of(context).colorScheme.outline),
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
                        const SizedBox(width: 8),
                        // AI Assistant Button
                        InkWell(
                          onTap: onShowAi,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Distinct Add Button
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: InkWell(
                            onTap: onAddBlock,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.secondary.withValues(
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
                          context: context,
                          icon: Icons.undo_rounded,
                          onPressed: state.canUndo ? cubit.undo : null,
                          color: state.canUndo
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          context: context,
                          icon: Icons.redo_rounded,
                          onPressed: state.canRedo ? cubit.redo : null,
                          color: state.canRedo
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          context: context,
                          icon: Icons.font_download_rounded,
                          onPressed: onShowFonts,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          context: context,
                          icon: Icons.color_lens_rounded,
                          onPressed: onShowColors,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          context: context,
                          icon: Icons.visibility_rounded,
                          onPressed: () =>
                              onChangePreview(PreviewMode.fullscreen),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 4),

          // Right: Publish (Rocket)
          _buildPublishButton(context),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface, size: 22),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildPublishButton(BuildContext context) {
    final bool canPublish = state.hasUnsavedChanges && !state.isSaving;
    return InkWell(
      onTap: canPublish ? () => cubit.saveForCurrentUser() : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: canPublish
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canPublish ? Colors.green : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: state.isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green,
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.rocket_launch_rounded,
                    color: canPublish
                        ? Colors.green
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  if (canPublish) ...[
                    const SizedBox(width: 6),
                    Text(
                      loc.translate('publish'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.green,
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
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }
}
