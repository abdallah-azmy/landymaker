import 'package:flutter/material.dart';
import '../../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../../core/widgets/molecules/form_group.dart';
import '../../../controllers/builder_cubit.dart';
import '../../../controllers/builder_state.dart';
import '../../molecules/custom_image_field.dart';
import '../../modals/image_picker_modal.dart';
import '../../../controllers/upload_manager_cubit.dart';
import '../../../../../injection_container.dart';
import '../common/dynamic_list_editor.dart';
import '../editor_types.dart';

/// Editor for the trust_logos block type.
/// Exposes title, layout_style (row/grid), and items (stringList of logo image URLs).
class TrustLogosEditor extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final Map<String, dynamic> block;
  final int index;
  final GetController getController;
  final GetFocusNode getFocusNode;
  final PickImage pickImage;
  final PickAndUploadImage pickAndUploadImage;
  final PersistAsset persistAsset;

  const TrustLogosEditor({
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
          label: 'نوع التخطيط',
          child: DropdownButtonFormField<String>(
            initialValue: () {
              final String currentStyle = block['layout_style'] ?? 'row';
              const allowedStyles = ['row', 'grid', 'logo_strip', 'dark_trust'];
              return allowedStyles.contains(currentStyle) ? currentStyle : 'row';
            }(),
            items: const [
              DropdownMenuItem(value: 'row', child: Text('صف')),
              DropdownMenuItem(value: 'grid', child: Text('شبكة')),
              DropdownMenuItem(value: 'logo_strip', child: Text('شريط شعارات')),
              DropdownMenuItem(value: 'dark_trust', child: Text('ثقة داكنة')),
            ],
            onChanged: (val) => cubit.updateBlockProperty(index, 'layout_style', val),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ),
        SizedBox(height: 16),
        DynamicListEditor(
          title: "الشعارات (Logos)",
          addLabel: "أضف شعار",
          addIcon: Icons.add_photo_alternate_rounded,
          itemCount: ((block['items'] as List?) ?? []).length,
          onAdd: () async {
            final selectedData = await ImagePickerModal.show(context);
            if (selectedData == null) return;

            final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';
            
            // Add a temporary upload:// item so the UI shows the loading spinner!
            final List items = List.from(block['items'] ?? []);
            final int tIndex = items.length;
            items.add(uploadId);
            cubit.updateBlockProperty(index, 'items', items);

            sl<UploadManagerCubit>().upload(
              uploadId: uploadId,
              data: selectedData,
              onSuccess: (finalUrl) {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems.length) {
                    freshItems[tIndex] = finalUrl;
                    cubit.updateBlockProperty(index, 'items', freshItems);
                  }
                }
              },
              onCancel: () {
                final currentState = cubit.state;
                if (currentState is BuilderLoaded) {
                  final freshBlock = currentState.designMap['blocks'][index];
                  final List freshItems = List.from(freshBlock['items'] ?? []);
                  if (tIndex < freshItems.length) {
                    freshItems.removeAt(tIndex);
                    cubit.updateBlockProperty(index, 'items', freshItems);
                  }
                }
              },
            );
          },
          itemTitleBuilder: (tIndex) => "شعار رقم ${tIndex + 1}",
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final items = List.from(block['items'] ?? []);
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
            cubit.updateBlockProperty(index, 'items', items);
          },
          onDelete: (tIndex) {
            final List items = List.from(block['items'] ?? []);
            items.removeAt(tIndex);
            cubit.updateBlockProperty(index, 'items', items);
          },
          itemBuilder: (context, tIndex, onDelete) {
            final String url = ((block['items'] as List?) ?? [])[tIndex];
            final isUploading = url.startsWith('upload://');
            return Column(
              children: [
                CustomImageField(
                  label: "",
                  imageUrl: url,
                  isUploading: isUploading,
                  onAction: () => pickImage(cubit, index, itemIndex: tIndex, itemKey: 'items_array'),
                  onSaveTemplateAsset: () => persistAsset(cubit, index, itemIndex: tIndex, itemKey: 'items_array'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
