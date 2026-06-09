import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../controllers/ai_generation_cubit.dart';

class AiMagicFormModal extends StatefulWidget {
  const AiMagicFormModal({super.key});

  @override
  State<AiMagicFormModal> createState() => _AiMagicFormModalState();
}

class _AiMagicFormModalState extends State<AiMagicFormModal> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _offerController = TextEditingController();
  String _language = 'Arabic';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AIGenerationCubit, AIGenerationState>(
      listener: (context, state) {
        if (state is AIGenerationSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الصفحة بنجاح باستخدام الذكاء الاصطناعي!')),
          );
        }
        if (state is AIGenerationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AIGenerationLoading;

        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text("المنشئ الذكي (AI)", style: AppTypography.h2),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "أخبرنا قليلاً عن عملك وسيقوم الذكاء الاصطناعي ببناء صفحة هبوط كاملة لك في ثوانٍ.",
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: "اسم النشاط التجاري",
                  hint: "مثلاً: عيادة النور لطب الأسنان",
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "نوع النشاط",
                  hint: "مثلاً: عيادة طبية، مطعم، شركة شحن",
                  controller: _typeController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "الموقع (اختياري)",
                  hint: "مثلاً: الرياض، السعودية",
                  controller: _locationController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "العرض أو الهدف الأساسي",
                  hint: "مثلاً: احصل على استشارة مجانية أو خصم 20%",
                  controller: _offerController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: isLoading ? "جاري الإنشاء..." : "إنشاء الصفحة الآن",
                  icon: isLoading ? null : Icons.auto_awesome_rounded,
                  onPressed: isLoading ? null : _handleGenerate,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleGenerate() {
    if (_nameController.text.isEmpty || _typeController.text.isEmpty || _offerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول الأساسية')),
      );
      return;
    }

    context.read<AIGenerationCubit>().generatePage(
      businessName: _nameController.text,
      businessType: _typeController.text,
      location: _locationController.text,
      language: _language,
      offer: _offerController.text,
    );
  }
}
