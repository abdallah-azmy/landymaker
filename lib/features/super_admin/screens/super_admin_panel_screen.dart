import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminPanelScreen extends StatefulWidget {
  const SuperAdminPanelScreen({super.key});

  @override
  State<SuperAdminPanelScreen> createState() => _SuperAdminPanelScreenState();
}

class _SuperAdminPanelScreenState extends State<SuperAdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _currentSort;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<SuperAdminCubit>().fetchAdminMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final state = context.watch<SuperAdminCubit>().state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.secondary,
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: "Users & Limits", icon: Icon(Icons.people_rounded)),
          Tab(text: "Global Stats", icon: Icon(Icons.analytics_rounded)),
          Tab(text: "Page Manager", icon: Icon(Icons.web_rounded)),
          Tab(text: "Pending Payments", icon: Icon(Icons.payments_rounded)),
          Tab(text: "Affiliates", icon: Icon(Icons.group_add_rounded)),
        ],
      ),
      body: state is SuperAdminLoaded
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(state),
                _buildStatsTab(state),
                _buildPagesTab(state),
                _buildPaymentsTab(state),
                _buildAffiliatesTab(state),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUsersTab(SuperAdminLoaded state) {
    final filteredUsers = state.users
        .where(
          (u) => u['full_name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ResponsiveDataTable(
        title: "إدارة المستخدمين",
        headers: const ["الاسم", "البريد", "المستوى", "الحالة"],
        rows: filteredUsers
            .map(
              (u) => [
                Text(u['full_name'], style: AppTypography.bodyLarge),
                Text(u['email'], style: AppTypography.bodyMedium),
                StatusPill(
                  label: u['tier'].toString().toUpperCase(),
                  color: AppColors.primary,
                ),
                StatusPill(label: "نشط", color: AppColors.activeGreen),
              ],
            )
            .toList(),
        emptyMessage: "لا يوجد مستخدمين بهذا الاسم",
        onSearch: (val) => setState(() => _searchQuery = val),
        onSort: (val) => setState(() => _currentSort = val),
        sortOptions: const ["الاسم", "التاريخ"],
        onPageChanged: (p) {},
      ),
    );
  }

  Widget _buildPagesTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ResponsiveDataTable(
        title: "إدارة الصفحات",
        headers: const ["الرابط", "المالك", "المشاهدات", "الحالة"],
        rows: state.pages.map((p) {
          final owner = p['profiles']?['full_name'] ?? 'Unknown';
          return [
            Text(p['subdomain'], style: AppTypography.bodyLarge),
            Text(owner, style: AppTypography.bodyMedium),
            Text(p['views_count'].toString()),
            StatusPill(
              label: p['is_published'] ? "منشورة" : "مسودة",
              color: p['is_published'] ? AppColors.activeGreen : AppColors.textMuted,
            ),
          ];
        }).toList(),
        emptyMessage: "لا توجد صفحات",
        onSearch: (val) {},
        onSort: (val) {},
        onPageChanged: (p) {},
      ),
    );
  }

  Widget _buildPaymentsTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
              color: status == 'approved' ? AppColors.activeGreen : (status == 'rejected' ? AppColors.dangerRed : AppColors.warningOrange),
            ),
            if (status == 'pending')
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_rounded, color: AppColors.activeGreen),
                    onPressed: () => context.read<SuperAdminCubit>().approveRequest(r['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: AppColors.dangerRed),
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

  Widget _buildStatsTab(SuperAdminLoaded state) => _buildPlaceholder("إحصائيات المنصة");
  Widget _buildAffiliatesTab(SuperAdminLoaded state) => _buildPlaceholder("نظام المسوقين");

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 8),
          Text("جاري العمل على هذا القسم...", style: AppTypography.caption),
        ],
      ),
    );
  }
}
