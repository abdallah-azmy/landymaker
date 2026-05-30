import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'custom_loader.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool isSecondary;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.isSecondary = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    // Outer container layout
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const CustomLoader(size: 16),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: AppTypography.button.copyWith(
            color: widget.isSecondary ? AppColors.textPrimary : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    // Decorative shape & gradient
    final BoxDecoration decoration = widget.isSecondary
        ? BoxDecoration(
            color: _isHovered ? AppColors.cardBgHover : AppColors.cardBg,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(24),
          )
        : BoxDecoration(
            color: isDisabled ? AppColors.border : AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isHovered && !isDisabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    )
                  ]
                : [],
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          transform: Matrix4.diagonal3Values(
            _isHovered && !isDisabled ? 1.03 : 1.0,
            _isHovered && !isDisabled ? 1.03 : 1.0,
            1.0,
          ),
          alignment: Alignment.center,
          decoration: decoration,
          child: buttonContent,
        ),
      ),
    );
  }
}
