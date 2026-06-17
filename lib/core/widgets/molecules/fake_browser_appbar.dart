import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FakeBrowserAppbar extends StatelessWidget {
  final String pageSlug;

  const FakeBrowserAppbar({
    super.key,
    required this.pageSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsetsDirectional.only(end: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0
                      ? const Color(0xFFFF5F56)
                      : (i == 1
                          ? const Color(0xFFFFBD2E)
                          : const Color(0xFF27C93F)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 12, color: AppColors.activeGreen),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'landymaker.com/${pageSlug.isEmpty ? 'your-brand' : pageSlug}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}
