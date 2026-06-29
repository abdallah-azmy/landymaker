import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminAffiliatesTab extends StatelessWidget {
  const SuperAdminAffiliatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ResponsiveDataTable(
        title: "إدارة المسوقين",
        headers: const ["المسوق", "الكود", "العمولة (%)", "الرصيد"],
        rows: state.affiliates.map((a) {
          final user = a['profiles']?['full_name'] ?? 'Unknown';
          return [
            Text(user, style: AppTypography.bodyLarge),
            Text(a['promo_code'], style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
            Text("${a['commission_percent']}%"),
            Text("${a['balance']} EGP", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ];
        }).toList(),
        emptyMessage: "لا يوجد مسوقين مسجلين",
        onSearch: (val) {},
        onSort: (val) {},
        onPageChanged: (p) {},
      ),
    );
  }
}
