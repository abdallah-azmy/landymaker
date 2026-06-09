import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../molecules/pagination_control.dart';
import 'data_table_header.dart';

class ResponsiveDataTable extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<Widget>> rows;
  final String emptyMessage;
  final Function(String) onSearch;
  final Function(String?) onSort;
  final List<String> sortOptions;
  final String? currentSort;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const ResponsiveDataTable({
    super.key,
    required this.title,
    required this.headers,
    required this.rows,
    required this.emptyMessage,
    required this.onSearch,
    required this.onSort,
    this.sortOptions = const [],
    this.currentSort,
    this.currentPage = 1,
    this.totalPages = 1,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DataTableHeader(
                title: title,
                onSearch: onSearch,
                onSort: onSort,
                sortOptions: sortOptions,
                currentSort: currentSort,
              ),
              if (rows.isEmpty)
                _buildEmptyState()
              else if (isMobile)
                _buildMobileCards(context)
              else
                _buildTable(context),
              PaginationControl(
                currentPage: currentPage,
                totalPages: totalPages,
                onPageChanged: onPageChanged,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, color: AppColors.textMuted, size: 48),
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

  Widget _buildMobileCards(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(headers.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        headers[i],
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: row[i],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFF0B0F19)),
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
    );
  }
}
