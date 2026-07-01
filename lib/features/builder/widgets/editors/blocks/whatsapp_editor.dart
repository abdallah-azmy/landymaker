import 'package:flutter/material.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';

/// Editor for the whatsapp block type.
/// Exposes phone_number, message, and button_text.
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
            maxLength: 20,
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
            maxLength: 500,
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
      ],
    );
  }
}
