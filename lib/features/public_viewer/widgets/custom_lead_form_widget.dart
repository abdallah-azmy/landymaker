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

/// ======================================================
/// FEATURE: Custom Lead Form Widget
/// PURPOSE: Standard lead capture form with anti-spam (Turnstile + Honeypot) and Smart WhatsApp integration.
/// ARCHITECTURE: 
/// - State Hoisting: All controllers and form state are managed in [CustomLeadFormWidget] state.
/// - Layout Delegation: Renders [_DesktopLeadFormLayout] or [_MobileLeadFormLayout] 
///   based on screen width.
/// ======================================================
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
    _turnstileViewId = 'turnstile-lead-form-${widget.block.hashCode}';
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
    return [
      {'field_id': 'name', 'field_type': 'text', 'label': context.translate('full_name'), 'placeholder': context.translate('name_hint'), 'is_required': true},
      {'field_id': 'email', 'field_type': 'email', 'label': context.translate('email'), 'placeholder': context.translate('email_hint'), 'is_required': true},
      {'field_id': 'message', 'field_type': 'textarea', 'label': context.translate('message_label'), 'placeholder': context.translate('message_hint'), 'is_required': true}
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

  Future<void> _submitForm() async {
    if (_honeypotController.text.isNotEmpty) {
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
      setState(() => _errorMessage = context.translate('captcha_required'));
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
      payload['__metadata'] = {'fingerprint': fingerprint, 'turnstile_token': _turnstileToken};

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
            _successMessage = state is LeadsAnalyticsLoaded ? (state.leadSuccessMessage ?? context.translate('lead_success')) : context.translate('lead_success');
            _errorMessage = null;
          });
          _clearForm();
          TurnstileService.reset(_turnstileViewId);
          setState(() => _turnstileToken = null);
          PixelEventService.trackLead();

          if (widget.block['whatsapp_auto_open'] == true) {
            final String whatsappNumber = widget.block['whatsapp_number']?.toString() ?? '';
            String template = widget.block['whatsapp_message_template']?.toString() ?? 'New Lead Submission';
            _dataPayload.forEach((key, value) => template = template.replaceAll('{{$key}}', value.toString()));
            await ActionHandlerService.openWhatsApp(phoneNumber: whatsappNumber, message: template, pageId: widget.pageId, blockType: 'lead_form');
          }
        }
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _successMessage = context.translate('lead_preview_success');
          _errorMessage = null;
        });
        _clearForm();
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
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
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        final props = _LeadFormProps(
          title: widget.title,
          buttonText: widget.buttonText,
          theme: widget.theme,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          isSubmitting: _isSubmitting,
          successMessage: _successMessage,
          errorMessage: _errorMessage,
          turnstileViewId: _turnstileViewId,
          fields: _fields,
          controllers: _controllers,
          dataPayload: _dataPayload,
          validationErrors: _validationErrors,
          honeypotController: _honeypotController,
          onFieldValueChanged: _onFieldValueChanged,
          onSubmit: _submitForm,
        );

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
              child: isMobile ? _MobileLeadFormLayout(props: props) : _DesktopLeadFormLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for Lead Form properties.
class _LeadFormProps {
  final String title;
  final String buttonText;
  final LandingPageTheme? theme;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final bool isSubmitting;
  final String? successMessage;
  final String? errorMessage;
  final String turnstileViewId;
  final List<dynamic> fields;
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> dataPayload;
  final Map<String, String> validationErrors;
  final TextEditingController honeypotController;
  final Function(String, String) onFieldValueChanged;
  final VoidCallback onSubmit;

  const _LeadFormProps({
    required this.title,
    required this.buttonText,
    this.theme,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.isSubmitting,
    this.successMessage,
    this.errorMessage,
    required this.turnstileViewId,
    required this.fields,
    required this.controllers,
    required this.dataPayload,
    required this.validationErrors,
    required this.honeypotController,
    required this.onFieldValueChanged,
    required this.onSubmit,
  });
}

/// Desktop version of the Lead Form layout.
class _DesktopLeadFormLayout extends StatelessWidget {
  final _LeadFormProps props;
  const _DesktopLeadFormLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return _LeadFormContainer(props: props);
  }
}

/// Mobile version of the Lead Form layout.
class _MobileLeadFormLayout extends StatelessWidget {
  final _LeadFormProps props;
  const _MobileLeadFormLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return _LeadFormContainer(props: props);
  }
}

/// Shared Lead Form Container.
class _LeadFormContainer extends StatelessWidget {
  final _LeadFormProps props;
  const _LeadFormContainer({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(props.isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(props.isMobile ? 16 : 24),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Offstage(child: TextField(controller: props.honeypotController, decoration: const InputDecoration(labelText: 'Leave this field empty'))),
          Text(props.title, style: AppTypography.h2.copyWith(fontSize: props.isMobile ? 22 : 26, fontWeight: FontWeight.bold, color: props.textColor)),
          SizedBox(height: 8),
          Text(context.translate('form_subtitle'), style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 12 : 14)),
          SizedBox(height: props.isMobile ? 24 : 32),
          if (props.successMessage != null) _StatusBanner(message: props.successMessage!, color: AppColors.activeGreen, isMobile: props.isMobile),
          if (props.errorMessage != null) _StatusBanner(message: props.errorMessage!, color: AppColors.dangerRed, isMobile: props.isMobile),
          ...props.fields.map((field) {
            if (field is! Map) return SizedBox.shrink();
            final fieldId = field['field_id'] as String?;
            if (fieldId == null) return SizedBox.shrink();
            final controller = props.controllers[fieldId];
            if (controller == null) return SizedBox.shrink();
            return _LeadFormField(field: field.cast<String, dynamic>(), controller: controller, props: props);
          }),
          SizedBox(height: props.isMobile ? 8 : 16),
          Center(child: SizedBox(width: 300, height: 70, child: HtmlElementView(viewType: props.turnstileViewId))),
          SizedBox(height: 16),
          _LeadFormSubmitButton(props: props),
        ],
      ),
    );
  }
}

/// Shared Status Banner (Success/Error).
class _StatusBanner extends StatelessWidget {
  final String message;
  final Color color;
  final bool isMobile;

  const _StatusBanner({required this.message, required this.color, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Icon(color == AppColors.activeGreen ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: color, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
        ],
      ),
    );
  }
}

/// Modular Lead Form Field.
class _LeadFormField extends StatelessWidget {
  final Map<String, dynamic> field;
  final TextEditingController controller;
  final _LeadFormProps props;

  const _LeadFormField({required this.field, required this.controller, required this.props});

  @override
  Widget build(BuildContext context) {
    final fieldId = field['field_id'] as String;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          titleSmall: TextStyle(color: props.textColor, fontSize: props.isMobile ? 12 : 14, fontWeight: FontWeight.bold),
        ),
      ),
      child: FieldRenderer.render(
        schema: field,
        controller: controller,
        currentValue: props.dataPayload[fieldId]?.toString(),
        errorMessage: props.validationErrors[fieldId],
        onChanged: (val) => props.onFieldValueChanged(fieldId, val),
      ),
    );
  }
}

/// Shared Lead Form Submit Button.
class _LeadFormSubmitButton extends StatelessWidget {
  final _LeadFormProps props;
  const _LeadFormSubmitButton({required this.props});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: props.isMobile ? 48 : 54,
      child: ElevatedButton(
        onPressed: props.isSubmitting ? null : props.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: props.secondaryColor,
          foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
          disabledBackgroundColor: props.secondaryColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: props.isSubmitting
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
            : Text(props.buttonText, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: props.isMobile ? 14 : 16)),
      ),
    );
  }
}
