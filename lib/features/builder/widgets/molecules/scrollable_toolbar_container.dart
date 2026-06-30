import 'package:flutter/material.dart';
import '../../../../core/widgets/atoms/blur_effect.dart';

class ScrollableToolbarContainer extends StatefulWidget {
  final List<Widget> children;
  final double? minWidth;
  final MainAxisAlignment mainAxisAlignment;
  final Axis scrollDirection;
  final ScrollPhysics physics;

  const ScrollableToolbarContainer({
    super.key,
    required this.children,
    this.minWidth,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.scrollDirection = Axis.horizontal,
    this.physics = const BouncingScrollPhysics(),
  });

  @override
  State<ScrollableToolbarContainer> createState() => _ScrollableToolbarContainerState();
}

class _ScrollableToolbarContainerState extends State<ScrollableToolbarContainer> {
  late final ScrollController _scrollController;
  bool _showStartArrow = false;
  bool _showEndArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    final showStart = currentScroll > 5;
    final showEnd = currentScroll < maxScroll - 5;

    if (showStart != _showStartArrow || showEnd != _showEndArrow) {
      setState(() {
        _showStartArrow = showStart;
        _showEndArrow = showEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final IconData startIcon = isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
    final IconData endIcon = isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded;

    Widget rowWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: widget.children,
    );

    if (widget.minWidth != null) {
      rowWidget = ConstrainedBox(
        constraints: BoxConstraints(minWidth: widget.minWidth!),
        child: rowWidget,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _updateScrollIndicators();
            return false;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: widget.scrollDirection,
            physics: widget.physics,
            child: rowWidget,
          ),
        ),
        if (_showStartArrow)
          PositionedDirectional(
            start: 1,
            top: 0,
            bottom: 0,
            child: Center(
              child: AppBlurEffect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      startIcon,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    tooltip: isRtl ? "تمرير للبداية" : "Scroll to Start",
                  ),
                ),
              ),
            ),
          ),
        if (_showEndArrow)
          PositionedDirectional(
            end: 1,
            top: 0,
            bottom: 0,
            child: Center(
              child: AppBlurEffect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      endIcon,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    tooltip: isRtl ? "تمرير للنهاية" : "Scroll to End",
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
