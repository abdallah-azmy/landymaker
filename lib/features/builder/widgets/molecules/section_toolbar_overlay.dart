import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/ai_generation_cubit.dart';
import '../modals/ai_chat_modal.dart';

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
  double _topOffset = 0;
  double _horizontalOffset = 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final loc = context.watch<LocalizationCubit>();
    final state = cubit.state as BuilderLoaded;
    final blocks = state.designMap['blocks'] as List;
    final totalBlocks = blocks.length;
    final isVisible = widget.index < totalBlocks
        ? (blocks[widget.index]['is_visible'] ?? true)
        : true;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Content
          Opacity(
            opacity: isVisible ? 1.0 : 0.4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: (widget.isSelected || _isHovered)
                    ? Border.all(color: AppColors.secondary, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: widget.child,
            ),
          ),

          // Toolbar
          if (widget.isSelected || _isHovered)
            Positioned(
              top: _topOffset,
              right: loc.isRtl ? null : _horizontalOffset,
              left: loc.isRtl ? _horizontalOffset : null,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.75),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _topOffset += details.delta.dy;
                                  if (loc.isRtl) {
                                    _horizontalOffset += details.delta.dx;
                                  } else {
                                    _horizontalOffset -= details.delta.dx;
                                  }
                                });
                              },
                              child: const MouseRegion(
                                cursor: SystemMouseCursors.move,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: Icon(
                                    Icons.drag_indicator_rounded,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            _buildDivider(),
                            _buildIconButton(
                              icon: Icons.edit_rounded,
                              tooltip: loc.translate('edit'),
                              onPressed: widget.onEdit,
                            ),
                            _buildIconButton(
                              icon: Icons.auto_awesome_rounded,
                              tooltip: loc.translate('ai_edit_section'),
                              onPressed: () {
                                final state = cubit.state;
                                if (state is! BuilderLoaded) return;
                                final block = state
                                    .designMap['blocks'][widget.index]
                                    as Map<String, dynamic>;
                                final type = block['type'] ?? '';
                                final aiCubit = context.read<AIGenerationCubit>();
                                aiCubit.pendingSectionIndex = widget.index;
                                aiCubit.pendingSectionType = type;
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const AIChatModal(),
                                );
                              },
                            ),
                            _buildIconButton(
                              icon: isVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              tooltip: loc.translate(isVisible ? 'hide' : 'show'),
                              onPressed: () =>
                                  cubit.toggleBlockVisibility(widget.index),
                            ),
                            _buildDivider(),
                            _buildIconButton(
                              icon: Icons.copy_rounded,
                              tooltip: loc.translate('duplicate'),
                              onPressed: () =>
                                  cubit.duplicateBlock(widget.index),
                            ),
                            _buildIconButton(
                              icon: Icons.arrow_upward_rounded,
                              tooltip: loc.translate('move_up'),
                              onPressed: widget.index > 0
                                  ? () => cubit.moveBlock(widget.index, true)
                                  : null,
                            ),
                            _buildIconButton(
                              icon: Icons.arrow_downward_rounded,
                              tooltip: loc.translate('move_down'),
                              onPressed: widget.index < totalBlocks - 1
                                  ? () => cubit.moveBlock(widget.index, false)
                                  : null,
                            ),
                            _buildDivider(),
                            _buildIconButton(
                              icon: Icons.delete_rounded,
                              tooltip: loc.translate('delete'),
                              color: Colors.white,
                              onPressed: () =>
                                  _showDeleteConfirmation(context, cubit, loc),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (!isVisible)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.05),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_off_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "مخفي من الصفحة المباشرة",
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      icon: Icon(
        icon,
        size: 18,
        color: onPressed == null ? Colors.white24 : color,
      ),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      tooltip: tooltip,
      splashRadius: 20,
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

  void _showDeleteConfirmation(
    BuildContext context,
    LandingPageBuilderCubit cubit,
    LocalizationCubit loc,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          loc.translate('delete_confirm_title'),
          style: AppTypography.h3,
        ),
        content: Text(loc.translate('delete_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              loc.translate('cancel'),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
            ),
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
