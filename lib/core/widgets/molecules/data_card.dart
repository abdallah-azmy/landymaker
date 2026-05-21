import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class DataCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final bool? trendUp;

  const DataCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.trendUp,
  });

  @override
  State<DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(24),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.cardBgHover : AppColors.cardBg,
          border: Border.all(
            color: _isHovered ? AppColors.secondary.withOpacity(0.5) : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.value,
                    style: AppTypography.h1.copyWith(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.trendUp != null) ...[
                          Icon(
                            widget.trendUp! ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: widget.trendUp! ? AppColors.activeGreen : AppColors.dangerRed,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          widget.subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: widget.trendUp == null
                                ? AppColors.textMuted
                                : (widget.trendUp! ? AppColors.activeGreen : AppColors.dangerRed),
                            fontWeight: widget.trendUp == null ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.iconColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
