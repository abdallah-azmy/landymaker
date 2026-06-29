import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/molecules/status_pill.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/organisms/responsive_data_table.dart';
import '../../../services/auth_service.dart';
import '../../builder/registries/template_registry.dart';
import '../controllers/super_admin_cubit.dart';
import '../controllers/super_admin_state.dart';
import 'package:landymaker/injection_container.dart' as di;

class SuperAdminTemplatesTab extends StatefulWidget {
  const SuperAdminTemplatesTab({super.key});

  @override
  State<SuperAdminTemplatesTab> createState() => _SuperAdminTemplatesTabState();
}

class _SuperAdminTemplatesTabState extends State<SuperAdminTemplatesTab> {
  void _confirmDeleteTemplate(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to soft-delete this template? It will be hidden from users."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          PrimaryButton(
            text: "Delete",
            width: 120,
            onPressed: () {
              context.read<SuperAdminCubit>().deleteTemplate(id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _seedTemplatesFromRegistry() async {
    final templates = TemplateRegistry.availableTemplates.map((t) {
      final design = TemplateRegistry.getTemplateDesign(t.id);
      return <String, dynamic>{
        'id': t.id,
        'name': t.name,
        'description': t.description,
        'image_url': t.imageUrl,
        'category': t.category,
        'recommended_sections': t.recommendedSections,
        'ai_prompt_hint': t.aiPromptHint,
        'design_json': design,
      };
    }).toList();

    final cubit = context.read<SuperAdminCubit>();
    final count = await cubit.seedTemplatesFromRegistry(templates);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Seeded $count templates from registry. Existing templates were skipped."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showTemplateEditorDialog(SuperAdminLoaded state, Map<String, dynamic>? existing) {
    final isEditing = existing != null;
    final idController = TextEditingController(text: existing?['id'] ?? '');
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final descriptionController = TextEditingController(text: existing?['description'] ?? '');
    final imageUrlController = TextEditingController(text: existing?['image_url'] ?? '');
    final categoryController = TextEditingController(text: existing?['category'] ?? 'general');
    final aiHintController = TextEditingController(text: existing?['ai_prompt_hint'] ?? '');

    final personalPages = state.pages.where((p) => p['user_id'] == di.sl<AuthService>().currentUserId).toList();

    String designJsonText = '';
    if (existing?['design_json'] != null) {
      final dj = existing!['design_json'];
      if (dj is String) {
        designJsonText = dj;
      } else {
        designJsonText = const JsonEncoder.withIndent('  ').convert(dj);
      }
    } else {
      designJsonText = '{"blocks": []}';
    }
    final designJsonController = TextEditingController(text: designJsonText);

    bool isDraft = existing?['is_draft'] ?? false;
    bool isFeatured = existing?['is_featured'] ?? false;

    String? jsonError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(isEditing ? "Edit Template: ${existing['name']}" : "Add New Template"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isEditing && personalPages.isNotEmpty) ...[
                  Text(
                    "نسخ من صفحة هبوط شخصية (Clone from Page)",
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        hint: const Text("اختر صفحة لنسخها كقالب (Select page to clone)"),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: personalPages.map((page) {
                          final subdomain = page['subdomain'] as String? ?? '';
                          final name = page['name'] as String? ?? subdomain;
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: page,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (page) {
                          if (page == null) return;
                          setDialogState(() {
                            final rawSubdomain = page['subdomain'] as String? ?? '';
                            idController.text = rawSubdomain.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
                            nameController.text = page['name'] as String? ?? rawSubdomain;
                            descriptionController.text = page['description'] as String? ?? '';
                            final dj = page['design_json'];
                            if (dj is String) {
                              designJsonController.text = dj;
                            } else if (dj != null) {
                              designJsonController.text = const JsonEncoder.withIndent('  ').convert(dj);
                            } else {
                              designJsonController.text = '{"blocks": []}';
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                CustomTextField(
                  controller: idController,
                  hintText: "Template ID (e.g. saas_startup)",
                  label: "ID",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: nameController,
                  hintText: "Template Name",
                  label: "Name",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: descriptionController,
                  hintText: "Brief description",
                  label: "Description",
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: imageUrlController,
                  hintText: "Cover image URL",
                  label: "Image URL",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: categoryController,
                  hintText: "e.g. technology, ecommerce",
                  label: "Category",
                ),
                SizedBox(height: 12),
                CustomTextField(
                  controller: aiHintController,
                  hintText: "AI generation hint",
                  label: "AI Prompt Hint",
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                Text("Design JSON (blocks map)", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: jsonError != null ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: designJsonController,
                    maxLines: 8,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    decoration: InputDecoration(
                      hintText: '{ "blocks": [...] }',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      errorText: jsonError,
                    ),
                    onChanged: (_) {
                      setDialogState(() {
                        jsonError = null;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Is Draft (hidden from users)", style: TextStyle(fontSize: 14)),
                  value: isDraft,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => isDraft = val),
                ),
                SwitchListTile(
                  title: const Text("Featured on Homepage", style: TextStyle(fontSize: 14)),
                  value: isFeatured,
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (val) => setDialogState(() => isFeatured = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            PrimaryButton(
              text: isEditing ? "Save Changes" : "Create Template",
              width: 160,
              onPressed: () {
                if (idController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template ID is required")),
                  );
                  return;
                }
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Template name is required")),
                  );
                  return;
                }
                if (imageUrlController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Image URL is required")),
                  );
                  return;
                }
                final uri = Uri.tryParse(imageUrlController.text.trim());
                if (uri == null || !uri.isAbsolute) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid image URL. Must be an absolute URL (e.g. https://...)")),
                  );
                  return;
                }

                dynamic parsedJson;
                try {
                  parsedJson = jsonDecode(designJsonController.text);
                } catch (e) {
                  setDialogState(() {
                    jsonError = "Invalid JSON: ${e.toString()}";
                  });
                  return;
                }

                final data = <String, dynamic>{
                  'id': idController.text.trim(),
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'image_url': imageUrlController.text.trim(),
                  'category': categoryController.text.trim().isEmpty ? 'general' : categoryController.text.trim(),
                  'ai_prompt_hint': aiHintController.text.trim(),
                  'design_json': parsedJson,
                  'is_draft': isDraft,
                  'is_featured': isFeatured,
                };

                if (isEditing) {
                  context.read<SuperAdminCubit>().updateTemplate(existing['id'], data);
                } else {
                  data['is_active'] = true;
                  context.read<SuperAdminCubit>().createTemplate(data);
                }
                Navigator.pop(ctx);
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
              Text("Template Management", style: AppTypography.h3),
              Row(
                children: [
                  PrimaryButton(
                    text: "Seed from Registry",
                    width: 180,
                    isSecondary: true,
                    onPressed: () => _seedTemplatesFromRegistry(),
                  ),
                  SizedBox(width: 12),
                  PrimaryButton(
                    text: "Add Template",
                    width: 160,
                    onPressed: () => _showTemplateEditorDialog(state, null),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          ResponsiveDataTable(
            title: "All Templates",
            headers: const [
              "Name",
              "Category",
              "Status",
              "Homepage",
              "Actions",
            ],
            rows: state.templates.map((t) {
              final isDraft = t['is_draft'] == true;
              final isFeatured = t['is_featured'] == true;
              final isActive = t['is_active'] == true;
              return [
                Flexible(
                  child: Text(
                    t['name'] ?? '',
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(t['category'] ?? 'general', style: AppTypography.bodyMedium),
                StatusPill(
                  label: isDraft ? "Draft" : "Live",
                  color: isDraft ? Colors.orange : Colors.green,
                ),
                StatusPill(
                  label: isFeatured ? "Featured" : "Standard",
                  color: isFeatured ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_rounded, size: 18, color: Theme.of(context).colorScheme.secondary),
                      tooltip: "Edit",
                      onPressed: () => _showTemplateEditorDialog(state, t),
                    ),
                    IconButton(
                      icon: Icon(
                        isDraft ? Icons.publish_rounded : Icons.drafts_rounded,
                        size: 18,
                        color: isDraft ? Colors.green : Colors.orange,
                      ),
                      tooltip: isDraft ? "Publish" : "Set as Draft",
                      onPressed: () => context.read<SuperAdminCubit>().toggleTemplateStatus(
                        t['id'],
                        isDraft: !isDraft,
                      ),
                    ),
                    if (isActive)
                      IconButton(
                        icon: Icon(Icons.delete_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                        tooltip: "Delete",
                        onPressed: () => _confirmDeleteTemplate(t['id']),
                      ),
                  ],
                ),
              ];
            }).toList(),
            emptyMessage: "No templates found. Click 'Add Template' to create one.",
            onSearch: (v) {},
            onSort: (v) {},
            onPageChanged: (p) {},
          ),
        ],
      ),
    );
  }
}
