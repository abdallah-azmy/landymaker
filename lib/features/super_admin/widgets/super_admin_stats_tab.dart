import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminStatsTab extends StatelessWidget {
  const SuperAdminStatsTab({super.key});

  Widget _buildMetricMiniCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 10),
          Text(title, style: AppTypography.caption),
          Text(value, style: AppTypography.h3),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    final stats = state.globalStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إحصائيات المنصة الشاملة", style: AppTypography.h3),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMetricMiniCard(context, "إجمالي المشاهدات", stats['total_views'].toString(), Icons.visibility_rounded, Theme.of(context).colorScheme.secondary)),
              SizedBox(width: 16),
              Expanded(child: _buildMetricMiniCard(context, "إجمالي المبيات", stats['total_purchases'].toString(), Icons.shopping_cart_rounded, Colors.green)),
            ],
          ),
          SizedBox(height: 32),
          Text("آخر النشاطات", style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          ResponsiveDataTable(
            title: "سجل العمليات",
            headers: const ["نوع الحدث", "رقم الصفحة", "الوقت"],
            rows: (stats['recent_logs'] as List).map((l) => [
              StatusPill(label: l['event_type'].toString().toUpperCase(), color: l['event_type'] == 'view' ? Theme.of(context).colorScheme.secondary : Colors.green),
              Text(l['landing_page_id'].toString().substring(0, 8) + "..."),
              Text(l['created_at'].toString().split('T').last.substring(0, 5)),
            ]).toList(),
            emptyMessage: "لا يوجد نشاط مؤخراً",
            onSearch: (v) {},
            onSort: (v) {},
            onPageChanged: (p) {},
          ),
        ],
      ),
    );
  }
}
