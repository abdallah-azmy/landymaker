import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

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

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isVisible
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsetsDirectional.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.drag_indicator_rounded, color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsetsDirectional.all(10),
              decoration: BoxDecoration(
                color: isVisible
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
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
                  Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isVisible
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    key,
                    style: AppTypography.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
                icon: Icon(Icons.settings_rounded, size: 20),
                onPressed: onEditConfig,
                tooltip: 'الإعدادات',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            Switch(
              value: isVisible,
              onChanged: (_) => onToggle(),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
