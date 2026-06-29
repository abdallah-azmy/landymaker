import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';

class TemplatesTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;

  final BuilderLoaded state;

  const TemplatesTab({super.key, required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, dynamicState) {
          if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("اختر قالب جاهز", style: AppTypography.h3),
              const SizedBox(height: 8),
              Text(
                "سيقوم اختيار قالب باستبدال المحتوى الحالي.",
                style: AppTypography.caption,
              ),
              const SizedBox(height: 24),
              _buildTemplateCard(
                context,
                dynamicState,
                'store',
                "متجر إلكتروني",
                Icons.shopping_cart_rounded,
                "مناسب لبيع المنتجات والسلع.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'personal',
                "موقع شخصي",
                Icons.person_rounded,
                "معرض أعمال وسيرة ذاتية.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'professional',
                "خدمات مهنية",
                Icons.business_center_rounded,
                "للاستشارات والشركات الناشئة.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'restaurant',
                "مطعم / كافيه",
                Icons.restaurant_rounded,
                "منيو إلكتروني وأجواء ترفيهية.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'real_estate',
                "عقارات / Real Estate",
                Icons.home_work_rounded,
                "تسويق شقق وفلل ومجمعات سكنية.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'event',
                "فعالية ومؤتمر / Event",
                Icons.event_rounded,
                "حجز تذاكر، تفاصيل الفعالية، وخرائط الوصول.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'digital_course',
                "دورة تعليمية / Course",
                Icons.school_rounded,
                "تسويق كورسات، دروس، ومناهج تعليمية مع التسجيل.",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    BuilderLoaded currentState,
    String type,
    String label,
    IconData icon,
    String desc,
  ) {
    final loc = context.read<LocalizationCubit>();
    final isSelected = currentState.websiteType == type;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        ),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(desc, style: AppTypography.caption),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.secondary)
            : null,
        onTap: () => _showTemplateConfirmation(context, type, loc),
      ),
    );
  }

  void _showTemplateConfirmation(
    BuildContext context,
    String type,
    LocalizationCubit loc,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(loc.translate('confirm_template')),
        content: Text(loc.translate('confirm_template_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
          PrimaryButton(
            text: loc.translate('apply'),
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
