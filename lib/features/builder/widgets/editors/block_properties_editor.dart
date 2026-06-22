import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/models/landing_page_theme.dart';
import '../modals/image_picker_modal.dart';
import '../molecules/custom_image_field.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../../../../injection_container.dart';
import '../../../../core/localization/localization_cubit.dart';
import 'blocks/logo_header_editor.dart';
import 'blocks/lead_form_editor.dart';
import 'blocks/location_map_editor.dart';
import 'blocks/pricing_editor.dart';
import 'blocks/faq_editor.dart';
import 'blocks/products_editor.dart';
import 'blocks/testimonials_editor.dart';
import 'blocks/contact_info_editor.dart';
import 'blocks/social_qr_editor.dart';
import 'blocks/qr_code_editor.dart';
import 'blocks/basic_section_editor.dart';
import 'blocks/gallery_editor.dart';
import 'blocks/trust_logos_editor.dart';
import 'blocks/animated_counter_editor.dart';
import 'blocks/video_embed_editor.dart';
import 'blocks/multi_step_form_editor.dart';
import 'blocks/working_hours_editor.dart';
import 'blocks/statistics_grid_editor.dart';
import 'blocks/team_members_editor.dart';
import 'blocks/service_steps_editor.dart';
import 'blocks/cta_banner_editor.dart';
import 'blocks/comparison_table_editor.dart';
import 'blocks/featured_product_editor.dart';
import 'blocks/bento_store_editor.dart';

import '../../../../core/widgets/block_animation_wrapper.dart';
import '../../../../core/widgets/draggable_modal_sheet.dart';

