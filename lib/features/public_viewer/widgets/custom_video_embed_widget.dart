import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/utils/video_url_helper.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
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
      setState(() => _isPlaying = false);
    }
  }

  void _initVideo() {
    final rawUrl = widget.block['video_url'] ?? '';
    if (rawUrl.isEmpty) return;

    _embedUrl = VideoUrlHelper.getEmbedUrl(rawUrl);
    final bool autoplay = widget.block['autoplay'] ?? false;
    final bool showControls = widget.block['show_controls'] ?? true;

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

    _embedUrl = finalUrl;
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

  void _startPlaying() => setState(() => _isPlaying = true);

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
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final primaryColor = widget.theme?.primary ?? Theme.of(context).colorScheme.primary;

    double ratio = 16 / 9;
    if (aspectRatioStr == '4:3') ratio = 4 / 3;
    if (aspectRatioStr == '1:1') ratio = 1;
    if (aspectRatioStr == '9:16') ratio = 9 / 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _VideoEmbedProps(
          title: title,
          subtitle: subtitle,
          rawUrl: rawUrl,
          isPlaying: _isPlaying,
          viewId: _viewId,
          useThumbnail: useThumbnail,
          customThumbnail: customThumbnail,
          ratio: ratio,
          maxWidth: maxWidth,
          textColor: textColor,
          subTextColor: subTextColor,
          primaryColor: primaryColor,
          isMobile: isMobile,
          onPlay: _startPlaying,
          theme: widget.theme,
          bgImageUrl: widget.block['bg_image_url'],
          bgOverlayColor: widget.block['bg_overlay_color'],
          bgOverlayOpacity: (widget.block['bg_overlay_opacity'] ?? 0.5).toDouble(),
          bgBlur: (widget.block['bg_blur'] ?? 0).toDouble(),
        );

        return isMobile
            ? _MobileVideoEmbedLayout(props: props)
            : _DesktopVideoEmbedLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _VideoEmbedProps {
  final String title;
  final String subtitle;
  final String rawUrl;
  final bool isPlaying;
  final String viewId;
  final bool useThumbnail;
  final String customThumbnail;
  final double ratio;
  final double maxWidth;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;
  final bool isMobile;
  final VoidCallback onPlay;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double bgOverlayOpacity;
  final double? bgBlur;

  const _VideoEmbedProps({
    required this.title,
    required this.subtitle,
    required this.rawUrl,
    required this.isPlaying,
    required this.viewId,
    required this.useThumbnail,
    required this.customThumbnail,
    required this.ratio,
    required this.maxWidth,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
    required this.isMobile,
    required this.onPlay,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    required this.bgOverlayOpacity,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the Video Embed layout.
class _DesktopVideoEmbedLayout extends StatelessWidget {
  final _VideoEmbedProps props;
  const _DesktopVideoEmbedLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: props.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (props.title.isNotEmpty) ...[
                Text(props.title, textAlign: TextAlign.center, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: 40, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
              ],
              if (props.subtitle.isNotEmpty) ...[
                Text(props.subtitle, textAlign: TextAlign.center, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, height: 1.5)),
                SizedBox(height: 40),
              ],
              _VideoPlayerArea(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Video Embed layout.
class _MobileVideoEmbedLayout extends StatelessWidget {
  final _VideoEmbedProps props;
  const _MobileVideoEmbedLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: props.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (props.title.isNotEmpty) ...[
                Text(props.title, textAlign: TextAlign.center, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
              ],
              if (props.subtitle.isNotEmpty) ...[
                Text(props.subtitle, textAlign: TextAlign.center, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, height: 1.5)),
                SizedBox(height: 40),
              ],
              _VideoPlayerArea(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Video Player Area (thumbnail or iframe).
class _VideoPlayerArea extends StatelessWidget {
  final _VideoEmbedProps props;
  const _VideoPlayerArea({required this.props});

  @override
  Widget build(BuildContext context) {
    if (props.rawUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: props.isMobile ? 200 : 400,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library_rounded, size: 48, color: props.subTextColor.withValues(alpha: 0.5)),
              SizedBox(height: 16),
              Text('قم بإضافة رابط الفيديو من لوحة التحكم', style: TextStyle(color: props.subTextColor)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: props.ratio,
        child: Builder(
          builder: (context) {
            if (!props.isPlaying && props.useThumbnail) {
              String? thumb = props.customThumbnail.isNotEmpty ? props.customThumbnail : VideoUrlHelper.getThumbnailUrl(props.rawUrl);
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null && thumb.isNotEmpty)
                    CustomNetworkImage(imageUrl: thumb, fit: BoxFit.cover)
                  else
                    Container(color: Colors.black87),
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: props.onPlay,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: props.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: props.primaryColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)],
                            ),
                            child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return HtmlElementView(viewType: props.viewId);
          },
        ),
      ),
    );
  }
}
