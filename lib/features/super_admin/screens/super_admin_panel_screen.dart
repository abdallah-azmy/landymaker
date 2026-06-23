import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/database_service.dart';
import '../../../injection_container.dart' as di;
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../builder/registries/template_registry.dart';
import '../../../services/supabase_service.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';
import '../controllers/homepage_editor_cubit.dart';
import 'homepage_editor_screen.dart';
import '../widgets/bulk_action_bar.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../../../core/widgets/atoms/cube_refresh_indicator.dart';

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
  String? _lastTabParam;

  bool _bulkSelectionMode = false;
  final Set<String> _selectedUserIds = {};

  late final TextEditingController _broadcastTitleController;
  late final TextEditingController _broadcastMessageController;
  late final TextEditingController _broadcastRedirectController;
  String _broadcastType = 'info';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _broadcastTitleController = TextEditingController();
    _broadcastMessageController = TextEditingController();
    _broadcastRedirectController = TextEditingController();
    context.read<SuperAdminCubit>().fetchAdminMetrics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    if (tabParam != _lastTabParam) {
      _lastTabParam = tabParam;
      if (tabParam != null) {
        final tabIndex = _tabIndexForParam(tabParam);
        if (tabIndex != null && tabIndex != _tabController.index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _tabController.animateTo(tabIndex);
          });
        }
      }
    }
  }

  int? _tabIndexForParam(String tab) {
    switch (tab) {
      case 'users':
        return 0;
      case 'plans':
        return 1;
      case 'security':
        return 2;
      case 'audit':
        return 3;
      case 'stats':
        return 4;
      case 'payments':
        return 5;
      case 'affiliates':
        return 6;
      case 'templates':
        return 7;
      case 'broadcast':
        return 8;
      case 'homepage':
        return 9;
      case 'landing-pages':
        return 10;
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _broadcastTitleController.dispose();
    _broadcastMessageController.dispose();
    _broadcastRedirectController.dispose();
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
          Tab(text: "Broadcast", icon: Icon(Icons.campaign_rounded)),
          Tab(text: "Homepage", icon: Icon(Icons.web_rounded)),
          Tab(text: "Landing Pages", icon: Icon(Icons.web_asset_rounded)),
        ],
      ),
      body: CubeRefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: () => context.read<SuperAdminCubit>().fetchAdminMetrics(),
        child: state is SuperAdminLoaded
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
                  _buildBroadcastTab(state),
                  _buildHomepageTab(),
                  _buildLandingPagesTab(state),
                ],
              )
            : const Center(child: LoadingLogo()),
      ),
      ),
    );
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
        if (_selectedUserIds.isEmpty) _bulkSelectionMode = false;
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _toggleSelectAll(List<Map<String, dynamic>> users) {
    setState(() {
      if (_selectedUserIds.length == users.length) {
        _selectedUserIds.clear();
        _bulkSelectionMode = false;
      } else {
        _selectedUserIds.addAll(users.map((u) => u['id'].toString()));
      }
    });
  }

  void _exitBulkMode() {
    setState(() {
      _bulkSelectionMode = false;
      _selectedUserIds.clear();
    });
  }

  Future<void> _bulkRenew(List<Map<String, dynamic>> users) async {
    final months = await _showDurationPicker();
    if (months == null || months == 0) return;
    final ids = _selectedUserIds.toList();
    _exitBulkMode();
    try {
      await context.read<SuperAdminCubit>().bulkAddSubscriptionMonths(ids, months);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تجديد الاشتراك لـ ${ids.length} مستخدم لمدة $months شهر')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التجديد: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _bulkUpgrade(List<Map<String, dynamic>> users) async {
    final tier = await _showTierPicker('ترقية الباقة');
    if (tier == null) return;
    final ids = _selectedUserIds.toList();
    _exitBulkMode();
    try {
      await context.read<SuperAdminCubit>().bulkUpdateUserTier(ids, tier);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم ترقية ${ids.length} مستخدم إلى $tier')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الترقية: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _bulkDowngrade(List<Map<String, dynamic>> users) async {
    final tier = await _showTierPicker('تخفيض الباقة');
    if (tier == null) return;
    final ids = _selectedUserIds.toList();
    _exitBulkMode();
    try {
      await context.read<SuperAdminCubit>().bulkUpdateUserTier(ids, tier);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تخفيض ${ids.length} مستخدم إلى $tier')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التخفيض: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _bulkBlock(List<Map<String, dynamic>> users) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحظر'),
        content: Text('هل أنت متأكد من حظر ${_selectedUserIds.length} مستخدم؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حظر', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final ids = _selectedUserIds.toList();
    _exitBulkMode();
    try {
      await context.read<SuperAdminCubit>().bulkBlockUsers(ids, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حظر ${ids.length} مستخدم')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحظر: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _bulkUnblock(List<Map<String, dynamic>> users) async {
    final ids = _selectedUserIds.toList();
    _exitBulkMode();
    try {
      await context.read<SuperAdminCubit>().bulkBlockUsers(ids, false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إلغاء الحظر عن ${ids.length} مستخدم')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إلغاء الحظر: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _bulkNotify(List<Map<String, dynamic>> users) async {
    final ids = _selectedUserIds.toList();
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final redirectCtrl = TextEditingController();
    String notifType = 'info';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إرسال إشعار للمستخدمين المحددين'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('عدد المستخدمين: ${ids.length}', style: AppTypography.bodyMedium),
                const SizedBox(height: 12),
                CustomTextField(label: 'العنوان', controller: titleCtrl, hint: 'عنوان الإشعار'),
                const SizedBox(height: 8),
                CustomTextField(label: 'الرسالة', controller: msgCtrl, hint: 'محتوى الإشعار', maxLines: 3),
                const SizedBox(height: 8),
                CustomTextField(label: 'رابط التوجيه (اختياري)', controller: redirectCtrl, hint: '/dashboard'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: notifType,
                  decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'info', child: Text('معلومات')),
                    DropdownMenuItem(value: 'warning', child: Text('تحذير')),
                    DropdownMenuItem(value: 'promo', child: Text('ترويج')),
                  ],
                  onChanged: (v) => notifType = v ?? 'info',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إرسال')),
        ],
      ),
    );

    if (result != true || titleCtrl.text.isEmpty || msgCtrl.text.isEmpty) return;
    _exitBulkMode();
    try {
      await context.read<SuperAdminCubit>().bulkSendNotification(ids, titleCtrl.text, msgCtrl.text, notifType, redirectTo: redirectCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال الإشعار لـ ${ids.length} مستخدم')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الإشعار: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<int?> _showDurationPicker() async {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر مدة التجديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 1), child: const Text('شهر واحد')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 3), child: const Text('3 أشهر')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 12), child: const Text('سنة كاملة')),
          ],
        ),
      ),
    );
  }

  Future<String?> _showTierPicker(String title) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 'free'), child: const Text('Free')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 'pro'), child: const Text('Pro')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, 'business'), child: const Text('Business')),
          ],
        ),
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

    final isAllSelected = filteredUsers.isNotEmpty && _selectedUserIds.length == filteredUsers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("إدارة مستخدمي المنصة", style: AppTypography.h2),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _bulkSelectionMode = !_bulkSelectionMode),
                    icon: Icon(_bulkSelectionMode ? Icons.close_rounded : Icons.checklist_rounded),
                    label: Text(_bulkSelectionMode ? 'إلغاء التحديد' : 'تحديد متعدد'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showSendNotificationDialog(allUsers: state.users),
                    icon: const Icon(Icons.notifications_active_rounded),
                    label: const Text("إرسال إشعار لمجموعة مستخدمين"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ResponsiveDataTable(
            title: "قائمة الأعضاء",
            headers: _bulkSelectionMode
                ? ["☐", "الاسم", "البريد", "المستوى", "الصفحات", "إجراء"]
                : const ["الاسم", "البريد", "المستوى", "الصفحات", "إجراء"],
            rows: filteredUsers
                .map(
                  (u) => _bulkSelectionMode
                      ? [
                          Checkbox(
                            value: _selectedUserIds.contains(u['id']),
                            onChanged: (_) => _toggleUserSelection(u['id']),
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () => context.go('/dashboard/super-admin/users/${u['id']}'),
                              child: Text(u['full_name'] ?? '', style: AppTypography.bodyLarge, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Flexible(child: Text(u['email'] ?? '', style: AppTypography.bodyMedium, overflow: TextOverflow.ellipsis)),
                          StatusPill(
                            label: u['tier'].toString().toUpperCase(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(u['pages_count']?.toString() ?? '0', style: AppTypography.bodyMedium),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary),
                                onPressed: () => _showSendNotificationDialog(singleUser: u, allUsers: state.users),
                                tooltip: "إرسال إشعار خاص",
                              ),
                              IconButton(
                                icon: Icon(Icons.manage_accounts_rounded, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () => _showEditUserDialog(u, state.plans),
                                tooltip: "تعديل الصلاحيات والباقة",
                              ),
                            ],
                          ),
                        ]
                      : [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => context.go('/dashboard/super-admin/users/${u['id']}'),
                              child: Text(u['full_name'] ?? '', style: AppTypography.bodyLarge, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Flexible(child: Text(u['email'] ?? '', style: AppTypography.bodyMedium, overflow: TextOverflow.ellipsis)),
                          StatusPill(
                            label: u['tier'].toString().toUpperCase(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(u['pages_count']?.toString() ?? '0', style: AppTypography.bodyMedium),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary),
                                onPressed: () => _showSendNotificationDialog(singleUser: u, allUsers: state.users),
                                tooltip: "إرسال إشعار خاص",
                              ),
                              IconButton(
                                icon: Icon(Icons.manage_accounts_rounded, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () => _showEditUserDialog(u, state.plans),
                                tooltip: "تعديل الصلاحيات والباقة",
                              ),
                            ],
                          ),
                        ],
                )
                .toList(),
            emptyMessage: "لا يوجد مستخدمين بهذا الاسم",
            onSearch: (val) => setState(() => _searchQuery = val),
            onSort: (val) => setState(() => _currentSort = val),
            sortOptions: const ["الاسم", "التاريخ"],
            onPageChanged: (p) {},
            bulkActionBar: _bulkSelectionMode
                ? BulkActionBar(
                    selectedCount: _selectedUserIds.length,
                    onCancel: _exitBulkMode,
                    onRenew: () => _bulkRenew(filteredUsers),
                    onUpgrade: () => _bulkUpgrade(filteredUsers),
                    onDowngrade: () => _bulkDowngrade(filteredUsers),
                    onBlock: () => _bulkBlock(filteredUsers),
                    onUnblock: () => _bulkUnblock(filteredUsers),
                    onNotify: () => _bulkNotify(filteredUsers),
                  )
                : null,
            mobileCardBuilder: (index, cells) {
              final u = filteredUsers[index];
              final name = u['full_name']?.toString() ?? '';
              final email = u['email']?.toString() ?? '';
              final tier = u['tier']?.toString() ?? '';
              final pagesCount = u['pages_count']?.toString() ?? '0';
              final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';
              final avatarColors = [
                Colors.blueAccent, Colors.teal, Colors.amber, Colors.pinkAccent,
                Colors.indigo, Colors.cyan, Colors.orangeAccent, Colors.purpleAccent,
              ];
              final avatarColor = avatarColors[index % avatarColors.length];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_bulkSelectionMode)
                          Checkbox(
                            value: _selectedUserIds.contains(u['id']),
                            onChanged: (_) => _toggleUserSelection(u['id']),
                          ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: avatarColor,
                          child: Text(firstLetter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.go('/dashboard/super-admin/users/${u['id']}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(email, style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_active_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                          onPressed: () => _showSendNotificationDialog(singleUser: u, allUsers: state.users),
                          tooltip: "إرسال إشعار خاص",
                        ),
                        IconButton(
                          icon: Icon(Icons.manage_accounts_rounded, color: Theme.of(context).colorScheme.secondary, size: 20),
                          onPressed: () => _showEditUserDialog(u, state.plans),
                          tooltip: "تعديل الصلاحيات والباقة",
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StatusPill(label: tier.toUpperCase(), color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Icon(Icons.description_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text("$pagesCount صفحات", style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSendNotificationDialog({Map<String, dynamic>? singleUser, required List<Map<String, dynamic>> allUsers}) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final redirectCtrl = TextEditingController();
    String notifType = 'info';

    List<String> selectedUserIds = [];
    if (singleUser != null) {
      selectedUserIds.add(singleUser['id'].toString());
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredList = allUsers.where((u) => u['id'] != singleUser?['id']).toList();

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              singleUser != null
                  ? "إرسال إشعار خاص إلى: ${singleUser['full_name']}"
                  : "إرسال إشعار لمجموعة مستخدمين",
              style: AppTypography.h3,
            ),
            content: Container(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (singleUser == null) ...[
                      Text("اختر المستخدمين (${selectedUserIds.length} محدد):", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final u = filteredList[index];
                            final id = u['id'].toString();
                            final isChecked = selectedUserIds.contains(id);
                            return CheckboxListTile(
                              title: Text(u['full_name'] ?? '', style: AppTypography.bodyMedium),
                              subtitle: Text(u['email'] ?? '', style: AppTypography.caption),
                              value: isChecked,
                              onChanged: (val) {
                                setDialogState(() {
                                  if (val == true) {
                                    selectedUserIds.add(id);
                                  } else {
                                    selectedUserIds.remove(id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text("عنوان الإشعار", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: titleCtrl,
                      hintText: "مثال: عرض خاص ومميز لك 🎁",
                    ),
                    const SizedBox(height: 16),
                    Text("نص الرسالة", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: msgCtrl,
                      hintText: "أدخل محتوى الإشعار هنا...",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text("نوع الإشعار", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: notifType,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'info', child: Text("Info (عام)")),
                        DropdownMenuItem(value: 'broadcast', child: Text("Broadcast (إعلان)")),
                        DropdownMenuItem(value: 'warning', child: Text("Warning (تحذير)")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => notifType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text("رابط التوجيه عند الضغط (اختياري)", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: redirectCtrl,
                      hintText: "مثال: /dashboard/leads أو /dashboard/settings",
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  titleCtrl.dispose();
                  msgCtrl.dispose();
                  redirectCtrl.dispose();
                  Navigator.pop(context);
                },
                child: const Text("إلغاء"),
              ),
              PrimaryButton(
                text: "إرسال الإشعار",
                width: 150,
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final msg = msgCtrl.text.trim();
                  final redir = redirectCtrl.text.trim();
                  if (selectedUserIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("يرجى اختيار مستخدم واحد على الأقل!")),
                    );
                    return;
                  }
                  if (title.isEmpty || msg.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("العنوان والرسالة مطلوبان!")),
                    );
                    return;
                  }

                  try {
                    await SupabaseService.instance.sendTargetedNotification(
                      selectedUserIds,
                      title,
                      msg,
                      notifType,
                      redirectTo: redir.isEmpty ? null : redir,
                    );
                    titleCtrl.dispose();
                    msgCtrl.dispose();
                    redirectCtrl.dispose();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم إرسال الإشعار الخاص بنجاح!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("فشل الإرسال: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
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
                initialValue: selectedTier,
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
                initialValue: selectedRole,
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
                    SizedBox(width: 16),
                    Icon(Icons.auto_awesome_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 8),
                    Text("AI Limit: ${plan['ai_generation_limit'] ?? 0} attempts", style: AppTypography.bodyMedium),
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
    final aiLimitController = TextEditingController(text: (plan['ai_generation_limit'] ?? 0).toString());
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
                CustomTextField(
                  controller: aiLimitController,
                  hintText: "AI Generation Limit",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Custom Domain Access", style: TextStyle(fontSize: 14)),
                  value: customDomain,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => customDomain = val),
                ),
                SwitchListTile(
                  title: const Text("Advanced SEO Access", style: TextStyle(fontSize: 14)),
                  value: seoAccess,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
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
                final newAiLimit = int.tryParse(aiLimitController.text) ?? 0;
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
                  'ai_generation_limit': newAiLimit,
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
          title: Text(isEditing ? "Edit Template: ${existing['name']}" : "Add New Template"),
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
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => isDraft = val),
                ),
                SwitchListTile(
                  title: const Text("Featured on Homepage", style: TextStyle(fontSize: 14)),
                  value: isFeatured,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
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
                  context.read<SuperAdminCubit>().updateTemplate(existing['id'], data);
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

  Widget _buildBroadcastTab(SuperAdminLoaded state) {
    return StatefulBuilder(
      builder: (context, setTabState) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text("System Broadcast Notifications", style: AppTypography.h3),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Create and send custom push/in-app notifications to all registered users simultaneously across all devices.",
              style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notification Title", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _broadcastTitleController,
                    hintText: "Enter title (e.g. تحديث جديد بالمنصة 🚀)",
                  ),
                  const SizedBox(height: 20),
                  Text("Notification Message / Body", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _broadcastMessageController,
                    hintText: "Enter detailed message text",
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  Text("Notification Type", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _broadcastType,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'info', child: Text("Info (General Info)")),
                      DropdownMenuItem(value: 'broadcast', child: Text("Broadcast (Announcements)")),
                      DropdownMenuItem(value: 'warning', child: Text("Warning (Alerts)")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setTabState(() => _broadcastType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text("Redirect Path / URL (Optional)", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _broadcastRedirectController,
                    hintText: "e.g. /dashboard/leads or /dashboard/products",
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: "Send Broadcast to All Users",
                    icon: Icons.send_rounded,
                    width: double.infinity,
                    onPressed: () {
                      final title = _broadcastTitleController.text.trim();
                      final message = _broadcastMessageController.text.trim();
                      final redirectTo = _broadcastRedirectController.text.trim();
                      if (title.isEmpty || message.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Title and Message cannot be empty!")),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          title: const Text("Confirm Broadcast"),
                          content: Text("Are you sure you want to send this notification to all ${state.users.length} registered users? This action cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("Cancel"),
                            ),
                            PrimaryButton(
                              text: "Yes, Send",
                              width: 120,
                              onPressed: () async {
                                Navigator.pop(dialogContext);
                                try {
                                  await SupabaseService.instance.broadcastNotification(
                                    title,
                                    message,
                                    _broadcastType,
                                    redirectTo: redirectTo.isEmpty ? null : redirectTo,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Broadcast sent successfully to all users!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _broadcastTitleController.clear();
                                    _broadcastMessageController.clear();
                                    _broadcastRedirectController.clear();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Failed to send: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomepageTab() {
    return BlocProvider(
      create: (_) => HomepageEditorCubit(di.sl<DatabaseService>()),
      child: const HomepageEditorScreen(),
    );
  }

  Widget _buildLandingPagesTab(SuperAdminLoaded state) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: di.sl<DatabaseService>().fetchAllLandingPages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingLogo());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.web_asset_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('لا توجد صفحات هبوط', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        final pages = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            final id = page['id']?.toString() ?? '';
            final name = page['name'] as String? ?? 'بدون اسم';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.web_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(name),
                subtitle: Text(id.length > 12 ? '${id.substring(0, 12)}...' : id, style: Theme.of(context).textTheme.bodySmall),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new_rounded),
                  onPressed: () => context.go('/builder/$id'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
