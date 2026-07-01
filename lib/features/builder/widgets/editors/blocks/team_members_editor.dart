import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_state.dart';
import '../../../controllers/builder_cubit.dart';
import '../../molecules/custom_image_field.dart';
import '../../modals/image_picker_modal.dart';
import '../../../controllers/upload_manager_cubit.dart';
import '../../../../../injection_container.dart';
import '../common/dynamic_list_editor.dart';
import '../editor_types.dart';

/// Editor for the team_members block type.
/// Exposes title, subtitle, variant (0=Grid/1=Carousel),
/// and team member items with name, role, bio, image_url, socials.
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
          label: 'العنوان الرئيسي',
          child: CustomTextField(
            controller: getController("${index}_title", block['title'] ?? ''),
            focusNode: getFocusNode("${index}_title"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'title', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: 'العنوان الفرعي',
          child: CustomTextField(
            controller: getController("${index}_subtitle", block['subtitle'] ?? ''),
            focusNode: getFocusNode("${index}_subtitle"),
            onChanged: (val) => cubit.updateBlockProperty(index, 'subtitle', val),
          ),
        ),
        SizedBox(height: 24),
        FormGroup(
          label: 'نوع العرض',
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('شبكة')),
              ButtonSegment(value: 1, label: Text('شريط متحرك')),
            ],
            selected: {(block['variant'] as int?) ?? 0},
            onSelectionChanged: (val) => cubit.updateBlockProperty(index, 'variant', val.first),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        SizedBox(height: 24),
        DynamicListEditor(
          title: "أعضاء الفريق",
          addLabel: "إضافة عضو",
          itemCount: items.length,
          itemTitleBuilder: (i) => (items[i]['name'] ?? '').isEmpty ? 'عضو جديد' : items[i]['name'],
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final List items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onAdd: () async {
            final selectedData = await ImagePickerModal.show(context);
            if (selectedData == null) return;

            final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';
            
            // Add a temporary upload:// item so the UI shows the loading spinner!
            final List freshItems = List.from(block['items'] ?? []);
            final int tIndex = freshItems.length;
            freshItems.add({
              'name': 'عضو جديد',
              'role': 'مسمى وظيفي',
              'bio': '',
              'image_url': uploadId,
              'socials': []
            });
            cubit.updateBlockProperty(index, 'items', freshItems);

            sl<UploadManagerCubit>().upload(
              uploadId: uploadId,
              data: selectedData,
              onSuccess: (finalUrl) {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems2 = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems2.length) {
                    freshItems2[tIndex] = Map<String, dynamic>.from(freshItems2[tIndex])..['image_url'] = finalUrl;
                    cubit.updateBlockProperty(index, 'items', freshItems2);
                  }
                }
              },
              onCancel: () {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems2 = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems2.length) {
                    freshItems2.removeAt(tIndex);
                    cubit.updateBlockProperty(index, 'items', freshItems2);
                  }
                }
              },
            );
          },
          onDelete: (i) {
            final List updated = List.from(block['items'] ?? []);
            updated.removeAt(i);
            cubit.updateBlockProperty(index, 'items', updated);
          },
          itemBuilder: (context, i, onDelete) {
            final item = items[i];
            final String imageUrl = item['image_url'] ?? '';
            final isUploading = imageUrl.startsWith('upload://');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageField(
                  label: 'صورة العضو',
                  imageUrl: imageUrl,
                  isUploading: isUploading,
                  onAction: () => pickImage(cubit, index, itemIndex: i, itemKey: 'image_url'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: i, itemKey: 'image_url'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: "الاسم",
                  controller: getController("${index}_member_${i}_name", item['name'] ?? ''),
                  focusNode: getFocusNode("${index}_member_${i}_name"),
                  maxLength: 100,
                  onChanged: (val) {
                    final List freshItems = List.from(block['items'] ?? []);
                    freshItems[i]['name'] = val;
                    cubit.updateBlockProperty(index, 'items', freshItems);
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "المسمى الوظيفي",
                  controller: getController("${index}_member_${i}_role", item['role'] ?? ''),
                  focusNode: getFocusNode("${index}_member_${i}_role"),
                  maxLength: 100,
                  onChanged: (val) {
                    final List freshItems = List.from(block['items'] ?? []);
                    freshItems[i]['role'] = val;
                    cubit.updateBlockProperty(index, 'items', freshItems);
                  },
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "نبذة مختصرة",
                  maxLines: 2,
                  controller: getController("${index}_member_${i}_bio", item['bio'] ?? ''),
                  focusNode: getFocusNode("${index}_member_${i}_bio"),
                  onChanged: (val) {
                    final List freshItems = List.from(block['items'] ?? []);
                    freshItems[i]['bio'] = val;
                    cubit.updateBlockProperty(index, 'items', freshItems);
                  },
                ),
                const SizedBox(height: 12),
                _buildSocialsEditor(i, item['socials'] ?? []),
              ],
            );
          },
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
        SizedBox(height: 8),
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
                SizedBox(width: 8),
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
                  icon: Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
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
          icon: Icon(Icons.add, size: 16),
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
      items: platforms.map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(fontSize: 11)))).toList(),
      onChanged: (val) => onSelect(val!),
    );
  }
}
