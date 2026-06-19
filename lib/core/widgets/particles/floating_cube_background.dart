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

  @override
  void initState() {
    super.initState();
    _cubes = List.generate(widget.cubeCount, (_) => _Cube(widget.baseColor));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    if (widget.isActive) _controller.repeat();
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
              progress: _controller.value,
              speed: widget.speed,
            ),
          );
        },
      ),
    );
  }
}

class _Cube {
  double x, y;
  double size;
  double driftX, driftY;
  double rotation;
  double rotationSpeed;
  double opacity;

  _Cube(Color baseColor) {
    final rng = Random();
    x = rng.nextDouble();
    y = rng.nextDouble();
    size = 3.0 + rng.nextDouble() * 14.0;
    driftX = (rng.nextDouble() - 0.5) * 0.003;
    driftY = -(0.001 + rng.nextDouble() * 0.004);
    rotation = rng.nextDouble() * pi * 2;
    rotationSpeed = (rng.nextDouble() - 0.5) * 0.002;
    opacity = 0.1 + rng.nextDouble() * 0.25;
  }
}

class _CubePainter extends CustomPainter {
  final List<_Cube> cubes;
  final double progress;
  final double speed;

  _CubePainter({
    required this.cubes,
    required this.progress,
    this.speed = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final cube in cubes) {
      final cx = (cube.x + cube.driftX * progress * 60 * speed) % 1.0;
      final cy = (cube.y + cube.driftY * progress * 60 * speed) % 1.0;

      final px = cx * size.width;
      final py = cy * size.height;

      final s = cube.size;
      final rot = cube.rotation + cube.rotationSpeed * progress * 60 * speed;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: cube.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final half = s / 2;
      final path = Path()
        ..moveTo(-half, -half)
        ..lineTo(half, -half)
        ..lineTo(half, half)
        ..lineTo(-half, half)
        ..close();

      canvas.drawPath(path, paint);

      final fill = Paint()
        ..color = Colors.white.withValues(alpha: cube.opacity * 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fill);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
