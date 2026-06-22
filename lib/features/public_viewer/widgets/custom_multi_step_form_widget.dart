import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/forms/elements/field_renderer.dart';
import '../../../core/forms/validation_engine.dart';
import '../../../core/widgets/atoms/cube_spinner.dart';
import '../../../core/services/turnstile_service.dart';
import '../../../core/utils/fingerprint_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_text_parser.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';

import '../../../core/services/event_analytics_service.dart';
import '../../../core/services/action_handler_service.dart';

class CustomMultiStepFormWidget extends StatefulWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;
  final String pageId;

  const CustomMultiStepFormWidget({
    super.key,
    required this.block,
    required this.theme,
    required this.pageId,
  });

  @override
  State<CustomMultiStepFormWidget> createState() =>
      _CustomMultiStepFormWidgetState();
}

class _CustomMultiStepFormWidgetState extends State<CustomMultiStepFormWidget> {
  int _currentStepIndex = 0;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _validationErrors = {};
  Map<String, dynamic> _dataPayload = {};
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _errorMessage;

  late String _draftKey;
  late List<dynamic> _steps;
  late final String _turnstileViewId;
  String? _turnstileToken;

  @override
  void initState() {
    super.initState();
    _steps = widget.block['steps'] ?? [];

    // Fallback block ID if missing
    final blockId = widget.block['id'] ?? widget.block.hashCode.toString();
    _draftKey = 'draft_lead_\${widget.pageId}_\$blockId';

    _initializeControllers();

    if (widget.block['enable_local_save'] == true) {
      _loadDraft();
    }

    _turnstileViewId = 'turnstile-multi-step-\${widget.block.hashCode}';
    TurnstileService.registerViewFactory(_turnstileViewId, (token) {
      setState(() {
        _turnstileToken = token;
        if (_errorMessage == context.translate('captcha_required')) {
          _errorMessage = null;
        }
      });
    });
  }

