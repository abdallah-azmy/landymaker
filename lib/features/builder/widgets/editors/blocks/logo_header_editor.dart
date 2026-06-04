import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';

class LogoHeaderEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const LogoHeaderEditor({
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
          label: "لوجو الموقع (Logo Image)",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: getController("${index}_logo_url", block['logo_url'] ?? ''),
                focusNode: getFocusNode("${index}_logo_url"),
                onChanged: (val) => cubit.updateBlockProperty(index, 'logo_url', val),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: "ابحث في الصور (Stock Images)",
                icon: Icons.search_rounded,
                isSecondary: true,
                onPressed: () => pickImage(cubit, index, itemKey: 'logo_url'),
                width: double.infinity,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "محاذاة الترويسة (Alignment)",
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: block['alignment'] ?? 'center',
                dropdownColor: AppColors.cardBg,
                isExpanded: true,
                style: AppTypography.bodyMedium,
                items: const [
                  DropdownMenuItem(value: 'right', child: Text("يمين (Right)")),
                  DropdownMenuItem(value: 'center', child: Text("المنتصف (Center)")),
                  DropdownMenuItem(value: 'left', child: Text("يسار (Left)")),
                ],
                onChanged: (val) => cubit.updateBlockProperty(index, 'alignment', val),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
