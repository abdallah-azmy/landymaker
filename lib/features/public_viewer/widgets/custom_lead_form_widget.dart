import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/pixel_event_service.dart';
import '../../../core/services/turnstile_service.dart';
import '../../../core/utils/fingerprint_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import '../../dashboard/controllers/leads_analytics_state.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/forms/validation_engine.dart';
import '../../../core/forms/elements/field_renderer.dart';

import '../../../core/services/action_handler_service.dart';

class CustomLeadFormWidget extends StatefulWidget {
  final Map<String, dynamic> block;
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
    required this.block,
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
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _validationErrors = {};
  final Map<String, dynamic> _dataPayload = {};
  final TextEditingController _honeypotController = TextEditingController();
  late final String _turnstileViewId;
  String? _turnstileToken;
  
  bool _isSubmitting = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _turnstileViewId = 'turnstile-lead-form-\${widget.block.hashCode}';
    TurnstileService.registerViewFactory(_turnstileViewId, (token) {
      setState(() {
        _turnstileToken = token;
        if (_errorMessage == context.translate('captcha_required')) {
          _errorMessage = null;
        }
      });
    });
  }

  List<dynamic> get _fields {
    final blockFields = widget.block['fields'];
    if (blockFields != null && blockFields is List && blockFields.isNotEmpty) {
      return blockFields;
    }
    // Fallback schema
    return [
      {
        'field_id': 'name',
        'field_type': 'text',
        'label': context.translate('full_name'),
        'placeholder': context.translate('name_hint'),
        'is_required': true,
      },
      {
        'field_id': 'email',
        'field_type': 'email',
        'label': context.translate('email'),
        'placeholder': context.translate('email_hint'),
        'is_required': true,
      },
      {
        'field_id': 'message',
        'field_type': 'textarea',
        'label': context.translate('message_label'),
        'placeholder': context.translate('message_hint'),
        'is_required': true,
      }
    ];
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _honeypotController.dispose();
    super.dispose();
  }

  void _onFieldValueChanged(String fieldId, String value) {
    setState(() {
      _dataPayload[fieldId] = value;
      if (_validationErrors.containsKey(fieldId)) {
        _validationErrors.remove(fieldId);
      }
    });
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_honeypotController.text.isNotEmpty) {
      // Silently discard spam and mimic successful response to bot
      setState(() {
        _successMessage = context.translate('form_spam_success');
        _errorMessage = null;
      });
      _clearForm();
      return;
    }

    final fields = _fields;
    final errors = ValidationEngine.validate(fields, _dataPayload);

    if (errors.isNotEmpty) {
      setState(() {
        _validationErrors.clear();
        _validationErrors.addAll(errors);
        _errorMessage = null;
      });
      return;
    }

    if (_turnstileToken == null) {
      setState(() {
        _errorMessage = context.translate('captcha_required');
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _successMessage = null;
      _errorMessage = null;
    });

    try {
      final fingerprint = FingerprintUtils.getFingerprint();
      final payload = Map<String, dynamic>.from(_dataPayload);
      payload['__metadata'] = {
        'fingerprint': fingerprint,
        'turnstile_token': _turnstileToken,
      };

      final cubit = context.read<LeadsAnalyticsCubit>();
      await cubit.submitLead(widget.pageId, payload);
      
      if (mounted) {
        final state = cubit.state;
        if (state is LeadsAnalyticsLoaded && state.leadErrorMessage != null) {
          setState(() {
            _errorMessage = state.leadErrorMessage;
            _successMessage = null;
          });
        } else {
          setState(() {
            _successMessage = state is LeadsAnalyticsLoaded 
                ? (state.leadSuccessMessage ?? context.translate('lead_success'))
                : context.translate('lead_success');
            _errorMessage = null;
          });
          _clearForm();
          TurnstileService.reset(_turnstileViewId);
          setState(() => _turnstileToken = null);
          PixelEventService.trackLead();

          // MISSION: Smart WhatsApp Leads
          if (widget.block['whatsapp_auto_open'] == true) {
            final String whatsappNumber = widget.block['whatsapp_number']?.toString() ?? '';
            String template = widget.block['whatsapp_message_template']?.toString() ?? 'New Lead Submission';
            
            // Replace placeholders {{field_id}}
            _dataPayload.forEach((key, value) {
              template = template.replaceAll('{{$key}}', value.toString());
            });

            await ActionHandlerService.openWhatsApp(
              phoneNumber: whatsappNumber,
              message: template,
              pageId: widget.pageId,
              blockType: 'lead_form',
            );
          }
        }
      }
    } catch (e) {
      // Fallback for preview mode or complete failure
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _successMessage = context.translate('lead_preview_success');
          _errorMessage = null;
        });
        _clearForm();
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    setState(() {
      _dataPayload.clear();
      _validationErrors.clear();
    });
    for (var controller in _controllers.values) {
      controller.clear();
    }
    _honeypotController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: EdgeInsetsDirectional.all(isMobile ? 24 : 40),
              decoration: BoxDecoration(
                color: subTextColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                border: Border.all(
                  color: subTextColor.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Honeypot field (hidden from real users, filled by bots)
                  Offstage(
                    child: TextField(
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

                  if (_successMessage != null) ...[
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
                              _successMessage!,
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

                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.dangerRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.dangerRed,
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

                  ..._fields.map((field) {
                    if (field is! Map) return const SizedBox.shrink();
                    final fieldId = field['field_id'] as String?;
                    if (fieldId == null) return const SizedBox.shrink();
                    
                    if (!_controllers.containsKey(fieldId)) {
                      _controllers[fieldId] = TextEditingController();
                    }

                    return Theme(
                      data: Theme.of(context).copyWith(
                        textTheme: Theme.of(context).textTheme.copyWith(
                          titleSmall: TextStyle(color: textColor, fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      child: FieldRenderer.render(
                        schema: field.cast<String, dynamic>(),
                        controller: _controllers[fieldId]!,
                        currentValue: _dataPayload[fieldId]?.toString(),
                        errorMessage: _validationErrors[fieldId],
                        onChanged: (val) => _onFieldValueChanged(fieldId, val),
                      ),
                    );
                  }),

                  SizedBox(height: isMobile ? 8 : 16),

                  // Turnstile Widget
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 70,
                      child: HtmlElementView(viewType: _turnstileViewId),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 48 : 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: secondaryColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isSubmitting
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
            ),
          ),
        );
      },
    );
  }
}
