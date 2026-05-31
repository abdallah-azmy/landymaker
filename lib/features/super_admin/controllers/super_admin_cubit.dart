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
      
      // New configurations
      final plans = await _databaseService.getSubscriptionPlans();
      final securityLimits = await _databaseService.getSystemSecurityLimits();
      final auditLogs = await _databaseService.getSystemAuditLogs();

      emit(SuperAdminLoaded(
        totalUsers: metrics['total_users'] ?? 0,
        activePages: metrics['active_pages'] ?? 0,
        totalLeads: metrics['total_leads'] ?? 0,
        users: users,
        pages: pages,
        requests: requests,
        affiliates: affiliates,
        globalStats: globalStats,
        plans: plans,
        securityLimits: securityLimits,
        auditLogs: auditLogs,
      ));
    } catch (e) {
      emit(SuperAdminFailure("Error loading admin metrics: $e"));
    }
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> data) async {
    try {
      await _databaseService.updateSubscriptionPlan(planId, data);
      await fetchAdminMetrics(); // Refresh all data to include audit logs
    } catch (e) {
      emit(SuperAdminFailure("Failed to update plan: $e"));
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _databaseService.updateUserProfile(userId, data);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to update user profile: $e"));
    }
  }

  Future<void> approveRequest(String requestId) async {
    try {
      await _databaseService.updateSubscriptionStatus(requestId, 'approved');
      await fetchAdminMetrics(); // Refresh data
    } catch (e) {
      emit(SuperAdminFailure("Failed to approve: $e"));
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _databaseService.updateSubscriptionStatus(requestId, 'rejected');
      await fetchAdminMetrics(); // Refresh data
    } catch (e) {
      emit(SuperAdminFailure("Failed to reject: $e"));
    }
  }
}
