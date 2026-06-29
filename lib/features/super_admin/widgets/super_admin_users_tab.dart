import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../services/supabase_service.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';
import 'bulk_action_bar.dart';

class SuperAdminUsersTab extends StatefulWidget {
  const SuperAdminUsersTab({super.key});

  @override
  State<SuperAdminUsersTab> createState() => _SuperAdminUsersTabState();
}

class _SuperAdminUsersTabState extends State<SuperAdminUsersTab> {
  String _searchQuery = '';
  bool _bulkSelectionMode = false;
  final Set<String> _selectedUserIds = {};

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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    final filteredUsers = state.users
        .where(
          (u) => u['full_name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

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
            onSort: (val) {},
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
}
