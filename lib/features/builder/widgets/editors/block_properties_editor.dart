import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/models/landing_page_theme.dart';
import '../modals/image_picker_modal.dart';
import '../molecules/custom_image_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/upload_manager_cubit.dart';
import '../../../../features/dashboard/controllers/media_gallery_cubit.dart';
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

import '../../../../core/widgets/block_animation_wrapper.dart';
import '../../registries/style_registry.dart';

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
            color: isSelected ? AppColors.secondary : Colors.transparent,
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
                ? AppColors.secondary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.transparent,
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
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.textSecondary,
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
    list.add(const SizedBox(height: 16));

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
          const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
    final int selectedVariant = block['variant'] ?? 0;
    final Map<String, dynamic> anim = block['animation'] ?? {'type': 'none'};

    final List<Widget> list = [
      Text(
        loc.translate('variants'),
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: StyleRegistry.variants.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final v = StyleRegistry.variants[i];
            final isSelected = selectedVariant == v.index;
            return InkWell(
              onTap: () =>
                  cubit.updateBlockProperty(widget.index, 'variant', v.index),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${v.index}",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.index == 0 ? "Std" : "V${v.index}",
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 24),
      const Divider(color: AppColors.border),
      const SizedBox(height: 16),

      // Block Specific Design Settings
      if (type == 'gallery') ...[
        Text(
          loc.translate('display_mode'),
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 24),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
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
        const SizedBox(height: 24),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
      ],

      Text(
        loc.translate('animation'),
        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
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
      ],
      const SizedBox(height: 24),
      const Divider(color: AppColors.border),
      const SizedBox(height: 16),
      FormGroup(
        label: loc.translate('font_family'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: block['fontFamily'],
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(loc.translate('default_font')),
                ),
                ...LandingPageTheme.availableFonts.map(
                  (font) => DropdownMenuItem<String>(
                    value: font['family'],
                    child: Text(
                      font['family']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              onChanged: (val) =>
                  cubit.updateBlockProperty(widget.index, 'fontFamily', val),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
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
      const SizedBox(height: 16),
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
              activeColor: AppColors.secondary,
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
      const SizedBox(height: 16),
      SwitchListTile(
        title: Text(loc.translate('visible')),
        value: block['is_visible'] ?? true,
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
                ? AppColors.secondary.withValues(alpha: 0.1)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.textSecondary,
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

    if (widget.index >= blocks.length) return const SizedBox.shrink();

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
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.isBottomSheet) ...[
            PrimaryButton(
              text: loc.translate('delete'),
              icon: Icons.delete_rounded,
              isSecondary: true,
              width: double.infinity,
              onPressed: () {
                cubit.deleteBlock(widget.index);
                widget.onDone();
              },
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 24),
          ],
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
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
          const SizedBox(height: 24),
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
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: options.contains(stringValue) ? stringValue : options.first,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.background,
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
        const SizedBox(height: 16),
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
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppColors.secondary,
          onChanged: (v) {
            onChanged(v);
            setState(() {});
          },
        ),
      ],
    );
  }
}
