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
      emit(SuperAdminLoaded(
        totalUsers: metrics['total_users'] ?? 0,
        activePages: metrics['active_pages'] ?? 0,
        totalLeads: metrics['total_leads'] ?? 0,
      ));
    } catch (e) {
      emit(SuperAdminFailure("Error loading admin metrics: $e"));
    }
  }
}
