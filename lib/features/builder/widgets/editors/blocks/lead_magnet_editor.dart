import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';

class LeadMagnetEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const LeadMagnetEditor({
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
            label: "العنوان الفرعي (Subtitle)",
            child: CustomTextField(
              controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
              focusNode: getFocusNode("${index}_subtitle"),
              maxLines: 2,
              onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
            ),
          ),
          const SizedBox(height: 16),
          FormGroup(
            label: "صورة الدليل أو الغلاف (Image)",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: getController("${index}_image_url", block['image_url'] ?? ''),
                  focusNode: getFocusNode("${index}_image_url"),
                  onChanged: (val) => cubit.updateBlockProperty(index, 'image_url', val),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: "ابحث في الصور (Stock Images)",
                  icon: Icons.search_rounded,
                  isSecondary: true,
                  onPressed: () => pickImage(cubit, index),
                  width: double.infinity,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
      ],
    );
  }
}
