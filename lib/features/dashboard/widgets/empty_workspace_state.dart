import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';

class EmptyWorkspaceState extends StatelessWidget {
  final String title;
  final String description;

  const EmptyWorkspaceState({
    super.key,
    this.title = 'ليس لديك أي صفحات هبوط بعد',
    this.description = 'قم بإنشاء صفحتك الأولى الآن للوصول إلى هذا القسم والبدء في بناء تواجدك الرقمي.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.web_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            PrimaryButton(
              text: 'العودة للرئيسية لإنشاء صفحة',
              onPressed: () => context.go('/dashboard'),
              icon: Icons.dashboard_rounded,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
