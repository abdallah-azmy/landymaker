import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

class PulsingDot extends StatefulWidget {
  final bool isActive;
  const PulsingDot({super.key, required this.isActive});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.isActive ? theme.colorScheme.primary : theme.colorScheme.outline;

    if (!widget.isActive) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.5),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 8 + (12 * _controller.value),
              height: 8 + (12 * _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.4 * (1.0 - _controller.value)),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HomepageSectionCard extends StatelessWidget {
  final Map<String, dynamic> section;
  final bool isVisible;
  final VoidCallback onToggle;
  final VoidCallback onEditConfig;
  final int index;

  const HomepageSectionCard({
    super.key,
    required this.section,
    required this.isVisible,
    required this.onToggle,
    required this.onEditConfig,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = section['display_name'] as String? ?? '';
    final key = section['section_key'] as String? ?? '';

    final icons = <String, IconData>{
      'hero': Icons.dashboard_rounded,
      'features': Icons.grid_view_rounded,
      'templates': Icons.dashboard_customize_rounded,
      'desktop_preview': Icons.desktop_windows_rounded,
      'cta': Icons.call_to_action_rounded,
      'footer': Icons.layers_rounded,
      'navbar': Icons.navigation_rounded,
      'section_renderer': Icons.web_asset_rounded,
    };

    final glowColor = isVisible
        ? theme.colorScheme.primary.withValues(alpha: 0.1)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isVisible)
            BoxShadow(
              color: glowColor,
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.35 : 0.65,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isVisible
                    ? theme.colorScheme.primary.withValues(alpha: 0.35)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsetsDirectional.all(16),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsetsDirectional.all(10),
                  decoration: BoxDecoration(
                    gradient: isVisible
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              theme.colorScheme.onSurface.withValues(alpha: 0.06),
                              theme.colorScheme.onSurface.withValues(alpha: 0.02),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isVisible
                          ? theme.colorScheme.primary.withValues(alpha: 0.25)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Icon(
                    icons[key] ?? Icons.widgets_rounded,
                    color: isVisible ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PulsingDot(isActive: isVisible),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isVisible
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        key.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 20),
                  onPressed: onEditConfig,
                  tooltip: 'الإعدادات',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    hoverColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                  color: isVisible ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isVisible,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

