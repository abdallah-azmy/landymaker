import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/controllers/leads_analytics_cubit.dart';
import '../../../core/utils/toast_service.dart';

class CustomLeadMagnetWidget extends StatefulWidget {
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitLead() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ToastService.showError(context, message: "يرجى إدخال الاسم والبريد الإلكتروني.");
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final cubit = context.read<LeadsAnalyticsCubit>();
      await cubit.submitLead(widget.pageId, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });
      
      if (mounted) {
        ToastService.showSuccess(context, message: "تم التسجيل بنجاح! شكراً لك.");
        _nameController.clear();
        _emailController.clear();
      }
    } catch (e) {
      // In builder mode (where the Cubit might not be provided)
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ToastService.showSuccess(context, message: "وضع المعاينة: تم استلام البيانات بنجاح.");
      }
    }
    
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
              constraints: const BoxConstraints(maxWidth: 1000),
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
                          child: _buildFormContent(textColor, subTextColor, secondaryColor),
                        ),
                      ),
                    ],
                  ),
                  mobile: Column(
                    children: [
                      _buildImageCover(height: 250),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: _buildFormContent(textColor, subTextColor, secondaryColor),
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

  Widget _buildFormContent(Color textColor, Color subTextColor, Color secondaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "الاسم كامل",
            filled: true,
            fillColor: textColor.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "البريد الإلكتروني",
            filled: true,
            fillColor: textColor.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
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
