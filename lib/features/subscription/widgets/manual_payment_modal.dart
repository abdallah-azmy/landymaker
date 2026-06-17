import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';

class ManualPaymentModal extends StatelessWidget {
  final String planName;
  final double price;
  final String userId;

  const ManualPaymentModal({
    super.key,
    required this.planName,
    required this.price,
    required this.userId,
  });

  Future<void> _contactSupport() async {
    const adminPhone = "201000000000"; // Replace with your actual WhatsApp number
    final message = "مرحباً، أود تفعيل باقة $planName.\nرقم المستخدم: $userId\nالمبلغ المدفوع: $price EGP\n(يرجى إرفاق صورة إيصال الدفع هنا)";
    final url = "https://wa.me/$adminPhone?text=${Uri.encodeComponent(message)}";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ترقية الحساب إلى $planName", style: AppTypography.h2),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Text("قيمة الاشتراك: $price EGP", style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInfoBox(context, "خطوات التفعيل:", "1. قم بتحويل المبلغ عبر فودافون كاش أو إنستا باي.\n2. اضغط على الزر أدناه لإرسال صورة الإيصال عبر واتساب.\n3. سيتم تفعيل حسابك فور مراجعة التحويل."),
          const SizedBox(height: 24),
          _buildPaymentDetail(context, "فودافون كاش", "010XXXXXXXX"),
          _buildPaymentDetail(context, "إنستا باي", "user@instapay"),
          const SizedBox(height: 32),
          PrimaryButton(
            text: "تأكيد الدفع عبر واتساب",
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: _contactSupport,
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "نحن متواجدون 24/7 لخدمتك",
              style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
          const SizedBox(height: 4),
          Text(content, style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(BuildContext context, String method, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: Theme.of(context).colorScheme.secondary, size: 20),
          const SizedBox(width: 12),
          Text("$method: ", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
