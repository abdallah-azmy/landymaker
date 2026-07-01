import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/draggable_modal_sheet.dart';
import '../layout_picker/layout_picker_panel.dart';
import 'blocks/editor_utils.dart';
import 'editor_media_helper.dart';
import 'content_tab_dispatcher.dart';
import 'block_design_settings.dart';

class BlockPropertiesEditor extends StatefulWidget {
  final int index;
  final BuilderLoaded state;
  final bool isBottomSheet;
  final VoidCallback onDone;

  const BlockPropertiesEditor({
    super.key,
    required this.index,
    required this.state,
    this.isBottomSheet = false,
    required this.onDone,
  });

  @override
  State<BlockPropertiesEditor> createState() => _BlockPropertiesEditorState();
}

class _BlockPropertiesEditorState extends State<BlockPropertiesEditor> {
  final TextEditingController _newCategoryController = TextEditingController();
  int _activeTab = 0;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  TextEditingController _getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    } else {
      final node = _getFocusNode(key);
      if (!node.hasFocus && _controllers[key]!.text != initialValue) {
        _controllers[key]!.text = initialValue;
      }
    }
    return _controllers[key]!;
  }

  FocusNode _getFocusNode(String key) {
    return _focusNodes.putIfAbsent(key, () => FocusNode());
  }

  @override
  void didUpdateWidget(covariant BlockPropertiesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      for (var c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      for (var f in _focusNodes.values) {
        f.dispose();
      }
      _focusNodes.clear();
    }
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _showLayoutPicker(BuildContext context) {
    DraggableModalSheet.show(
      context: context,
      title: 'مُنتقي التخطيط',
      initialChildSize: 0.85,
      minChildSize: 0.5,
      child: LayoutPickerPanel(blockIndex: widget.index),
    );
  }

  List<Widget> _buildContentTab(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    Map<String, dynamic> block,
    String type,
  ) {
    final list = <Widget>[];

    if (type != 'trust_logos') {
      list.add(
        FormGroup(
          label: loc.translate('section_title'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_title",
              block['title'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_title"),
            maxLength: 100,
            onChanged: (val) =>
                cubit.updateBlockProperty(widget.index, 'title', val),
          ),
        ),
      );
      list.add(const SizedBox(height: 16));
    }

    final editor = buildContentEditor(
      type: type,
      cubit: cubit,
      block: block,
      index: widget.index,
      getController: _getController,
      getFocusNode: _getFocusNode,
      pickImage: (c, idx, {itemIndex, itemKey}) =>
          pickMedia(context, c, idx, itemKey: itemKey, itemIndex: itemIndex),
      pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
          pickMedia(context, c, idx, itemKey: itemKey, itemIndex: itemIndex),
      persistAsset: (c, idx, {itemIndex, itemKey}) =>
          persistAsset(context, c, idx, itemKey: itemKey, itemIndex: itemIndex),
    );
    if (editor != null) list.add(editor);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final loc = context.read<LocalizationCubit>();
    final blocks = (widget.state.designMap['blocks'] as List?) ?? [];

    if (widget.index >= blocks.length) return const SizedBox.shrink();

    final block = blocks[widget.index] as Map<String, dynamic>;
    final String type = block['type'] ?? '';

    List<Widget> activeWidgets;
    if (_activeTab == 0) {
      activeWidgets = _buildContentTab(loc, cubit, block, type);
    } else {
      activeWidgets = [
        BlockDesignSettings(
          cubit: cubit,
          block: block,
          type: type,
          index: widget.index,
          onPickMedia: (c, idx, {isBackground = false}) =>
              pickMedia(context, c, idx, isBackground: isBackground),
          onPersistAsset: (c, idx, {isBackground = false}) =>
              persistAsset(context, c, idx, isBackground: isBackground),
          onShowLayoutPicker: () => _showLayoutPicker(context),
        ),
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.translate('edit_block'), style: AppTypography.h3),
              TextButton(
                onPressed: widget.onDone,
                child: Text(
                  loc.translate('close'),
                  style: AppTypography.button.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (widget.isBottomSheet) ...[
            PrimaryButton(
              text: loc.translate('delete'),
              icon: Icons.delete_rounded,
              isSecondary: true,
              width: double.infinity,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: const Text('تأكيد الحذف'),
                    content: const Text('هل تريد حذف هذا القسم؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          cubit.deleteBlock(widget.index);
                          widget.onDone();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                 buildTabButton(
                  context,
                  _activeTab,
                  0,
                  loc.translate('content'),
                  Icons.edit_note_rounded,
                  () => setState(() => _activeTab = 0),
                ),
                buildTabButton(
                  context,
                  _activeTab,
                  1,
                  loc.translate('design'),
                  Icons.palette_rounded,
                  () => setState(() => _activeTab = 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          ...activeWidgets,
        ],
      ),
    );
  }
}
