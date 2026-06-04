import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
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
        ...List.generate(itemCount, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
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
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                        onPressed: () => onDelete(index),
                      ),
                    ],
                  ),
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
