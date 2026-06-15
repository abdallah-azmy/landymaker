import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/features/builder/controllers/builder_cubit.dart';
import 'package:landymaker/features/builder/controllers/builder_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/form_group.dart';

class AdvancedSettingsPanel extends StatefulWidget {
  const AdvancedSettingsPanel({super.key});

  @override
  State<AdvancedSettingsPanel> createState() => _AdvancedSettingsPanelState();
}

class _AdvancedSettingsPanelState extends State<AdvancedSettingsPanel> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _keywordsController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LandingPageBuilderCubit>();
    final state = cubit.state;
    final design = state is BuilderLoaded ? state.designMap : <String, dynamic>{};
    _titleController = TextEditingController(text: (design['meta_title'] ?? '') as String);
    _descController = TextEditingController(text: (design['meta_description'] ?? '') as String);
    _keywordsController = TextEditingController(text: (design['keywords'] ?? '') as String);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LandingPageBuilderCubit>();
    final state = cubit.state;

    if (state is! BuilderLoaded) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.secondary),
              const SizedBox(width: 12),
              Text("الإعدادات المتقدمة (SEO)", style: AppTypography.h3),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBox(
            "ما هي إعدادات SEO؟",
            "هذه الإعدادات تساعد موقعك على الظهور في نتائج بحث جوجل. هي المعلومات التي يراها الشخص عندما يبحث عن مجالك ويظهر موقعك أمامه.",
          ),
          const SizedBox(height: 24),
          FormGroup(
            label: "عنوان الصفحة في البحث (SEO Title)",
            helperText:
                "اجعله قصيراً وجذاباً (مثال: صالون الحلاقة الأفضل في القاهرة)",
            child: CustomTextField(
              controller: _titleController,
              onChanged: (val) => cubit.updateMetadata('meta_title', val),
              hintText: "أدخل عنواناً جذاباً لجوجل",
            ),
          ),
          const SizedBox(height: 20),
          FormGroup(
            label: "وصف الصفحة (SEO Description)",
            helperText:
                "اشرح باختصار ما تقدمه لكي يتشجع الناس على الضغط على رابطك.",
            child: CustomTextField(
              controller: _descController,
              onChanged: (val) => cubit.updateMetadata('meta_description', val),
              hintText: "اكتب وصفاً مختصراً لخدماتك...",
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 20),
          FormGroup(
            label: "الكلمات المفتاحية (Keywords)",
            helperText: "كلمات مفتاحية يفصل بينها فواصل.",
            child: CustomTextField(
              controller: _keywordsController,
              onChanged: (val) => cubit.updateMetadata('keywords', val),
              hintText: "متجر, إلكترونيات, عروض",
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
