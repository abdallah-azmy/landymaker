import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

class LogoHeaderEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const LogoHeaderEditor({
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
    final logoUrl = block['logo_url'];
    final isUploading = (logoUrl ?? '').toString().startsWith('upload://');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImageField(
          label: "لوجو الموقع (Logo Image)",
          imageUrl: logoUrl,
          isUploading: isUploading,
          onAction: () => pickImage(cubit, index, itemKey: 'logo_url'),
          onSaveTemplateAsset: () => persistAsset(cubit, index, itemKey: 'logo_url'),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: context.translate('display_mode'),
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
