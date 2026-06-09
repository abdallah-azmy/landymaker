import 'package:flutter/material.dart';

enum BlockAnimationType {
  none,
  fadeIn,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  zoomIn,
  bounceIn,
}

class BlockAnimationSettings {
  final BlockAnimationType type;
  final Duration duration;
  final Duration delay;
  final double intensity;
  final Curve curve;

  const BlockAnimationSettings({
    this.type = BlockAnimationType.fadeIn,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.intensity = 1.0,
    this.curve = Curves.easeOutCubic,
  });

  factory BlockAnimationSettings.fromJson(Map<String, dynamic> json) {
    return BlockAnimationSettings(
      type: _parseType(json['type']),
      duration: Duration(milliseconds: json['duration'] ?? 800),
      delay: Duration(milliseconds: json['delay'] ?? 0),
      intensity: (json['intensity'] ?? 1.0).toDouble(),
      curve: _parseCurve(json['curve']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'duration': duration.inMilliseconds,
    'delay': delay.inMilliseconds,
    'intensity': intensity,
    'curve': 'easeOutCubic', 
  };

  static BlockAnimationType _parseType(dynamic value) {
    if (value == null) return BlockAnimationType.none;
    return BlockAnimationType.values.firstWhere(
      (e) => e.name == value.toString(),
      orElse: () => BlockAnimationType.fadeIn,
    );
  }

  static Curve _parseCurve(dynamic value) {
    return Curves.easeOutCubic;
  }
}

class BlockAnimationWrapper extends StatefulWidget {
  final Widget child;
  final BlockAnimationSettings settings;
  final bool trigger;

  const BlockAnimationWrapper({
    super.key,
    required this.child,
    required this.settings,
    this.trigger = true,
  });

  @override
  State<BlockAnimationWrapper> createState() => _BlockAnimationWrapperState();
}

class _BlockAnimationWrapperState extends State<BlockAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.settings.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.settings.curve),
    );

    _offset = _getOffsetAnimation();
    _scale = _getScaleAnimation();

    if (widget.trigger) {
      Future.delayed(widget.settings.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  Animation<Offset> _getOffsetAnimation() {
    Offset begin = Offset.zero;
    switch (widget.settings.type) {
      case BlockAnimationType.slideUp:
        begin = Offset(0, 0.2 * widget.settings.intensity);
        break;
      case BlockAnimationType.slideDown:
        begin = Offset(0, -0.2 * widget.settings.intensity);
        break;
      case BlockAnimationType.slideLeft:
        begin = Offset(0.2 * widget.settings.intensity, 0);
        break;
      case BlockAnimationType.slideRight:
        begin = Offset(-0.2 * widget.settings.intensity, 0);
        break;
      default:
        begin = Offset.zero;
    }
    return Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.settings.curve),
    );
  }

  Animation<double> _getScaleAnimation() {
    double begin = 1.0;
    if (widget.settings.type == BlockAnimationType.zoomIn) {
      begin = 1.0 - (0.2 * widget.settings.intensity);
    } else if (widget.settings.type == BlockAnimationType.bounceIn) {
      begin = 0.5;
    }
    return Tween<double>(begin: begin, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.settings.type == BlockAnimationType.bounceIn
            ? Curves.elasticOut
            : widget.settings.curve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.settings.type == BlockAnimationType.none) return widget.child;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          const double referenceOffset = 50.0; 
          final Offset pixelOffset = _offset.value * referenceOffset;

          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: pixelOffset,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
