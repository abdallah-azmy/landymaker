import 'package:flutter/material.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';

/// Editor for the whatsapp block type.
/// Exposes phone_number, message, button_text, card_style,
/// hover_effect, and stagger_animations.
class WhatsappEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final TextEditingController Function(String, String) getController;
  final FocusNode Function(String) getFocusNode;

  const WhatsappEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: 'رقم الهاتف (مطلوب)',
          helperText: "2010...",
          child: CustomTextField(
            controller: getController("${index}_phone", block['phone_number'] ?? ''),
            focusNode: getFocusNode("${index}_phone"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'phone_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'الرسالة الافتراضية',
          child: CustomTextField(
            controller: getController("${index}_message", block['message'] ?? ''),
            focusNode: getFocusNode("${index}_message"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'message', val),
            maxLines: 3,
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'نص الزر',
          child: CustomTextField(
            controller: getController("${index}_button_text", block['button_text'] ?? ''),
            focusNode: getFocusNode("${index}_button_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'نوع البطاقة',
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'classic', label: Text('كلاسيكي')),
              ButtonSegment(value: 'modern', label: Text('حديث')),
              ButtonSegment(value: 'minimal', label: Text('بسيط')),
            ],
            selected: {block['card_style'] ?? 'classic'},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'card_style', val.first),
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
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'hover_effect', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          value: block['stagger_animations'] ?? true,
          onChanged: (val) => cubit.updateBlockProperty(index, 'stagger_animations', val),
          title: Text('تحريك متدرج', style: AppTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
