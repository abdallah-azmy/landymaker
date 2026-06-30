import 'package:flutter/material.dart';

class DesktopFab extends StatelessWidget {
  final VoidCallback onShowAi;
  final VoidCallback onAddBlock;

  const DesktopFab({required this.onShowAi, required this.onAddBlock});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: onShowAi,
          heroTag: 'ai_fab',
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(Icons.auto_awesome_rounded, color: Colors.white),
          label: const Text("مساعد الذكاء الاصطناعي", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: onAddBlock,
          heroTag: 'add_fab',
          backgroundColor: Theme.of(context).colorScheme.secondary,
          icon: Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("إضافة قسم جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
