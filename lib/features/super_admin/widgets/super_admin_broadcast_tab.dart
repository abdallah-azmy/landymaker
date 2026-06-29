import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../services/supabase_service.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';

class SuperAdminBroadcastTab extends StatefulWidget {
  const SuperAdminBroadcastTab({super.key});

  @override
  State<SuperAdminBroadcastTab> createState() => _SuperAdminBroadcastTabState();
}

class _SuperAdminBroadcastTabState extends State<SuperAdminBroadcastTab> {
  late final TextEditingController _broadcastTitleController;
  late final TextEditingController _broadcastMessageController;
  late final TextEditingController _broadcastRedirectController;
  String _broadcastType = 'info';

  @override
  void initState() {
    super.initState();
    _broadcastTitleController = TextEditingController();
    _broadcastMessageController = TextEditingController();
    _broadcastRedirectController = TextEditingController();
  }

  @override
  void dispose() {
    _broadcastTitleController.dispose();
    _broadcastMessageController.dispose();
    _broadcastRedirectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SuperAdminCubit>().state as SuperAdminLoaded;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text("System Broadcast Notifications", style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Create and send custom push/in-app notifications to all registered users simultaneously across all devices.",
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notification Title", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _broadcastTitleController,
                  hintText: "Enter title (e.g. تحديث جديد بالمنصة 🚀)",
                ),
                const SizedBox(height: 20),
                Text("Notification Message / Body", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _broadcastMessageController,
                  hintText: "Enter detailed message text",
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Text("Notification Type", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _broadcastType,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'info', child: Text("Info (General Info)")),
                    DropdownMenuItem(value: 'broadcast', child: Text("Broadcast (Announcements)")),
                    DropdownMenuItem(value: 'warning', child: Text("Warning (Alerts)")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _broadcastType = val);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text("Redirect Path / URL (Optional)", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _broadcastRedirectController,
                  hintText: "e.g. /dashboard/leads or /dashboard/products",
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: "Send Broadcast to All Users",
                  icon: Icons.send_rounded,
                  width: double.infinity,
                  onPressed: () {
                    final title = _broadcastTitleController.text.trim();
                    final message = _broadcastMessageController.text.trim();
                    final redirectTo = _broadcastRedirectController.text.trim();
                    if (title.isEmpty || message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Title and Message cannot be empty!")),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        title: const Text("Confirm Broadcast"),
                        content: Text("Are you sure you want to send this notification to all ${state.users.length} registered users? This action cannot be undone."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text("Cancel"),
                          ),
                          PrimaryButton(
                            text: "Yes, Send",
                            width: 120,
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              try {
                                await SupabaseService.instance.broadcastNotification(
                                  title,
                                  message,
                                  _broadcastType,
                                  redirectTo: redirectTo.isEmpty ? null : redirectTo,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Broadcast sent successfully to all users!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _broadcastTitleController.clear();
                                  _broadcastMessageController.clear();
                                  _broadcastRedirectController.clear();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Failed to send: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
