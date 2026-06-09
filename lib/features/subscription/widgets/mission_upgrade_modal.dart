import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/localization_cubit.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import 'manual_payment_modal.dart';

class MissionUpgradeModal extends StatelessWidget {
  final String userId;

  const MissionUpgradeModal({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationCubit>();
    final isRtl = loc.isRtl;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isRtl),
            const SizedBox(height: 32),
            _buildPlanCard(
              context,
              name: isRtl ? "باقة الأعمال (Business)" : "Business Plan",
              price: "79",
              features: [
                isRtl ? "ميزات الذكاء الاصطناعي (150 عملية/شهر)" : "AI Features (150/mo)",
                isRtl ? "Smart WhatsApp Leads (قمع تحويل)" : "Smart WhatsApp Leads",
                isRtl ? "نطاق مخصص (Custom Domain)" : "Custom Domain",
                isRtl ? "إحصائيات متقدمة وتحليلات دقيقة" : "Advanced Analytics",
              ],
              isHighlighted: true,
              onSelect: () => _openPayment(context, "Business", 79.0),
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              name: isRtl ? "باقة برو (Pro)" : "Pro Plan",
              price: "29",
              features: [
                isRtl ? "ذكاء اصطناعي (50 عملية/شهر)" : "AI Features (50/mo)",
                isRtl ? "نطاق مخصص (Custom Domain)" : "Custom Domain",
                isRtl ? "بدون شعار لاندي ميكر" : "Remove Branding",
              ],
              onSelect: () => _openPayment(context, "Pro", 29.0),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isRtl ? "إغلاق" : "Close",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRtl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 20),
        Text(
          isRtl ? "ضاعف تحويلاتك مع لاندي ميكر برو" : "Multiply Conversions with LandyMaker Pro",
          style: AppTypography.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isRtl ? "اختر الباقة المناسبة لنمو تجارتك" : "Choose the right plan for your business growth",
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String name,
    required String price,
    required List<String> features,
    required VoidCallback onSelect,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF0F172A) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : AppColors.border,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTypography.h3.copyWith(color: isHighlighted ? Colors.white : null)),
              if (isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("الأكثر طلباً", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("\$$price", style: AppTypography.h1.copyWith(color: isHighlighted ? Colors.white : null)),
              const SizedBox(width: 4),
              Text("/mo", style: AppTypography.bodySmall.copyWith(color: isHighlighted ? Colors.white70 : AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.activeGreen, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(f, style: AppTypography.bodySmall.copyWith(color: isHighlighted ? Colors.white : null))),
              ],
            ),
          )),
          const SizedBox(height: 24),
          PrimaryButton(
            text: "اشترك الآن",
            onPressed: onSelect,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void _openPayment(BuildContext context, String plan, double price) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualPaymentModal(
        planName: plan,
        price: price,
        userId: userId,
      ),
    );
  }
}
