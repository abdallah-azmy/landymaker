import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/status_pill.dart';
import '../models/landing_page_theme.dart';
import '../controllers/builder_cubit.dart';
import '../controllers/builder_state.dart';

class TemplatesTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;

  const TemplatesTab({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("اختر قالب جاهز", style: AppTypography.h3),
          const SizedBox(height: 8),
          Text("سيقوم اختيار قالب باستبدال المحتوى الحالي.", style: AppTypography.caption),
          const SizedBox(height: 24),
          _buildTemplateCard(context, 'store', "متجر إلكتروني", Icons.shopping_cart_rounded, "مناسب لبيع المنتجات والسلع."),
          _buildTemplateCard(context, 'personal', "موقع شخصي", Icons.person_rounded, "معرض أعمال وسيرة ذاتية."),
          _buildTemplateCard(context, 'professional', "خدمات مهنية", Icons.business_center_rounded, "للاستشارات والشركات الناشئة."),
          _buildTemplateCard(context, 'tv_bar', "مطعم / كافيه", Icons.restaurant_rounded, "منيو إلكتروني وأجواء ترفيهية."),
          _buildTemplateCard(context, 'real_estate', "عقارات / Real Estate", Icons.home_work_rounded, "تسويق شقق وفلل ومجمعات سكنية."),
          _buildTemplateCard(context, 'event', "فعالية ومؤتمر / Event", Icons.event_rounded, "حجز تذاكر، تفاصيل الفعالية، وخرائط الوصول."),
          _buildTemplateCard(context, 'digital_course', "دورة تعليمية / Course", Icons.school_rounded, "تسويق كورسات، دروس، ومناهج تعليمية مع التسجيل."),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, String type, String label, IconData icon, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.secondary),
        ),
        title: Text(label, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: AppTypography.caption),
        onTap: () => _showTemplateConfirmation(context, type),
      ),
    );
  }

  void _showTemplateConfirmation(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text("تأكيد تغيير القالب"),
        content: const Text("هل أنت متأكد؟ سيتم حذف جميع الأقسام الحالية واستبدالها بالقالب الجديد."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          PrimaryButton(
            text: "تطبيق",
            width: 100,
            onPressed: () {
              cubit.applyTemplate(type);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class DesignTab extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const DesignTab({super.key, required this.loc, required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("لوحات الألوان", style: AppTypography.h3),
          const SizedBox(height: 16),
          ...LandingPageTheme.palettes.map((palette) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.theme.name == palette.name ? AppColors.secondary : AppColors.border,
                width: state.theme.name == palette.name ? 2 : 1,
              ),
            ),
            child: ListTile(
              onTap: () => cubit.updateTheme(palette),
              title: Text(palette.name, style: AppTypography.bodyMedium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorBox(palette.primary),
                  _colorBox(palette.secondary),
                  _colorBox(palette.background),
                  if (state.theme.name == palette.name)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
                    ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),
          Text("تخصيص الألوان", style: AppTypography.h3),
          const SizedBox(height: 16),
          _buildColorPickerItem(context, cubit, "اللون الأساسي", "primary", state.theme.primary),
          _buildColorPickerItem(context, cubit, "اللون الثانوي", "secondary", state.theme.secondary),
          _buildColorPickerItem(context, cubit, "لون الخلفية", "background", state.theme.background),
          _buildColorPickerItem(context, cubit, "لون النص الرئيسي", "textPrimary", state.theme.textPrimary),
        ],
      ),
    );
  }

  Widget _colorBox(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
    );
  }

  Widget _buildColorPickerItem(BuildContext context, LandingPageBuilderCubit cubit, String label, String key, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showColorPicker(context, cubit, key, color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, LandingPageBuilderCubit cubit, String key, Color currentColor) {
    final List<Color> colors = [
      AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.activeGreen, AppColors.dangerRed,
      Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.teal, Colors.brown,
      Colors.black, Colors.white, const Color(0xFF1E293B), const Color(0xFFF8FAFC),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text("اختر لون"),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              cubit.updateThemeProperty(key, color);
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: color == currentColor ? 2 : 0),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}

class ContentTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final List<Map<String, dynamic>> blocks;
  final Function(int) onEditBlock;
  final Function(BuildContext, LandingPageBuilderCubit) onAddBlock;

  const ContentTab({
    super.key,
    required this.cubit,
    required this.blocks,
    required this.onEditBlock,
    required this.onAddBlock,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("إضافة قسم جديد", style: AppTypography.h3),
              TextButton.icon(
                onPressed: () => onAddBlock(context, cubit),
                icon: const Icon(Icons.grid_view_rounded, size: 16),
                label: const Text("كل الأقسام"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildQuickAddButton(cubit, 'hero', "+ هيرو"),
              _buildQuickAddButton(cubit, 'features', "+ مميزات"),
              _buildQuickAddButton(cubit, 'whatsapp', "+ واتساب"),
              _buildQuickAddButton(cubit, 'products', "+ منتجات"),
              _buildQuickAddButton(cubit, 'qr_code', "+ QR"),
              _buildQuickAddButton(cubit, 'social_qr', "+ روابط"),
              _buildQuickAddButton(cubit, 'pricing', "+ الأسعار"),
              _buildQuickAddButton(cubit, 'faq', "+ أسئلة"),
              _buildQuickAddButton(cubit, 'testimonials', "+ آراء"),
              _buildQuickAddButton(cubit, 'contact_info', "+ تواصل"),
              _buildQuickAddButton(cubit, 'gallery', "+ صور"),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 32),
          Text("الأقسام المضافة", style: AppTypography.h3),
          const SizedBox(height: 16),
          if (blocks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("لا توجد أقسام بعد.")),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blocks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final block = blocks[index];
                final String type = block['type'] ?? '';
                final String title = block['title'] ?? 'Section';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusPill(
                              label: type.toUpperCase(),
                              color: _getSectionColor(type),
                            ),
                            const SizedBox(height: 8),
                            Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.arrow_upward_rounded, size: 18), onPressed: index > 0 ? () => cubit.moveBlock(index, true) : null),
                      IconButton(icon: const Icon(Icons.arrow_downward_rounded, size: 18), onPressed: index < blocks.length - 1 ? () => cubit.moveBlock(index, false) : null),
                      IconButton(icon: const Icon(Icons.edit_rounded, color: AppColors.secondary, size: 18), onPressed: () => onEditBlock(index)),
                      IconButton(icon: const Icon(Icons.delete_rounded, color: AppColors.dangerRed, size: 18), onPressed: () => cubit.deleteBlock(index)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(LandingPageBuilderCubit cubit, String type, String label) {
    return Container(
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardBg,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
        ),
        onPressed: () => cubit.addBlock(type),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getSectionColor(String type) {
    switch (type) {
      case 'hero': return AppColors.secondary;
      case 'features': return AppColors.primary;
      case 'products': return AppColors.activeGreen;
      case 'pricing': return AppColors.warningOrange;
      default: return AppColors.accent;
    }
  }
}
