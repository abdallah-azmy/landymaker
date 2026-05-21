import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
class ResponsiveDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final String emptyMessage;

  const ResponsiveDataTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Horizontal scrolling support on Mobile/Tablets
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 64,
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Color(0xFF0B0F19)), // Dark Slate header background
            dividerThickness: 1.2,
            horizontalMargin: 24,
            columnSpacing: 24,
            columns: headers.map((header) {
              return DataColumn(
                label: Text(
                  header,
                  style: AppTypography.h3.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            rows: rows.map((rowCells) {
              return DataRow(
                cells: rowCells.map((cellWidget) {
                  return DataCell(cellWidget);
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
