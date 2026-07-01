import 'package:flutter/material.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';

/// Editor for the contact_info block type.
/// Exposes title, variant (0=Grid/1=Row), email, phone, location, and icon overrides.
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
          label: 'نوع العرض',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('شبكة')),
              ButtonSegment(value: 1, label: Text('صف')),
            ],
            selected: {(block['variant'] as int?) ?? 0},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'variant', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "البريد الإلكتروني",
          child: CustomTextField(
            controller: getController("${index}_email", block['email'] ?? ''),
            focusNode: getFocusNode("${index}_email"),
            maxLength: 254,
            onChanged: (val) => cubit.updateBlockProperty(index, 'email', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "رقم الهاتف",
          child: CustomTextField(
            controller: getController("${index}_phone", block['phone'] ?? ''),
            focusNode: getFocusNode("${index}_phone"),
            maxLength: 20,
            onChanged: (val) => cubit.updateBlockProperty(index, 'phone', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "العنوان",
          child: CustomTextField(
            controller: getController("${index}_location", block['location'] ?? ''),
            focusNode: getFocusNode("${index}_location"),
            maxLength: 300,
            onChanged: (val) => cubit.updateBlockProperty(index, 'location', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "أيقونة البريد الإلكتروني (Email Icon Name)",
          child: CustomTextField(
            controller: getController("${index}_email_icon", block['email_icon'] ?? ''),
            focusNode: getFocusNode("${index}_email_icon"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'email_icon', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "أيقونة الهاتف (Phone Icon Name)",
          child: CustomTextField(
            controller: getController("${index}_phone_icon", block['phone_icon'] ?? ''),
            focusNode: getFocusNode("${index}_phone_icon"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'phone_icon', val),
          ),
        ),
        SizedBox(height: 16),
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
