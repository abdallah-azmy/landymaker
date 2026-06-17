import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

class PaginationControl extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControl({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Page \$currentPage of \$totalPages",
            style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(width: 16),
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            icon: Icon(Icons.arrow_forward_ios_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ],
      ),
    );
  }
}
