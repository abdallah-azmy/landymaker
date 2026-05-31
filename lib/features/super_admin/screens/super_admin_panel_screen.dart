import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
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
    _tabController = TabController(length: 7, vsync: this);
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
          Tab(text: "Users", icon: Icon(Icons.people_rounded)),
          Tab(text: "Plans & Config", icon: Icon(Icons.settings_suggest_rounded)),
          Tab(text: "Security Limits", icon: Icon(Icons.security_rounded)),
          Tab(text: "Audit Logs", icon: Icon(Icons.history_rounded)),
          Tab(text: "Global Stats", icon: Icon(Icons.analytics_rounded)),
          Tab(text: "Payments", icon: Icon(Icons.payments_rounded)),
          Tab(text: "Affiliates", icon: Icon(Icons.group_add_rounded)),
        ],
      ),
      body: state is SuperAdminLoaded
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(state),
                _buildPlansTab(state),
                _buildSecurityTab(state),
                _buildAuditTab(state),
                _buildStatsTab(state),
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
        headers: const ["الاسم", "البريد", "المستوى", "الحالة", "إجراء"],
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
                IconButton(
                  icon: const Icon(Icons.manage_accounts_rounded, color: AppColors.secondary),
                  onPressed: () => _showEditUserDialog(u, state.plans),
                ),
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

  void _showEditUserDialog(Map<String, dynamic> user, List<Map<String, dynamic>> plans) {
    String selectedTier = user['tier'] ?? 'free';
    String selectedRole = user['role'] ?? 'user';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          title: Text("Manage User: ${user['full_name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Subscription Tier", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTier,
                dropdownColor: AppColors.cardBg,
                items: plans.map((p) => DropdownMenuItem(
                  value: p['id'].toString(),
                  child: Text(p['display_name']),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedTier = val!),
              ),
              const SizedBox(height: 16),
              const Text("System Role", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: AppColors.cardBg,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text("Regular User")),
                  DropdownMenuItem(value: 'super_admin', child: Text("Super Admin")),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            PrimaryButton(
              text: "Save Changes",
              width: 150,
              onPressed: () {
                context.read<SuperAdminCubit>().updateUserProfile(user['id'], {
                  'tier': selectedTier,
                  'role': selectedRole,
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Business Configuration (Plans)", style: AppTypography.h3),
              const Icon(Icons.info_outline, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Admins can modify pricing and limits. Changes are restricted by Security Boundaries.",
            style: AppTypography.caption,
          ),
          const SizedBox(height: 24),
          ...state.plans.map((plan) => _buildPlanEditCard(plan, state.securityLimits['MAX_PLAN_PAGE_LIMIT'] ?? 50)),
        ],
      ),
    );
  }

  Widget _buildPlanEditCard(Map<String, dynamic> plan, int maxAllowed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan['display_name'], style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("Price: ${plan['monthly_price']} EGP/mo", style: AppTypography.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.web_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text("Limit: ${plan['page_limit']} pages", style: AppTypography.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          PrimaryButton(
            text: "Edit Config",
            width: 120,
            onPressed: () => _showEditPlanDialog(plan, maxAllowed),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(Map<String, dynamic> plan, int maxAllowed) {
    final nameController = TextEditingController(text: plan['display_name']);
    final priceController = TextEditingController(text: plan['monthly_price'].toString());
    final limitController = TextEditingController(text: plan['page_limit'].toString());
    bool customDomain = plan['custom_domain_access'] ?? false;
    bool seoAccess = plan['advanced_seo_access'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          title: Text("Edit Plan: ${plan['id']}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, hintText: "Display Name"),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: priceController,
                  hintText: "Monthly Price (EGP)",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: limitController,
                  hintText: "Page Limit (Max $maxAllowed)",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Custom Domain Access", style: TextStyle(fontSize: 14)),
                  value: customDomain,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => setDialogState(() => customDomain = val),
                ),
                SwitchListTile(
                  title: const Text("Advanced SEO Access", style: TextStyle(fontSize: 14)),
                  value: seoAccess,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => setDialogState(() => seoAccess = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            PrimaryButton(
              text: "Save Changes",
              width: 150,
              onPressed: () {
                final newLimit = int.tryParse(limitController.text) ?? 1;
                if (newLimit > maxAllowed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: Cannot exceed security limit of $maxAllowed",
                      ),
                    ),
                  );
                  return;
                }

                context.read<SuperAdminCubit>().updatePlan(plan['id'], {
                  'display_name': nameController.text,
                  'monthly_price': double.tryParse(priceController.text) ?? 0.0,
                  'page_limit': newLimit,
                  'custom_domain_access': customDomain,
                  'advanced_seo_access': seoAccess,
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.dangerRed),
              const SizedBox(width: 12),
              Text("Infrastructure Security Boundaries", style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "These limits are fixed at the database level and cannot be changed through the UI. They prevent accidental or intentional abuse of system resources.",
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildSecurityLimitCard("Global Plan Cap", "${state.securityLimits['MAX_PLAN_PAGE_LIMIT'] ?? 50} pages", "The highest page limit any business plan can be configured to have."),
          const SizedBox(height: 16),
          _buildSecurityLimitCard("Super Admin Cap", "${state.securityLimits['SUPER_ADMIN_PAGE_LIMIT'] ?? 500} pages", "The absolute hard limit for Super Admin accounts."),
        ],
      ),
    );
  }

  Widget _buildSecurityLimitCard(String title, String value, String desc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dangerRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.dangerRed, borderRadius: BorderRadius.circular(20)),
                child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildAuditTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                  ? AppColors.secondary
                  : AppColors.activeGreen,
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

  Widget _buildStatsTab(SuperAdminLoaded state) {
    final stats = state.globalStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إحصائيات المنصة الشاملة", style: AppTypography.h3),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMetricMiniCard("إجمالي المشاهدات", stats['total_views'].toString(), Icons.visibility_rounded, AppColors.secondary)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricMiniCard("إجمالي المبيات", stats['total_purchases'].toString(), Icons.shopping_cart_rounded, AppColors.activeGreen)),
            ],
          ),
          const SizedBox(height: 32),
          Text("آخر النشاطات", style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveDataTable(
            title: "سجل العمليات",
            headers: const ["نوع الحدث", "رقم الصفحة", "الوقت"],
            rows: (stats['recent_logs'] as List).map((l) => [
              StatusPill(label: l['event_type'].toString().toUpperCase(), color: l['event_type'] == 'view' ? AppColors.secondary : AppColors.activeGreen),
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

  Widget _buildMetricMiniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.caption),
          Text(value, style: AppTypography.h3),
        ],
      ),
    );
  }
  Widget _buildAffiliatesTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ResponsiveDataTable(
        title: "إدارة المسوقين",
        headers: const ["المسوق", "الكود", "العمولة (%)", "الرصيد"],
        rows: state.affiliates.map((a) {
          final user = a['profiles']?['full_name'] ?? 'Unknown';
          return [
            Text(user, style: AppTypography.bodyLarge),
            Text(a['promo_code'], style: AppTypography.bodyMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            Text("${a['commission_percent']}%"),
            Text("${a['balance']} EGP", style: const TextStyle(color: AppColors.activeGreen, fontWeight: FontWeight.bold)),
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
