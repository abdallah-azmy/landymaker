import 'package:flutter/material.dart';
import '../../controllers/builder_cubit.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';

class OutlineTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final LocalizationCubit loc;
  final List<Map<String, dynamic>> blocks;
  final Function(int) onEditBlock;
  final Function(BuildContext, LandingPageBuilderCubit) onAddBlock;
  final int? selectedIndex;

  const OutlineTab({
    super.key,
    required this.cubit,
    required this.loc,
    required this.blocks,
    required this.onEditBlock,
    required this.onAddBlock,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.translate('added_sections'), style: AppTypography.h3),
              IconButton(
                onPressed: () => onAddBlock(context, cubit),
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                tooltip: loc.translate('add_block'),
              ),
            ],
          ),
        ),
        Expanded(
          child: blocks.isEmpty
              ? _buildEmptyState(context)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  itemCount: blocks.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    cubit.reorderBlocks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    final String type = block['type'] ?? '';
                    final String title = block['title'] ?? 'Section';
                    final bool isVisible = block['is_visible'] ?? true;
                    final bool isSelected = selectedIndex == index;

                    return Container(
                      key: ValueKey("outline_$index"),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05)
                            : Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          cubit.selectSection(index);
                          onEditBlock(index);
                        },
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isVisible
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: 18,
                                color: isVisible
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () =>
                                  cubit.toggleBlockVisibility(index),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => cubit.deleteBlock(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد أقسام مضافة بعد",
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
