import 'package:flutter/material.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';

class CtaBannerEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final TextEditingController Function(String, String) getController;
  final FocusNode Function(String) getFocusNode;

  const CtaBannerEditor({
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
          label: 'العنوان الرئيسي',
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            maxLength: 100,
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'العنوان الفرعي',
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            maxLength: 300,
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'نص الزر',
          child: CustomTextField(
            controller: getController("${index}_btn_text", block['button_text'] ?? ''),
            focusNode: getFocusNode("${index}_btn_text"),
            maxLength: 50,
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_text', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'رابط الزر',
          child: CustomTextField(
            controller: getController("${index}_btn_url", block['button_url'] ?? ''),
            focusNode: getFocusNode("${index}_btn_url"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'button_url', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'نص الزر الثانوي',
          child: CustomTextField(
            controller: getController("${index}_sec_btn_text", block['secondary_button_text'] ?? ''),
            focusNode: getFocusNode("${index}_sec_btn_text"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'secondary_button_text', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'رابط الزر الثانوي',
          child: CustomTextField(
            controller: getController("${index}_sec_btn_url", block['secondary_button_url'] ?? ''),
            focusNode: getFocusNode("${index}_sec_btn_url"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'secondary_button_url', val),
          ),
        ),
        SizedBox(height: 24),
        FormGroup(
          label: 'نوع التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: (block['layout_style'] as String?) ?? 'centeredGradient',
            items: const [
              DropdownMenuItem(value: 'centeredGradient', child: Text('مركز مع تدرج')),
              DropdownMenuItem(value: 'split', child: Text('نص + أزرار (Split)')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
          ),
        ),
      ],
    );
  }
}
