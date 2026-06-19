import 'dart:math';
import 'package:flutter/material.dart';

class FloatingCubeBackgroundController {
  void Function(Offset?)? onRepelUpdate;
  void Function(Offset)? onBurst;

  void repelAt(Offset? normalizedPosition) {
    onRepelUpdate?.call(normalizedPosition);
  }

  void burstAt(Offset normalizedPosition) {
    onBurst?.call(normalizedPosition);
  }
}

class FloatingCubeBackground extends StatefulWidget {
  final int cubeCount;
  final Color baseColor;
  final double speed;
  final bool isActive;
  final FloatingCubeBackgroundController? controller;

  const FloatingCubeBackground({
    super.key,
    this.cubeCount = 50,
    this.baseColor = const Color(0xFF6366F1),
    this.speed = 1.0,
    this.isActive = true,
    this.controller,
  });

  @override
  State<FloatingCubeBackground> createState() => _FloatingCubeBackgroundState();
}

class _FloatingCubeBackgroundState extends State<FloatingCubeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_Cube> _cubes;
  double _lastValue = 0.0;
  Offset? _repelPoint;
  bool _hasRepelPoint = false;

  void setRepelPoint(Offset? point) {
    _repelPoint = point;
    _hasRepelPoint = point != null;
  }

  void triggerBurst(Offset point) {
    for (final cube in _cubes) {
      cube.applyBurst(point);
    }
  }

  @override
  void initState() {
    super.initState();
    _cubes = List.generate(widget.cubeCount, (_) => _Cube());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _animController.addListener(_updateCubes);
    if (widget.isActive) _animController.repeat();
    widget.controller?.onRepelUpdate = setRepelPoint;
    widget.controller?.onBurst = triggerBurst;
  }

  void _updateCubes() {
    if (!mounted) return;
    final current = _animController.value;
    double dt = current - _lastValue;
    if (dt < 0) dt += 1.0;
    _lastValue = current;

    for (final cube in _cubes) {
      cube.update(dt, widget.speed, _hasRepelPoint ? _repelPoint : null);
    }
  }

  @override
  void didUpdateWidget(FloatingCubeBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animController.repeat();
      } else {
        _animController.stop();
      }
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.onRepelUpdate = null;
      oldWidget.controller?.onBurst = null;
      widget.controller?.onRepelUpdate = setRepelPoint;
      widget.controller?.onBurst = triggerBurst;
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_updateCubes);
    _animController.dispose();
    widget.controller?.onRepelUpdate = null;
    widget.controller?.onBurst = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _CubePainter(cubes: _cubes, baseColor: widget.baseColor),
          );
        },
      ),
    );
  }
}

class _Cube {
  double x, y;
  final double size;
  double vx, vy;
  double rx, ry, rz;
  double vrx, vry, vrz;
  final double opacity;
  double _timeSinceLastChange = 0.0;

  _Cube()
    : x = Random().nextDouble(),
      y = Random().nextDouble(),
      size = 6.0 + Random().nextDouble() * 18.0,
      vx = (Random().nextDouble() - 0.5) * 0.05,
      vy = (Random().nextDouble() - 0.5) * 0.05,
      rx = Random().nextDouble() * pi * 2,
      ry = Random().nextDouble() * pi * 2,
      rz = Random().nextDouble() * pi * 2,
      vrx = (Random().nextDouble() - 0.5) * 0.6,
      vry = (Random().nextDouble() - 0.5) * 1.2,
      vrz = (Random().nextDouble() - 0.5) * 0.4,
      opacity = 0.15 + Random().nextDouble() * 0.35;

  void update(double dt, double speedMultiplier, Offset? repelPoint) {
    _timeSinceLastChange += dt;
    if (_timeSinceLastChange > 0.033) {
      _timeSinceLastChange = 0.0;
      vx += (Random().nextDouble() - 0.5) * 0.02;
      vy += (Random().nextDouble() - 0.5) * 0.02;
    }

    if (repelPoint != null) {
      final dx = x - repelPoint.dx;
      final dy = y - repelPoint.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < 0.25 && dist > 0.001) {
        final force = (0.25 - dist) / 0.25 * 0.10;
        vx += (dx / dist) * force;
        vy += (dy / dist) * force;
      }
    }

    final speed = sqrt(vx * vx + vy * vy);
    if (speed > 0.15) {
      vx = (vx / speed) * 0.15;
      vy = (vy / speed) * 0.15;
    }

    x += vx * dt * 60 * speedMultiplier;
    y += vy * dt * 60 * speedMultiplier;

    if (x < 0) {
      x = 0;
      vx = -vx * 0.92;
    }
    if (x > 1) {
      x = 1;
      vx = -vx * 0.92;
    }
    if (y < 0) {
      y = 0;
      vy = -vy * 0.92;
    }
    if (y > 1) {
      y = 1;
      vy = -vy * 0.92;
    }

