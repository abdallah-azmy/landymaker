import 'dart:math';
import 'package:flutter/material.dart';

class FloatingCubeBackground extends StatefulWidget {
  final int cubeCount;
  final Color baseColor;
  final double speed;
  final bool isActive;

  const FloatingCubeBackground({
    super.key,
    this.cubeCount = 40,
    this.baseColor = const Color(0xFF6366F1),
    this.speed = 1.0,
    this.isActive = true,
  });

  @override
  State<FloatingCubeBackground> createState() => _FloatingCubeBackgroundState();
}

class _FloatingCubeBackgroundState extends State<FloatingCubeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Cube> _cubes;
  double _lastValue = 0.0;

  @override
  void initState() {
    super.initState();
    _cubes = List.generate(widget.cubeCount, (_) => _Cube());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _controller.addListener(_updateCubes);
    if (widget.isActive) _controller.repeat();
  }

  void _updateCubes() {
    if (!mounted) return;
    final current = _controller.value;
    double dt = current - _lastValue;
    if (dt < 0) {
      dt += 1.0;
    }
    _lastValue = current;

    for (final cube in _cubes) {
      cube.update(dt, widget.speed);
    }
  }

  @override
  void didUpdateWidget(FloatingCubeBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCubes);
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
            size: Size.infinite,
            painter: _CubePainter(
              cubes: _cubes,
              baseColor: widget.baseColor,
            ),
          );
        },
      ),
    );
  }
}

class _Cube {
  double x, y;
  final double size;
  late double vx, vy;
  late double targetVx, targetVy;
  double rotation;
  final double rotationSpeed;
  final double opacity;
  double _timeSinceLastChange = 0.0;

  _Cube()
      : x = Random().nextDouble(),
        y = Random().nextDouble(),
        size = 4.0 + Random().nextDouble() * 16.0,
        rotation = Random().nextDouble() * pi * 2,
        rotationSpeed = (Random().nextDouble() - 0.5) * 0.006,
        opacity = 0.08 + Random().nextDouble() * 0.22 {
    // Initial random velocities (noticeable but elegant)
    vx = (Random().nextDouble() - 0.5) * 0.05;
    vy = (Random().nextDouble() - 0.5) * 0.05;
    targetVx = vx;
    targetVy = vy;
  }

  void update(double dt, double speedMultiplier) {
    _timeSinceLastChange += dt;
    // Periodically change velocity targets to create organic random curving paths
    if (_timeSinceLastChange > 0.033) { // every ~2 seconds in 60s loop
      _timeSinceLastChange = 0.0;
      targetVx = (Random().nextDouble() - 0.5) * 0.07;
      targetVy = (Random().nextDouble() - 0.5) * 0.07;
    }

    // Smoothly interpolate towards target velocity
    vx = vx + (targetVx - vx) * 0.08;
    vy = vy + (targetVy - vy) * 0.08;

    // Scale motion parameters for organic rendering
    x += vx * dt * 60 * speedMultiplier;
    y += vy * dt * 60 * speedMultiplier;

    // Wrap around coordinates
    if (x < 0) x += 1.0;
    if (x > 1.0) x -= 1.0;
    if (y < 0) y += 1.0;
    if (y > 1.0) y -= 1.0;

    rotation += rotationSpeed * dt * 60 * speedMultiplier;
  }
}

class _CubePainter extends CustomPainter {
  final List<_Cube> cubes;
  final Color baseColor;

  _CubePainter({
    required this.cubes,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    for (final cube in cubes) {
      final px = cube.x * size.width;
      final py = cube.y * size.height;
      final s = cube.size;
      final rot = cube.rotation;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final half = s / 2;
      final rect = Rect.fromLTWH(-half, -half, s, s);

      strokePaint.color = baseColor.withValues(alpha: cube.opacity);
      canvas.drawRect(rect, strokePaint);

      fillPaint.color = baseColor.withValues(alpha: cube.opacity * 0.22);
      canvas.drawRect(rect, fillPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
