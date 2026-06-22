import 'package:flutter/material.dart';
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
      color: Colors.green,
    );
  }

  factory StatusPill.draft({required String label}) {
    return StatusPill(
      label: label,
      color: Colors.orange,
    );
  }

  factory StatusPill.admin({required String label, required BuildContext context}) {
    return StatusPill(
      label: label,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  factory StatusPill.user({required String label, required BuildContext context}) {
    return StatusPill(
      label: label,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
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
