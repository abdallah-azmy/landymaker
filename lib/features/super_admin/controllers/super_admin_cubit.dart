import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/database_service.dart';
import 'super_admin_state.dart';

class SuperAdminCubit extends Cubit<SuperAdminState> {
  /// Default platform routes pre-seeded so admins can configure SEO for every
  /// public page without having to manually add each one.
  static const List<Map<String, dynamic>> defaultPlatformRoutes = [
    {
      'route_path': '/',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'الصفحة الرئيسية',
    },
    {
      'route_path': '/pricing',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'صفحة الأسعار',
    },
    {
      'route_path': '/templates',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'صفحة القوالب',
    },
    {
      'route_path': '/about',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'صفحة عن المنصة',
    },
    {
      'route_path': '/contact',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'صفحة الاتصال',
    },
    {
      'route_path': '/faq',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'صفحة الأسئلة الشائعة',
    },
    {
      'route_path': '/privacy',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'سياسة الخصوصية',
    },
    {
      'route_path': '/terms',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'شروط الخدمة',
    },
    {
      'route_path': '/cookies',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'سياسة ملفات تعريف الارتباط',
    },
    {
      'route_path': '/refund',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'سياسة الاسترجاع والاستبدال',
    },
    {
      'route_path': '/brand-assets',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'الموارد والعلامات التجارية',
    },
    {
      'route_path': '/affiliates',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'صفحة نظام الأفلييت',
    },
    {
      'route_path': '/blog',
      'meta_title': '',
      'meta_description': '',
      'og_image_url': '',
      'page_content': null,
      'admin_note': 'المدونة (قائمة المقالات)',
    },
  ];
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
      final dbSeoSettings = await _databaseService.getPlatformSeoSettings();
      final templates = await _databaseService.fetchAllTemplates();

      // Merge DB data with default routes — any route not yet in DB is added
      // so admins see every route they need to configure.
      final dbPaths = dbSeoSettings
          .map((s) => s['route_path'] as String)
          .toSet();
      final merged = <Map<String, dynamic>>[...dbSeoSettings];
      for (final def in defaultPlatformRoutes) {
        if (!dbPaths.contains(def['route_path'])) {
          merged.add(Map<String, dynamic>.from(def));
        }
      }

      emit(
        SuperAdminLoaded(
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
          platformSeoSettings: merged,
          templates: templates,
        ),
      );
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

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
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

  // ----------------------------------------------------
  // TEMPLATE MANAGEMENT
  // ----------------------------------------------------

  Future<void> createTemplate(Map<String, dynamic> data) async {
    try {
      await _databaseService.createTemplate(data);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to create template: $e"));
    }
  }

  Future<void> updateTemplate(String id, Map<String, dynamic> data) async {
    try {
      await _databaseService.updateTemplate(id, data);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to update template: $e"));
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _databaseService.deleteTemplate(id);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to delete template: $e"));
    }
  }

  Future<int> seedTemplatesFromRegistry(
    List<Map<String, dynamic>> templates,
  ) async {
    try {
      final count = await _databaseService.seedTemplatesFromRegistry(templates);
      await fetchAdminMetrics();
      return count;
    } catch (e) {
      emit(SuperAdminFailure("Failed to seed templates: $e"));
      return 0;
    }
  }

  Future<void> toggleTemplateStatus(
    String id, {
    bool? isDraft,
    bool? isFeatured,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (isDraft != null) updates['is_draft'] = isDraft;
      if (isFeatured != null) updates['is_featured'] = isFeatured;
      if (isActive != null) updates['is_active'] = isActive;
      await _databaseService.updateTemplate(id, updates);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to toggle template status: $e"));
    }
  }

  Future<void> updatePlatformSeo(
    String routePath,
    Map<String, dynamic> data,
  ) async {
    try {
      // Security Check: Block internal/protected routes from SEO configuration
      if (routePath.startsWith('/dashboard') ||
          routePath.startsWith('/login') ||
          routePath.startsWith('/register') ||
          routePath.startsWith('/builder')) {
        emit(
          SuperAdminFailure(
            "لا يمكن إضافة بيانات SEO لمسارات لوحة التحكم أو النظام الداخلي لأن محركات البحث لا تستطيع الوصول إليها.",
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        await fetchAdminMetrics();
        return;
      }

      final isAvailable = await _databaseService.isRouteAvailable(
        routePath,
        checkPlatform:
            false, // We don't check platform itself because we might be updating our own route
      );

      if (!isAvailable) {
        emit(
          SuperAdminFailure(
            "هذا المسار مستخدم بالفعل كصفحة هبوط أو محجوز للمنصة.",
          ),
        );
        // We wait a bit then fetch metrics to clear the loading/failure state and reload normal data
        await Future.delayed(const Duration(seconds: 2));
        await fetchAdminMetrics();
        return;
      }

      await _databaseService.updatePlatformSeoSettings(routePath, data);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to update SEO settings: $e"));
    }
  }

  // ----------------------------------------------------
  // BULK ACTIONS
  // ----------------------------------------------------

  Future<void> bulkBlockUsers(List<String> userIds, bool isBlocked) async {
    try {
      await _databaseService.bulkBlockUsers(userIds, isBlocked);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to block users: $e"));
    }
  }

  Future<void> bulkUpdateUserTier(List<String> userIds, String newTier) async {
    try {
      await _databaseService.bulkUpdateUserTier(userIds, newTier);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to update user tier: $e"));
    }
  }

  Future<void> bulkAddSubscriptionMonths(
    List<String> userIds,
    int months,
  ) async {
    try {
      await _databaseService.bulkAddSubscriptionMonths(userIds, months);
      await fetchAdminMetrics();
    } catch (e) {
      emit(SuperAdminFailure("Failed to add subscription months: $e"));
    }
  }

  Future<void> bulkSendNotification(
    List<String> userIds,
    String title,
    String message,
    String type, {
    String? redirectTo,
  }) async {
    try {
      await _databaseService.sendTargetedNotification(
        userIds,
        title,
        message,
        type,
        redirectTo: redirectTo,
      );
    } catch (e) {
      emit(SuperAdminFailure("Failed to send bulk notification: $e"));
    }
  }
}
