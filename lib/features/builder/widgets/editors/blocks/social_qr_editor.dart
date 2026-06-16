import 'package:flutter/material.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../editor_types.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/atoms/primary_button.dart';
import '../../../../../core/widgets/molecules/form_group.dart';
import 'package:flutter/services.dart';
import '../../../../../core/utils/toast_service.dart';

class SocialQrEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;

  const SocialQrEditor({
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
    final state = cubit.state;
    final String subdomain = state is BuilderLoaded ? state.subdomain : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: "رابط صفحتك المباشر (Live Page URL)",
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: getController("${index}_socialurl_live", "https://landymaker.com/$subdomain"),
                  readOnly: true,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: AppColors.secondary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "https://landymaker.com/$subdomain"));
                  ToastService.showSuccess(context, message: "تم نسخ الرابط بنجاح!");
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: "العنوان الفرعي (Subtitle)",
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "روابط التواصل",
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                final List links = List.from(block['links'] ?? []);
                links.add({'platform': 'website', 'url': 'https://'});
                cubit.updateBlockProperty(index, 'links', links);
              },
              icon: Icon(Icons.add_link_rounded, size: 16),
              label: const Text("أضف رابط"),
            ),
          ],
        ),
        SizedBox(height: 10),
        ...List.generate(((block['links'] as List?) ?? []).length, (lIndex) {
          final link = ((block['links'] as List?) ?? [])[lIndex] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: link['platform'] ?? 'website',
                          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                          items: const [
                            DropdownMenuItem(value: 'website', child: Text("موقع إلكتروني")),
                            DropdownMenuItem(value: 'instagram', child: Text("انستجرام")),
                            DropdownMenuItem(value: 'facebook', child: Text("فيسبوك")),
                            DropdownMenuItem(value: 'twitter', child: Text("تويتر (X)")),
                            DropdownMenuItem(value: 'linkedin', child: Text("لينكد إن")),
                            DropdownMenuItem(value: 'whatsapp', child: Text("واتساب")),
                          ],
                          onChanged: (val) {
                            final List links = List.from(block['links']);
                            final Map<String, dynamic> updatedLink = Map<String, dynamic>.from(links[lIndex]);
                            updatedLink['platform'] = val;
                            links[lIndex] = updatedLink;
                            cubit.updateBlockProperty(index, 'links', links);
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 20),
                      onPressed: () {
                        final List links = List.from(block['links']);
                        links.removeAt(lIndex);
                        cubit.updateBlockProperty(index, 'links', links);
                      },
                    ),
                  ],
                ),
                CustomTextField(
                  hintText: "الرابط (URL)",
                  controller: getController("${index}_sociallink_${lIndex}_url", link['url'] ?? ''),
                  focusNode: getFocusNode("${index}_sociallink_${lIndex}_url"),
                  onChanged: (val) {
                    final List links = List.from(block['links']);
                    final Map<String, dynamic> updatedLink = Map<String, dynamic>.from(links[lIndex]);
                    updatedLink['url'] = val;
                    links[lIndex] = updatedLink;
                    cubit.updateBlockProperty(index, 'links', links);
                  },
                ),
                SizedBox(height: 12),
                PrimaryButton(
                  text: "ابحث في الصور (Stock Images)",
                  icon: Icons.search_rounded,
                  isSecondary: true,
                  onPressed: () => pickImage(
                    cubit,
                    index,
                    itemIndex: lIndex,
                    itemKey: 'image_url',
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
