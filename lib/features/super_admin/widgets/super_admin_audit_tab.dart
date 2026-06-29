import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminAuditTab extends StatelessWidget {
  const SuperAdminAuditTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveDataTable(
        title: "Configuration Audit History",
        headers: const ["Admin", "Action", "Changes", "Timestamp"],
        rows: state.auditLogs.map((log) {
          final admin = log['profiles']?['full_name'] ?? 'System';
          final action = log['action'];
          
          String changesText = "Modified ${log['table_name']}";
          if (log['old_data'] != null && log['new_data'] != null) {
            final Map<String, dynamic> oldData = log['old_data'];
            final Map<String, dynamic> newData = log['new_data'];
            final List<String> changedFields = [];
            
            newData.forEach((key, value) {
              if (oldData.containsKey(key) && oldData[key].toString() != value.toString()) {
                changedFields.add("$key: ${oldData[key]} -> $value");
              }
            });
            if (changedFields.isNotEmpty) {
              changesText = changedFields.join(", ");
            }
          }

          return [
            Text(admin, style: AppTypography.bodyMedium),
            StatusPill(
              label: action,
              color: action == 'UPDATE'
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.green,
            ),
            Tooltip(
              message: changesText,
              child: Text(
                changesText,
                style: AppTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              log['created_at'].toString().split('T').first + 
              " " + 
              log['created_at'].toString().split('T').last.substring(0, 5),
            ),
          ];
        }).toList(),
        emptyMessage: "No audit logs found",
        onSearch: (v) {},
        onSort: (v) {},
        onPageChanged: (p) {},
      ),
    );
  }
}
