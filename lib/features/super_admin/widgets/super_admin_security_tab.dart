import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminSecurityTab extends StatelessWidget {
  const SuperAdminSecurityTab({super.key});

  Widget _buildSecurityLimitCard(BuildContext context, String title, String value, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(20)),
                child: Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(desc, style: AppTypography.caption),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security_rounded, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 12),
              Text("Infrastructure Security Boundaries", style: AppTypography.h3),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "These limits are fixed at the database level and cannot be changed through the UI. They prevent accidental or intentional abuse of system resources.",
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 32),
          _buildSecurityLimitCard(context, "Global Plan Cap", "${state.securityLimits['MAX_PLAN_PAGE_LIMIT'] ?? 50} pages", "The highest page limit any business plan can be configured to have."),
          SizedBox(height: 16),
          _buildSecurityLimitCard(context, "Super Admin Cap", "${state.securityLimits['SUPER_ADMIN_PAGE_LIMIT'] ?? 500} pages", "The absolute hard limit for Super Admin accounts."),
        ],
      ),
    );
  }
}
