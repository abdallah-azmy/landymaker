import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:landymaker/core/widgets/molecules/status_pill.dart';
import 'package:landymaker/features/builder/models/landing_page_theme.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../modals/stock_image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';
import '../../../../core/utils/toast_service.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';

import '../../../../core/utils/file_utils.dart';

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

  @override
  void dispose() {
    _newCategoryController.dispose();
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
    int blockIndex,
  ) async {
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

  void _showProductQrShare(
    BuildContext context,
    Map<String, dynamic> product,
    String subdomain,
  ) {
    final String baseUrl = Uri.base.origin;
    final String productUrl = "$baseUrl/$subdomain?product=${product['id']}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("مشاركة المنتج", style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: PrettyQrView.data(
                data: productUrl,
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(color: AppColors.background),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "سيقوم هذا الكود بتوجيه العميل مباشرة إلى منتج: ${product['name']}",
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: productUrl));
                ToastService.showSuccess(
                  context,
                  message: "تم نسخ الرابط بنجاح!",
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text("نسخ الرابط المباشر"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingPageBuilderCubit>();
    final blocks = widget.state.designMap['blocks'] as List;

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
      case 'features':
        sectionName = "المميزات";
        break;
      case 'products':
        sectionName = "المنتجات";
        break;
      case 'pricing':
        sectionName = "الأسعار";
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

          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text(
                "إعدادات المحتوى (Content)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              initiallyExpanded: true,
              childrenPadding: EdgeInsets.zero,
              tilePadding: EdgeInsets.zero,
              children: [
                FormGroup(
                  label: "عنوان السكشن (Section Title)",
                  child: CustomTextField(
                    controller:
                        TextEditingController(text: block['title'] ?? '')
                          ..selection = TextSelection.collapsed(
                            offset: (block['title'] ?? '').length,
                          ),
                    onChanged: (val) =>
                        cubit.updateBlockProperty(widget.index, 'title', val),
                  ),
                ),
                const SizedBox(height: 16),

                if (type == 'logo_header') ...[
                  FormGroup(
                    label: "لوجو الموقع (Logo Image)",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller:
                              TextEditingController(
                                  text: block['logo_url'] ?? '',
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: (block['logo_url'] ?? '').length,
                                ),
                          onChanged: (val) => cubit.updateBlockProperty(
                            widget.index,
                            'logo_url',
                            val,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: "ابحث في الصور (Stock Images)",
                          icon: Icons.search_rounded,
                          isSecondary: true,
                          onPressed: () => _pickStockImage(cubit, widget.index, itemKey: 'logo_url'),
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "محاذاة الترويسة (Alignment)",
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: block['alignment'] ?? 'center',
                          dropdownColor: AppColors.cardBg,
                          isExpanded: true,
                          style: AppTypography.bodyMedium,
                          items: const [
                            DropdownMenuItem(value: 'right', child: Text("يمين (Right)")),
                            DropdownMenuItem(value: 'center', child: Text("المنتصف (Center)")),
                            DropdownMenuItem(value: 'left', child: Text("يسار (Left)")),
                          ],
                          onChanged: (val) => cubit.updateBlockProperty(
                            widget.index,
                            'alignment',
                            val,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (type == 'hero' || type == 'hero_saas') ...[
                  FormGroup(
                    label: "العنوان الفرعي (Subtitle)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['subtitle'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['subtitle'] ?? '').length,
                            ),
                      maxLines: 3,
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'subtitle',
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "نص الزر (Button Label)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(
                              text: block['button_text'] ?? '',
                            )
                            ..selection = TextSelection.collapsed(
                              offset: (block['button_text'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'button_text',
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "صورة السكشن (Hero Image)",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller:
                              TextEditingController(
                                  text: block['image_url'] ?? '',
                                )
                                ..selection = TextSelection.collapsed(
                                  offset: (block['image_url'] ?? '').length,
                                ),
                          onChanged: (val) => cubit.updateBlockProperty(
                            widget.index,
                            'image_url',
                            val,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: "ابحث في الصور (Stock Images)",
                          icon: Icons.search_rounded,
                          isSecondary: true,
                          onPressed: () => _pickStockImage(cubit, widget.index),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: "ارفع صورة (Upload Image)",
                          icon: Icons.upload_file_rounded,
                          isSecondary: true,
                          onPressed: () =>
                              _pickAndUploadImage(cubit, widget.index),
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ],

                if (type == 'lead_form' || type == 'lead_magnet') ...[
                  if (type == 'lead_magnet') ...[
                    FormGroup(
                      label: "العنوان الفرعي (Subtitle)",
                      child: CustomTextField(
                        controller:
                            TextEditingController(text: block['subtitle'] ?? '')
                              ..selection = TextSelection.collapsed(
                                offset: (block['subtitle'] ?? '').length,
                              ),
                        maxLines: 2,
                        onChanged: (val) => cubit.updateBlockProperty(
                          widget.index,
                          'subtitle',
                          val,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormGroup(
                      label: "صورة الدليل أو الغلاف (Image)",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller:
                                TextEditingController(
                                    text: block['image_url'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (block['image_url'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateBlockProperty(
                              widget.index,
                              'image_url',
                              val,
                            ),
                          ),
                          const SizedBox(height: 10),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () =>
                                _pickStockImage(cubit, widget.index),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FormGroup(
                    label: "نص زر الإرسال (Submit Button Text)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(
                              text: block['button_text'] ?? '',
                            )
                            ..selection = TextSelection.collapsed(
                              offset: (block['button_text'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'button_text',
                        val,
                      ),
                    ),
                  ),
                ],

                if (type == 'whatsapp') ...[
                  FormGroup(
                    label: "رقم الواتساب (Phone Number)",
                    helperText: "مثال: 201000000000",
                    child: CustomTextField(
                      controller:
                          TextEditingController(
                              text: block['phone_number'] ?? '',
                            )
                            ..selection = TextSelection.collapsed(
                              offset: (block['phone_number'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'phone_number',
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "رسالة ترحيبية (Initial Message)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['message'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['message'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'message',
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "نص الزر (Button Text)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(
                              text: block['button_text'] ?? '',
                            )
                            ..selection = TextSelection.collapsed(
                              offset: (block['button_text'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'button_text',
                        val,
                      ),
                    ),
                  ),
                ],

                if (type == 'features') ...[
                  FormGroup(
                    label: "شكل العرض (Layout Style)",
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: block['layout_style'] ?? 'grid',
                          dropdownColor: AppColors.cardBg,
                          isExpanded: true,
                          style: AppTypography.bodyMedium,
                          items: const [
                            DropdownMenuItem(
                              value: 'grid',
                              child: Text("شبكة كلاسيكية (Classic Grid)"),
                            ),
                            DropdownMenuItem(
                              value: 'bento',
                              child: Text("شبكة بينتو (Bento Grid 2025)"),
                            ),
                          ],
                          onChanged: (val) => cubit.updateBlockProperty(
                            widget.index,
                            'layout_style',
                            val,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "قائمة المميزات (Feature Items)",
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['items'] as List).length, (fIndex) {
                    final item =
                        (block['items'] as List)[fIndex]
                            as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgHover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            hintText: "عنوان الميزة (Feature Title)",
                            controller:
                                TextEditingController(text: item['title'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['title'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateFeatureItem(
                              widget.index,
                              fIndex,
                              'title',
                              val,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: "وصف الميزة (Description)",
                            controller:
                                TextEditingController(
                                    text: item['description'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['description'] ?? '').length,
                                  ),
                            maxLines: 2,
                            onChanged: (val) => cubit.updateFeatureItem(
                              widget.index,
                              fIndex,
                              'description',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
                              itemIndex: fIndex,
                              itemKey: 'image_url',
                            ),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (type == 'products') ...[
                  FormGroup(
                    label: "رقم الواتساب للطلبات (WhatsApp Number)",
                    helperText: "مثال: 201012345678",
                    child: CustomTextField(
                      controller:
                          TextEditingController(
                              text: block['whatsapp_number'] ?? '',
                            )
                            ..selection = TextSelection.collapsed(
                              offset: (block['whatsapp_number'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'whatsapp_number',
                        val,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: block['show_category_filter'] ?? true,
                    onChanged: (val) => cubit.updateBlockProperty(
                      widget.index,
                      'show_category_filter',
                      val,
                    ),
                    title: Text(
                      "إظهار أزرار تصفية الفئات",
                      style: AppTypography.bodyMedium,
                    ),
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "إدارة الفئات (Manage Categories)",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _newCategoryController,
                                hintText: "اسم الفئة الجديدة...",
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                final val = _newCategoryController.text.trim();
                                if (val.isNotEmpty) {
                                  final List<String> cats =
                                      (block['categories'] as List?)
                                          ?.cast<String>() ??
                                      [];
                                  if (!cats.contains(val)) {
                                    cubit.updateBlockProperty(
                                      widget.index,
                                      'categories',
                                      [...cats, val],
                                    );
                                  }
                                  _newCategoryController.clear();
                                }
                              },
                              icon: const Icon(Icons.add_circle),
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              ((block['categories'] as List?)?.cast<String>() ??
                                      [])
                                  .map((cat) {
                                    return Chip(
                                      label: Text(cat),
                                      onDeleted: () {
                                        final List<String> cats =
                                            (block['categories'] as List?)
                                                ?.cast<String>() ??
                                            [];
                                        cats.remove(cat);
                                        cubit.updateBlockProperty(
                                          widget.index,
                                          'categories',
                                          cats,
                                        );
                                      },
                                    );
                                  })
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "شكل العرض (Layout Style)",
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              (block['layout_style'] == 'grid' ||
                                  block['layout_style'] == null)
                              ? 'grid_2'
                              : block['layout_style'],
                          dropdownColor: AppColors.cardBg,
                          isExpanded: true,
                          style: AppTypography.bodyMedium,
                          items: [
                            DropdownMenuItem(
                              value: 'grid_2',
                              child: const Text("شبكة (عمودين)"),
                            ),
                            DropdownMenuItem(
                              value: 'grid_3',
                              child: const Text("شبكة (٣ أعمدة)"),
                            ),
                            DropdownMenuItem(
                              value: 'list',
                              child: const Text("قائمة (List)"),
                            ),
                            DropdownMenuItem(
                              value: 'list_large',
                              child: const Text("قائمة (صورة كبيرة)"),
                            ),
                          ],
                          onChanged: (val) => cubit.updateBlockProperty(
                            widget.index,
                            'layout_style',
                            val,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "قائمة المنتجات (Product List)",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => cubit.addProductItem(widget.index),
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 16,
                        ),
                        label: const Text("أضف منتج"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['items'] as List).length, (pIndex) {
                    final item =
                        (block['items'] as List)[pIndex]
                            as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgHover,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "المنتج #${pIndex + 1}",
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.qr_code_2_rounded,
                                      color: AppColors.secondary,
                                      size: 20,
                                    ),
                                    onPressed: () => _showProductQrShare(
                                      context,
                                      item,
                                      widget.state.subdomain,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.dangerRed,
                                      size: 20,
                                    ),
                                    onPressed: () => cubit.deleteProductItem(
                                      widget.index,
                                      pIndex,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: "اسم المنتج",
                            controller:
                                TextEditingController(text: item['name'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['name'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateProductItem(
                              widget.index,
                              pIndex,
                              'name',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "السعر",
                            controller:
                                TextEditingController(text: item['price'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['price'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateProductItem(
                              widget.index,
                              pIndex,
                              'price',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children:
                                ((block['categories'] as List?)
                                            ?.cast<String>() ??
                                        [])
                                    .map((cat) {
                                      final bool isSelected =
                                          (item['category'] ?? '') == cat;
                                      return ChoiceChip(
                                        label: Text(cat),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected)
                                            cubit.updateProductItem(
                                              widget.index,
                                              pIndex,
                                              'category',
                                              cat,
                                            );
                                        },
                                      );
                                    })
                                    .toList(),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "وصف المنتج",
                            controller:
                                TextEditingController(
                                    text: item['description'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['description'] ?? '').length,
                                  ),
                            maxLines: 2,
                            onChanged: (val) => cubit.updateProductItem(
                              widget.index,
                              pIndex,
                              'description',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "رابط الصورة",
                            controller:
                                TextEditingController(
                                    text: item['image_url'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['image_url'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateProductItem(
                              widget.index,
                              pIndex,
                              'image_url',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
                              itemIndex: pIndex,
                              itemKey: 'image_url',
                            ),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (type == 'pricing') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "خطط الأسعار (Pricing Plans)",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => cubit.addPricingPlan(widget.index),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text("أضف خطة"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['items'] as List).length, (pIndex) {
                    final item =
                        (block['items'] as List)[pIndex]
                            as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgHover,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "الخطة #${pIndex + 1}",
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                  size: 20,
                                ),
                                onPressed: () => cubit.deletePricingPlan(
                                  widget.index,
                                  pIndex,
                                ),
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: "اسم الخطة",
                            controller:
                                TextEditingController(text: item['name'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['name'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updatePricingPlan(
                              widget.index,
                              pIndex,
                              'name',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "السعر",
                            controller:
                                TextEditingController(text: item['price'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['price'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updatePricingPlan(
                              widget.index,
                              pIndex,
                              'price',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: Text(
                              "خطة مميزة؟",
                              style: AppTypography.caption,
                            ),
                            value: item['is_popular'] ?? false,
                            onChanged: (val) => cubit.updatePricingPlan(
                              widget.index,
                              pIndex,
                              'is_popular',
                              val,
                            ),
                            activeThumbColor: AppColors.secondary,
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
                              itemIndex: pIndex,
                              itemKey: 'image_url',
                            ),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (type == 'faq') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الأسئلة الشائعة (FAQ Items)",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => cubit.addFaqItem(widget.index),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text("أضف سؤال"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['items'] as List).length, (fIndex) {
                    final item =
                        (block['items'] as List)[fIndex]
                            as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgHover,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "سؤال #${fIndex + 1}",
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    cubit.deleteFaqItem(widget.index, fIndex),
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: "السؤال",
                            controller:
                                TextEditingController(
                                    text: item['question'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['question'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateFaqItem(
                              widget.index,
                              fIndex,
                              'question',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "الإجابة",
                            maxLines: 3,
                            controller:
                                TextEditingController(
                                    text: item['answer'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['answer'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateFaqItem(
                              widget.index,
                              fIndex,
                              'answer',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
                              itemIndex: fIndex,
                              itemKey: 'image_url',
                            ),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (type == 'testimonials') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "آراء العملاء (Testimonials)",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => cubit.addTestimonialItem(widget.index),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text("أضف رأي"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['items'] as List).length, (tIndex) {
                    final item =
                        (block['items'] as List)[tIndex]
                            as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgHover,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "رأي #${tIndex + 1}",
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                  size: 20,
                                ),
                                onPressed: () => cubit.deleteTestimonialItem(
                                  widget.index,
                                  tIndex,
                                ),
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: "الاسم",
                            controller:
                                TextEditingController(
                                    text: item['author'] ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['author'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateTestimonialItem(
                              widget.index,
                              tIndex,
                              'author',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "المنصب/الوصف",
                            controller:
                                TextEditingController(text: item['role'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['role'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateTestimonialItem(
                              widget.index,
                              tIndex,
                              'role',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "الرأي",
                            maxLines: 3,
                            controller:
                                TextEditingController(text: item['quote'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['quote'] ?? '').length,
                                  ),
                            onChanged: (val) => cubit.updateTestimonialItem(
                              widget.index,
                              tIndex,
                              'quote',
                              val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
                              itemIndex: tIndex,
                              itemKey: 'image_url',
                            ),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (type == 'contact_info') ...[
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "البريد الإلكتروني",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['email'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['email'] ?? '').length,
                            ),
                      onChanged: (val) =>
                          cubit.updateBlockProperty(widget.index, 'email', val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "رقم الهاتف",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['phone'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['phone'] ?? '').length,
                            ),
                      onChanged: (val) =>
                          cubit.updateBlockProperty(widget.index, 'phone', val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "العنوان",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['location'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['location'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'location',
                        val,
                      ),
                    ),
                  ),
                ],

                if (type == 'social_qr') ...[
                  FormGroup(
                    label: "رابط صفحتك المباشر (Live Page URL)",
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(
                              text:
                                  "https://landymaker.com/${widget.state.subdomain}",
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: AppColors.secondary,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    "https://landymaker.com/${widget.state.subdomain}",
                              ),
                            );
                            ToastService.showSuccess(
                              context,
                              message: "تم نسخ الرابط بنجاح!",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "العنوان الفرعي (Subtitle)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['subtitle'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['subtitle'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'subtitle',
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "روابط التواصل",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final List links = List.from(block['links'] ?? []);
                          links.add({'platform': 'website', 'url': 'https://'});
                          cubit.updateBlockProperty(
                            widget.index,
                            'links',
                            links,
                          );
                        },
                        icon: const Icon(Icons.add_link_rounded, size: 16),
                        label: const Text("أضف رابط"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['links'] as List).length, (lIndex) {
                    final link =
                        (block['links'] as List)[lIndex]
                            as Map<String, dynamic>;
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
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: link['platform'] ?? 'website',
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'website',
                                        child: Text("موقع إلكتروني"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'instagram',
                                        child: Text("انستجرام"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'facebook',
                                        child: Text("فيسبوك"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'twitter',
                                        child: Text("تويتر (X)"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'linkedin',
                                        child: Text("لينكد إن"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'whatsapp',
                                        child: Text("واتساب"),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      final List links = List.from(
                                        block['links'],
                                      );
                                      final Map<String, dynamic> updatedLink =
                                          Map<String, dynamic>.from(
                                            links[lIndex],
                                          );
                                      updatedLink['platform'] = val;
                                      links[lIndex] = updatedLink;
                                      cubit.updateBlockProperty(
                                        widget.index,
                                        'links',
                                        links,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final List links = List.from(block['links']);
                                  links.removeAt(lIndex);
                                  cubit.updateBlockProperty(
                                    widget.index,
                                    'links',
                                    links,
                                  );
                                },
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: "الرابط (URL)",
                            controller:
                                TextEditingController(text: link['url'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (link['url'] ?? '').length,
                                  ),
                            onChanged: (val) {
                              final List links = List.from(block['links']);
                              final Map<String, dynamic> updatedLink =
                                  Map<String, dynamic>.from(links[lIndex]);
                              updatedLink['url'] = val;
                              links[lIndex] = updatedLink;
                              cubit.updateBlockProperty(
                                widget.index,
                                'links',
                                links,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور (Stock Images)",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
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

                if (type == 'qr_code') ...[
                  FormGroup(
                    label: "رابط صفحتك المباشر (Live Page URL)",
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(
                              text:
                                  "https://landymaker.com/${widget.state.subdomain}",
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: AppColors.secondary,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    "https://landymaker.com/${widget.state.subdomain}",
                              ),
                            );
                            ToastService.showSuccess(
                              context,
                              message: "تم نسخ الرابط بنجاح!",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormGroup(
                    label: "العنوان الفرعي (Subtitle)",
                    child: CustomTextField(
                      controller:
                          TextEditingController(text: block['subtitle'] ?? '')
                            ..selection = TextSelection.collapsed(
                              offset: (block['subtitle'] ?? '').length,
                            ),
                      onChanged: (val) => cubit.updateBlockProperty(
                        widget.index,
                        'subtitle',
                        val,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "حجم الكود: ${((block['qr_size'] ?? 200.0) as num).toStringAsFixed(0)}px",
                    style: AppTypography.caption,
                  ),
                  Slider(
                    value: ((block['qr_size'] ?? 200.0) as num).toDouble(),
                    min: 100.0,
                    max: 350.0,
                    divisions: 25,
                    activeColor: AppColors.secondary,
                    onChanged: (val) =>
                        cubit.updateBlockProperty(widget.index, 'qr_size', val),
                  ),
                ],

                if (type == 'basic_section') ...[
                  const SizedBox(height: 16),
                  Text(
                    "إعدادات التخطيط",
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    "اتجاه التخطيط",
                    'layout_direction',
                    ['column', 'row'],
                    (val) => cubit.updateBlockProperty(
                      widget.index,
                      'layout_direction',
                      val,
                    ),
                  ),
                  _buildDropdown(
                    "المحاذاة الرأسية",
                    'main_axis_alignment',
                    ['start', 'center', 'end', 'spaceBetween'],
                    (val) => cubit.updateBlockProperty(
                      widget.index,
                      'main_axis_alignment',
                      val,
                    ),
                  ),
                  _buildDropdown(
                    "المحاذاة الأفقية",
                    'cross_axis_alignment',
                    ['start', 'center', 'end', 'stretch'],
                    (val) => cubit.updateBlockProperty(
                      widget.index,
                      'cross_axis_alignment',
                      val,
                    ),
                  ),
                  _buildSlider(
                    "المسافة بين العناصر",
                    'spacing',
                    0,
                    100,
                    (val) =>
                        cubit.updateBlockProperty(widget.index, 'spacing', val),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "العناصر (Elements)",
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PopupMenuButton<String>(
                        color: AppColors.cardBg,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.secondary,
                        ),
                        onSelected: (val) {
                          final elements = List<Map<String, dynamic>>.from(
                            block['elements'] ?? [],
                          );
                          final newId =
                              'elem_${DateTime.now().millisecondsSinceEpoch}';
                          if (val == 'text') {
                            elements.add({
                              'id': newId,
                              'type': 'text',
                              'content': 'نص جديد',
                              'style_overrides': {},
                            });
                          } else if (val == 'image') {
                            elements.add({
                              'id': newId,
                              'type': 'image',
                              'url': '',
                              'width': 200,
                              'height': 200,
                              'fit': 'cover',
                            });
                          }
                          cubit.updateBlockProperty(
                            widget.index,
                            'elements',
                            elements,
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'text',
                            child: Text("إضافة نص"),
                          ),
                          const PopupMenuItem(
                            value: 'image',
                            child: Text("إضافة صورة"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate((block['elements'] ?? []).length, (i) {
                    final elem =
                        (block['elements'] ?? [])[i] as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusPill(
                                label: elem['type'] == 'text' ? 'نص' : 'صورة',
                                color: AppColors.secondary,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                  size: 18,
                                ),
                                onPressed: () {
                                  final elements =
                                      List<Map<String, dynamic>>.from(
                                        block['elements'] ?? [],
                                      );
                                  elements.removeAt(i);
                                  cubit.updateBlockProperty(
                                    widget.index,
                                    'elements',
                                    elements,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (elem['type'] == 'text')
                            CustomTextField(
                              controller:
                                  TextEditingController(text: elem['content'])
                                    ..selection = TextSelection.collapsed(
                                      offset: (elem['content'] ?? '').length,
                                    ),
                              maxLines: 3,
                              onChanged: (val) {
                                final elements =
                                    List<Map<String, dynamic>>.from(
                                      block['elements'] ?? [],
                                    );
                                elements[i]['content'] = val;
                                cubit.updateBlockProperty(
                                  widget.index,
                                  'elements',
                                  elements,
                                );
                              },
                            )
                          else if (elem['type'] == 'image') ...[
                            CustomTextField(
                              hintText: "رابط الصورة...",
                              controller:
                                  TextEditingController(text: elem['url'])
                                    ..selection = TextSelection.collapsed(
                                      offset: (elem['url'] ?? '').length,
                                    ),
                              onChanged: (val) {
                                final elements =
                                    List<Map<String, dynamic>>.from(
                                      block['elements'] ?? [],
                                    );
                                elements[i]['url'] = val;
                                cubit.updateBlockProperty(
                                  widget.index,
                                  'elements',
                                  elements,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: "العرض",
                                    controller: TextEditingController(
                                      text: elem['width'].toString(),
                                    ),
                                    onChanged: (val) {
                                      final elements =
                                          List<Map<String, dynamic>>.from(
                                            block['elements'] ?? [],
                                          );
                                      elements[i]['width'] =
                                          double.tryParse(val) ?? 200;
                                      cubit.updateBlockProperty(
                                        widget.index,
                                        'elements',
                                        elements,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    hintText: "الطول",
                                    controller: TextEditingController(
                                      text: elem['height'].toString(),
                                    ),
                                    onChanged: (val) {
                                      final elements =
                                          List<Map<String, dynamic>>.from(
                                            block['elements'] ?? [],
                                          );
                                      elements[i]['height'] =
                                          double.tryParse(val) ?? 200;
                                      cubit.updateBlockProperty(
                                        widget.index,
                                        'elements',
                                        elements,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],

                if (type == 'gallery') ...[
                  const SizedBox(height: 16),
                  Text(
                    "شكل العرض",
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDisplayModeOption(
                        cubit,
                        isSelected:
                            (block['display_mode'] ?? 'grid') == 'grid' &&
                            (block['grid_columns'] ?? 3) == 2,
                        icon: Icons.grid_view_rounded,
                        label: "شبكة (٢)",
                        onTap: () {
                          cubit.updateBlockProperty(
                            widget.index,
                            'display_mode',
                            'grid',
                          );
                          cubit.updateBlockProperty(
                            widget.index,
                            'grid_columns',
                            2,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildDisplayModeOption(
                        cubit,
                        isSelected:
                            (block['display_mode'] ?? 'grid') == 'grid' &&
                            (block['grid_columns'] ?? 3) == 3,
                        icon: Icons.grid_on_rounded,
                        label: "شبكة (٣)",
                        onTap: () {
                          cubit.updateBlockProperty(
                            widget.index,
                            'display_mode',
                            'grid',
                          );
                          cubit.updateBlockProperty(
                            widget.index,
                            'grid_columns',
                            3,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildDisplayModeOption(
                        cubit,
                        isSelected:
                            (block['display_mode'] ?? 'grid') == 'carousel',
                        icon: Icons.view_carousel_rounded,
                        label: "متحرك",
                        onTap: () {
                          cubit.updateBlockProperty(
                            widget.index,
                            'display_mode',
                            'carousel',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "صور المعرض",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => cubit.addGalleryImage(widget.index),
                        icon: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 16,
                        ),
                        label: const Text("أضف صورة"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (block['items'] as List).length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, gIndex) {
                      final String imageUrl = (block['items'] as List)[gIndex];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBgHover,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.5,
                                ),
                                radius: 14,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    size: 14,
                                    color: AppColors.dangerRed,
                                  ),
                                  onPressed: () => cubit.deleteGalleryImage(
                                    widget.index,
                                    gIndex,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                if (type == 'trust_logos') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الشعارات (Logos)",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final List items = List.from(block['items'] ?? []);
                          items.add(
                            'https://upload.wikimedia.org/wikipedia/commons/2/2f/Google_2015_logo.svg',
                          );
                          cubit.updateBlockProperty(
                            widget.index,
                            'items',
                            items,
                          );
                        },
                        icon: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 16,
                        ),
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
                                  controller: TextEditingController(text: url)
                                    ..selection = TextSelection.collapsed(
                                      offset: url.length,
                                    ),
                                  onChanged: (val) {
                                    final List items = List.from(
                                      block['items'] ?? [],
                                    );
                                    items[tIndex] = val;
                                    cubit.updateBlockProperty(
                                      widget.index,
                                      'items',
                                      items,
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                ),
                                onPressed: () {
                                  final List items = List.from(
                                    block['items'] ?? [],
                                  );
                                  items.removeAt(tIndex);
                                  cubit.updateBlockProperty(
                                    widget.index,
                                    'items',
                                    items,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: "ابحث في الصور",
                            icon: Icons.search_rounded,
                            isSecondary: true,
                            onPressed: () => _pickStockImage(
                              cubit,
                              widget.index,
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

                if (type == 'animated_counter') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "العدادات (Counters)",
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          final List items = List.from(block['items'] ?? []);
                          items.add({
                            'value': '100',
                            'label': 'تسمية جديدة',
                            'prefix': '',
                            'suffix': '',
                          });
                          cubit.updateBlockProperty(
                            widget.index,
                            'items',
                            items,
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text("أضف عداد"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List.generate((block['items'] as List).length, (tIndex) {
                    final Map<String, dynamic> item =
                        (block['items'] as List)[tIndex];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "عداد #${tIndex + 1}",
                                style: AppTypography.caption,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.dangerRed,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final List items = List.from(
                                    block['items'] ?? [],
                                  );
                                  items.removeAt(tIndex);
                                  cubit.updateBlockProperty(
                                    widget.index,
                                    'items',
                                    items,
                                  );
                                },
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: "القيمة (الرقم)",
                            controller:
                                TextEditingController(
                                    text: item['value']?.toString() ?? '',
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['value']?.toString() ?? '')
                                        .length,
                                  ),
                            onChanged: (val) {
                              final List items = List.from(
                                block['items'] ?? [],
                              );
                              final updatedItem = Map<String, dynamic>.from(
                                items[tIndex],
                              );
                              updatedItem['value'] = val;
                              items[tIndex] = updatedItem;
                              cubit.updateBlockProperty(
                                widget.index,
                                'items',
                                items,
                              );
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: "التسمية (مثال: عميل سعيد)",
                            controller:
                                TextEditingController(text: item['label'] ?? '')
                                  ..selection = TextSelection.collapsed(
                                    offset: (item['label'] ?? '').length,
                                  ),
                            onChanged: (val) {
                              final List items = List.from(
                                block['items'] ?? [],
                              );
                              final updatedItem = Map<String, dynamic>.from(
                                items[tIndex],
                              );
                              updatedItem['label'] = val;
                              items[tIndex] = updatedItem;
                              cubit.updateBlockProperty(
                                widget.index,
                                'items',
                                items,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  hintText: "بادئة (Prefix)",
                                  controller:
                                      TextEditingController(
                                          text: item['prefix'] ?? '',
                                        )
                                        ..selection = TextSelection.collapsed(
                                          offset: (item['prefix'] ?? '').length,
                                        ),
                                  onChanged: (val) {
                                    final List items = List.from(
                                      block['items'] ?? [],
                                    );
                                    final updatedItem =
                                        Map<String, dynamic>.from(
                                          items[tIndex],
                                        );
                                    updatedItem['prefix'] = val;
                                    items[tIndex] = updatedItem;
                                    cubit.updateBlockProperty(
                                      widget.index,
                                      'items',
                                      items,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  hintText: "خاتمة (Suffix)",
                                  controller:
                                      TextEditingController(
                                          text: item['suffix'] ?? '',
                                        )
                                        ..selection = TextSelection.collapsed(
                                          offset: (item['suffix'] ?? '').length,
                                        ),
                                  onChanged: (val) {
                                    final List items = List.from(
                                      block['items'] ?? [],
                                    );
                                    final updatedItem =
                                        Map<String, dynamic>.from(
                                          items[tIndex],
                                        );
                                    updatedItem['suffix'] = val;
                                    items[tIndex] = updatedItem;
                                    cubit.updateBlockProperty(
                                      widget.index,
                                      'items',
                                      items,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text(
                "التصميم والخلفية (Design)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              initiallyExpanded: false,
              childrenPadding: EdgeInsets.zero,
              tilePadding: EdgeInsets.zero,
              children: [
                FormGroup(
                  label: "خط القسم (Font Family)",
                  helperText: "اتركه فارغاً لاستخدام خط الصفحة العام.",
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
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
                          cubit.updateBlockProperty(
                            widget.index,
                            'fontFamily',
                            val,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FormGroup(
                  label: "رابط صورة الخلفية (Background Image URL)",
                  child: CustomTextField(
                    controller:
                        TextEditingController(text: block['bg_image_url'] ?? '')
                          ..selection = TextSelection.collapsed(
                            offset: (block['bg_image_url'] ?? '').length,
                          ),
                    onChanged: (val) => cubit.updateBlockProperty(
                      widget.index,
                      'bg_image_url',
                      val,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: "ارفع صورة الخلفية (Upload Background)",
                  icon: Icons.upload_file_rounded,
                  isSecondary: true,
                  onPressed: () =>
                      _pickAndUploadBackgroundImage(cubit, widget.index),
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
                        controller:
                            TextEditingController(
                                text: block['bg_overlay_color'] ?? '',
                              )
                              ..selection = TextSelection.collapsed(
                                offset:
                                    (block['bg_overlay_color'] ?? '').length,
                              ),
                        onChanged: (val) => cubit.updateBlockProperty(
                          widget.index,
                          'bg_overlay_color',
                          val,
                        ),
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
                  value: ((block['bg_overlay_opacity'] ?? 0.4) as num)
                      .toDouble(),
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  activeColor: AppColors.secondary,
                  onChanged: (val) => cubit.updateBlockProperty(
                    widget.index,
                    'bg_overlay_opacity',
                    val,
                  ),
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
                  onChanged: (val) =>
                      cubit.updateBlockProperty(widget.index, 'bg_blur', val),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
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
