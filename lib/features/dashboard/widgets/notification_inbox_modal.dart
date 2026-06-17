import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../controllers/notification_cubit.dart';
import '../controllers/notification_state.dart';

class NotificationInboxModal extends StatelessWidget {
  const NotificationInboxModal({super.key});

  static void show({required BuildContext context, required NotificationCubit cubit}) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const NotificationInboxModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = context.isRtl;

    return Align(
      alignment: isRtl ? Alignment.topLeft : Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 80, right: 24, left: 24),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Divider(height: 1),
                Flexible(child: _buildList(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.translate('notifications'),
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            child: Text(
              context.translate('mark_all_read'),
              style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is NotificationLoaded) {
          final list = state.notifications;
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      context.translate('no_notifications'),
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final n = list[index];
              return _NotificationItem(notification: n);
            },
          );
        }
        return SizedBox();
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['is_read'] == true;
    final String type = notification['type'] ?? 'info';

    return InkWell(
      onTap: () {
        if (!isRead) {
          context.read<NotificationCubit>().markAsRead(notification['id']);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isRead
            ? Colors.transparent
            : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(type),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] ?? '',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    context.translate('just_now'), // Simplified
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData iconData = Icons.notifications_active_rounded;
    Color color = Theme.of(context).colorScheme.secondary;

    if (type == 'lead') {
      iconData = Icons.person_add_alt_1_rounded;
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, size: 20, color: color),
    );
  }
}
