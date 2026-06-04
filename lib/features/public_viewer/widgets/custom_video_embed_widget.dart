import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/utils/video_url_helper.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomVideoEmbedWidget extends StatefulWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomVideoEmbedWidget({
    super.key,
    required this.block,
    this.theme,
  });

  @override
  State<CustomVideoEmbedWidget> createState() => _CustomVideoEmbedWidgetState();
}

class _CustomVideoEmbedWidgetState extends State<CustomVideoEmbedWidget> {
  static final Set<String> _registeredViews = {};
  bool _isPlaying = false;
  late String _viewId;
  late String _embedUrl;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant CustomVideoEmbedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block['video_url'] != widget.block['video_url'] || 
        oldWidget.block['autoplay'] != widget.block['autoplay'] ||
        oldWidget.block['show_controls'] != widget.block['show_controls']) {
      _initVideo();
      // If URL changed in builder, stop playing to show new thumbnail
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _initVideo() {
    final rawUrl = widget.block['video_url'] ?? '';
    if (rawUrl.isEmpty) return;

    _embedUrl = VideoUrlHelper.getEmbedUrl(rawUrl);
    final bool autoplay = widget.block['autoplay'] ?? false;
    final bool showControls = widget.block['show_controls'] ?? true;

    // Append standard parameters
    String finalUrl = _embedUrl;
    if (finalUrl.contains('youtube.com') || finalUrl.contains('youtu.be')) {
      finalUrl += finalUrl.contains('?') ? '&' : '?';
      finalUrl += 'rel=0';
      if (!showControls) finalUrl += '&controls=0';
      if (autoplay) finalUrl += '&autoplay=1&mute=1';
    } else if (finalUrl.contains('vimeo.com')) {
      finalUrl += finalUrl.contains('?') ? '&' : '?';
      if (!showControls) finalUrl += 'controls=0';
      if (autoplay) finalUrl += '&autoplay=1&muted=1';
    }

    _viewId = 'iframe-${finalUrl.hashCode}';

    if (!_registeredViews.contains(_viewId)) {
      ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = finalUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
        
        return iframe;
      });
      _registeredViews.add(_viewId);
    }
  }

  String _extractText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return value['ar'] ?? value['en'] ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = widget.block['video_url'] ?? '';
    final String title = _extractText(widget.block['title']);
    final String subtitle = _extractText(widget.block['subtitle']);
    final String aspectRatioStr = widget.block['aspect_ratio'] ?? '16:9';
    final double maxWidth = (widget.block['max_width'] ?? 900).toDouble();
    final bool useThumbnail = widget.block['use_thumbnail'] ?? true;
    final String customThumbnail = widget.block['thumbnail_url'] ?? '';

    final textColor = widget.theme?.textPrimary ?? Colors.white;
    final subTextColor = widget.theme?.textSecondary ?? AppColors.textSecondary;
    final primaryColor = widget.theme?.primary ?? AppColors.primary;

    double ratio = 16 / 9;
    if (aspectRatioStr == '4:3') ratio = 4 / 3;
    if (aspectRatioStr == '1:1') ratio = 1;
    if (aspectRatioStr == '9:16') ratio = 9 / 16;

    final bool isMobile = ResponsiveLayout.isMobile(context);
    final double verticalPadding = isMobile ? 40 : 80;

    return SectionBackground(
      bgImageUrl: widget.block['bg_image_url'],
      bgOverlayColor: widget.block['bg_overlay_color'],
      bgOverlayOpacity: (widget.block['bg_overlay_opacity'] ?? 0.5).toDouble(),
      bgBlur: (widget.block['bg_blur'] ?? 0).toDouble(),
      theme: widget.theme,
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: textColor,
                    fontSize: isMobile ? 28 : 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (subtitle.isNotEmpty) ...[
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              if (rawUrl.isEmpty)
                Container(
                  width: double.infinity,
                  height: isMobile ? 200 : 400,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_library_rounded, size: 48, color: subTextColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'قم بإضافة رابط الفيديو من لوحة التحكم',
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: ratio,
                    child: Builder(
                      builder: (context) {
                        if (!_isPlaying && useThumbnail) {
                          String? thumb = customThumbnail.isNotEmpty ? customThumbnail : VideoUrlHelper.getThumbnailUrl(rawUrl);
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumb != null && thumb.isNotEmpty)
                                Image.network(
                                  thumb,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.black87),
                                )
                              else
                                Container(color: Colors.black87),
                              // Play Button Overlay
                              Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: Center(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isPlaying = true;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withValues(alpha: 0.5),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            )
                                          ]
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        
                        return HtmlElementView(viewType: _viewId);
                      }
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
