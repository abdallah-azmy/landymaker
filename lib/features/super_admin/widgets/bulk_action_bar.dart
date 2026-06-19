import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

class BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onRenew;
  final VoidCallback onUpgrade;
  final VoidCallback onDowngrade;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onNotify;

  const BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onRenew,
    required this.onUpgrade,
    required this.onDowngrade,
    required this.onBlock,
    required this.onUnblock,
    required this.onNotify,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(label: 'تجديد', icon: Icons.replay_rounded, onTap: onRenew),
      _ActionData(label: 'ترقية', icon: Icons.arrow_upward_rounded, onTap: onUpgrade),
      _ActionData(label: 'تخفيض', icon: Icons.arrow_downward_rounded, onTap: onDowngrade),
      _ActionData(label: 'حظر', icon: Icons.block_rounded, onTap: onBlock, isDestructive: true),
      _ActionData(label: 'إلغاء حظر', icon: Icons.lock_open_rounded, onTap: onUnblock),
      _ActionData(label: 'إشعار', icon: Icons.notifications_active_rounded, onTap: onNotify),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            'محدد: $selectedCount',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onCancel,
            child: const Text('إلغاء', style: TextStyle(fontSize: 12)),
          ),
          const Spacer(),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: actions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final action = actions[index];
                return _ActionChip(
                  label: action.label,
                  icon: action.icon,
                  isDestructive: action.isDestructive,
                  onTap: action.onTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionData({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.isDestructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
