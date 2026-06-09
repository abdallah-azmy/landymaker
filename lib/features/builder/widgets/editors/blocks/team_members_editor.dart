import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../../molecules/custom_image_field.dart';
import '../editor_types.dart';

class TeamMembersEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PersistAsset persistAsset;

  const TeamMembersEditor({
    super.key,
    required this.cubit,
    required this.block,
    required this.index,
    required this.getController,
    required this.getFocusNode,
    required this.pickImage,
    required this.persistAsset,
  });

  @override
  Widget build(BuildContext context) {
    final List items = List.from(block['items'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormGroup(
          label: 'العنوان الفرعي',
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        const SizedBox(height: 24),
        Text("أعضاء الفريق", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(items.length, (i) {
          final item = items[i];
          final String imageUrl = item['image_url'] ?? '';
          final isUploading = imageUrl.startsWith('upload://');

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomImageField(
                        label: 'صورة العضو',
                        imageUrl: imageUrl,
                        isUploading: isUploading,
                        onAction: () => pickImage(cubit, index, itemIndex: i, itemKey: 'image_url'),
                        onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: i, itemKey: 'image_url'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        items.removeAt(i);
                        cubit.updateBlockProperty(index, 'items', items);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: "الاسم",
                  controller: getController("${index}_member_${i}_name", item['name'] ?? ''),
                  focusNode: getFocusNode("${index}_member_${i}_name"),
                  onChanged: (val) {
                    items[i]['name'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "المسمى الوظيفي",
                  controller: getController("${index}_member_${i}_role", item['role'] ?? ''),
                  focusNode: getFocusNode("${index}_member_${i}_role"),
                  onChanged: (val) {
                    items[i]['role'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "نبذة مختصرة",
                  maxLines: 2,
                  controller: getController("${index}_member_${i}_bio", item['bio'] ?? ''),
                  focusNode: getFocusNode("${index}_member_${i}_bio"),
                  onChanged: (val) {
                    items[i]['bio'] = val;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialsEditor(i, item['socials'] ?? []),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            items.add({'name': 'عضو جديد', 'role': 'مسمى وظيفي', 'bio': '', 'image_url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400', 'socials': []});
            cubit.updateBlockProperty(index, 'items', items);
          },
          icon: const Icon(Icons.add),
          label: const Text("إضافة عضو"),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialsEditor(int memberIndex, List socials) {
    final List items = List.from(block['items'] ?? []);
    final List currentSocials = List.from(socials);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("روابط التواصل", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(currentSocials.length, (si) {
          final s = currentSocials[si];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPlatformPicker(s['platform'], (p) {
                    currentSocials[si]['platform'] = p;
                    items[memberIndex]['socials'] = currentSocials;
                    cubit.updateBlockProperty(index, 'items', items);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    hintText: "الرابط",
                    controller: getController("${index}_mem_${memberIndex}_soc_${si}_url", s['url'] ?? ''),
                    focusNode: getFocusNode("${index}_mem_${memberIndex}_soc_${si}_url"),
                    onChanged: (val) {
                      currentSocials[si]['url'] = val;
                      items[memberIndex]['socials'] = currentSocials;
                      cubit.updateBlockProperty(index, 'items', items);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
                  onPressed: () {
                    currentSocials.removeAt(si);
                    items[memberIndex]['socials'] = currentSocials;
                    cubit.updateBlockProperty(index, 'items', items);
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            currentSocials.add({'platform': 'linkedin', 'url': ''});
            items[memberIndex]['socials'] = currentSocials;
            cubit.updateBlockProperty(index, 'items', items);
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text("إضافة رابط", style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildPlatformPicker(String? current, Function(String) onSelect) {
    final platforms = ['linkedin', 'instagram', 'twitter', 'facebook'];
    return DropdownButton<String>(
      value: platforms.contains(current) ? current : platforms.first,
      isExpanded: true,
      items: platforms.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)))).toList(),
      onChanged: (val) => onSelect(val!),
    );
  }
}
