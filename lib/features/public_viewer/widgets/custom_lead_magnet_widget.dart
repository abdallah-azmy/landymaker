import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import '../../dashboard/controllers/leads_analytics_state.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/forms/validation_engine.dart';
import '../../../core/forms/elements/field_renderer.dart';

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
  
  bool _isSubmitting = false;
  String? _successMessage;
  String? _errorMessage;

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
        'label': '',
        'placeholder': context.translate('full_name'),
        'is_required': true,
      },
      {
        'field_id': 'email',
        'field_type': 'email',
        'label': '',
        'placeholder': context.translate('email'),
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

  Future<void> _submitLead() async {
    if (_honeypotController.text.isNotEmpty) {
      // Silently discard spam
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

    setState(() {
      _isSubmitting = true;
      _successMessage = null;
      _errorMessage = null;
    });
    
    try {
      final cubit = context.read<LeadsAnalyticsCubit>();
      await cubit.submitLead(widget.pageId, Map<String, dynamic>.from(_dataPayload));
      
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
        }
      }
    } catch (e) {
      // In builder mode (where the Cubit might not be provided)
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
    final textColor = widget.theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        
        return SectionBackground(
          bgImageUrl: widget.bgImageUrl,
          bgOverlayColor: widget.bgOverlayColor,
          bgOverlayOpacity: widget.bgOverlayOpacity,
          bgBlur: widget.bgBlur,
          theme: widget.theme,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              decoration: BoxDecoration(
                color: widget.theme?.background.withValues(alpha: 0.9) ?? AppColors.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ResponsiveLayout(
                  desktop: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildImageCover(),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: _buildFormContent(textColor, subTextColor, secondaryColor, isMobile: false),
                        ),
                      ),
                    ],
                  ),
                  tablet: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildImageCover(),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildFormContent(textColor, subTextColor, secondaryColor, isMobile: false),
                        ),
                      ),
                    ],
                  ),
                  mobile: Column(
                    children: [
                      _buildImageCover(height: 250),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _buildFormContent(textColor, subTextColor, secondaryColor, isMobile: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCover({double? height}) {
    return Container(
      height: height ?? 500,
      width: double.infinity,
      color: widget.theme?.textPrimary.withValues(alpha: 0.05) ?? Colors.white10,
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.menu_book_rounded, size: 80, color: widget.theme?.textPrimary.withValues(alpha: 0.2) ?? Colors.white24),
        ),
      ),
    );
  }

  Widget _buildFormContent(Color textColor, Color subTextColor, Color secondaryColor, {required bool isMobile}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: subTextColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

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
                titleSmall: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
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

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitLead,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    widget.buttonText,
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}
