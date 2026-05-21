import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/molecules/data_card.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminPanelScreen extends StatefulWidget {
  const SuperAdminPanelScreen({super.key});

  @override
  State<SuperAdminPanelScreen> createState() => _SuperAdminPanelScreenState();
}

class _SuperAdminPanelScreenState extends State<SuperAdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SuperAdminCubit>().fetchAdminMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final cubit = context.watch<SuperAdminCubit>();
    final state = cubit.state;

    // Prepare table mock platform users data for administration display
    final List<Map<String, String>> mockUsers = [
      {'name': 'Alex Carter', 'email': 'alex@carter.com', 'role': 'user', 'status': 'active'},
      {'name': 'Fatima Omar', 'email': 'fatima@admin.com', 'role': 'super_admin', 'status': 'active'},
      {'name': 'Tariq Ziad', 'email': 'tariq@build.org', 'role': 'user', 'status': 'inactive'},
    ];

    final headers = [
      loc.translate('full_name'),
      loc.translate('email'),
      loc.translate('role'),
      "Status"
    ];

    final rows = mockUsers.map((u) {
      final role = u['role'] == 'super_admin' ? 'super_admin' : 'user';
      final isActive = u['status'] == 'active';

      return [
        Text(u['name']!, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        Text(u['email']!, style: AppTypography.bodyMedium),
        StatusPill(
          label: role == 'super_admin' ? loc.translate('super_admin') : loc.translate('dashboard'),
          color: role == 'super_admin' ? AppColors.primary : AppColors.secondary,
        ),
        StatusPill(
          label: isActive ? 'Active' : 'Inactive',
          color: isActive ? AppColors.activeGreen : AppColors.dangerRed,
        ),
      ];
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('super_admin'),
                    style: AppTypography.h1.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Global platform administration and multi-tenant performance audits.",
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => context.read<SuperAdminCubit>().fetchAdminMetrics(),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (state is SuperAdminFailure) ...[
            Text(state.message, style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerRed)),
            const SizedBox(height: 16),
          ],

          if (state is SuperAdminLoading || state is SuperAdminInitial)
            const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          else if (state is SuperAdminLoaded) ...[
            // Metrics Cards row
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context, desktop: 3, tablet: 2, mobile: 1),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                DataCard(
                  title: loc.translate('total_users'),
                  value: '${state.totalUsers}',
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.secondary,
                ),
                DataCard(
                  title: loc.translate('active_pages'),
                  value: '${state.activePages}',
                  icon: Icons.web_rounded,
                  iconColor: AppColors.primary,
                ),
                DataCard(
                  title: loc.translate('total_leads'),
                  value: '${state.totalLeads}',
                  icon: Icons.hub_rounded,
                  iconColor: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Registered tenant user profiles table
            Text("Registered Platform Profiles", style: AppTypography.h3),
            const SizedBox(height: 16),
            ResponsiveDataTable(
              headers: headers,
              rows: rows,
              emptyMessage: "No profiles registered",
            ),
          ],
        ],
      ),
    );
  }
}
