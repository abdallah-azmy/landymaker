import 'package:flutter/material.dart';
import 'package:landymaker/core/localization/localization_cubit.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../../molecules/custom_image_field.dart';
import '../editor_types.dart';

/// Editor for lead_form and lead_magnet block types.
/// Exposes title, subtitle, button_text, layout_style (lead_magnet only),
/// card_style, hover_effect, stagger_animations, image_url,
/// WhatsApp auto-open settings, and form fields list.
class LeadFormEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const LeadFormEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
    required this.persistAsset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = block['image_url'];
    final isUploading = (imageUrl ?? '').toString().startsWith('upload://');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block['type'] == 'lead_magnet') ...[
          FormGroup(
            label: 'نوع التخطيط',
            child: DropdownButtonFormField<String>(
              initialValue: (block['layout_style'] as String?) ?? 'split',
              items: const [
                DropdownMenuItem(value: 'split', child: Text('نص+صورة')),
                DropdownMenuItem(value: 'centered', child: Text('مركز')),
              ],
              onChanged: (val) =>
                  cubit.updateBlockProperty(index, 'layout_style', val),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          FormGroup(
            label: context.translate('subtitle'),
            child: CustomTextField(
              controller: getController(
                "${index}_subtitle",
                block['subtitle'] ?? '',
              ),
              focusNode: getFocusNode("${index}_subtitle"),
              maxLines: 2,
              onChanged: (val) =>
                  cubit.updateBlockProperty(index, 'subtitle', val),
            ),
          ),
          SizedBox(height: 16),
          CustomImageField(
            label: context.translate('image_url'),
            imageUrl: imageUrl,
            isUploading: isUploading,
            onAction: () => pickImage(cubit, index),
            onSaveTemplateAsset: () => persistAsset(cubit, index),
          ),
          SizedBox(height: 16),
        ],
        FormGroup(
          label: context.translate('button_text'),
          child: CustomTextField(
            controller: getController(
              "${index}_button_text",
              block['button_text'] ?? '',
            ),
            focusNode: getFocusNode("${index}_button_text"),
            onChanged: (val) =>
                cubit.updateBlockProperty(index, 'button_text', val),
          ),
        ),
        SizedBox(height: 24),
        FormGroup(
          label: 'نوع البطاقة',
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'classic', label: Text('كلاسيكي')),
              ButtonSegment(value: 'modern', label: Text('حديث')),
              ButtonSegment(value: 'minimal', label: Text('بسيط')),
            ],
            selected: {block['card_style'] ?? 'classic'},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'card_style', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'تأثير التحويم',
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'none', label: Text('بدون')),
              ButtonSegment(value: 'scale', label: Text('تكبير')),
              ButtonSegment(value: 'elevate', label: Text('رفع')),
              const ButtonSegment(value: 'glow', label: Text('وهج')),
            ],
            selected: {block['hover_effect'] ?? 'scale'},
            onSelectionChanged: (val) =>
                cubit.updateBlockProperty(index, 'hover_effect', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: block['stagger_animations'] ?? true,
          onChanged: (val) =>
              cubit.updateBlockProperty(index, 'stagger_animations', val),
          title: Text('تحريك متدرج', style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
        Text(
          "Smart WhatsApp Leads",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 8),
        SwitchListTile(
          title: const Text("فتح واتساب تلقائياً بعد الإرسال"),
          subtitle: const Text("يحول الفورم إلى قمع تحويل لواتساب"),
          value: block['whatsapp_auto_open'] ?? false,
          onChanged: (val) =>
              cubit.updateBlockProperty(index, 'whatsapp_auto_open', val),
          contentPadding: EdgeInsets.zero,
        ),
        if (block['whatsapp_auto_open'] == true) ...[
          SizedBox(height: 16),
          FormGroup(
            label: "رقم الواتساب",
            child: CustomTextField(
              controller: getController(
                "${index}_wa_num",
                block['whatsapp_number'] ?? '',
              ),
              focusNode: getFocusNode("${index}_wa_num"),
              onChanged: (val) =>
                  cubit.updateBlockProperty(index, 'whatsapp_number', val),
            ),
          ),
          SizedBox(height: 16),
          FormGroup(
            label: "قالب الرسالة (استخدم {{name}} للتعويض)",
            child: CustomTextField(
              controller: getController(
                "${index}_wa_msg",
                block['whatsapp_message_template'] ?? '',
              ),
              focusNode: getFocusNode("${index}_wa_msg"),
              maxLines: 3,
              onChanged: (val) => cubit.updateBlockProperty(
                index,
                'whatsapp_message_template',
                val,
              ),
            ),
          ),
        ],
        SizedBox(height: 24),
        Divider(),
        SizedBox(height: 16),
        Text(
          "حقول النموذج (Form Fields)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...List.generate(((block['fields'] as List?) ?? []).length, (fIndex) {
          final field =
              ((block['fields'] as List?) ?? [])[fIndex]
                  as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "التسمية (Label)",
                        controller: getController(
                          "${index}_field_${fIndex}_label",
                          field['label'] ?? '',
                        ),
                        focusNode: getFocusNode(
                          "${index}_field_${fIndex}_label",
                        ),
                        onChanged: (val) => _updateField(fIndex, 'label', val),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () {
                        final List fields = List.from(block['fields'] ?? []);
                        fields.removeAt(fIndex);
                        cubit.updateBlockProperty(index, 'fields', fields);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomTextField(
                  hintText: "النص التوجيهي (Placeholder)",
                  controller: getController(
                    "${index}_field_${fIndex}_placeholder",
                    field['placeholder'] ?? '',
                  ),
                  focusNode: getFocusNode(
                    "${index}_field_${fIndex}_placeholder",
                  ),
                  onChanged: (val) => _updateField(fIndex, 'placeholder', val),
                ),
                SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('مطلوب', style: TextStyle(fontSize: 12)),
                  value: field['required'] ?? false,
                  onChanged: (val) => _updateField(fIndex, 'required', val),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            final List fields = List.from(block['fields'] ?? []);
            fields.add({
              'type': 'text',
              'label': 'حقل جديد',
              'placeholder': '',
              'required': false,
            });
            cubit.updateBlockProperty(index, 'fields', fields);
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text("إضافة حقل"),
        ),
      ],
    );
  }

  void _updateField(int fIndex, String key, dynamic value) {
    final List fields = List.from(block['fields'] ?? []);
    final field = Map<String, dynamic>.from(fields[fIndex]);
    field[key] = value;
    fields[fIndex] = field;
    cubit.updateBlockProperty(index, 'fields', fields);
  }
}
