import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/action_handler_service.dart';
import '../../../../core/services/event_analytics_service.dart';
import '../../../../core/widgets/atoms/cube_spinner.dart';

class StickyCtaBar extends StatefulWidget {
  final Map<String, dynamic> config;
  final String pageId;
  final String lang;
  final Color primaryColor;
  final ScrollController? scrollController;
  final ValueNotifier<bool>? visibilityNotifier;

  const StickyCtaBar({
    super.key,
    required this.config,
    required this.pageId,
    required this.lang,
    required this.primaryColor,
    this.scrollController,
    this.visibilityNotifier,
  });

  @override
  State<StickyCtaBar> createState() => _StickyCtaBarState();
}

class _StickyCtaBarState extends State<StickyCtaBar> {
  bool _isVisible = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _isVisible = false; // Start hidden until scroll threshold
      widget.scrollController!.addListener(_scrollListener);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollListener());
    }
  }

  @override
  void didUpdateWidget(covariant StickyCtaBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController?.removeListener(_scrollListener);
      widget.scrollController?.addListener(_scrollListener);
      if (widget.scrollController != null) {
        _scrollListener();
      } else {
        _isVisible = true;
      }
    }
  }

  void _scrollListener() {
    if (!mounted || widget.scrollController == null || !widget.scrollController!.hasClients) return;
    
    final maxScroll = widget.scrollController!.position.maxScrollExtent;
    final currentScroll = widget.scrollController!.position.pixels;
    
    if (maxScroll <= 0) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
        if (widget.visibilityNotifier != null) {
          widget.visibilityNotifier!.value = true;
        }
      }
      return;
    }
    
    final percentage = currentScroll / maxScroll;
    final shouldBeVisible = percentage >= 0.3;
    
    if (_isVisible != shouldBeVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });
      if (widget.visibilityNotifier != null) {
        widget.visibilityNotifier!.value = shouldBeVisible;
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.config['is_enabled'] != true) {
      return SizedBox.shrink();
    }

    final String text = _getLocalizedText(widget.config['text'], widget.lang) ?? '';
    final String priceText = _getLocalizedText(widget.config['price_text'], widget.lang) ?? '';
    final String buttonText = _getLocalizedText(widget.config['button_text'], widget.lang) ?? 'Click Here';
    final String actionValue = widget.config['button_action_value']?.toString().trim() ?? '';
    final bool hasValidAction = actionValue.isNotEmpty;

    return AnimatedSlide(
      offset: _isVisible ? Offset.zero : const Offset(0, 1.2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (text.isNotEmpty || priceText.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (text.isNotEmpty)
                          Text(
                            text,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (priceText.isNotEmpty)
                          Text(
                            priceText,
                            style: AppTypography.caption.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                if (text.isNotEmpty || priceText.isNotEmpty) SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: widget.primaryColor.withValues(alpha: 0.5),
                  ),
                  onPressed: !hasValidAction || _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

                          EventAnalyticsService.logEvent(
                            eventName: 'sticky_cta_clicked',
                            parameters: {
                              'action_type': widget.config['button_action_type'],
                              'action_value': actionValue,
                            },
                          );

                          await ActionHandlerService.executeAction(
                            context,
                            actionType: widget.config['button_action_type'] ?? 'link',
                            actionValue: actionValue,
                            pageId: widget.pageId,
                            buttonText: buttonText,
                            blockType: 'sticky_cta',
                          );

                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? const CubeSpinner(size: 20, color: Colors.white)
                      : Text(
                          buttonText,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _getLocalizedText(dynamic data, String lang) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      return data[lang] ?? data['en'] ?? data.values.firstOrNull?.toString();
    }
    return data.toString();
  }
}
