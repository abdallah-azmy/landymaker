import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

class FeaturesEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const FeaturesEditor({
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
          label: context.translate('layout_style'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: block['layout_style'] ?? 'grid',
                dropdownColor: AppColors.cardBg,
                isExpanded: true,
                style: AppTypography.bodyMedium,
                items: const [
                  DropdownMenuItem(value: 'grid', child: Text("شبكة (Grid)")),
                  DropdownMenuItem(value: 'bento', child: Text("بينتو (Bento)")),
                ],
                onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.translate('feature_list'),
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...List.generate(((block['items'] as List?) ?? []).length, (fIndex) {
          final item = ((block['items'] as List?) ?? [])[fIndex] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CustomTextField(
                  hintText: context.translate('title'),
                  controller: getController("${index}_feature_${fIndex}_title", item['title'] ?? ''),
                  focusNode: getFocusNode("${index}_feature_${fIndex}_title"),
                  onChanged: (val) => cubit.updateFeatureItem(index, fIndex, 'title', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('description'),
                  controller: getController("${index}_feature_${fIndex}_description", item['description'] ?? ''),
                  focusNode: getFocusNode("${index}_feature_${fIndex}_description"),
                  maxLines: 2,
                  onChanged: (val) => cubit.updateFeatureItem(index, fIndex, 'description', val),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: context.translate('redirect_url'),
                  controller: getController("${index}_feature_${fIndex}_link_url", item['link_url'] ?? ''),
                  focusNode: getFocusNode("${index}_feature_${fIndex}_link_url"),
                  onChanged: (val) => cubit.updateFeatureItem(index, fIndex, 'link_url', val),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                CustomImageField(
                  label: context.translate('image_url'),
                  imageUrl: item['image_url'],
                  onAction: () => pickImage(cubit, index, itemIndex: fIndex, itemKey: 'image_url'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
