import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class FormGroup extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helperText;
  final TextStyle? labelStyle;

  const FormGroup({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: labelStyle ?? AppTypography.h3.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}
