import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

class FormGroup extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helperText;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;

  const FormGroup({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
    this.labelStyle,
    this.helperStyle,
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        child,
        if (helperText != null) ...[
          SizedBox(height: 6),
          Text(
            helperText!,
            style: helperStyle ?? AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ],
    );
  }
}
