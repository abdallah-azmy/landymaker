import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';

class SectionToolbarOverlay extends StatefulWidget {
  final Widget child;
  final int index;
  final bool isSelected;
  final VoidCallback onEdit;

  const SectionToolbarOverlay({
    super.key,
    required this.child,
    required this.index,
    required this.isSelected,
    required this.onEdit,
  });

  @override
  State<SectionToolbarOverlay> createState() => _SectionToolbarOverlayState();
}

class _SectionToolbarOverlayState extends State<SectionToolbarOverlay> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final loc = context.watch<LocalizationCubit>();
    final state = cubit.state as BuilderLoaded;
    final totalBlocks = (state.designMap['blocks'] as List).length;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: (widget.isSelected || _isHovered)
                  ? Border.all(color: AppColors.secondary, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: widget.child,
          ),
          
          // Toolbar
          if (widget.isSelected || _isHovered)
            Positioned(
              top: -40,
              right: loc.isRtl ? null : 0,
              left: loc.isRtl ? 0 : null,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        icon: Icons.edit_rounded,
                        tooltip: loc.translate('edit'),
                        onPressed: widget.onEdit,
                      ),
                      _buildDivider(),
                      _buildIconButton(
                        icon: Icons.copy_rounded,
                        tooltip: loc.translate('duplicate'),
                        onPressed: () => cubit.duplicateBlock(widget.index),
                      ),
                      _buildDivider(),
                      _buildIconButton(
                        icon: Icons.arrow_upward_rounded,
                        tooltip: loc.translate('move_up'),
                        onPressed: widget.index > 0 ? () => cubit.moveBlock(widget.index, true) : null,
                      ),
                      _buildIconButton(
                        icon: Icons.arrow_downward_rounded,
                        tooltip: loc.translate('move_down'),
                        onPressed: widget.index < totalBlocks - 1 ? () => cubit.moveBlock(widget.index, false) : null,
                      ),
                      _buildDivider(),
                      _buildIconButton(
                        icon: Icons.delete_rounded,
                        tooltip: loc.translate('delete'),
                        color: Colors.white,
                        onPressed: () => _showDeleteConfirmation(context, cubit, loc),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color color = Colors.white,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: onPressed == null ? Colors.white24 : color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      tooltip: tooltip,
      splashRadius: 24,
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white24,
    );
  }

  void _showDeleteConfirmation(BuildContext context, LandingPageBuilderCubit cubit, LocalizationCubit loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(loc.translate('delete_confirm_title'), style: AppTypography.h3),
        content: Text(loc.translate('delete_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel'), style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            onPressed: () {
              cubit.deleteBlock(widget.index);
              Navigator.pop(context);
            },
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );
  }
}
