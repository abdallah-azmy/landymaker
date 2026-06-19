import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/pixel_event_service.dart';
import '../../../core/services/turnstile_service.dart';
import '../../../core/utils/fingerprint_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import '../../dashboard/controllers/leads_analytics_state.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/forms/validation_engine.dart';
import '../../../core/forms/elements/field_renderer.dart';

/// ======================================================
/// FEATURE: Custom Lead Magnet Widget
/// PURPOSE: A split layout section (Image + Form) designed for conversion offers (ebooks, audits, etc).
/// ARCHITECTURE: 
/// - State Hoisting: All controllers and form state are managed in [CustomLeadMagnetWidget] state.
/// - Layout Delegation: Renders [_DesktopLeadMagnetLayout] or [_MobileLeadMagnetLayout] 
///   based on screen width.
/// ======================================================
class CustomLeadMagnetWidget extends StatefulWidget {
  final Map<String, dynamic> block;
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String pageId;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const CustomLeadMagnetWidget({
    super.key,
    required this.block,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });

  @override
  State<CustomLeadMagnetWidget> createState() => _CustomLeadMagnetWidgetState();
}

class _CustomLeadMagnetWidgetState extends State<CustomLeadMagnetWidget> {
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
    _turnstileViewId = 'turnstile-lead-magnet-${widget.block.hashCode}';
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
      {'field_id': 'name', 'field_type': 'text', 'label': '', 'placeholder': context.translate('full_name'), 'is_required': true},
      {'field_id': 'email', 'field_type': 'email', 'label': '', 'placeholder': context.translate('email'), 'is_required': true}
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

  Future<void> _submitLead() async {
    if (_honeypotController.text.isNotEmpty) {
      setState(() {
        _successMessage = context.translate('lead_success');
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
    final secondaryColor = widget.theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);
        
        final props = _LeadMagnetProps(
          title: widget.title,
          subtitle: widget.subtitle,
          buttonText: widget.buttonText,
          imageUrl: widget.imageUrl,
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
          onSubmit: _submitLead,
        );

        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          backgroundColorHex: widget.backgroundColorHex,
          verticalPaddingOverride: widget.verticalPadding,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              decoration: BoxDecoration(
                color: widget.theme?.background.withValues(alpha: 0.9) ?? Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: isMobile ? _MobileLeadMagnetLayout(props: props) : _DesktopLeadMagnetLayout(props: props),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Data class for Lead Magnet properties.
class _LeadMagnetProps {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
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

  const _LeadMagnetProps({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
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

/// Desktop version of the Lead Magnet layout.
class _DesktopLeadMagnetLayout extends StatelessWidget {
  final _LeadMagnetProps props;
  const _DesktopLeadMagnetLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: _LeadMagnetImage(props: props, height: 500)),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: _LeadMagnetForm(props: props),
          ),
        ),
      ],
    );
  }
}

/// Mobile version of the Lead Magnet layout.
class _MobileLeadMagnetLayout extends StatelessWidget {
  final _LeadMagnetProps props;
  const _MobileLeadMagnetLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LeadMagnetImage(props: props, height: 250),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _LeadMagnetForm(props: props),
        ),
      ],
    );
  }
}

/// Shared Lead Magnet Image.
class _LeadMagnetImage extends StatelessWidget {
  final _LeadMagnetProps props;
  final double height;

  const _LeadMagnetImage({required this.props, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: props.theme?.textPrimary.withValues(alpha: 0.05) ?? Colors.white10,
      child: CustomNetworkImage(imageUrl: props.imageUrl, fit: BoxFit.cover),
    );
  }
}

/// Shared Lead Magnet Form Content.
class _LeadMagnetForm extends StatelessWidget {
  final _LeadMagnetProps props;
  const _LeadMagnetForm({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Offstage(child: TextField(controller: props.honeypotController, decoration: const InputDecoration(labelText: 'Leave this field empty'))),
        Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text(props.subtitle, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, height: 1.5)),
        SizedBox(height: 32),
        if (props.successMessage != null) _MagnetStatusBanner(message: props.successMessage!, color: Colors.green, isMobile: props.isMobile),
        if (props.errorMessage != null) _MagnetStatusBanner(message: props.errorMessage!, color: Theme.of(context).colorScheme.error, isMobile: props.isMobile),
        ...props.fields.map((field) {
          if (field is! Map) return SizedBox.shrink();
          final fieldId = field['field_id'] as String?;
          if (fieldId == null) return SizedBox.shrink();
          final controller = props.controllers[fieldId];
          if (controller == null) return SizedBox.shrink();
          return _LeadMagnetField(field: field.cast<String, dynamic>(), controller: controller, props: props);
        }),
        SizedBox(height: 24),
        Center(child: SizedBox(width: 300, height: 70, child: HtmlElementView(viewType: props.turnstileViewId))),
        SizedBox(height: 24),
        _LeadMagnetSubmitButton(props: props),
      ],
    );
  }
}

/// Shared Magnet Status Banner.
class _MagnetStatusBanner extends StatelessWidget {
  final String message;
  final Color color;
  final bool isMobile;

  const _MagnetStatusBanner({required this.message, required this.color, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Icon(color == Colors.green ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: color, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14))),
        ],
      ),
    );
  }
}

/// Modular Lead Magnet Field.
class _LeadMagnetField extends StatelessWidget {
  final Map<String, dynamic> field;
  final TextEditingController controller;
  final _LeadMagnetProps props;

  const _LeadMagnetField({required this.field, required this.controller, required this.props});

  @override
  Widget build(BuildContext context) {
    final fieldId = field['field_id'] as String;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
          titleSmall: TextStyle(color: props.textColor, fontSize: 14, fontWeight: FontWeight.bold),
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

/// Shared Lead Magnet Submit Button.
class _LeadMagnetSubmitButton extends StatelessWidget {
  final _LeadMagnetProps props;
  const _LeadMagnetSubmitButton({required this.props});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: props.isSubmitting ? null : props.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: props.secondaryColor,
          foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: props.isSubmitting
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(props.buttonText, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
