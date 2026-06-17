import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../subscription/widgets/manual_payment_modal.dart';

class UpgradeLimitModal extends StatelessWidget {
  final String userId;

  const UpgradeLimitModal({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.orange, size: 40),
          ),
          SizedBox(height: 24),
          Text(
            "لقد وصلت إلى الحد الأقصى المسموح به في الباقة المجانية",
            style: AppTypography.h2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            "تسمح لك الباقة المجانية بإنشاء صفحة هبوط واحدة فقط. قم بالترقية للاستمتاع بإنشاء صفحات متعددة وربط نطاقات مخصصة والحصول على مزايا إضافية.",
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          _buildFeatureRow(loc, "إنشاء صفحات متعددة (حتى 5 صفحات)"),
          _buildFeatureRow(loc, "ربط نطاقات مخصصة (Custom Domains)"),
          _buildFeatureRow(loc, "إحصائيات متقدمة وتقارير أداء"),
          _buildFeatureRow(loc, "دعم فني مخصص وأولوية في المساعدة"),
          SizedBox(height: 40),
          PrimaryButton(
            text: "اشترك الآن في باقة برو",
            icon: Icons.star_rounded,
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ManualPaymentModal(planName: "Pro", price: 299.0, userId: userId),
              );
            },
            width: double.infinity,
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "لاحقاً",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(LocalizationCubit loc, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
