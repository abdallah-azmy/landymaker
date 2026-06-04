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

class TrustLogosEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const TrustLogosEditor({
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "الشعارات (Logos)",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                final List items = List.from(block['items'] ?? []);
                items.add('https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg');
                cubit.updateBlockProperty(index, 'items', items);
              },
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
              label: const Text("أضف شعار"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate((block['items'] as List).length, (tIndex) {
          final String url = (block['items'] as List)[tIndex];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: "رابط الشعار",
                        controller: getController("${index}_trustlogo_${tIndex}", url),
                        focusNode: getFocusNode("${index}_trustlogo_${tIndex}"),
                        onChanged: (val) {
                          final List items = List.from(block['items'] ?? []);
                          items[tIndex] = val;
                          cubit.updateBlockProperty(index, 'items', items);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
                      onPressed: () {
                        final List items = List.from(block['items'] ?? []);
                        items.removeAt(tIndex);
                        cubit.updateBlockProperty(index, 'items', items);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: "ابحث في الصور",
                  icon: Icons.search_rounded,
                  isSecondary: true,
                  onPressed: () => pickImage(
                    cubit,
                    index,
                    itemIndex: tIndex,
                    itemKey: 'items_array',
                  ),
                  width: double.infinity,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
