import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import '../../molecules/custom_image_field.dart';
import '../../../../../../core/localization/app_localizations.dart';

/// Editor for the logo_header block type.
/// Exposes logo_url, alignment (right/center/left), and logo_height slider.
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
        SizedBox(height: 16),
        FormGroup(
          label: context.translate('display_mode'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: block['alignment'] ?? 'center',
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
        SizedBox(height: 16),
        FormGroup(
          label: 'ارتفاع الشعار (Logo Height)',
          child: Row(
            children: [
              Text('${((block['logo_height'] ?? 48.0) as num).toInt()}'),
              Expanded(
                child: Slider(
                  value: ((block['logo_height'] ?? 48.0) as num).toDouble(),
                  min: 24,
                  max: 120,
                  divisions: 16,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (val) => cubit.updateBlockProperty(index, 'logo_height', val),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
