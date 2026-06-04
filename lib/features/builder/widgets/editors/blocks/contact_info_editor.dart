import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';

class ContactInfoEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const ContactInfoEditor({
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.pickAndUploadImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "البريد الإلكتروني",
          child: CustomTextField(
            controller: getController("${index}_email", block['email'] ?? ''),
            focusNode: getFocusNode("${index}_email"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'email', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "رقم الهاتف",
          child: CustomTextField(
            controller: getController("${index}_phone", block['phone'] ?? ''),
            focusNode: getFocusNode("${index}_phone"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'phone', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "العنوان",
          child: CustomTextField(
            controller: getController("${index}_location", block['location'] ?? ''),
            focusNode: getFocusNode("${index}_location"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'location', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "أيقونة البريد الإلكتروني (Email Icon Name)",
          child: CustomTextField(
            controller: getController("${index}_email_icon", block['email_icon'] ?? ''),
            focusNode: getFocusNode("${index}_email_icon"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'email_icon', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "أيقونة الهاتف (Phone Icon Name)",
          child: CustomTextField(
            controller: getController("${index}_phone_icon", block['phone_icon'] ?? ''),
            focusNode: getFocusNode("${index}_phone_icon"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'phone_icon', val),
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "أيقونة العنوان (Location Icon Name)",
          child: CustomTextField(
            controller: getController("${index}_location_icon", block['location_icon'] ?? ''),
            focusNode: getFocusNode("${index}_location_icon"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'location_icon', val),
          ),
        ),
      ],
    );
  }
}
