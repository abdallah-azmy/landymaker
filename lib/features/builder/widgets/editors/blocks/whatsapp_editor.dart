import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';

class WhatsappEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;

  const WhatsappEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "العنوان الرئيسي",
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "رقم الواتساب",
          helperText: "2010...",
          child: CustomTextField(
            controller: getController("${index}_phone_number", block['phone_number'] ?? ''),
            focusNode: getFocusNode("${index}_phone_number"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'phone_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "الرسالة الافتراضية",
          child: CustomTextField(
            controller: getController("${index}_message", block['message'] ?? ''),
            focusNode: getFocusNode("${index}_message"),
            maxLines: 3,
            onChanged: (val) => cubit.updateBlockProperty(index, 'message', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "نص الزر",
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
