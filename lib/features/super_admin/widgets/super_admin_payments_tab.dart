import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminPaymentsTab extends StatelessWidget {
  const SuperAdminPaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveDataTable(
        title: "طلبات الاشتراك",
        headers: const ["المستخدم", "الخطة", "المبلغ", "الحالة", "إجراء"],
        rows: state.requests.map((r) {
          final user = r['profiles']?['full_name'] ?? 'Unknown';
          final status = r['status'] ?? 'pending';
          return [
            Text(user, style: AppTypography.bodyLarge),
            Text(r['plan_name'], style: AppTypography.bodyMedium),
            Text("${r['price_paid']} EGP"),
            StatusPill(
              label: status.toUpperCase(),
              color: status == 'approved' ? Colors.green : (status == 'rejected' ? Theme.of(context).colorScheme.error : Colors.orange),
            ),
            if (status == 'pending')
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle_rounded, color: Colors.green),
                    onPressed: () => context.read<SuperAdminCubit>().approveRequest(r['id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_rounded, color: Theme.of(context).colorScheme.error),
                    onPressed: () => context.read<SuperAdminCubit>().rejectRequest(r['id']),
                  ),
                ],
              )
            else
              const Text("-"),
          ];
        }).toList(),
        emptyMessage: "لا توجد طلبات معلقة",
        onSearch: (val) {},
        onSort: (val) {},
        onPageChanged: (p) {},
      ),
    );
  }
}
