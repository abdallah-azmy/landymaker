import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/ai_copywriter_cubit.dart';
import '../modals/ai_copywriter_modal.dart';

class AiCopywriterTrigger extends StatelessWidget {
  final String fieldType;
  final Function(String) onApply;
  final Map<String, dynamic> contextData;

  const AiCopywriterTrigger({
    super.key,
    required this.fieldType,
    required this.onApply,
    required this.contextData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAiModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 4),
            Text(
              "تحسين بالذكاء الاصطناعي",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiCopywriterModal(
        fieldType: fieldType,
        onApply: onApply,
        contextData: contextData,
      ),
    );
  }
}
