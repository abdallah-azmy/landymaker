import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/atoms/custom_text_field.dart';
import '../../../core/widgets/molecules/form_group.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import '../../dashboard/controllers/leads_analytics_state.dart';
import '../../../core/localization/app_localizations.dart';

class CustomLeadFormWidget extends StatefulWidget {
  final String title;
  final String buttonText;
  final String pageId;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomLeadFormWidget({
    super.key,
    required this.title,
    required this.buttonText,
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  State<CustomLeadFormWidget> createState() => _CustomLeadFormWidgetState();
}

class _CustomLeadFormWidgetState extends State<CustomLeadFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _honeypotController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _honeypotController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_honeypotController.text.isNotEmpty) {
      // Silently discard spam and mimic successful response to bot
      ToastService.showSuccess(
        context,
        message: context.translate('form_spam_success'),
      );
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      _honeypotController.clear();
      return;
    }

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
    final secondaryColor = widget.theme?.secondary ?? AppColors.secondary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(isMobile ? 24 : 40),
              decoration: BoxDecoration(
                color: subTextColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                border: Border.all(
                  color: subTextColor.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: BlocConsumer<LeadsAnalyticsCubit, LeadsAnalyticsState>(
                listener: (context, state) {
                  if (state is LeadsAnalyticsLoaded) {
                    if (state.leadSuccessMessage != null) {
                      ToastService.showSuccess(context, message: state.leadSuccessMessage!);
                      _nameController.clear();
                      _emailController.clear();
                      _messageController.clear();
                    } else if (state.leadErrorMessage != null) {
                      ToastService.showError(context, message: state.leadErrorMessage!);
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
                        // Honeypot field (hidden from real users, filled by bots)
                        Offstage(
                          child: TextFormField(
                            controller: _honeypotController,
                            decoration: const InputDecoration(labelText: 'Leave this field empty'),
                          ),
                        ),
                        Text(
                          widget.title,
                          style: AppTypography.h2.copyWith(
                            fontSize: isMobile ? 22 : 26, 
                            fontWeight: FontWeight.bold, 
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.translate('form_subtitle'),
                          style: AppTypography.bodyMedium.copyWith(color: subTextColor, fontSize: isMobile ? 12 : 14),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),

                        if (successMsg != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.activeGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.activeGreen.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.activeGreen, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    successMsg,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.activeGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        FormGroup(
                          label: context.translate('full_name'),
                          labelStyle: TextStyle(color: textColor, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold),
                          child: CustomTextField(
                            controller: _nameController,
                            hintText: context.translate('name_hint'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return context.translate('required_field');
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        FormGroup(
                          label: context.translate('email'),
                          labelStyle: TextStyle(color: textColor, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold),
                          child: CustomTextField(
                            controller: _emailController,
                            hintText: context.translate('email_hint'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return context.translate('required_field');
                              }
                              final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegExp.hasMatch(val.trim())) {
                                return context.translate('invalid_email');
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        FormGroup(
                          label: context.translate('message_label'),
                          labelStyle: TextStyle(color: textColor, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold),
                          child: CustomTextField(
                            controller: _messageController,
                            hintText: context.translate('message_hint'),
                            maxLines: isMobile ? 3 : 4,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return context.translate('required_field');
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),

                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 48 : 54,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : () => _submitForm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: secondaryColor.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Text(
                                    widget.buttonText,
                                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
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
      },
    );
  }
}
