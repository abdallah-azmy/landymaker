import 'package:flutter/material.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../../../builder/controllers/builder_cubit.dart';
import '../editor_types.dart';
import 'package:uuid/uuid.dart';

class MultiStepFormEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;

  const MultiStepFormEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final steps = (block['steps'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "عنوان النموذج (Title)",
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "وصف فرعي (Subtitle)",
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "رسالة النجاح (Success Message)",
          child: CustomTextField(
            controller: getController("${index}_success", block['success_message'] ?? ''),
            focusNode: getFocusNode("${index}_success"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'success_message', val),
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('حفظ التقدم محلياً (Local Save)'),
          subtitle: const Text('يمنع ضياع البيانات إذا تم تحديث الصفحة'),
          value: block['enable_local_save'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'enable_local_save', val),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Text("Smart WhatsApp Leads", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text("فتح واتساب تلقائياً بعد الإرسال"),
          subtitle: const Text("يحول الفورم إلى قمع تحويل لواتساب"),
          value: block['whatsapp_auto_open'] ?? false,
          onChanged: (val) => cubit.updateBlockProperty(index, 'whatsapp_auto_open', val),
          contentPadding: EdgeInsets.zero,
        ),
        if (block['whatsapp_auto_open'] == true) ...[
          const SizedBox(height: 16),
          FormGroup(
            label: "رقم الواتساب",
            child: CustomTextField(
              controller: getController("${index}_wa_num", block['whatsapp_number'] ?? ''),
              focusNode: getFocusNode("${index}_wa_num"),
              onChanged: (val) => cubit.updateBlockProperty(index, 'whatsapp_number', val),
            ),
          ),
          const SizedBox(height: 16),
          FormGroup(
            label: "قالب الرسالة (استخدم {{field_id}} للتعويض)",
            child: CustomTextField(
              controller: getController("${index}_wa_msg", block['whatsapp_message_template'] ?? ''),
              focusNode: getFocusNode("${index}_wa_msg"),
              maxLines: 3,
              onChanged: (val) => cubit.updateBlockProperty(index, 'whatsapp_message_template', val),
            ),
          ),
        ],
        const Divider(height: 32),
        const Text(
          "خطوات النموذج (Steps)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        // Simple Reorderable list for Steps (In a production app, we'd use ReorderableListView but Column is fine for MVP)
        ...steps.asMap().entries.map((entry) {
          final stepIndex = entry.key;
          final step = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(step['step_title'] ?? 'خطوة بدون عنوان'),
              subtitle: Text('${(step['fields'] as List?)?.length ?? 0} حقول'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final newSteps = List.from(steps);
                  newSteps.removeAt(stepIndex);
                  cubit.updateBlockProperty(index, 'steps', newSteps);
                },
              ),
              onTap: () {
                // Here we would push a nested editor view. 
                // For this MVP file, we just show how the data updates.
              },
            ),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('إضافة خطوة جديدة'),
          onPressed: () {
            final newSteps = List.from(steps);
            newSteps.add({
              'step_id': const Uuid().v4(),
              'step_title': 'خطوة جديدة',
              'fields': []
            });
            cubit.updateBlockProperty(index, 'steps', newSteps);
          },
        ),
      ],
    );
  }
}
