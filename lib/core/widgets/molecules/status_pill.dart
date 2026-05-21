import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  factory StatusPill.published({required String label}) {
    return StatusPill(
      label: label,
      color: AppColors.activeGreen,
    );
  }

  factory StatusPill.draft({required String label}) {
    return StatusPill(
      label: label,
      color: AppColors.warningOrange,
    );
  }

  factory StatusPill.admin({required String label}) {
    return StatusPill(
      label: label,
      color: AppColors.primary,
    );
  }

  factory StatusPill.user({required String label}) {
    return StatusPill(
      label: label,
      color: AppColors.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
