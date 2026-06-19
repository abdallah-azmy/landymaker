import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database_service.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final DatabaseService _databaseService;

  UserProfileCubit(this._databaseService) : super(UserProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(UserProfileLoading());
    try {
      final results = await Future.wait([
        _databaseService.getProfile(userId),
        _databaseService.getLandingPagesByUserId(userId),
        _databaseService.getUserSubscriptionRequests(userId),
        _databaseService.getUserAuditLogs(userId),
        _databaseService.getUserAggregatedAnalytics(userId),
      ]);

      final profile = results[0] as Map<String, dynamic>? ?? {};
      final pages = results[1] as List<Map<String, dynamic>>;
      final subscriptionRequests = results[2] as List<Map<String, dynamic>>;
      final auditLogs = results[3] as List<Map<String, dynamic>>;
      final analytics = results[4] as Map<String, dynamic>;

      emit(UserProfileLoaded(
        profile: profile,
        pages: pages,
        subscriptionRequests: subscriptionRequests,
        auditLogs: auditLogs,
        analytics: analytics,
      ));
    } catch (e) {
      emit(UserProfileFailure('فشل تحميل بيانات المستخدم: $e'));
    }
  }

  Future<void> blockUser(String userId) async {
    if (state is! UserProfileLoaded) return;
    try {
      await _databaseService.updateUserProfile(userId, {
        'is_blocked': true,
        'blocked_at': DateTime.now().toUtc().toIso8601String(),
      });
      await loadProfile(userId);
    } catch (e) {
      emit(UserProfileFailure('فشل حظر المستخدم: $e'));
    }
  }

  Future<void> unblockUser(String userId) async {
    if (state is! UserProfileLoaded) return;
    try {
      await _databaseService.updateUserProfile(userId, {
        'is_blocked': false,
        'blocked_at': null,
      });
      await loadProfile(userId);
    } catch (e) {
      emit(UserProfileFailure('فشل إلغاء حظر المستخدم: $e'));
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    if (state is! UserProfileLoaded) return;
    try {
      await _databaseService.updateUserProfile(userId, data);
      await loadProfile(userId);
    } catch (e) {
      emit(UserProfileFailure('فشل تحديث بيانات المستخدم: $e'));
    }
  }
}
