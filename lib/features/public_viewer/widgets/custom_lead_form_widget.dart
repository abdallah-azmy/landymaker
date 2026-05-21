import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import '../../dashboard/controllers/leads_analytics_state.dart';

class CustomLeadFormWidget extends StatefulWidget {
  final String title;
  final String buttonText;
  final String pageId;

  const CustomLeadFormWidget({
    super.key,
    required this.title,
    required this.buttonText,
    required this.pageId,
  });

  @override
  State<CustomLeadFormWidget> createState() => _CustomLeadFormWidgetState();
}

class _CustomLeadFormWidgetState extends State<CustomLeadFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<LeadsAnalyticsCubit>();
    cubit.submitLead(widget.pageId, {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'message': _messageController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.2),
        border: Border(
          top: BorderSide(color: AppColors.textSecondary.withOpacity(0.05)),
          bottom: BorderSide(color: AppColors.textSecondary.withOpacity(0.05)),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.textSecondary.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: BlocConsumer<LeadsAnalyticsCubit, LeadsAnalyticsState>(
            listener: (context, state) {
              if (state is LeadsAnalyticsLoaded) {
                if (state.leadSuccessMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.leadSuccessMessage!),
                      backgroundColor: AppColors.activeGreen,
                    ),
                  );
                  _nameController.clear();
                  _emailController.clear();
                  _messageController.clear();
                } else if (state.leadErrorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.leadErrorMessage!),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              final bool isSubmitting = state is LeadsAnalyticsLoaded && state.isSubmittingLead;
              final String? successMsg = state is LeadsAnalyticsLoaded ? state.leadSuccessMessage : null;

              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.h2.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRtl 
                          ? "املأ النموذج أدناه وسنتواصل معك في أقرب وقت ممكن."
                          : "Fill out the form below and we will get back to you shortly.",
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),

                    if (successMsg != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.activeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.activeGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.activeGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                successMsg,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.activeGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    FormGroup(
                      label: isRtl ? "الاسم الكامل" : "Full Name",
                      child: CustomTextField(
                        controller: _nameController,
                        hintText: isRtl ? "أدخل اسمك هنا" : "Enter your full name",
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isRtl ? "هذا الحقل مطلوب" : "Name is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    FormGroup(
                      label: isRtl ? "البريد الإلكتروني" : "Email Address",
                      child: CustomTextField(
                        controller: _emailController,
                        hintText: isRtl ? "name@example.com" : "you@example.com",
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isRtl ? "هذا الحقل مطلوب" : "Email is required";
                          }
                          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(val.trim())) {
                            return isRtl ? "البريد الإلكتروني غير صالح" : "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    FormGroup(
                      label: isRtl ? "الرسالة" : "Your Message",
                      child: CustomTextField(
                        controller: _messageController,
                        hintText: isRtl ? "كيف يمكننا مساعدتك؟" : "How can we help you?",
                        maxLines: 4,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isRtl ? "هذا الحقل مطلوب" : "Message is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () => _submitForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                widget.buttonText,
                                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
