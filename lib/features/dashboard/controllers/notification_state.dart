sealed class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;

  NotificationLoaded({required this.notifications});

  int get unreadCount => notifications.where((n) => n['is_read'] == false).length;

  NotificationLoaded copyWith({
    List<Map<String, dynamic>>? notifications,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationFailure extends NotificationState {
  final String message;
  NotificationFailure(this.message);
}
