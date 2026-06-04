import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/forms/elements/field_renderer.dart';
import '../../../core/forms/validation_engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/localized_text_parser.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';

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

  late String _draftKey;
  late List<dynamic> _steps;

  @override
  void initState() {
    super.initState();
    _steps = widget.block['steps'] ?? [];

    // Fallback block ID if missing
    final blockId = widget.block['id'] ?? widget.block.hashCode.toString();
    _draftKey = 'draft_lead_${widget.pageId}_$blockId';

    _initializeControllers();

    if (widget.block['enable_local_save'] == true) {
      _loadDraft();
    }
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
      _submitForm();
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

    final cubit = context.read<LeadsAnalyticsCubit>();
    await cubit.submitLead(widget.pageId, finalSubmission);

    await _clearDraft();

    setState(() {
      _isSubmitting = false;
      _isSuccess = true;
    });
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

    final primaryColor = widget.theme?.primary ?? AppColors.primary;
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;

    return SectionBackground(
      theme: widget.theme,
      bgImageUrl: widget.block['bg_image_url'],
      bgOverlayColor: widget.block['bg_overlay_color'],
      bgOverlayOpacity: widget.block['bg_overlay_opacity']?.toDouble(),
      bgBlur: widget.block['bg_blur']?.toDouble(),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
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
                ),
        ),
      ),
    );
  }

  Widget _buildFormView(
    String title,
    String subtitle,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (_steps.isEmpty) {
      return const Text("No steps defined.");
    }

    final currentStep = _steps[_currentStepIndex];
    if (currentStep is! Map) return const SizedBox.shrink();

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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (subtitle.isNotEmpty) ...[
          Text(subtitle, style: TextStyle(fontSize: 16, color: subTextColor)),
          const SizedBox(height: 24),
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
            const SizedBox(width: 16),
            Expanded(
              child: LinearProgressIndicator(
                value: (_currentStepIndex + 1) / _steps.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (stepTitle.isNotEmpty) ...[
          Text(
            stepTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
        ],
        // Fields
        ...fields.map((field) {
          if (field is! Map) return const SizedBox.shrink();
          final fieldId = field['field_id'] as String?;
          if (fieldId == null) return const SizedBox.shrink();

          // Hide field if it fails condition
          if (!_evaluateCondition(field['show_if'])) {
            return const SizedBox.shrink();
          }

          return FieldRenderer.render(
            schema: field.cast<String, dynamic>(),
            controller: _controllers[fieldId] ?? TextEditingController(),
            currentValue: _dataPayload[fieldId]?.toString(),
            errorMessage: _validationErrors[fieldId],
            onChanged: (val) => _onFieldValueChanged(fieldId, val),
          );
        }),
        const SizedBox(height: 16),
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
              const SizedBox.shrink(),
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
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
        const SizedBox(height: 24),
        Text(
          msg,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
