import 'package:flutter/material.dart';
import 'cube_spinner.dart';

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
    final cs = Theme.of(context).colorScheme;
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          CubeSpinner(
            size: 16,
            color: widget.isSecondary ? cs.onSurface : cs.onPrimary,
          ),
          SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 16, color: widget.isSecondary ? cs.onSurface : cs.onPrimary),
          SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: widget.isSecondary ? cs.onSurface : cs.onPrimary,
          ),
        ),
      ],
    );

    final BoxDecoration decoration = widget.isSecondary
        ? BoxDecoration(
            color: _isHovered
                ? cs.surface.withValues(alpha: 0.8)
                : cs.surface,
            border: Border.all(color: cs.outline, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          )
        : BoxDecoration(
            color: isDisabled ? cs.outline.withValues(alpha: 0.4) : cs.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered && !isDisabled
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
