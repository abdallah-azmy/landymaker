import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database_service.dart';
import 'super_admin_state.dart';

class SuperAdminCubit extends Cubit<SuperAdminState> {
  final DatabaseService _databaseService;

  SuperAdminCubit({required DatabaseService databaseService})
      : _databaseService = databaseService,
        super(SuperAdminInitial());

  Future<void> fetchAdminMetrics() async {
    emit(SuperAdminLoading());
    try {
      final metrics = await _databaseService.getSuperAdminMetrics();
      final users = await _databaseService.getAdminUsers();
      final pages = await _databaseService.getAdminPages();
      final requests = await _databaseService.getAdminSubscriptionRequests();
      final affiliates = await _databaseService.getAdminAffiliates();
      final globalStats = await _databaseService.getAdminGlobalStats();

      emit(SuperAdminLoaded(
        totalUsers: metrics['total_users'] ?? 0,
        activePages: metrics['active_pages'] ?? 0,
        totalLeads: metrics['total_leads'] ?? 0,
        users: users,
        pages: pages,
        requests: requests,
        affiliates: affiliates,
        globalStats: globalStats,
      ));
    } catch (e) {
      emit(SuperAdminFailure("Error loading admin metrics: \$e"));
    }
  }

  Future<void> approveRequest(String requestId) async {
    try {
      await _databaseService.updateSubscriptionStatus(requestId, 'approved');
      await fetchAdminMetrics(); // Refresh data
    } catch (e) {
      emit(SuperAdminFailure("Failed to approve: \$e"));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _databaseService.updateSubscriptionStatus(requestId, 'rejected');
      await fetchAdminMetrics(); // Refresh data
    } catch (e) {
      emit(SuperAdminFailure("Failed to reject: \$e"));
    }
  }
}
