import 'package:flutter/material.dart';

class VisibilityObserver extends StatefulWidget {
  final Widget child;
  final VoidCallback onVisible;

  const VisibilityObserver({
    super.key,
    required this.child,
    required this.onVisible,
  });

  @override
  State<VisibilityObserver> createState() => _VisibilityObserverState();
}

class _VisibilityObserverState extends State<VisibilityObserver> {
  bool _wasVisible = false;
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    final scrollable = Scrollable.maybeOf(context);
    _scrollPosition = scrollable?.position;
    _scrollPosition?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!_wasVisible && mounted) {
      _checkVisibility();
    }
  }

  void _checkVisibility() {
    if (_wasVisible) return;
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    if (_scrollPosition == null || !_scrollPosition!.haveDimensions) return;

    final RenderBox box = renderObject as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final viewportHeight = _scrollPosition!.viewportDimension;

    if (position.dy < viewportHeight * 0.9) {
      _wasVisible = true;
      _scrollPosition?.removeListener(_onScroll);
      widget.onVisible();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