    rx += vrx * dt * 60 * speedMultiplier;
    ry += vry * dt * 60 * speedMultiplier;
    rz += vrz * dt * 60 * speedMultiplier;
  }

  void applyBurst(Offset point) {
    final dx = x - point.dx;
    final dy = y - point.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 0.4 && dist > 0.001) {
      final force = (0.4 - dist) / 0.4 * 0.15;
      vx += (dx / dist) * force;
      vy += (dy / dist) * force;
    }
  }
}

class _FaceDrawData {
  final double z;
  final double brightness;
  final double opacity;
  final double x0, y0, x1, y1, x2, y2, x3, y3;

  _FaceDrawData({
    required this.z,
    required this.brightness,
    required this.opacity,
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.x3,
    required this.y3,
  });
}

class _CubePainter extends CustomPainter {
  final List<_Cube> cubes;
  final Color baseColor;

  _CubePainter({required this.cubes, required this.baseColor});

  static const double _lx = 0.577;
  static const double _ly = 0.577;
  static const double _lz = 0.577;

  static const List<List<double>> _verts = [
    [-1.0, -1.0, 1.0],
    [1.0, -1.0, 1.0],
    [1.0, 1.0, 1.0],
    [-1.0, 1.0, 1.0],
    [-1.0, -1.0, -1.0],
    [1.0, -1.0, -1.0],
    [1.0, 1.0, -1.0],
    [-1.0, 1.0, -1.0],
  ];

  static const List<List<int>> _faces = [
    [0, 1, 2, 3],
    [4, 5, 6, 7],
    [3, 2, 6, 7],
    [0, 1, 5, 4],
    [1, 2, 6, 5],
    [0, 3, 7, 4],
  ];

  static const List<List<double>> _normals = [
    [0.0, 0.0, 1.0],
    [0.0, 0.0, -1.0],
    [0.0, 1.0, 0.0],
    [0.0, -1.0, 0.0],
    [1.0, 0.0, 0.0],
    [-1.0, 0.0, 0.0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final faces = <_FaceDrawData>[];
    final tv = <List<double>>[
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
    ];

    for (final cube in cubes) {
      final h = cube.size * 0.5;
      final px = cube.x * size.width;
      final py = cube.y * size.height;
      final a = cube.opacity;

      final cx = cos(cube.rx), sx = sin(cube.rx);
      final cy = cos(cube.ry), sy = sin(cube.ry);
      final cz = cos(cube.rz), sz = sin(cube.rz);

      for (int i = 0; i < 8; i++) {
        double x = _verts[i][0] * h;
        double y = _verts[i][1] * h;
        double z = _verts[i][2] * h;

        double y1 = y * cx - z * sx;
        double z1 = y * sx + z * cx;
        y = y1;
        z = z1;

        double x1 = x * cy + z * sy;
        double z2 = -x * sy + z * cy;
        x = x1;
        z = z2;

        double x2 = x * cz - y * sz;
        double y2 = x * sz + y * cz;
        x = x2;
        y = y2;

        tv[i][0] = x;
        tv[i][1] = y;
        tv[i][2] = z;
      }

      for (int f = 0; f < 6; f++) {
        double nx = _normals[f][0];
        double ny = _normals[f][1];
        double nz = _normals[f][2];

        double ny1 = ny * cx - nz * sx;
        double nz1 = ny * sx + nz * cx;
        ny = ny1;
        nz = nz1;

        double nx1 = nx * cy + nz * sy;
        double nz2 = -nx * sy + nz * cy;
        nx = nx1;
        nz = nz2;

        double nx2 = nx * cz - ny * sz;
        double ny2 = nx * sz + ny * cz;
        nx = nx2;
        ny = ny2;

        if (nz <= 0) continue;

        final dot = nx * _lx + ny * _ly + nz * _lz;
        final brightness = 0.25 + max(0.0, dot) * 0.75;

        double sumZ = 0.0;
        for (int vi = 0; vi < 4; vi++) {
          sumZ += tv[_faces[f][vi]][2];
        }

        final faceVerts = _faces[f];
        faces.add(
          _FaceDrawData(
            z: sumZ,
            brightness: brightness,
            opacity: a,
            x0: px + tv[faceVerts[0]][0],
            y0: py - tv[faceVerts[0]][1],
            x1: px + tv[faceVerts[1]][0],
            y1: py - tv[faceVerts[1]][1],
            x2: px + tv[faceVerts[2]][0],
            y2: py - tv[faceVerts[2]][1],
            x3: px + tv[faceVerts[3]][0],
            y3: py - tv[faceVerts[3]][1],
          ),
        );
      }
    }

    faces.sort((a, b) => a.z.compareTo(b.z));

    for (final fd in faces) {
      final alpha = fd.opacity * fd.brightness;
      final path = Path()
        ..moveTo(fd.x0, fd.y0)
        ..lineTo(fd.x1, fd.y1)
        ..lineTo(fd.x2, fd.y2)
        ..lineTo(fd.x3, fd.y3)
        ..close();

      fillPaint.color = baseColor.withValues(alpha: alpha * 0.35);
      canvas.drawPath(path, fillPaint);
      strokePaint.color = baseColor.withValues(alpha: alpha * 0.65);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
