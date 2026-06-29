import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminPlansTab extends StatelessWidget {
  const SuperAdminPlansTab({super.key});

  Widget _buildPlanEditCard(BuildContext context, Map<String, dynamic> plan, int maxAllowed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan['display_name'], style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("Price: ${plan['monthly_price']} EGP/mo", style: AppTypography.caption),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.web_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
                    SizedBox(width: 8),
                    Text("Limit: ${plan['page_limit']} pages", style: AppTypography.bodyMedium),
                    SizedBox(width: 16),
                    Icon(Icons.auto_awesome_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 8),
                    Text("AI Limit: ${plan['ai_generation_limit'] ?? 0} attempts", style: AppTypography.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
          PrimaryButton(
            text: "Edit Config",
            width: 120,
            onPressed: () => _showEditPlanDialog(context, plan, maxAllowed),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context, Map<String, dynamic> plan, int maxAllowed) {
    final nameController = TextEditingController(text: plan['display_name']);
    final priceController = TextEditingController(text: plan['monthly_price'].toString());
    final limitController = TextEditingController(text: plan['page_limit'].toString());
    final aiLimitController = TextEditingController(text: (plan['ai_generation_limit'] ?? 0).toString());
    bool customDomain = plan['custom_domain_access'] ?? false;
    bool seoAccess = plan['advanced_seo_access'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Edit Plan: ${plan['id']}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, hintText: "Display Name"),
                SizedBox(height: 16),
                CustomTextField(
                  controller: priceController,
                  hintText: "Monthly Price (EGP)",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: limitController,
                  hintText: "Page Limit (Max $maxAllowed)",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: aiLimitController,
                  hintText: "AI Generation Limit",
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Custom Domain Access", style: TextStyle(fontSize: 14)),
                  value: customDomain,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => customDomain = val),
                ),
                SwitchListTile(
                  title: const Text("Advanced SEO Access", style: TextStyle(fontSize: 14)),
                  value: seoAccess,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => seoAccess = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            PrimaryButton(
              text: "Save Changes",
              width: 150,
              onPressed: () {
                final newLimit = int.tryParse(limitController.text) ?? 1;
                final newAiLimit = int.tryParse(aiLimitController.text) ?? 0;
                if (newLimit > maxAllowed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: Cannot exceed security limit of $maxAllowed",
                      ),
                    ),
                  );
                  return;
                }

                context.read<SuperAdminCubit>().updatePlan(plan['id'], {
                  'display_name': nameController.text,
                  'monthly_price': double.tryParse(priceController.text) ?? 0.0,
                  'page_limit': newLimit,
                  'custom_domain_access': customDomain,
                  'advanced_seo_access': seoAccess,
                  'ai_generation_limit': newAiLimit,
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Business Configuration (Plans)", style: AppTypography.h3),
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Admins can modify pricing and limits. Changes are restricted by Security Boundaries.",
            style: AppTypography.caption,
          ),
          SizedBox(height: 24),
          ...state.plans.map((plan) => _buildPlanEditCard(context, plan, state.securityLimits['MAX_PLAN_PAGE_LIMIT'] ?? 50)),
        ],
      ),
    );
  }
}
