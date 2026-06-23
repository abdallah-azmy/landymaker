import 'package:flutter/material.dart';
import 'cube_spinner.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool isSecondary;
  final Widget? loadingWidget;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.isSecondary = false,
    this.loadingWidget,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isDisabled = widget.onPressed == null && !widget.isLoading;
    final bool isInteractive = !isDisabled && !widget.isLoading;

    final Color contentColor;
    if (widget.isSecondary || widget.isLoading) {
      contentColor = cs.onSurface;
    } else {
      contentColor = cs.onPrimary;
    }

    Widget? leading;
    if (widget.isLoading) {
      leading = widget.loadingWidget ?? const CubeSpinner(
        size: 16,
      );
    } else if (widget.icon != null) {
      leading = Icon(widget.icon, size: 16, color: contentColor);
    }

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
      ],
    );

    final Color bgColor;
    if (widget.isSecondary) {
      bgColor = _isHovered
          ? cs.surface.withValues(alpha: 0.8)
          : cs.surface;
    } else if (widget.isLoading) {
      bgColor = cs.surfaceContainerHigh;
    } else if (isDisabled) {
      bgColor = cs.outline.withValues(alpha: 0.4);
    } else {
      bgColor = cs.primary;
    }

    final BoxDecoration decoration = (widget.isSecondary || widget.isLoading)
        ? BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: widget.isSecondary ? cs.outline : cs.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          )
        : BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered && isInteractive
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
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isInteractive ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          transform: Matrix4.diagonal3Values(
            _isHovered && isInteractive ? 1.03 : 1.0,
            _isHovered && isInteractive ? 1.03 : 1.0,
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
