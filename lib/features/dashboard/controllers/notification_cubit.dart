import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final SupabaseService _supabase;
  final String _userId;
  RealtimeChannel? _subscription;

  NotificationCubit({required SupabaseService supabase, required String userId})
    : _supabase = supabase,
      _userId = userId,
      super(NotificationInitial()) {
    _initRealtime();
  }

  void _initRealtime() {
    _subscription = _supabase.client
        .channel('public:notifications:user_id=eq.\$_userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _userId,
          ),
          callback: (payload) {
            fetchNotifications();
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }

  Future<void> fetchNotifications() async {
    // Only emit loading on first fetch
    if (state is NotificationInitial) {
      emit(NotificationLoading());
    }
    try {
      final list = await _supabase.getNotifications(_userId);
      emit(NotificationLoaded(notifications: list));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.markNotificationAsRead(notificationId);
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        final updatedList = currentList.map((n) {
          if (n['id'] == notificationId) {
            return {...n, 'is_read': true};
          }
          return n;
        }).toList();
        emit(NotificationLoaded(notifications: updatedList));
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _supabase.markAllNotificationsAsRead(_userId);
      if (state is NotificationLoaded) {
        final currentList = (state as NotificationLoaded).notifications;
        final updatedList = currentList
            .map((n) => {...n, 'is_read': true})
            .toList();
        emit(NotificationLoaded(notifications: updatedList));
      }
    } catch (_) {}
  }
}
