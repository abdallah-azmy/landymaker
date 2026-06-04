import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/models/landing_page_theme.dart';
import '../modals/stock_image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../../../core/utils/file_utils.dart';
import 'blocks/logo_header_editor.dart';
import 'blocks/hero_editor.dart';
import 'blocks/lead_form_editor.dart';
import 'blocks/lead_magnet_editor.dart';
import 'blocks/location_map_editor.dart';
import 'blocks/pricing_editor.dart';
import 'blocks/faq_editor.dart';
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

  Future<void> _pickStockImage(
    LandingPageBuilderCubit cubit,
    int blockIndex, {
    String? itemKey,
    int? itemIndex,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => StockImagePicker(
          onImageSelected: (url) {
            if (itemKey == 'items_array' && itemIndex != null) {
              final block = (cubit.state as BuilderLoaded)
                  .designMap['blocks'][blockIndex];
              final List items = List.from(block['items'] ?? []);
              items[itemIndex] = url;
              cubit.updateBlockProperty(blockIndex, 'items', items);
            } else if (itemKey != null && itemIndex != null) {
              cubit.updateProductItem(blockIndex, itemIndex, itemKey, url);
            } else {
              cubit.updateBlockProperty(blockIndex, 'image_url', url);
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    LandingPageBuilderCubit cubit,
    int blockIndex, {
    String? itemKey,
    int? itemIndex,
  }) async {
    try {
      final file = await FileUtils.pickImage();
      if (file != null) {
        await cubit.uploadBlockImage(blockIndex, file);
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadBackgroundImage(
    LandingPageBuilderCubit cubit,
    int blockIndex,
  ) async {
    try {
      final file = await FileUtils.pickImage();
      if (file != null) {
        await cubit.uploadBlockBackgroundImage(blockIndex, file);
      }
    } catch (_) {}
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
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayModeOption(
    LandingPageBuilderCubit cubit, {
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
                color: isSelected ? AppColors.secondary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentTab(LandingPageBuilderCubit cubit, Map<String, dynamic> block, String type) {
    return [
      if (type == 'multi_step_lead_form') ...[
      MultiStepFormEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
      ),
    ],
      if (type == 'video_embed') ...[
      VideoEmbedEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
      ),
    ],
      FormGroup(
        label: "عنوان السكشن (Section Title)",
        child: CustomTextField(
          controller: _getController("${widget.index}_title", block['title'] ?? ''),
          focusNode: _getFocusNode("${widget.index}_title"),
          onChanged: (val) => cubit.updateBlockProperty(widget.index, 'title', val),
        ),
      ),
      const SizedBox(height: 16),

      if (type == 'logo_header') ...[
      LogoHeaderEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'hero' || type == 'hero_saas') ...[
      HeroEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'lead_form') ...[
      LeadFormEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'lead_magnet') ...[
      LeadMagnetEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'faq') ...[
      FaqEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'testimonials') ...[
      TestimonialsEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'contact_info') ...[
      ContactInfoEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'social_qr') ...[
      SocialQrEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'qr_code') ...[
      QrCodeEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'basic_section') ...[
      BasicSectionEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'gallery') ...[
      GalleryEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'trust_logos') ...[
      TrustLogosEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'animated_counter') ...[
      AnimatedCounterEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'pricing') ...[
      PricingEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
      ),
    ],

      if (type == 'working_hours') ...[
      WorkingHoursEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],

      if (type == 'location_map') ...[
      LocationMapEditor(
        cubit: cubit,
        block: block,
        index: widget.index,
        getController: _getController,
        getFocusNode: _getFocusNode,
        pickImage: _pickStockImage,
        pickAndUploadImage: _pickAndUploadImage,
      ),
    ],
    ];
  }

  List<Widget> _buildActionsTab(LandingPageBuilderCubit cubit, Map<String, dynamic> block, String type) {
    final List<Widget> list = [];

    if (type == 'hero' || type == 'hero_saas') {
      list.add(
        FormGroup(
          label: "رابط توجيه الزر الأساسي (Hero Button Redirect URL)",
          helperText: "مثال: https://google.com أو صفحة أخرى",
          child: CustomTextField(
            controller: _getController("${widget.index}_button_url", block['button_url'] ?? ''),
            focusNode: _getFocusNode("${widget.index}_button_url"),
            onChanged: (val) => cubit.updateBlockProperty(widget.index, 'button_url', val),
            keyboardType: TextInputType.url,
          ),
        ),
      );
    }

    if (type == 'whatsapp') {
      list.addAll([
        FormGroup(
          label: "رقم الواتساب (WhatsApp Number)",
          helperText: "مثال: 201012345678",
          child: CustomTextField(
            controller: _getController("${widget.index}_phone_number", block['phone_number'] ?? ''),
            focusNode: _getFocusNode("${widget.index}_phone_number"),
            onChanged: (val) => cubit.updateBlockProperty(widget.index, 'phone_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 16),
        FormGroup(
          label: "الرسالة التلقائية (Initial Message)",
          child: CustomTextField(
            controller: _getController("${widget.index}_whatsapp_message", block['message'] ?? ''),
            focusNode: _getFocusNode("${widget.index}_whatsapp_message"),
            onChanged: (val) => cubit.updateBlockProperty(widget.index, 'message', val),
          ),
        ),
      ]);
    }

    if (type == 'features') {
      list.add(
        Text(
          "روابط توجيه عناصر المميزات (Feature Items Redirect Links)",
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      list.add(const SizedBox(height: 12));
      final items = (block['items'] as List?) ?? [];
      for (int fIndex = 0; fIndex < items.length; fIndex++) {
        final item = items[fIndex] as Map<String, dynamic>;
        list.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FormGroup(
              label: "رابط التوجيه للميزة: ${item['title'] ?? '#${fIndex + 1}'}",
              child: CustomTextField(
                hintText: "https://example.com/feature-link",
                controller: _getController("${widget.index}_feature_${fIndex}_link_url", item['link_url'] ?? ''),
                focusNode: _getFocusNode("${widget.index}_feature_${fIndex}_link_url"),
                onChanged: (val) => cubit.updateFeatureItem(widget.index, fIndex, 'link_url', val),
                keyboardType: TextInputType.url,
              ),
            ),
          ),
        );
      }
    }

    if (type == 'products') {
      list.addAll([
        FormGroup(
          label: "رقم الواتساب للطلبات (WhatsApp Number)",
          helperText: "مثال: 201012345678",
          child: CustomTextField(
            controller: _getController("${widget.index}_whatsapp_number", block['whatsapp_number'] ?? ''),
            focusNode: _getFocusNode("${widget.index}_whatsapp_number"),
            onChanged: (val) => cubit.updateBlockProperty(widget.index, 'whatsapp_number', val),
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "روابط شراء أو تفاصيل المنتجات (Products Direct Links)",
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
      ]);
      final items = (block['items'] as List?) ?? [];
      for (int pIndex = 0; pIndex < items.length; pIndex++) {
        final item = items[pIndex] as Map<String, dynamic>;
        list.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FormGroup(
              label: "رابط الشراء للمنتج: ${item['name'] ?? '#${pIndex + 1}'}",
              helperText: "في حال إدخال رابط، سيقوم الزر بنقل العميل إليه بدلاً من رسالة الواتساب.",
              child: CustomTextField(
                hintText: "https://example.com/buy-now",
                controller: _getController("${widget.index}_product_${pIndex}_purchase_url", item['purchase_url'] ?? ''),
                focusNode: _getFocusNode("${widget.index}_product_${pIndex}_purchase_url"),
                onChanged: (val) => cubit.updateProductItem(widget.index, pIndex, 'purchase_url', val),
                keyboardType: TextInputType.url,
              ),
            ),
          ),
        );
      }
    }

    if (type == 'gallery') {
      list.add(
        Text(
          "روابط توجيه صور المعرض (Gallery Images Redirect Links)",
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      list.add(const SizedBox(height: 12));
      final items = (block['items'] as List?) ?? [];
      final List galleryLinks = List.from(block['gallery_links'] ?? List.filled(items.length, ''));
      while (galleryLinks.length < items.length) {
        galleryLinks.add('');
      }
      for (int gIndex = 0; gIndex < items.length; gIndex++) {
        final String linkVal = galleryLinks[gIndex] as String;
        list.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBgHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    items[gIndex],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormGroup(
                    label: "رابط التوجيه للصورة #${gIndex + 1}",
                    child: CustomTextField(
                      hintText: "https://example.com/item-details",
                      controller: _getController("${widget.index}_gallery_link_${gIndex}", linkVal),
                      focusNode: _getFocusNode("${widget.index}_gallery_link_${gIndex}"),
                      onChanged: (val) {
                        final List updatedLinks = List.from(galleryLinks);
                        updatedLinks[gIndex] = val;
                        cubit.updateBlockProperty(widget.index, 'gallery_links', updatedLinks);
                      },
                      keyboardType: TextInputType.url,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (list.isEmpty) {
      list.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.link_off_rounded,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  "هذا القسم لا يحتوي على أزرار أو روابط للتوجيه.",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return list;
  }

  List<Widget> _buildDesignTab(LandingPageBuilderCubit cubit, Map<String, dynamic> block, String type) {
    return [
      FormGroup(
        label: "خط القسم (Font Family)",
        helperText: "اتركه فارغاً لاستخدام خط الصفحة العام.",
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
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              hint: const Text(
                "الخط الافتراضي للصفحة",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    "الخط الافتراضي للصفحة",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                ...LandingPageTheme.availableFonts.map((font) {
                  return DropdownMenuItem<String>(
                    value: font['family'],
                    child: Text(
                      font['family']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                cubit.updateBlockProperty(widget.index, 'fontFamily', val);
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      FormGroup(
        label: "رابط صورة الخلفية (Background Image URL)",
        child: CustomTextField(
          controller: _getController("${widget.index}_bg_image_url", block['bg_image_url'] ?? ''),
          focusNode: _getFocusNode("${widget.index}_bg_image_url"),
          onChanged: (val) => cubit.updateBlockProperty(widget.index, 'bg_image_url', val),
        ),
      ),
      const SizedBox(height: 10),
      PrimaryButton(
        text: "ارفع صورة الخلفية (Upload Background)",
        icon: Icons.upload_file_rounded,
        isSecondary: true,
        onPressed: () => _pickAndUploadBackgroundImage(cubit, widget.index),
        width: double.infinity,
      ),
      const SizedBox(height: 16),
      FormGroup(
        label: "لون التراكب (Overlay Color Hex)",
        helperText: "مثال: #000000",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _getController("${widget.index}_bg_overlay_color", block['bg_overlay_color'] ?? ''),
              focusNode: _getFocusNode("${widget.index}_bg_overlay_color"),
              onChanged: (val) => cubit.updateBlockProperty(widget.index, 'bg_overlay_color', val),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#000000',
                  Colors.black,
                  isSelected: (block['bg_overlay_color'] ?? '') == '#000000',
                ),
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#FFFFFF',
                  Colors.white,
                  isSelected: (block['bg_overlay_color'] ?? '') == '#FFFFFF',
                ),
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#1E293B',
                  const Color(0xFF1E293B),
                  isSelected: (block['bg_overlay_color'] ?? '') == '#1E293B',
                ),
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#0F172A',
                  const Color(0xFF0F172A),
                  isSelected: (block['bg_overlay_color'] ?? '') == '#0F172A',
                ),
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#1E3A8A',
                  Colors.blue.shade900,
                  isSelected: (block['bg_overlay_color'] ?? '') == '#1E3A8A',
                ),
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#7F1D1D',
                  Colors.red.shade900,
                  isSelected: (block['bg_overlay_color'] ?? '') == '#7F1D1D',
                ),
                _buildColorPreset(
                  cubit,
                  widget.index,
                  '#14532D',
                  Colors.green.shade900,
                  isSelected: (block['bg_overlay_color'] ?? '') == '#14532D',
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        "شفافية التراكب: ${((block['bg_overlay_opacity'] ?? 0.4) as num).toStringAsFixed(1)} (Overlay Opacity)",
        style: AppTypography.caption,
      ),
      Slider(
        value: ((block['bg_overlay_opacity'] ?? 0.4) as num).toDouble(),
        min: 0.0,
        max: 1.0,
        divisions: 10,
        activeColor: AppColors.secondary,
        onChanged: (val) => cubit.updateBlockProperty(widget.index, 'bg_overlay_opacity', val),
      ),
      const SizedBox(height: 8),
      Text(
        "تأثير التمويه: ${((block['bg_blur'] ?? 0.0) as num).toStringAsFixed(0)}px (Background Blur)",
        style: AppTypography.caption,
      ),
      Slider(
        value: ((block['bg_blur'] ?? 0.0) as num).toDouble(),
        min: 0.0,
        max: 20.0,
        divisions: 20,
        activeColor: AppColors.secondary,
        onChanged: (val) => cubit.updateBlockProperty(widget.index, 'bg_blur', val),
      ),
      const SizedBox(height: 16),

      if (type == 'gallery') ...[
        const SizedBox(height: 16),
        Text(
          "شكل العرض",
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDisplayModeOption(
              cubit,
              isSelected: (block['display_mode'] ?? 'grid') == 'grid' && (block['grid_columns'] ?? 3) == 2,
              icon: Icons.grid_view_rounded,
              label: "شبكة (٢)",
              onTap: () {
                cubit.updateBlockProperty(widget.index, 'display_mode', 'grid');
                cubit.updateBlockProperty(widget.index, 'grid_columns', 2);
              },
            ),
            const SizedBox(width: 8),
            _buildDisplayModeOption(
              cubit,
              isSelected: (block['display_mode'] ?? 'grid') == 'grid' && (block['grid_columns'] ?? 3) == 3,
              icon: Icons.grid_on_rounded,
              label: "شبكة (٣)",
              onTap: () {
                cubit.updateBlockProperty(widget.index, 'display_mode', 'grid');
                cubit.updateBlockProperty(widget.index, 'grid_columns', 3);
              },
            ),
            const SizedBox(width: 8),
            _buildDisplayModeOption(
              cubit,
              isSelected: (block['display_mode'] ?? 'grid') == 'carousel',
              icon: Icons.view_carousel_rounded,
              label: "متحرك",
              onTap: () {
                cubit.updateBlockProperty(widget.index, 'display_mode', 'carousel');
              },
            ),
          ],
        ),
      ],

      if (type == 'basic_section') ...[
        const SizedBox(height: 16),
        Text(
          "إعدادات التخطيط",
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          "اتجاه التخطيط",
          'layout_direction',
          ['column', 'row'],
          (val) => cubit.updateBlockProperty(widget.index, 'layout_direction', val),
        ),
        _buildDropdown(
          "المحاذاة الرأسية",
          'main_axis_alignment',
          ['start', 'center', 'end', 'spaceBetween'],
          (val) => cubit.updateBlockProperty(widget.index, 'main_axis_alignment', val),
        ),
        _buildDropdown(
          "المحاذاة الأفقية",
          'cross_axis_alignment',
          ['start', 'center', 'end', 'stretch'],
          (val) => cubit.updateBlockProperty(widget.index, 'cross_axis_alignment', val),
        ),
        _buildSlider(
          "المسافة بين العناصر",
          'spacing',
          0,
          100,
          (val) => cubit.updateBlockProperty(widget.index, 'spacing', val),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final blocks = (widget.state.designMap['blocks'] as List?) ?? [];

    if (widget.index >= blocks.length) return const SizedBox.shrink();

    final block = blocks[widget.index] as Map<String, dynamic>;
    final String type = block['type'] ?? '';
    String sectionName = "السكشن";

    switch (type) {
      case 'logo_header':
        sectionName = "الترويسة (Logo Header)";
        break;
      case 'basic_section':
        sectionName = "القسم المرن (Flex Section)";
        break;
      case 'navbar':
        sectionName = "شريط التنقل (Navbar)";
        break;
      case 'hero':
        sectionName = "قسم البطل (Hero)";
        break;
      case 'hero_saas':
        sectionName = "قسم البطل التقني (Hero SaaS)";
        break;
      case 'features':
        sectionName = "المميزات";
        break;
      case 'products':
        sectionName = "المنتجات";
        break;
      case 'pricing':
        sectionName = "الأسعار";
        break;
      case 'multi_step_lead_form':
        sectionName = "نموذج خطوات (Multi-Step Form)";
        break;
      case 'video_embed':
        sectionName = "فيديو مضمن (Video Embed)";
        break;
      case 'gallery':
        sectionName = "معرض الصور";
        break;
      case 'testimonials':
        sectionName = "آراء العملاء";
        break;
      case 'faq':
        sectionName = "الأسئلة الشائعة";
        break;
      case 'lead_form':
        sectionName = "نموذج التواصل";
        break;
      case 'lead_magnet':
        sectionName = "مغناطيس العملاء (Lead Magnet)";
        break;
      case 'working_hours':
        sectionName = "مواعيد العمل (Working Hours)";
        break;
      case 'location_map':
        sectionName = "الخريطة والموقع (Location Map)";
        break;
      case 'contact_info':
        sectionName = "معلومات الاتصال";
        break;
      case 'social_qr':
        sectionName = "روابط تواصل";
        break;
      case 'qr_code':
        sectionName = "رمز QR";
        break;
      case 'whatsapp':
        sectionName = "واتساب";
        break;
      case 'footer':
        sectionName = "التذييل (Footer)";
        break;
      case 'trust_logos':
        sectionName = "شركاء النجاح (Trust Logos)";
        break;
      case 'animated_counter':
        sectionName = "العدادات (Animated Counters)";
        break;
    }

    List<Widget> activeWidgets;
    if (_activeTab == 0) {
      activeWidgets = _buildContentTab(cubit, block, type);
    } else if (_activeTab == 1) {
      activeWidgets = _buildActionsTab(cubit, block, type);
    } else {
      activeWidgets = _buildDesignTab(cubit, block, type);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!widget.isBottomSheet)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: widget.onDone,
                ),
              Text(
                widget.isBottomSheet ? "تعديل $sectionName" : "تعديل القسم",
                style: AppTypography.h3,
              ),
              if (!widget.isBottomSheet) const Spacer(),
              TextButton(
                onPressed: widget.onDone,
                child: Text(
                  widget.isBottomSheet ? "إغلاق" : "تم",
                  style: AppTypography.button.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (widget.isBottomSheet) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.index > 0
                        ? () {
                            cubit.moveBlock(widget.index, true);
                            widget.onDone();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    label: const Text("نقل للأعلى"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.index < blocks.length - 1
                        ? () {
                            cubit.moveBlock(widget.index, false);
                            widget.onDone();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                    label: const Text("نقل للأسفل"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: "حذف السكشن",
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

          // Beautiful Tab Selection Control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildTabButton(0, "المحتوى", Icons.edit_note_rounded),
                _buildTabButton(1, "روابط وأفعال", Icons.link_rounded),
                _buildTabButton(2, "التصميم", Icons.palette_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content body
          ...activeWidgets,
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String key,
    List<String> options,
    Function(String?) onChanged,
  ) {
    final block = widget.state.designMap['blocks'][widget.index];
    final value = block[key] as String? ?? options.first;

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
            value: options.contains(value) ? value : options.first,
            isExpanded: true,
            underline: const SizedBox(),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
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
    Function(double) onChanged,
  ) {
    final block = widget.state.designMap['blocks'][widget.index];
    final value = ((block[key] ?? min) as num).toDouble();
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
          onChanged: onChanged,
        ),
      ],
    );
  }
}
