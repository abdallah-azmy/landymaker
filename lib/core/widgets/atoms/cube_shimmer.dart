import 'dart:math';
import 'package:flutter/material.dart';
import '../particles/core/cube_geometry.dart' as cg;

class CubeShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const CubeShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0,
  });

  @override
  State<CubeShimmer> createState() => _CubeShimmerState();
}

class _CubeShimmerState extends State<CubeShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(
              widget.width ?? double.infinity,
              widget.height ?? 200.0,
            ),
            painter: _CubeShimmerPainter(
              animValue: _controller.value,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

class _CubeShimmerPainter extends CustomPainter {
  final double animValue;
  final double borderRadius;

  _CubeShimmerPainter({
    required this.animValue,
    this.borderRadius = 0,
  });

  static const Color _bgColor = Color(0xFF0F172A);

  // Pre-allocated scratch buffers
  static final List<List<double>> _tv = List.generate(
    8,
    (_) => [0.0, 0.0, 0.0],
  );
  static final List<double> _nv = [0.0, 0.0, 0.0];
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFF334155).withValues(alpha: 0.3);
  static final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    if (borderRadius > 0) {
      canvas.clipRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(borderRadius),
      ));
    }

    canvas.drawRect(Offset.zero & size, Paint()..color = _bgColor);

    final cols = max(3, (size.width / 60).round());
    final rows = max(2, (size.height / 60).round());
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final cubeH = min(cellW, cellH) * 0.22;

    const rx = 0.70;
    final ry = pi / 4 + animValue * pi * 2 * 0.02;
    final rot = cg.computeRotation(rx, ry, 0.0);

    // Transform vertices for one cube
    for (int i = 0; i < 8; i++) {
      final vIn = cg.cubeVerts[i];
      cg.rotatePoint(
        [vIn[0] * cubeH, vIn[1] * cubeH, vIn[2] * cubeH],
        rot,
        _tv[i],
      );
    }

    // Determine visible faces
    final visibleFaces = <int>[];
    for (int f = 0; f < 6; f++) {
      final n = cg.cubeNormals[f];
      cg.rotatePoint(n, rot, _nv);
      if (_nv[2] > 0) {
        visibleFaces.add(f);
      }
    }

    const waveLength = 1.2;
    const speed = 0.25;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * cellW + cellW * 0.5;
        final cy = r * cellH + cellH * 0.5;

        final phase = (c / cols) * waveLength + (r / rows) * waveLength;
        final wave = sin(animValue * pi * 2 * speed - phase * pi * 2);
        final brightness = 0.3 + 0.7 * (0.5 + 0.5 * wave);

        for (final f in visibleFaces) {
          final verts = cg.cubeFaces[f];
          _path.reset();
          for (int vi = 0; vi < 4; vi++) {
            final idx = verts[vi];
            final x = cx + _tv[idx][0];
            final y = cy - _tv[idx][1];
            if (vi == 0) {
              _path.moveTo(x, y);
            } else {
              _path.lineTo(x, y);
            }
          }
          _path.close();

          const baseBrightness = 0.4;
          const range = 0.15;
          final colorVal = baseBrightness + brightness * range;
          _fillPaint.color = Color.lerp(
            const Color(0xFF1E293B),
            const Color(0xFF475569),
            colorVal,
          )!;

          canvas.drawPath(_path, _fillPaint);
          canvas.drawPath(_path, _strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CubeShimmerPainter oldDelegate) {
    return animValue != oldDelegate.animValue ||
        borderRadius != oldDelegate.borderRadius;
  }
}