  void _initializeControllers() {
    for (var step in _steps) {
      if (step is! Map) continue;
      final fields = step['fields'] ?? [];
      for (var field in fields) {
        if (field is! Map) continue;
        final fieldId = field['field_id'] as String?;
        if (fieldId != null && !_controllers.containsKey(fieldId)) {
          _controllers[fieldId] = TextEditingController();
        }
      }
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString(_draftKey);
    if (draftStr != null) {
      try {
        final draft = jsonDecode(draftStr) as Map<String, dynamic>;
        setState(() {
          _dataPayload = draft;
          // Hydrate controllers
          draft.forEach((key, value) {
            if (_controllers.containsKey(key)) {
              _controllers[key]!.text = value.toString();
            }
          });
        });
      } catch (_) {}
    }
  }

  Future<void> _saveDraft() async {
    if (widget.block['enable_local_save'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, jsonEncode(_dataPayload));
    }
  }

  Future<void> _clearDraft() async {
    if (widget.block['enable_local_save'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFieldValueChanged(String fieldId, String value) {
    if (_dataPayload.isEmpty) {
      EventAnalyticsService.recordFunnelStart(
        widget.pageId,
        formId: widget.block['id'] ?? 'multi_step',
        blockType: 'multi_step_form',
      );
    }
    setState(() {
      _dataPayload[fieldId] = value;
      // Clear error as user types
      if (_validationErrors.containsKey(fieldId)) {
        _validationErrors.remove(fieldId);
      }
    });
    _saveDraft();
  }

  bool _evaluateCondition(Map<String, dynamic>? condition) {
    if (condition == null) return true;
    final String fieldId = condition['field_id']?.toString() ?? '';
    final String operator = condition['operator']?.toString() ?? '==';
    final String targetValue = condition['value']?.toString() ?? '';

    final currentValue = _dataPayload[fieldId]?.toString() ?? '';

    switch (operator) {
      case '==':
        return currentValue == targetValue;
      case '!=':
        return currentValue != targetValue;
      case 'contains':
        return currentValue.contains(targetValue);
      case 'not_contains':
        return !currentValue.contains(targetValue);
      // Extendable for >, <, >=, <= if we parse them as numbers
      default:
        return currentValue == targetValue;
    }
  }

  int _findNextVisibleStep(int startIndex, int direction) {
    int nextIndex = startIndex + direction;
    while (nextIndex >= 0 && nextIndex < _steps.length) {
      final step = _steps[nextIndex];
      if (step is Map) {
        if (_evaluateCondition(step['show_if'])) {
          return nextIndex;
        }
      }
      nextIndex += direction;
    }
    return nextIndex; // Might return out of bounds, which we handle
  }

  void _nextStep() {
    final currentStep = _steps[_currentStepIndex];
    if (currentStep is! Map) return;

    final fields = currentStep['fields'] ?? [];

    // Validate current step
    final errors = ValidationEngine.validate(fields, _dataPayload);
    if (errors.isNotEmpty) {
      setState(() {
        _validationErrors.clear();
        _validationErrors.addAll(errors);
      });
      return;
    }

    // Go to next visible step
    final nextIndex = _findNextVisibleStep(_currentStepIndex, 1);

    if (nextIndex >= _steps.length) {
      if (_turnstileToken == null) {
        setState(() {
          _errorMessage = context.translate('captcha_required');
        });
      } else {
        _submitForm();
      }
    } else {
      setState(() {
        _validationErrors.clear();
        _currentStepIndex = nextIndex;
      });
    }
  }

  void _prevStep() {
    final prevIndex = _findNextVisibleStep(_currentStepIndex, -1);
    if (prevIndex >= 0) {
      setState(() {
        _validationErrors.clear();
        _currentStepIndex = prevIndex;
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    final metaData = {
      'form_type': 'multi_step_lead_form',
      'schema_version': widget.block['schema_version'] ?? 1,
      'submitted_at': DateTime.now().toIso8601String(),
      'page_id': widget.pageId,
      'block_id': widget.block['id'] ?? 'unknown',
    };

    final finalSubmission = {'payload': _dataPayload, 'meta': metaData};
    
    final fingerprint = FingerprintUtils.getFingerprint();
    finalSubmission['__metadata'] = {
      'fingerprint': fingerprint,
      'turnstile_token': _turnstileToken,
    };

    final cubit = context.read<LeadsAnalyticsCubit>();
    await cubit.submitLead(widget.pageId, finalSubmission);

    EventAnalyticsService.recordFunnelComplete(
      widget.pageId,
      formId: widget.block['id'] ?? 'multi_step',
      blockType: 'multi_step_form',
    );

    await _clearDraft();
    TurnstileService.reset(_turnstileViewId);

    setState(() {
      _isSubmitting = false;
      _isSuccess = true;
      _turnstileToken = null;
    });

    // MISSION: Smart WhatsApp Leads
    if (widget.block['whatsapp_auto_open'] == true) {
      final String whatsappNumber = widget.block['whatsapp_number']?.toString() ?? '';
      String template = widget.block['whatsapp_message_template']?.toString() ?? 'New Qualified Lead';

      _dataPayload.forEach((key, value) {
        template = template.replaceAll('{{$key}}', value.toString());
      });

      await ActionHandlerService.openWhatsApp(
        phoneNumber: whatsappNumber,
        message: template,
        pageId: widget.pageId,
        blockType: 'multi_step_form',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final title = LocalizedTextParser.extractText(
      widget.block['title'],
      isRtl ? 'ar' : 'en',
    );
    final subtitle = LocalizedTextParser.extractText(
      widget.block['subtitle'],
      isRtl ? 'ar' : 'en',
    );
    final successMsg = LocalizedTextParser.extractText(
      widget.block['success_message'],
      isRtl ? 'ar' : 'en',
    );

    final primaryColor = widget.theme?.primary ?? Theme.of(context).colorScheme.primary;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          theme: widget.theme,
          bgImageUrl: widget.block['bg_image_url'],
          bgOverlayColor: widget.block['bg_overlay_color'],
          bgOverlayOpacity: (widget.block['bg_overlay_opacity'] ?? widget.block['overlay_opacity'])?.toDouble(),
          backgroundColorHex: widget.block['bg_color'] ?? widget.block['background_color'],
          verticalPaddingOverride: (widget.block['vertical_padding'] as num?)?.toDouble(),
          bgBlur: widget.block['bg_blur']?.toDouble(),
          padding: EdgeInsetsDirectional.symmetric(
            vertical: verticalPadding,
            horizontal: 24,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: EdgeInsetsDirectional.all(isMobile ? 24 : 32),
              child: _isSuccess
                  ? _buildSuccessView(
                      successMsg.isNotEmpty ? successMsg : 'تم الإرسال بنجاح',
                      primaryColor,
                    )
                  : _buildFormView(
                      title,
                      subtitle,
                      primaryColor,
                      textColor,
                      subTextColor,
                      isMobile,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormView(
    String title,
    String subtitle,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
    bool isMobile,
  ) {
    if (_steps.isEmpty) {
      return const Text("No steps defined.");
    }

    final currentStep = _steps[_currentStepIndex];
    if (currentStep is! Map) return SizedBox.shrink();

    final stepTitle = LocalizedTextParser.extractText(
      currentStep['step_title'],
      'ar',
    );
    final fields = currentStep['fields'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
        ],
        if (subtitle.isNotEmpty) ...[
          Text(
            subtitle,
            style: TextStyle(fontSize: isMobile ? 14 : 16, color: subTextColor),
          ),
          SizedBox(height: 24),
        ],
        // Progress Indicator
        Row(
          children: [
            Text(
              "الخطوة ${_currentStepIndex + 1} من ${_steps.length}",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: LinearProgressIndicator(
                value: (_currentStepIndex + 1) / _steps.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        if (stepTitle.isNotEmpty) ...[
          Text(
            stepTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
        ],
        // Fields
        ...fields.map((field) {
          if (field is! Map) return SizedBox.shrink();
          final fieldId = field['field_id'] as String?;
          if (fieldId == null) return SizedBox.shrink();

          // Hide field if it fails condition
          if (!_evaluateCondition(field['show_if'])) {
            return SizedBox.shrink();
          }

          return FieldRenderer.render(
            schema: field.cast<String, dynamic>(),
            controller: _controllers[fieldId] ?? TextEditingController(),
            currentValue: _dataPayload[fieldId]?.toString(),
            errorMessage: _validationErrors[fieldId],
            onChanged: (val) => _onFieldValueChanged(fieldId, val),
          );
        }),

        if (_errorMessage != null) ...[
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],

        if (_findNextVisibleStep(_currentStepIndex, 1) >= _steps.length) ...[
          SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 300,
              height: 70,
              child: HtmlElementView(viewType: _turnstileViewId),
            ),
          ),
        ],

        SizedBox(height: 16),
        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStepIndex > 0)
              TextButton(
                onPressed: _isSubmitting ? null : _prevStep,
                child: const Text('السابق'),
              )
            else
              SizedBox.shrink(),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: _isSubmitting
                  ? const CubeSpinner(size: 20, color: Colors.white)
                  : Text(
                      _findNextVisibleStep(_currentStepIndex, 1) >=
                              _steps.length
                          ? 'إرسال'
                          : 'التالي',
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessView(String msg, Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, color: primaryColor, size: 80),
        SizedBox(height: 24),
        Text(
          msg,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
