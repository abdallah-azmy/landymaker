import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/database_service.dart';
import '../../../injection_container.dart';
import '../controllers/user_profile_cubit.dart';
import '../controllers/user_profile_state.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final UserProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = UserProfileCubit(sl<DatabaseService>())..loadProfile(widget.userId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('بروفايل المستخدم'),
      ),
      body: BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UserProfileFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(state.message, style: TextStyle(color: theme.colorScheme.error)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<UserProfileCubit>().loadProfile(widget.userId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            if (state is! UserProfileLoaded) {
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                children: [
                  _buildUserHeader(state, theme),
                  const SizedBox(height: 16),
                  _buildPagesSection(state, theme),
                  const SizedBox(height: 16),
                  _buildSubscriptionSection(state, theme),
                  const SizedBox(height: 16),
                  _buildStatsSection(state, theme),
                  const SizedBox(height: 16),
                  _buildActivitySection(state, theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserProfileLoaded state, ThemeData theme) {
    final p = state.profile;
    final fullName = p['full_name'] as String? ?? 'بدون اسم';
    final email = p['email'] as String? ?? '';
    final tier = (p['tier'] as String? ?? 'free').toUpperCase();
    final role = p['role'] as String? ?? 'user';
    final isBlocked = p['is_blocked'] == true;
    final createdAt = p['created_at'] as String? ?? '';
    final joinedYear = createdAt.length >= 4 ? createdAt.substring(0, 4) : '';

    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: isBlocked
                  ? theme.colorScheme.error.withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isBlocked ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(fullName, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            if (joinedYear.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4),
                child: Text('عضو منذ $joinedYear', style: AppTypography.caption),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPill(tier, theme.colorScheme.primary, theme),
                const SizedBox(width: 8),
                _buildPill(role, theme.colorScheme.secondary, theme),
                if (isBlocked) ...[
                  const SizedBox(width: 8),
                  _buildPill('محظور', theme.colorScheme.error, theme),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'تعديل',
                  onPressed: () => _showEditDialog(context, state),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                  label: isBlocked ? 'إلغاء الحظر' : 'حظر',
                  color: isBlocked ? Colors.green : theme.colorScheme.error,
                  onPressed: () {
                    final cubit = context.read<UserProfileCubit>();
                    if (isBlocked) {
                      cubit.unblockUser(widget.userId);
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تأكيد الحظر'),
                          content: Text('هل أنت متأكد من حظر $email؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                cubit.blockUser(widget.userId);
                              },
                              child: const Text('حظر'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color?.withValues(alpha: 0.5) ?? const Color(0xFF6366F1).withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPagesSection(UserProfileLoaded state, ThemeData theme) {
    final pages = state.pages;
    final count = state.analytics['pages_count'] ?? pages.length;

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('صفحات الهبوط: $count صفحات',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (pages.isEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8),
                child: Text('لا توجد صفحات بعد', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              )
            else
              ...pages.take(4).map((page) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          page['is_published'] == true ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                          size: 20,
                          color: page['is_published'] == true ? Colors.green : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            page['name'] as String? ?? 'بدون اسم',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          page['is_published'] == true ? 'منشور' : 'مسودة',
                          style: AppTypography.caption.copyWith(
                            color: page['is_published'] == true ? Colors.green : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )),
            if (pages.length > 4)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8),
                child: Center(
                  child: Text('+ ${pages.length - 4} صفحات أخرى',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(UserProfileLoaded state, ThemeData theme) {
    final p = state.profile;
    final tier = (p['tier'] as String? ?? 'free').toUpperCase();
    final endDate = p['subscription_end_date'] as String?;
    final isBlocked = p['is_blocked'] == true;

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('الاشتراك والحالة',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الباقة', tier, theme),
            const SizedBox(height: 6),
            _buildInfoRow(
              'الحالة',
              isBlocked ? 'محظور' : endDate != null ? 'نشط' : 'مجاني',
              theme,
              color: isBlocked ? theme.colorScheme.error : Colors.green,
            ),
            if (endDate != null) ...[
              const SizedBox(height: 6),
              _buildInfoRow('تاريخ الانتهاء', _formatDate(endDate), theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserProfileLoaded state, ThemeData theme) {
    final analytics = state.analytics;
    final views = analytics['total_views'] ?? 0;
    final leads = analytics['total_leads'] ?? 0;

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('إحصائيات سريعة',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('المشاهدات', views.toString(), Icons.visibility_rounded, theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('الليدات', leads.toString(), Icons.person_add_rounded, theme)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildActivitySection(UserProfileLoaded state, ThemeData theme) {
    final logs = state.auditLogs;

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('سجل النشاطات (آخر ${logs.length})',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              Text('لا توجد نشاطات', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
            else
              ...logs.take(5).map((log) => Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsetsDirectional.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log['action'] as String? ?? '',
                                style: AppTypography.bodySmall,
                              ),
                              Text(
                                _formatDate(log['created_at'] as String? ?? ''),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    if (iso.length < 10) return iso;
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }

  void _showEditDialog(BuildContext context, UserProfileLoaded state) {
    final p = state.profile;
    final nameController = TextEditingController(text: p['full_name'] as String? ?? '');
    final tierController = TextEditingController(text: p['tier'] as String? ?? 'free');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل بيانات المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tierController,
              decoration: InputDecoration(
                labelText: 'المستوى (tier)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProfileCubit>().updateProfile(widget.userId, {
                'full_name': nameController.text,
                'tier': tierController.text,
              });
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