import '../layout_picker/layout_picker_panel.dart';

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

  // Cached controllers and focus nodes mapped by key
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
      // Clear old controllers to prevent memory leak & stale values
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

  Future<void> _pickMedia(
    LandingPageBuilderCubit cubit,
    int blockIndex, {
    String? itemKey,
    int? itemIndex,
    bool isBackground = false,
  }) async {
    final selectedData = await ImagePickerModal.show(context);
    if (selectedData == null) return;

    final uploadId = 'upload://${DateTime.now().millisecondsSinceEpoch}';

    void updateProp(String url) {
      final builderCubit = context.read<LandingPageBuilderCubit>();
      if (isBackground) {
        builderCubit.updateBlockProperty(blockIndex, 'bg_image_url', url);
      } else if (itemKey == 'items_array' && itemIndex != null) {
        final block = (builderCubit.state as BuilderLoaded)
            .designMap['blocks'][blockIndex];
        final List items = List.from(block['items'] ?? []);
        items[itemIndex] = url;
        builderCubit.updateBlockProperty(blockIndex, 'items', items);
      } else if (itemKey != null && itemIndex != null) {
        builderCubit.updateProductItem(blockIndex, itemIndex, itemKey, url);
      } else if (itemKey != null) {
        builderCubit.updateBlockProperty(blockIndex, itemKey, url);
      } else {
        builderCubit.updateBlockProperty(blockIndex, 'image_url', url);
      }
    }

    // 1. Capture old URL to revert if cancelled
    String oldUrl = '';
    final blockMap =
        (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
    if (isBackground) {
      oldUrl = blockMap['bg_image_url'] ?? '';
    } else if (itemKey == 'items_array' && itemIndex != null) {
      final items = blockMap['items'] as List? ?? [];
      if (itemIndex < items.length) {
        oldUrl = items[itemIndex] ?? '';
      }
    } else if (itemKey != null && itemIndex != null) {
      final items = blockMap[itemKey] as List? ?? [];
      if (itemIndex < items.length) {
        oldUrl = items[itemIndex]['image'] ?? '';
      }
    } else if (itemKey != null) {
      oldUrl = blockMap[itemKey] ?? '';
    } else {
      oldUrl = blockMap['image_url'] ?? '';
    }

    // 2. Optimistically update UI to show uploading
    updateProp(uploadId);

    // 3. Start background upload
    sl<UploadManagerCubit>().upload(
      uploadId: uploadId,
      data: selectedData,
      onSuccess: (finalUrl) {
        updateProp(finalUrl);
      },
      onCancel: () {
        updateProp(oldUrl);
      },
    );
  }

  Future<void> _persistAsset(
    LandingPageBuilderCubit cubit,
    int blockIndex, {
    String? itemKey,
    int? itemIndex,
    bool isBackground = false,
  }) async {
    final blockMap =
        (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
    String? currentUrl;

    if (isBackground) {
      currentUrl = blockMap['bg_image_url'];
    } else if (itemKey == 'items_array' && itemIndex != null) {
      final items = blockMap['items'] as List? ?? [];
      if (itemIndex < items.length) {
        currentUrl = items[itemIndex];
      }
    } else if (itemKey != null && itemIndex != null) {
      final items = blockMap[itemKey] as List? ?? [];
      if (itemIndex < items.length) {
        currentUrl = items[itemIndex]['image'];
      }
    } else if (itemKey != null) {
      currentUrl = blockMap[itemKey];
    } else {
      currentUrl = blockMap['image_url'];
    }

    if (currentUrl == null || currentUrl.isEmpty) return;

    final uploadId = 'persist://${DateTime.now().millisecondsSinceEpoch}';

    void updateProp(String url) {
      if (isBackground) {
        cubit.updateBlockProperty(blockIndex, 'bg_image_url', url);
      } else if (itemKey == 'items_array' && itemIndex != null) {
        final block =
            (cubit.state as BuilderLoaded).designMap['blocks'][blockIndex];
        final List items = List.from(block['items'] ?? []);
        items[itemIndex] = url;
        cubit.updateBlockProperty(blockIndex, 'items', items);
      } else if (itemKey != null && itemIndex != null) {
        cubit.updateProductItem(blockIndex, itemIndex, itemKey, url);
      } else if (itemKey != null) {
        cubit.updateBlockProperty(blockIndex, itemKey, url);
      } else {
        cubit.updateBlockProperty(blockIndex, 'image_url', url);
      }
    }

    // 1. Optimistic update (show as uploading)
    updateProp('upload://$uploadId');

    // 2. Start persistence
    sl<UploadManagerCubit>().persistExternalImage(
      uploadId: uploadId,
      externalUrl: currentUrl,
      onSuccess: (finalUrl) {
        updateProp(finalUrl);
      },
    );
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

  Widget _buildColorPreset(
    LandingPageBuilderCubit cubit,
    int index,
    String hex,
    Color color, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        cubit.updateBlockProperty(index, 'bg_overlay_color', hex);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentTab(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    Map<String, dynamic> block,
    String type,
  ) {
    final List<Widget> list = [];

    list.add(
      FormGroup(
        label: loc.translate('section_title'),
        child: CustomTextField(
          controller: _getController(
            "${widget.index}_title",
            block['title'] ?? '',
          ),
          focusNode: _getFocusNode("${widget.index}_title"),
          onChanged: (val) =>
              cubit.updateBlockProperty(widget.index, 'title', val),
        ),
      ),
    );
    list.add(SizedBox(height: 16));

    switch (type) {
      case 'hero':
      case 'hero_saas':
        list.addAll([
          FormGroup(
            label: loc.translate('subtitle'),
            child: CustomTextField(
              controller: _getController(
                "${widget.index}_subtitle",
                block['subtitle'] ?? '',
              ),
              focusNode: _getFocusNode("${widget.index}_subtitle"),
              maxLines: 3,
              onChanged: (val) =>
                  cubit.updateBlockProperty(widget.index, 'subtitle', val),
            ),
          ),
          SizedBox(height: 16),
          CustomImageField(
            label: loc.translate('image_url'),
            imageUrl: block['image_url'],
            isUploading: (block['image_url'] ?? '').toString().startsWith(
              'upload://',
            ),
            onAction: () => _pickMedia(cubit, widget.index),
            onSaveTemplateAsset: () => _persistAsset(cubit, widget.index),
          ),
        ]);
        break;
      case 'logo_header':
        list.add(
          LogoHeaderEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'multi_step_lead_form':
        list.add(
          MultiStepFormEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'video_embed':
        list.add(
          VideoEmbedEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'pricing':
        list.add(
          PricingEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'faq':
        list.add(
          FaqEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'testimonials':
        list.add(
          TestimonialsEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'gallery':
        list.add(
          GalleryEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'lead_form':
      case 'lead_magnet':
        list.add(
          LeadFormEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'contact_info':
        list.add(
          ContactInfoEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'location_map':
        list.add(
          LocationMapEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'social_qr':
        list.add(
          SocialQrEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'qr_code':
        list.add(
          QrCodeEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'basic_section':
        list.add(
          BasicSectionEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'trust_logos':
        list.add(
          TrustLogosEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'animated_counter':
        list.add(
          AnimatedCounterEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'working_hours':
        list.add(
          WorkingHoursEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'statistics_grid':
        list.add(
          StatisticsGridEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'team_members':
        list.add(
          TeamMembersEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'service_steps':
        list.add(
          ServiceStepsEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'cta_banner':
        list.add(
          CtaBannerEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'products':
        list.add(
          ProductsEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            pickAndUploadImage: (c, idx, {itemIndex, itemKey}) =>
                _pickMedia(c, idx, itemKey: itemKey, itemIndex: itemIndex),
            persistAsset: (c, idx, {itemIndex, itemKey}) =>
                _persistAsset(c, idx, itemKey: itemKey, itemIndex: itemIndex),
          ),
        );
        break;
      case 'comparison_table':
        list.add(
          ComparisonTableEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
          ),
        );
        break;
      case 'featured_product':
        list.add(
          FeaturedProductEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: _pickMedia,
            persistAsset: _persistAsset,
          ),
        );
        break;
      case 'bento_store':
        list.add(
          BentoStoreEditor(
            cubit: cubit,
            block: block,
            index: widget.index,
            getController: _getController,
            getFocusNode: _getFocusNode,
            pickImage: _pickMedia,
            persistAsset: _persistAsset,
          ),
        );
        break;
      case 'features':
        list.addAll([
          _buildDropdown(
            loc.translate('layout_style'),
            'layout_style',
            ['grid', 'bento'],
            (val) =>
                cubit.updateBlockProperty(widget.index, 'layout_style', val),
          ),
        ]);
        break;
    }

    return list;
  }

  List<Widget> _buildActionsTab(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    Map<String, dynamic> block,
    String type,
  ) {
    final List<Widget> list = [];

    if (type == 'hero' || type == 'hero_saas') {
      list.addAll([
        FormGroup(
          label: loc.translate('button_text'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_button_text",
              block['button_text'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_button_text"),
            onChanged: (val) =>
                cubit.updateBlockProperty(widget.index, 'button_text', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: loc.translate('button_url'),
          helperText: "https://...",
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_button_url",
              block['button_url'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_button_url"),
            onChanged: (val) =>
                cubit.updateBlockProperty(widget.index, 'button_url', val),
          ),
        ),
      ]);
    }

    if (type == 'whatsapp') {
      list.addAll([
        FormGroup(
          label: loc.translate('phone_number'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_phone",
              block['phone_number'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_phone"),
            onChanged: (val) =>
                cubit.updateBlockProperty(widget.index, 'phone_number', val),
          ),
        ),
      ]);
    }

    if (type == 'cta_banner') {
      list.addAll([
        FormGroup(
          label: loc.translate('button_text'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_btn_text",
              block['button_text'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_btn_text"),
            onChanged: (val) =>
                cubit.updateBlockProperty(widget.index, 'button_text', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: loc.translate('button_url'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_btn_url",
              block['button_url'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_btn_url"),
            onChanged: (val) =>
                cubit.updateBlockProperty(widget.index, 'button_url', val),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: loc.translate('secondary_button_text'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_sec_btn_text",
              block['secondary_button_text'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_sec_btn_text"),
            onChanged: (val) => cubit.updateBlockProperty(
              widget.index,
              'secondary_button_text',
              val,
            ),
          ),
        ),
        SizedBox(height: 16),
        FormGroup(
          label: loc.translate('secondary_button_url'),
          child: CustomTextField(
            controller: _getController(
              "${widget.index}_sec_btn_url",
              block['secondary_button_url'] ?? '',
            ),
            focusNode: _getFocusNode("${widget.index}_sec_btn_url"),
            onChanged: (val) => cubit.updateBlockProperty(
              widget.index,
              'secondary_button_url',
              val,
            ),
          ),
        ),
      ]);
    }

    if (list.isEmpty) {
      list.add(Center(child: Text(loc.translate('no_actions_available'))));
    }

    return list;
  }

  List<Widget> _buildDesignTab(
    LocalizationCubit loc,
    LandingPageBuilderCubit cubit,
    Map<String, dynamic> block,
    String type,
  ) {
    final Map<String, dynamic> anim = block['animation'] ?? {'type': 'none'};

    final List<Widget> list = [
      Text(
        'تخطيط القسم',
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: InkWell(
          onTap: () => _showLayoutPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.dashboard_customize_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مُنتقي التخطيط',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Text(
                        'اختر تخطيطاً وخصّص العناصر',
                        style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 24),
      Divider(color: Theme.of(context).colorScheme.outlineVariant),
      SizedBox(height: 16),

      // Block Specific Design Settings
      if (type == 'gallery') ...[
        Text(
          loc.translate('display_mode'),
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildAdvancedOption(
              isSelected: (block['display_mode'] ?? 'grid') == 'grid',
              icon: Icons.grid_view_rounded,
              label: loc.translate('grid'),
              onTap: () => cubit.updateBlockProperty(
                widget.index,
                'display_mode',
                'grid',
              ),
            ),
            SizedBox(width: 8),
            _buildAdvancedOption(
              isSelected: (block['display_mode'] ?? 'grid') == 'carousel',
              icon: Icons.view_carousel_rounded,
              label: loc.translate('carousel'),
              onTap: () => cubit.updateBlockProperty(
                widget.index,
                'display_mode',
                'carousel',
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        SizedBox(height: 16),
      ],

      if (type == 'basic_section') ...[
        _buildDropdown(
          loc.translate('layout_direction'),
          'layout_direction',
          ['column', 'row'],
          (val) =>
              cubit.updateBlockProperty(widget.index, 'layout_direction', val),
        ),
        _buildSlider(
          loc.translate('spacing'),
          'spacing',
          0,
          100,
          (val) => cubit.updateBlockProperty(widget.index, 'spacing', val),
        ),
        SizedBox(height: 24),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        SizedBox(height: 16),
      ],

      Text(
        loc.translate('animation'),
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 16),
      _buildDropdown(
        loc.translate('anim_type'),
        'animation.type',
        BlockAnimationType.values.map((e) => e.name).toList(),
        (val) {
          final newAnim = Map<String, dynamic>.from(anim);
          newAnim['type'] = val;
          cubit.updateBlockProperty(widget.index, 'animation', newAnim);
        },
        translateItem: (item) => loc.translate('anim_$item'),
      ),
      if ((anim['type'] ?? 'none') != 'none') ...[
        _buildSlider(
          loc.translate('anim_duration'),
          'animation.duration',
          100,
          3000,
          (val) {
            final newAnim = Map<String, dynamic>.from(anim);
            newAnim['duration'] = val.toInt();
            cubit.updateBlockProperty(widget.index, 'animation', newAnim);
          },
          currentValue: (anim['duration'] ?? 800).toDouble(),
        ),
        _buildSlider(
          loc.translate('anim_delay'),
          'animation.delay',
          0,
          2000,
          (val) {
            final newAnim = Map<String, dynamic>.from(anim);
            newAnim['delay'] = val.toInt();
            cubit.updateBlockProperty(widget.index, 'animation', newAnim);
          },
          currentValue: (anim['delay'] ?? 0).toDouble(),
        ),
        _buildSlider(
          loc.translate('anim_intensity'),
          'animation.intensity',
          0.1,
          2.0,
          (val) {
            final newAnim = Map<String, dynamic>.from(anim);
            newAnim['intensity'] = val;
            cubit.updateBlockProperty(widget.index, 'animation', newAnim);
          },
          currentValue: (anim['intensity'] ?? 1.0).toDouble(),
        ),
      ],
      SizedBox(height: 24),
      Divider(color: Theme.of(context).colorScheme.outlineVariant),
      SizedBox(height: 16),
      _buildDropdown(
        loc.translate('font_family'),
        'fontFamily',
        ['Default', ...LandingPageTheme.availableFonts.map((f) => f['family']!)],
        (val) => cubit.updateBlockProperty(
          widget.index,
          'fontFamily',
          val == 'Default' ? null : val,
        ),
        translateItem: (item) => item,
      ),
      _buildDropdown(
        'قالب القسم (Theme Override)',
        'theme_override',
        ['Default', ...LandingPageTheme.palettes.map((p) => p.name)],
        (val) => cubit.updateBlockProperty(
          widget.index,
          'theme_override',
          val == 'Default' ? null : val,
        ),
      ),
      SizedBox(height: 16),
      _buildColorPickerItem(
        context,
        "لون خلفية القسم",
        "bg_color",
        LandingPageTheme.parseColor(block['bg_color'] ?? block['background_color'], null) ?? Colors.transparent,
      ),
      SizedBox(height: 16),
      _buildSlider(
        loc.translate('vertical_padding'),
        'vertical_padding',
        0,
        300,
        (val) => cubit.updateBlockProperty(widget.index, 'vertical_padding', val),
      ),
      SizedBox(height: 16),
      CustomImageField(
        label: loc.translate('bg_image_url'),
        imageUrl: block['bg_image_url'],
        isUploading: (block['bg_image_url'] ?? '').toString().startsWith(
          'upload://',
        ),
        onAction: () => _pickMedia(cubit, widget.index, isBackground: true),
        onSaveTemplateAsset: () =>
            _persistAsset(cubit, widget.index, isBackground: true),
      ),
      SizedBox(height: 16),
      FormGroup(
        label: loc.translate('overlay_opacity'),
        child: Column(
          children: [
            Slider(
              value:
                  ((block['overlay_opacity'] ??
                              block['bg_overlay_opacity'] ??
                              0.4)
                          as num)
                      .toDouble(),
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (val) {
                cubit.updateBlockProperty(widget.index, 'overlay_opacity', val);
                cubit.updateBlockProperty(
                  widget.index,
                  'bg_overlay_opacity',
                  val,
                );
              },
            ),
          ],
        ),
      ),
      SizedBox(height: 16),
      SwitchListTile(
        title: Text(loc.translate('visible')),
        value: block['is_visible'] ?? true,
        activeThumbColor: Theme.of(context).colorScheme.primary,
        onChanged: (val) =>
            cubit.updateBlockProperty(widget.index, 'is_visible', val),
      ),
    ];

    return list;
  }

  Widget _buildAdvancedOption({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final loc = context.read<LocalizationCubit>();
    final blocks = (widget.state.designMap['blocks'] as List?) ?? [];

    if (widget.index >= blocks.length) return SizedBox.shrink();

    final block = blocks[widget.index] as Map<String, dynamic>;
    final String type = block['type'] ?? '';

    List<Widget> activeWidgets;
    if (_activeTab == 0) {
      activeWidgets = _buildContentTab(loc, cubit, block, type);
    } else if (_activeTab == 1) {
      activeWidgets = _buildActionsTab(loc, cubit, block, type);
    } else {
      activeWidgets = _buildDesignTab(loc, cubit, block, type);
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
                    title: Text('تأكيد الحذف'),
                    content: const Text('هل تريد حذف هذا القسم؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('إلغاء'),
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
                        child: Text('حذف'),
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
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  0,
                  loc.translate('content'),
                  Icons.edit_note_rounded,
                ),
                _buildTabButton(
                  1,
                  loc.translate('actions'),
                  Icons.touch_app_rounded,
                ),
                _buildTabButton(
                  2,
                  loc.translate('design'),
                  Icons.palette_rounded,
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

  Widget _buildDropdown(
    String label,
    String key,
    List<String> options,
    Function(String?) onChanged, {
    String Function(String)? translateItem,
  }) {
    final block = widget.state.designMap['blocks'][widget.index];

    dynamic value;
    if (key.contains('.')) {
      final parts = key.split('.');
      value = block[parts[0]]?[parts[1]];
    } else {
      value = block[key];
    }

    final String stringValue = value?.toString() ?? options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: DropdownButton<String>(
            value: options.contains(stringValue) ? stringValue : options.first,
            isExpanded: true,
            underline: SizedBox(),
            dropdownColor: Theme.of(context).colorScheme.surface,
            items: options
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: Text(translateItem != null ? translateItem(o) : o),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    String key,
    double min,
    double max,
    Function(double) onChanged, {
    double? currentValue,
  }) {
    final block = widget.state.designMap['blocks'][widget.index];

    double value;
    if (currentValue != null) {
      value = currentValue;
    } else {
      if (key.contains('.')) {
        final parts = key.split('.');
        value = ((block[parts[0]]?[parts[1]] ?? min) as num).toDouble();
      } else {
        value = ((block[key] ?? min) as num).toDouble();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${value.toInt()}",
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (v) {
            onChanged(v);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildColorPickerItem(
    BuildContext context,
    String label,
    String key,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showBlockColorPicker(context, key, color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color == Colors.transparent ? null : color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: color == Colors.transparent
                  ? const Icon(Icons.not_interested_rounded, size: 16, color: Colors.grey)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockColorPicker(
    BuildContext context,
    String key,
    Color currentColor,
  ) {
    final List<Color> colors = [
      Colors.transparent,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Colors.green,
      Theme.of(context).colorScheme.error,
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.brown,
      Colors.black,
      Colors.white,
      const Color(0xFF1E293B),
      const Color(0xFFF8FAFC),
      const Color(0xFFFEFAE0),
      const Color(0xFFECFDF5),
      const Color(0xFFEEF2FF),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("اختر لون خلفية القسم"),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors
              .map(
                (color) => GestureDetector(
                  onTap: () {
                    final hex = color == Colors.transparent
                        ? null
                        : '#\${color.toARGB32().toRadixString(16).padLeft(8, \u00270\u0027)}';
                    context.read<LandingPageBuilderCubit>().updateBlockProperty(
                          widget.index,
                          key,
                          hex,
                        );
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color == Colors.transparent ? null : color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: color == currentColor ? 3 : 1,
                      ),
                    ),
                    child: color == Colors.transparent
                        ? const Icon(Icons.not_interested_rounded, size: 20, color: Colors.grey)
                        : null,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
