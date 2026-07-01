import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';

class DynamicListEditor extends StatelessWidget {
  final String title;
  final String addLabel;
  final IconData addIcon;
  final VoidCallback onAdd;
  
  final int itemCount;
  /// If provided, renders a standard item header (Title + Delete Button).
  /// If null, the header is omitted and the [itemBuilder] is responsible for rendering the delete button using the passed callback.
  final String Function(int index)? itemTitleBuilder;
  final void Function(int index) onDelete;
  final ReorderCallback? onReorder;
  
  final List<Widget> Function(int index)? actionsBuilder;
  
  /// The builder for the item's contents.
  /// [onDelete] is passed down so the item can use it if [itemTitleBuilder] is null.
  final Widget Function(BuildContext context, int index, VoidCallback onDelete) itemBuilder;

  const DynamicListEditor({
    super.key,
    required this.title,
    required this.addLabel,
    required this.onAdd,
    required this.itemCount,
    required this.onDelete,
    required this.itemBuilder,
    this.addIcon = Icons.add_rounded,
    this.itemTitleBuilder,
    this.onReorder,
    this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header with Title and Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(addIcon, size: 16),
              label: Text(addLabel),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        // 2. Items List
        if (onReorder != null)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: itemCount,
            onReorder: onReorder!,
            itemBuilder: (context, index) {
              return Container(
                key: ValueKey("dynamic_item_$index"),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Drag Handle + Title + Delete Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8.0),
                                child: Icon(
                                  Icons.drag_indicator_rounded,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                            if (itemTitleBuilder != null)
                              Text(
                                itemTitleBuilder!(index),
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                              )
                            else
                              Text(
                                "$title #${index + 1}",
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (actionsBuilder != null) ...actionsBuilder!(index),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                              onPressed: () => onDelete(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    itemBuilder(context, index, () => onDelete(index)),
                  ],
                ),
              );
            },
          )
        else
          ...List.generate(itemCount, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Optional Item Header
                  if (itemTitleBuilder != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemTitleBuilder!(index),
                          style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (actionsBuilder != null) ...actionsBuilder!(index),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                              onPressed: () => onDelete(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 4. Custom Item Content
                  itemBuilder(context, index, () => onDelete(index)),
                ],
              ),
            );
          }),
      ],
    );
  }
}
