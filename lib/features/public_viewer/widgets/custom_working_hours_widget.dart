import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CustomWorkingHoursWidget extends StatelessWidget {
  final Map<String, dynamic> blockData;

  const CustomWorkingHoursWidget({super.key, required this.blockData});

  @override
  Widget build(BuildContext context) {
    final title = blockData['title'] ?? 'مواعيد العمل';
    final schedule = blockData['schedule'] as Map<String, dynamic>? ?? {};
    
    // Quick logic to check if open (10 AM to 11 PM)
    final now = DateTime.now();
    final currentHour = now.hour;
    final isOpen = currentHour >= 10 && currentHour < 23;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.h3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(isOpen),
            ],
          ),
          const SizedBox(height: 16),
          ...schedule.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isOpen ? AppColors.activeGreen : AppColors.dangerRed).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOpen ? AppColors.activeGreen : AppColors.dangerRed),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.activeGreen : AppColors.dangerRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? "مفتوح الآن" : "مغلق الآن",
            style: AppTypography.caption.copyWith(
              color: isOpen ? AppColors.activeGreen : AppColors.dangerRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
