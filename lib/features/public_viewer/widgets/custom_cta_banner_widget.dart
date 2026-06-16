import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomCtaBannerWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomCtaBannerWidget({
    super.key,
    required this.block,
    this.theme,
  });

  String get _layoutStyle => block['layout_style'] as String? ?? 'centeredGradient';

  @override
  Widget build(BuildContext context) {
    final accentColor = theme?.secondary ?? AppColors.secondary;

    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final buttonText = block['button_text'] ?? '';
    final buttonUrl = block['button_url'] ?? '';
    final secondaryButtonText = block['secondary_button_text'] ?? '';
    final secondaryButtonUrl = block['secondary_button_url'] ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        if (_layoutStyle == 'split') {
          return _buildSplitLayout(context, isMobile, title, subtitle, buttonText, buttonUrl, secondaryButtonText, secondaryButtonUrl, accentColor);
        }

        return _buildCenteredGradientLayout(context, isMobile, title, subtitle, buttonText, buttonUrl, secondaryButtonText, secondaryButtonUrl, accentColor);
      },
    );
  }

  Widget _buildCenteredGradientLayout(BuildContext context, bool isMobile, String title, String subtitle, String buttonText, String buttonUrl, String secondaryButtonText, String secondaryButtonUrl, Color accentColor) {
    return SectionBackground(
      theme: theme,
      bgImageUrl: block['bg_image_url'],
      bgOverlayColor: block['bg_overlay_color'],
      bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble() ?? 0.0,
      bgBlur: (block['bg_blur'] as num?)?.toDouble(),
      padding: EdgeInsetsDirectional.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: EdgeInsetsDirectional.all(isMobile ? 32 : 64),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor,
                accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 36,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isMobile ? 16 : 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () => _launchUrl(buttonUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  if (secondaryButtonText.isNotEmpty)
                    OutlinedButton(
                      onPressed: () => _launchUrl(secondaryButtonUrl),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(secondaryButtonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout(BuildContext context, bool isMobile, String title, String subtitle, String buttonText, String buttonUrl, String secondaryButtonText, String secondaryButtonUrl, Color accentColor) {
    return SectionBackground(
      theme: theme,
      bgImageUrl: block['bg_image_url'],
      bgOverlayColor: block['bg_overlay_color'],
      bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble() ?? 0.0,
      bgBlur: (block['bg_blur'] as num?)?.toDouble(),
      padding: EdgeInsetsDirectional.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: EdgeInsetsDirectional.all(isMobile ? 32 : 56),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor,
                accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title, style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(subtitle, style: AppTypography.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.9)), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 32),
                  _buildButtonRow(buttonText, buttonUrl, secondaryButtonText, secondaryButtonUrl, accentColor),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(subtitle, style: AppTypography.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  _buildButtonRow(buttonText, buttonUrl, secondaryButtonText, secondaryButtonUrl, accentColor),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(String buttonText, String buttonUrl, String secondaryButtonText, String secondaryButtonUrl, Color accentColor) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () => _launchUrl(buttonUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        if (secondaryButtonText.isNotEmpty)
          OutlinedButton(
            onPressed: () => _launchUrl(secondaryButtonUrl),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(secondaryButtonText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
