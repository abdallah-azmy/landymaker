import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../atoms/custom_text_field.dart';

class DataTableHeader extends StatelessWidget {
  final String title;
  final Function(String) onSearch;
  final Function(String?) onSort;
  final List<String> sortOptions;
  final String? currentSort;

  const DataTableHeader({
    super.key,
    required this.title,
    required this.onSearch,
    required this.onSort,
    this.sortOptions = const [],
    this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.h3),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: CustomTextField(
                  hintText: "بحث...",
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  onChanged: onSearch,
                ),
              ),
              if (sortOptions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: DropdownButton<String>(
                    value: currentSort,
                    underline: SizedBox(),
                    icon: Icon(Icons.sort_rounded, color: AppColors.secondary),
                    hint: const Text("ترتيب حسب"),
                    items: sortOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: onSort,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
