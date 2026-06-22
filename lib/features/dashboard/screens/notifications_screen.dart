import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/molecules/page_context_banner.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().fetchNotifications();
  }

  String _formatFriendlyDate(String rawDate, LocalizationCubit loc) {
    if (rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(parsed);

      if (diff.inMinutes < 1) {
        return loc.translate('just_now');
      } else if (diff.inMinutes < 60) {
        return loc.isRtl
            ? 'منذ $diff.inMinutes دقيقة'
            : '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return loc.isRtl
            ? 'منذ $diff.inHours ساعة'
            : '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return loc.isRtl ? 'منذ $diff.inDays أيام' : '${diff.inDays}d ago';
      } else {
        return "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
      }
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final cubit = context.watch<NotificationCubit>();
    final state = cubit.state;

    return Padding(
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
                    loc.translate('notifications'),
                    style: AppTypography.h1.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.translate('notifications_subtitle'),
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              if (state is NotificationLoaded && state.notifications.any((n) => n['is_read'] != true))
                TextButton.icon(
                  onPressed: () => cubit.markAllAsRead(),
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: Text(loc.translate('mark_all_read')),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          PageContextBanner(
            title: loc.translate('notifications_banner_title'),
            description: loc.translate('notifications_banner_desc'),
            icon: Icons.notifications_active_rounded,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: LoadingLogo());
                }

                if (state is NotificationFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loc.translate('failed_load_notifications'),
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: 8),
                        Text(state.message, style: AppTypography.caption),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => cubit.fetchNotifications(),
                          child: Text(loc.translate('retry')),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotificationLoaded) {
                  final list = state.notifications;

                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.translate('no_notifications'),
                              style: AppTypography.bodyLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final n = list[index];
                      final bool isRead = n['is_read'] == true;
                      final String type = n['type'] ?? 'info';
                      
                      IconData iconData = Icons.notifications_active_rounded;
                      Color color = Theme.of(context).colorScheme.secondary;

                      if (type == 'lead') {
                        iconData = Icons.person_add_alt_1_rounded;
                        color = Colors.green;
                      } else if (type == 'broadcast') {
                        iconData = Icons.campaign_rounded;
                        color = Colors.orange;
                      } else if (type == 'warning') {
                        iconData = Icons.warning_amber_rounded;
                        color = Colors.red;
                      }

                      return InkWell(
                        onTap: () {
                          if (!isRead) {
                            cubit.markAsRead(n['id']);
                          }
                          final String? redirectTo = n['redirect_to'];
                          final String type = n['type'] ?? 'info';
                          if (redirectTo != null && redirectTo.isNotEmpty) {
                            context.go(redirectTo);
                          } else {
                            if (type == 'lead') {
                              context.go('/dashboard/leads');
                            } else if (type == 'product') {
                              context.go('/dashboard/products');
                            } else if (type == 'domain') {
                              context.go('/dashboard/domain');
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.4)
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRead
                                  ? Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)
                                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              width: isRead ? 1 : 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(iconData, size: 24, color: color),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title'] ?? '',
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n['message'] ?? '',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatFriendlyDate(n['created_at'] ?? '', loc),
                                      style: AppTypography.caption.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
