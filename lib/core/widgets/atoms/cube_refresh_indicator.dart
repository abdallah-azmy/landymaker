import 'dart:math';
import 'package:flutter/material.dart';
import 'cube_spinner.dart';
import '../particles/core/cube_geometry.dart' as cg;

class CubeRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color color;

  const CubeRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color = Colors.white,
  });

  @override
  State<CubeRefreshIndicator> createState() => _CubeRefreshIndicatorState();
}

class _CubeRefreshIndicatorState extends State<CubeRefreshIndicator>
    with SingleTickerProviderStateMixin {
  double _pullProgress = 0.0;
  bool _isRefreshing = false;
  late AnimationController _bounceController;

  static const double _triggerDist = 80.0;
  static const double _indicatorHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (_isRefreshing) return false;

    double overscroll = 0.0;
    if (notification is OverscrollNotification && notification.overscroll < 0) {
      overscroll = notification.overscroll.abs();
    } else if (notification is ScrollUpdateNotification) {
      final m = notification.metrics;
      overscroll = max(0.0, m.minScrollExtent - m.pixels);
    }

    if (overscroll > 0) {
      _pullProgress = (overscroll / _triggerDist).clamp(0.0, 1.5);
    } else if (_pullProgress > 0 && !_isRefreshing) {
      _pullProgress = max(0.0, _pullProgress - 0.08);
    }

    if (notification is ScrollEndNotification) {
      if (_pullProgress >= 1.0) {
        _startRefresh();
      } else {
        _pullProgress = 0.0;
      }
    }

    return false;
  }

  Future<void> _startRefresh() async {
    setState(() => _isRefreshing = true);
    _bounceController.forward(from: 0.0);

    await widget.onRefresh();

    _bounceController.reverse();
    setState(() {
      _isRefreshing = false;
      _pullProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showOverlay = _pullProgress > 0.01 || _isRefreshing;
    final translateY = showOverlay
        ? (_pullProgress * _triggerDist * 0.6).clamp(0.0, _indicatorHeight)
        : 0.0;
    final cubeOpacity = showOverlay
        ? (_pullProgress * 2.0).clamp(0.0, 1.0)
        : 0.0;
    final cubeScale = showOverlay
        ? _pullProgress.clamp(0.0, 1.0)
        : 0.0;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (translateY > 0)
            Transform.translate(
              offset: Offset(0, translateY),
              child: widget.child,
            )
          else
            widget.child,
          if (cubeOpacity > 0.01)
            Positioned(
              top: (translateY - _indicatorHeight * 0.5).clamp(
                -_indicatorHeight * 0.5,
                8.0,
              ),
              left: 0,
              right: 0,
              height: _indicatorHeight,
              child: Opacity(
                opacity: cubeOpacity,
                child: Center(
                  child: _isRefreshing
                      ? _CubeOrbit(color: widget.color)
                      : Transform.scale(
                          scale: cubeScale,
                          child: _CubePullIndicator(
                            progress: _pullProgress,
                            color: widget.color,
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CubePullIndicator extends StatelessWidget {
  final double progress;
  final Color color;

  const _CubePullIndicator({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final count = (progress * 3).floor().clamp(1, 3);
    return SizedBox(
      width: 16 * count + 4 * (count - 1),
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final c = color.withValues(alpha: 0.5 + 0.5 * (i + 1) / count);
          return Padding(
            padding: EdgeInsetsDirectional.only(end: i < count - 1 ? 4 : 0),
            child: CubeSpinner(size: 12, color: c, strokeWidth: 1.5),
          );
        }),
      ),
    );
  }
}

class _CubeOrbit extends StatefulWidget {
  final Color color;

  const _CubeOrbit({required this.color});

  @override
  State<_CubeOrbit> createState() => _CubeOrbitState();
}

class _CubeOrbitState extends State<_CubeOrbit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: _CubeOrbitPainter(
                animValue: _controller.value,
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CubeOrbitPainter extends CustomPainter {
  final double animValue;
  final Color color;

  _CubeOrbitPainter({required this.animValue, required this.color});

  static final _scratch = [0.0, 0.0, 0.0];

  @override
  void paint(Canvas canvas, Size size) {
    final orbitR = size.width * 0.22;
    final cubeH = size.width * 0.14;
    const nCubes = 3;
    final angle = animValue * pi * 2;
    const rx = 0.70;
    final rot = cg.computeRotation(rx, angle, 0);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final entries = <_OEntry>[];

    for (int i = 0; i < nCubes; i++) {
      final a = angle + i * 2 * pi / nCubes;
      final cx = size.width * 0.5 + orbitR * cos(a);
      final cy = size.height * 0.5 + orbitR * sin(a);

      final tv = <List<double>>[];
      for (int j = 0; j < 8; j++) {
        cg.rotatePoint(cg.cubeVerts[j], rot, _scratch);
        tv.add([
          _scratch[0] * cubeH,
          _scratch[1] * cubeH,
          _scratch[2] * cubeH,
        ]);
      }

      for (int f = 0; f < 6; f++) {
        cg.rotatePoint(cg.cubeNormals[f], rot, _scratch);
        if (_scratch[2] <= 0) continue;
        final double nx = _scratch[0], ny = _scratch[1], nz = _scratch[2];

        double sumZ = 0;
        final verts = cg.cubeFaces[f];
        for (int vi = 0; vi < 4; vi++) sumZ += tv[verts[vi]][2];

        const lx = 0.1, ly = 0.05, lz = 0.5;
        final dot = nx * lx + ny * ly + nz * lz;
        final b = 0.4 + max(0.0, dot) * 0.6;

        final pts = <Offset>[
          for (int vi = 0; vi < 4; vi++)
            Offset(cx + tv[verts[vi]][0], cy - tv[verts[vi]][1]),
        ];

        fillPaint.color = Color.lerp(Colors.black, color, b)!;

        final path = Path();
        path.moveTo(pts[0].dx, pts[0].dy);
        for (int vi = 1; vi < 4; vi++) path.lineTo(pts[vi].dx, pts[vi].dy);
        path.close();

        entries.add((z: sumZ, path: path));
      }
    }

    entries.sort((a, b) => a.z.compareTo(b.z));
    for (final e in entries) {
      canvas.drawPath(e.path, fillPaint);
      canvas.drawPath(e.path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CubeOrbitPainter oldDelegate) {
    return animValue != oldDelegate.animValue;
  }
}

typedef _OEntry = ({double z, Path path});
