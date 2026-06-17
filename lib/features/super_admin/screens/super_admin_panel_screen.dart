import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../builder/registries/template_registry.dart';
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
  // ignore: unused_field
  String? _currentSort;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    context.read<SuperAdminCubit>().fetchAdminMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalizationCubit>();
    final state = context.watch<SuperAdminCubit>().state;

    return BlocListener<SuperAdminCubit, SuperAdminState>(
      listener: (context, stateListener) {
        if (stateListener is SuperAdminFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(stateListener.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Theme.of(context).colorScheme.secondary,
        labelColor: Theme.of(context).colorScheme.secondary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: const [
          Tab(text: "Users", icon: Icon(Icons.people_rounded)),
          Tab(text: "Plans & Config", icon: Icon(Icons.settings_suggest_rounded)),
          Tab(text: "Security Limits", icon: Icon(Icons.security_rounded)),
          Tab(text: "Audit Logs", icon: Icon(Icons.history_rounded)),
          Tab(text: "Global Stats", icon: Icon(Icons.analytics_rounded)),
          Tab(text: "Payments", icon: Icon(Icons.payments_rounded)),
          Tab(text: "Affiliates", icon: Icon(Icons.group_add_rounded)),
          Tab(text: "Templates", icon: Icon(Icons.dashboard_customize_rounded)),
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
                _buildTemplatesTab(state),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      ),
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
      padding: const EdgeInsets.all(20),
      child: ResponsiveDataTable(
        title: "إدارة المستخدمين",
        headers: const ["الاسم", "البريد", "المستوى", "الحالة", "إجراء"],
        rows: filteredUsers
            .map(
              (u) => [
                Flexible(child: Text(u['full_name'], style: AppTypography.bodyLarge, overflow: TextOverflow.ellipsis)),
                Flexible(child: Text(u['email'], style: AppTypography.bodyMedium, overflow: TextOverflow.ellipsis)),
                StatusPill(
                  label: u['tier'].toString().toUpperCase(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                StatusPill(label: "نشط", color: Colors.green),
                IconButton(
                  icon: Icon(Icons.manage_accounts_rounded, color: Theme.of(context).colorScheme.secondary),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Manage User: ${user['full_name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Subscription Tier", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTier,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                items: plans.map((p) => DropdownMenuItem(
                  value: p['id'].toString(),
                  child: Text(p['display_name']),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedTier = val!),
              ),
              SizedBox(height: 16),
              const Text("System Role", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Business Configuration (Plans)", style: AppTypography.h3),
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Admins can modify pricing and limits. Changes are restricted by Security Boundaries.",
            style: AppTypography.caption,
          ),
          SizedBox(height: 24),
          ...state.plans.map((plan) => _buildPlanEditCard(plan, state.securityLimits['MAX_PLAN_PAGE_LIMIT'] ?? 50)),
        ],
      ),
    );
  }

  Widget _buildPlanEditCard(Map<String, dynamic> plan, int maxAllowed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan['display_name'], style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("Price: ${plan['monthly_price']} EGP/mo", style: AppTypography.caption),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.web_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
                    SizedBox(width: 8),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Edit Plan: ${plan['id']}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, hintText: "Display Name"),
                SizedBox(height: 16),
                CustomTextField(
                  controller: priceController,
                  hintText: "Monthly Price (EGP)",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: limitController,
                  hintText: "Page Limit (Max $maxAllowed)",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Custom Domain Access", style: TextStyle(fontSize: 14)),
                  value: customDomain,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => customDomain = val),
                ),
                SwitchListTile(
                  title: const Text("Advanced SEO Access", style: TextStyle(fontSize: 14)),
                  value: seoAccess,
                  activeColor: Theme.of(context).colorScheme.secondary,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 12),
              Text("Infrastructure Security Boundaries", style: AppTypography.h3),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "These limits are fixed at the database level and cannot be changed through the UI. They prevent accidental or intentional abuse of system resources.",
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 32),
          _buildSecurityLimitCard("Global Plan Cap", "${state.securityLimits['MAX_PLAN_PAGE_LIMIT'] ?? 50} pages", "The highest page limit any business plan can be configured to have."),
          SizedBox(height: 16),
          _buildSecurityLimitCard("Super Admin Cap", "${state.securityLimits['SUPER_ADMIN_PAGE_LIMIT'] ?? 500} pages", "The absolute hard limit for Super Admin accounts."),
        ],
      ),
    );
  }

  Widget _buildSecurityLimitCard(String title, String value, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2)),
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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(20)),
                child: Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(desc, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildAuditTab(SuperAdminLoaded state) {
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



  Widget _buildPaymentsTab(SuperAdminLoaded state) {
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

  Widget _buildStatsTab(SuperAdminLoaded state) {
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
              Expanded(child: _buildMetricMiniCard("إجمالي المشاهدات", stats['total_views'].toString(), Icons.visibility_rounded, Theme.of(context).colorScheme.secondary)),
              SizedBox(width: 16),
              Expanded(child: _buildMetricMiniCard("إجمالي المبيات", stats['total_purchases'].toString(), Icons.shopping_cart_rounded, Colors.green)),
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

  Widget _buildMetricMiniCard(String title, String value, IconData icon, Color color) {
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
  Widget _buildAffiliatesTab(SuperAdminLoaded state) {
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

  // ----------------------------------------------------
  // TEMPLATES TAB
  // ----------------------------------------------------

  Widget _buildTemplatesTab(SuperAdminLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Template Management", style: AppTypography.h3),
              Row(
                children: [
                  PrimaryButton(
                    text: "Seed from Registry",
                    width: 180,
                    isSecondary: true,
                    onPressed: () => _seedTemplatesFromRegistry(),
                  ),
                  SizedBox(width: 12),
                  PrimaryButton(
                    text: "Add Template",
                    width: 160,
                    onPressed: () => _showTemplateEditorDialog(null),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          ResponsiveDataTable(
            title: "All Templates",
            headers: const [
              "Name",
              "Category",
              "Status",
              "Homepage",
              "Actions",
            ],
            rows: state.templates.map((t) {
              final isDraft = t['is_draft'] == true;
              final isFeatured = t['is_featured'] == true;
              final isActive = t['is_active'] == true;
              return [
                Flexible(
                  child: Text(
                    t['name'] ?? '',
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(t['category'] ?? 'general', style: AppTypography.bodyMedium),
                StatusPill(
                  label: isDraft ? "Draft" : "Live",
                  color: isDraft ? Colors.orange : Colors.green,
                ),
                StatusPill(
                  label: isFeatured ? "Featured" : "Standard",
                  color: isFeatured ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_rounded, size: 18, color: Theme.of(context).colorScheme.secondary),
                      tooltip: "Edit",
                      onPressed: () => _showTemplateEditorDialog(t),
                    ),
                    IconButton(
                      icon: Icon(
                        isDraft ? Icons.publish_rounded : Icons.drafts_rounded,
                        size: 18,
                        color: isDraft ? Colors.green : Colors.orange,
                      ),
                      tooltip: isDraft ? "Publish" : "Set as Draft",
                      onPressed: () => context.read<SuperAdminCubit>().toggleTemplateStatus(
                        t['id'],
                        isDraft: !isDraft,
                      ),
                    ),
                    if (isActive)
                      IconButton(
                        icon: Icon(Icons.delete_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                        tooltip: "Delete",
                        onPressed: () => _confirmDeleteTemplate(t['id']),
                      ),
                  ],
                ),
              ];
            }).toList(),
            emptyMessage: "No templates found. Click 'Add Template' to create one.",
            onSearch: (v) {},
            onSort: (v) {},
            onPageChanged: (p) {},
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTemplate(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to soft-delete this template? It will be hidden from users."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          PrimaryButton(
            text: "Delete",
            width: 120,
            onPressed: () {
              context.read<SuperAdminCubit>().deleteTemplate(id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _seedTemplatesFromRegistry() async {
    final templates = TemplateRegistry.availableTemplates.map((t) {
      final design = TemplateRegistry.getTemplateDesign(t.id);
      return <String, dynamic>{
        'id': t.id,
        'name': t.name,
        'description': t.description,
        'image_url': t.imageUrl,
        'category': t.category,
        'recommended_sections': t.recommendedSections,
        'ai_prompt_hint': t.aiPromptHint,
        'design_json': design,
      };
    }).toList();

    final cubit = context.read<SuperAdminCubit>();
    final count = await cubit.seedTemplatesFromRegistry(templates);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Seeded $count templates from registry. Existing templates were skipped."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showTemplateEditorDialog(Map<String, dynamic>? existing) {
    final isEditing = existing != null;
    final idController = TextEditingController(text: existing?['id'] ?? '');
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final descriptionController = TextEditingController(text: existing?['description'] ?? '');
    final imageUrlController = TextEditingController(text: existing?['image_url'] ?? '');
    final categoryController = TextEditingController(text: existing?['category'] ?? 'general');
    final aiHintController = TextEditingController(text: existing?['ai_prompt_hint'] ?? '');

    String designJsonText = '';
    if (existing?['design_json'] != null) {
      final dj = existing!['design_json'];
      if (dj is String) {
        designJsonText = dj;
      } else {
        designJsonText = const JsonEncoder.withIndent('  ').convert(dj);
      }
    } else {
      designJsonText = '{"blocks": []}';
    }
    final designJsonController = TextEditingController(text: designJsonText);

    bool isDraft = existing?['is_draft'] ?? false;
    bool isFeatured = existing?['is_featured'] ?? false;

    String? jsonError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(isEditing ? "Edit Template: ${existing!['name']}" : "Add New Template"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: idController,
                  hintText: "Template ID (e.g. saas_startup)",
                  label: "ID",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: nameController,
                  hintText: "Template Name",
                  label: "Name",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: descriptionController,
                  hintText: "Brief description",
                  label: "Description",
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: imageUrlController,
                  hintText: "Cover image URL",
                  label: "Image URL",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: categoryController,
                  hintText: "e.g. technology, ecommerce",
                  label: "Category",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: aiHintController,
                  hintText: "AI generation hint",
                  label: "AI Prompt Hint",
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                Text("Design JSON (blocks map)", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: jsonError != null ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: designJsonController,
                    maxLines: 8,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    decoration: InputDecoration(
                      hintText: '{ "blocks": [...] }',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      errorText: jsonError,
                    ),
                    onChanged: (_) {
                      setDialogState(() {
                        jsonError = null;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Is Draft (hidden from users)", style: TextStyle(fontSize: 14)),
                  value: isDraft,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => isDraft = val),
                ),
                SwitchListTile(
                  title: const Text("Featured on Homepage", style: TextStyle(fontSize: 14)),
                  value: isFeatured,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => isFeatured = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            PrimaryButton(
              text: isEditing ? "Save Changes" : "Create Template",
              width: 160,
              onPressed: () {
                if (idController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template ID is required")),
                  );
                  return;
                }
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template name is required")),
                  );
                  return;
                }
                if (imageUrlController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Image URL is required")),
                  );
                  return;
                }
                final uri = Uri.tryParse(imageUrlController.text.trim());
                if (uri == null || !uri.isAbsolute) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid image URL. Must be an absolute URL (e.g. https://...)")),
                  );
                  return;
                }

                dynamic parsedJson;
                try {
                  parsedJson = jsonDecode(designJsonController.text);
                } catch (e) {
                  setDialogState(() {
                    jsonError = "Invalid JSON: ${e.toString()}";
                  });
                  return;
                }

                final data = <String, dynamic>{
                  'id': idController.text.trim(),
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'image_url': imageUrlController.text.trim(),
                  'category': categoryController.text.trim().isEmpty ? 'general' : categoryController.text.trim(),
                  'ai_prompt_hint': aiHintController.text.trim(),
                  'design_json': parsedJson,
                  'is_draft': isDraft,
                  'is_featured': isFeatured,
                };

                if (isEditing) {
                  context.read<SuperAdminCubit>().updateTemplate(existing!['id'], data);
                } else {
                  data['is_active'] = true;
                  context.read<SuperAdminCubit>().createTemplate(data);
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
