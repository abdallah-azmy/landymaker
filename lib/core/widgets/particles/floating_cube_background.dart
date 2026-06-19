import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';

class FloatingCubeBackgroundController {
  void Function(Offset?)? onRepelUpdate;
  void Function(Offset)? onBurst;
  double scrollDrift = 0.0;

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
  final CubeMode cubeMode;

  const FloatingCubeBackground({
    super.key,
    this.cubeCount = 50,
    this.baseColor = const Color(0xFF6366F1),
    this.speed = 1.0,
    this.isActive = true,
    this.controller,
    this.cubeMode = CubeMode.standard,
  });

  @override
  State<FloatingCubeBackground> createState() => _FloatingCubeBackgroundState();
}

class _FloatingCubeBackgroundState extends State<FloatingCubeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_Cube> _cubes;
  final _clusters = <_CubeCluster>[];
  double _lastValue = 0.0;
  Offset? _repelPoint;
  bool _hasRepelPoint = false;
  double _clusterSpawnTimer = 0.0;
  final _random = Random();

  void setRepelPoint(Offset? point) {
    _repelPoint = point;
    _hasRepelPoint = point != null;
  }

  void triggerBurst(Offset point) {
    for (final cube in _cubes) {
      cube.applyBurst(point);
    }
    for (final cluster in _clusters) {
      if (!cluster.isExploding && cluster.containsPoint(point)) {
        cluster.explode();
      }
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
    final scrollDrift = widget.controller?.scrollDrift ?? 0.0;

    for (final cube in _cubes) {
      cube.update(
        dt,
        widget.speed,
        _hasRepelPoint ? _repelPoint : null,
        scrollDrift,
      );
    }

    if (widget.cubeMode == CubeMode.merge) {
      _clusterSpawnTimer += dt;
      if (_clusterSpawnTimer > 3.0 + _random.nextDouble() * 2.0 &&
          _clusters.length < 4) {
        _clusterSpawnTimer = 0.0;
        _clusters.add(
          _CubeCluster(_random.nextDouble(), _random.nextDouble()),
        );
      }
    }

    for (int i = _clusters.length - 1; i >= 0; i--) {
      final cluster = _clusters[i];
      cluster.update(
        dt,
        widget.speed,
        _hasRepelPoint ? _repelPoint : null,
        scrollDrift,
      );
      if (cluster.isExploding && cluster.explodeTimer > 1.5) {
        for (int j = 0; j < 27; j++) {
          _cubes.add(_Cube.fromCluster(
            normalizedX: cluster.x,
            normalizedY: cluster.y,
            size: _CubeCluster.cubeSize,
            baseVx: (Random().nextDouble() - 0.5) * 0.3,
            baseVy: (Random().nextDouble() - 0.5) * 0.3,
          ));
        }
        _clusters.removeAt(i);
      }
    }

    if (widget.controller != null) {
      widget.controller!.scrollDrift = 0.0;
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
    if (widget.cubeCount != oldWidget.cubeCount &&
        widget.cubeCount > _cubes.length) {
      _cubes.addAll(
        List.generate(widget.cubeCount - _cubes.length, (_) => _Cube()),
      );
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _CubePainter(
              cubes: _cubes,
              clusters: _clusters,
              baseColor: widget.baseColor,
              isLightMode: isLight,
              cubeMode: widget.cubeMode,
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
  double vx, vy;
  final double _baseVx, _baseVy;
  double rx, ry, rz;
  double vrx, vry, vrz;
  final double opacity;
  double _timeSinceLastChange = 0.0;

  factory _Cube() {
    final randVx = (Random().nextDouble() - 0.5) * 0.05;
    final randVy = (Random().nextDouble() - 0.5) * 0.05;
    return _Cube._internal(
      x: Random().nextDouble(),
      y: Random().nextDouble(),
      size: 6.0 + Random().nextDouble() * 18.0,
      vx: randVx,
      vy: randVy,
      baseVx: randVx,
      baseVy: randVy,
      rx: Random().nextDouble() * pi * 2,
      ry: Random().nextDouble() * pi * 2,
      rz: Random().nextDouble() * pi * 2,
      vrx: (Random().nextDouble() - 0.5) * 1.5,
      vry: (Random().nextDouble() - 0.5) * 2.5,
      vrz: (Random().nextDouble() - 0.5) * 0.8,
      opacity: 0.15 + Random().nextDouble() * 0.35,
    );
  }

  _Cube.fromCluster({
    required double normalizedX,
    required double normalizedY,
    required double size,
    required double baseVx,
    required double baseVy,
  }) : x = normalizedX,
       y = normalizedY,
       size = size,
       vx = baseVx,
       vy = baseVy,
       _baseVx = baseVx,
       _baseVy = baseVy,
       rx = Random().nextDouble() * pi * 2,
       ry = Random().nextDouble() * pi * 2,
       rz = Random().nextDouble() * pi * 2,
       vrx = (Random().nextDouble() - 0.5) * 1.5,
       vry = (Random().nextDouble() - 0.5) * 2.5,
       vrz = (Random().nextDouble() - 0.5) * 0.8,
       opacity = 0.15 + Random().nextDouble() * 0.35;

  _Cube._internal({
    required this.x,
    required this.y,
    required this.size,
    required this.vx,
    required this.vy,
    required double baseVx,
    required double baseVy,
    required this.rx,
    required this.ry,
    required this.rz,
    required this.vrx,
    required this.vry,
    required this.vrz,
    required this.opacity,
  }) : _baseVx = baseVx,
       _baseVy = baseVy;

  void update(
    double dt,
    double speedMultiplier,
    Offset? repelPoint,
    double scrollDrift,
  ) {
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
        final force = (0.25 - dist) / 0.25 * 0.30;
        vx += (dx / dist) * force;
        vy += (dy / dist) * force;
      }
    }

    vy -= scrollDrift * 5.0;

    const double repZone = 0.08;
    const double repForce = 0.025;
    if (y < repZone) vy += (repZone - y) / repZone * repForce;
    if (y > 1.0 - repZone) vy -= (repZone - (1.0 - y)) / repZone * repForce;
    if (x < repZone) vx += (repZone - x) / repZone * repForce;
    if (x > 1.0 - repZone) vx -= (repZone - (1.0 - x)) / repZone * repForce;

    final speed = sqrt(vx * vx + vy * vy);
    if (speed > 0.35) {
      vx = (vx / speed) * 0.35;
      vy = (vy / speed) * 0.35;
    }

    final realDt = dt * 60;
    final decay = max(0.0, 1.0 - 1.5 * realDt);
    vx = _baseVx + (vx - _baseVx) * decay;
    vy = _baseVy + (vy - _baseVy) * decay;

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
      final drift = scrollDrift.abs();
      if (drift > 0.001) {
        final bounceFactor = (0.92 + drift * 10.0).clamp(0.92, 1.5);
        vy = -vy * bounceFactor;
        vx += (Random().nextDouble() - 0.5) * drift * 4.0;
      } else {
        vy = 0.03 + Random().nextDouble() * 0.04;
        vx += (Random().nextDouble() - 0.5) * 0.015;
      }
    }
    if (y > 1) {
      y = 1;
      final drift = scrollDrift.abs();
      if (drift > 0.001) {
        final bounceFactor = (0.92 + drift * 10.0).clamp(0.92, 1.5);
        vy = -vy * bounceFactor;
        vx += (Random().nextDouble() - 0.5) * drift * 4.0;
      } else {
        vy = -(0.03 + Random().nextDouble() * 0.04);
        vx += (Random().nextDouble() - 0.5) * 0.015;
      }
    }

    rx += vrx * dt * 60 * speedMultiplier;
    ry += vry * dt * 60 * speedMultiplier;
    rz += vrz * dt * 60 * speedMultiplier;
  }

  void applyBurst(Offset point) {
    final dx = x - point.dx;
    final dy = y - point.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist < 0.65 && dist > 0.001) {
      final force = (0.65 - dist) / 0.65 * 0.6;
      vx += (dx / dist) * force;
      vy += (dy / dist) * force;
    }
  }
}

class _ClusterCubelet {
  final int gx, gy, gz;

  _ClusterCubelet({
    required this.gx,
    required this.gy,
    required this.gz,
  });
}

class _CubeCluster {
  static const double cubeSize = 7.0;
  static const double spacing = cubeSize * 1.2;

  double x, y;
  double vx = 0.0, vy = 0.0;
  double rx = 0.0, ry = 0.0, rz = 0.0;
  double vrx = 0.0, vry = 0.0, vrz = 0.0;
  bool isExploding = false;
  double explodeTimer = 0.0;
  List<_ClusterCubelet> cubelets;

  _CubeCluster(this.x, this.y) : cubelets = [] {
    vx = (Random().nextDouble() - 0.5) * 0.03;
    vy = (Random().nextDouble() - 0.5) * 0.03;
    rx = Random().nextDouble() * pi * 2;
    ry = Random().nextDouble() * pi * 2;
    rz = Random().nextDouble() * pi * 2;
    vrx = (Random().nextDouble() - 0.5) * 0.3;
    vry = (Random().nextDouble() - 0.5) * 0.4;
    vrz = (Random().nextDouble() - 0.5) * 0.2;

    for (int gx = -1; gx <= 1; gx++) {
      for (int gy = -1; gy <= 1; gy++) {
        for (int gz = -1; gz <= 1; gz++) {
          cubelets.add(_ClusterCubelet(gx: gx, gy: gy, gz: gz));
        }
      }
    }
  }

  void explode() {
    isExploding = true;
    explodeTimer = 0.0;
  }

  bool containsPoint(Offset point, {double radius = 0.1}) {
    return (x - point.dx).abs() < radius && (y - point.dy).abs() < radius;
  }

  void update(
    double dt,
    double speedMultiplier,
    Offset? repelPoint,
    double scrollDrift,
  ) {
    if (isExploding) {
      explodeTimer += dt;
      return;
    }

    if (repelPoint != null) {
      final dx = x - repelPoint.dx;
      final dy = y - repelPoint.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < 0.4 && dist > 0.001) {
        final force = (0.4 - dist) / 0.4 * 0.35;
        vx += (dx / dist) * force;
        vy += (dy / dist) * force;
      }
    }

    vy -= scrollDrift * 5.0;

    const double repZone = 0.08;
    const double repForce = 0.025;
    if (y < repZone) vy += (repZone - y) / repZone * repForce;
    if (y > 1.0 - repZone) vy -= (repZone - (1.0 - y)) / repZone * repForce;
    if (x < repZone) vx += (repZone - x) / repZone * repForce;
    if (x > 1.0 - repZone) vx -= (repZone - (1.0 - x)) / repZone * repForce;

    final speed = sqrt(vx * vx + vy * vy);
    if (speed > 0.15) {
      vx = (vx / speed) * 0.15;
      vy = (vy / speed) * 0.15;
    }

    x += vx * dt * 60 * speedMultiplier;
    y += vy * dt * 60 * speedMultiplier;

    if (x < 0) { x = 0; vx = -vx * 0.5; }
    if (x > 1) { x = 1; vx = -vx * 0.5; }
    if (y < 0) { y = 0; vy = -vy * 0.5; }
    if (y > 1) { y = 1; vy = -vy * 0.5; }

    rx += vrx * dt * 60 * speedMultiplier;
    ry += vry * dt * 60 * speedMultiplier;
    rz += vrz * dt * 60 * speedMultiplier;
  }
}

class _FaceDrawData {
  final double z;
  final double brightness;
  final double opacity;
  final Color? faceColor;
  final double x0, y0, x1, y1, x2, y2, x3, y3;

  _FaceDrawData({
    required this.z,
    required this.brightness,
    required this.opacity,
    this.faceColor,
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

class _OccupiedFace {
  final Path path;
  final Rect bounds;

  _OccupiedFace({required this.path, required this.bounds});
}

class _CubeDrawData {
  final double size;
  final double left, right, top, bottom;
  final List<_FaceDrawData> faces;

  _CubeDrawData({
    required this.size,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.faces,
  });

  bool overlapsWith(_CubeDrawData other) {
    return !(right < other.left ||
        left > other.right ||
        bottom < other.top ||
        top > other.bottom);
  }
}

class _CubePainter extends CustomPainter {
  final List<_Cube> cubes;
  final List<_CubeCluster> clusters;
  final Color baseColor;
  final bool isLightMode;
  final CubeMode cubeMode;

  _CubePainter({
    required this.cubes,
    required this.clusters,
    required this.baseColor,
    this.isLightMode = false,
    this.cubeMode = CubeMode.standard,
  });

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

  Color _interiorColor() =>
      isLightMode ? const Color(0xFF1A1A1A) : const Color(0xFF0A0A0A);

  Color _clusterFaceColor(int faceIndex, int gx, int gy, int gz) {
    final bool isOutside = switch (faceIndex) {
      0 => gz == 1,
      1 => gz == -1,
      2 => gy == 1,
      3 => gy == -1,
      4 => gx == 1,
      5 => gx == -1,
      _ => false,
    };
    if (!isOutside) return _interiorColor();

    switch (faceIndex) {
      case 0: return baseColor;
      case 1: return _adjustBrightness(baseColor, -0.3);
      case 2: return _adjustBrightness(baseColor, 0.35);
      case 3: return _adjustBrightness(baseColor, -0.2);
      case 4: return _adjustBrightness(baseColor, 0.2);
      case 5: return _adjustBrightness(baseColor, -0.15);
      default: return baseColor;
    }
  }

  Color _adjustBrightness(Color c, double amount) {
    final r = (c.r + amount).clamp(0.0, 1.0);
    final g = (c.g + amount).clamp(0.0, 1.0);
    final b = (c.b + amount).clamp(0.0, 1.0);
    return Color.from(alpha: c.a, red: r, green: g, blue: b);
  }

  void _transformPoint(
    double x, double y, double z,
    double cx, double sx, double cy, double sy, double cz, double sz,
    List<double> out,
  ) {
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

    out[0] = x;
    out[1] = y;
    out[2] = z;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final fillPaint = Paint()..style = PaintingStyle.fill;

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

    final allData = <_CubeDrawData>[];

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

      final faceBuffer = <_FaceDrawData>[];
      double minX = double.infinity, maxX = double.negativeInfinity;
      double minY = double.infinity, maxY = double.negativeInfinity;

      for (int i = 0; i < 8; i++) {
        final sx_ = px + tv[i][0];
        final sy_ = py - tv[i][1];
        if (sx_ < minX) minX = sx_;
        if (sx_ > maxX) maxX = sx_;
        if (sy_ < minY) minY = sy_;
        if (sy_ > maxY) maxY = sy_;
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
        faceBuffer.add(
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

      if (faceBuffer.length > 1) {
        faceBuffer.sort((a, b) => a.z.compareTo(b.z));
      }

      allData.add(
        _CubeDrawData(
          size: cube.size,
          left: minX,
          right: maxX,
          top: minY,
          bottom: maxY,
          faces: faceBuffer,
        ),
      );
    }

    if (cubeMode == CubeMode.merge) {
      for (final cluster in clusters) {
        if (cluster.isExploding) continue;

        final cx = cos(cluster.rx), sx = sin(cluster.rx);
        final cy = cos(cluster.ry), sy = sin(cluster.ry);
        final cz = cos(cluster.rz), sz = sin(cluster.rz);

        final h = _CubeCluster.cubeSize * 0.5;
        final spacing = _CubeCluster.spacing;

        final gridOffset = [0.0, 0.0, 0.0];

        for (final cubelet in cluster.cubelets) {
          _transformPoint(
            cubelet.gx * spacing,
            cubelet.gy * spacing,
            cubelet.gz * spacing,
            cx, sx, cy, sy, cz, sz,
            gridOffset,
          );

          final px = cluster.x * size.width + gridOffset[0];
          final py = cluster.y * size.height - gridOffset[1];
          final a = 0.8;

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

          final faceBuffer = <_FaceDrawData>[];
          double minX = double.infinity, maxX = double.negativeInfinity;
          double minY = double.infinity, maxY = double.negativeInfinity;

          for (int i = 0; i < 8; i++) {
            final sx_ = px + tv[i][0];
            final sy_ = py - tv[i][1];
            if (sx_ < minX) minX = sx_;
            if (sx_ > maxX) maxX = sx_;
            if (sy_ < minY) minY = sy_;
            if (sy_ > maxY) maxY = sy_;
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
            faceBuffer.add(
              _FaceDrawData(
                z: sumZ,
                brightness: brightness,
                opacity: a,
                faceColor: _clusterFaceColor(f, cubelet.gx, cubelet.gy, cubelet.gz),
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

          if (faceBuffer.length > 1) {
            faceBuffer.sort((a, b) => a.z.compareTo(b.z));
          }

          allData.add(
            _CubeDrawData(
              size: _CubeCluster.cubeSize,
              left: minX,
              right: maxX,
              top: minY,
              bottom: maxY,
              faces: faceBuffer,
            ),
          );
        }
      }
    }

    allData.sort((a, b) => b.size.compareTo(a.size));

    final occupiedFaces = <_OccupiedFace>[];

    for (final cubeData in allData) {
      final cubeRect = Rect.fromLTRB(
        cubeData.left,
        cubeData.top,
        cubeData.right,
        cubeData.bottom,
      );

      final overlappingPaths = <Path>[];
      for (final occ in occupiedFaces) {
        if (cubeRect.overlaps(occ.bounds)) {
          overlappingPaths.add(occ.path);
        }
      }

      if (overlappingPaths.isEmpty) {
        for (final fd in cubeData.faces) {
          _drawFace(canvas, fd, fillPaint, strokePaint);
        }
      } else {
        final clipPath = Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        for (final fp in overlappingPaths) {
          clipPath.addPath(fp, Offset.zero);
        }
        clipPath.fillType = PathFillType.evenOdd;
        canvas.save();
        canvas.clipPath(clipPath);
        for (final fd in cubeData.faces) {
          _drawFace(canvas, fd, fillPaint, strokePaint);
        }
        canvas.restore();
      }

      for (final fd in cubeData.faces) {
        final path = Path()
          ..moveTo(fd.x0, fd.y0)
          ..lineTo(fd.x1, fd.y1)
          ..lineTo(fd.x2, fd.y2)
          ..lineTo(fd.x3, fd.y3)
          ..close();
        occupiedFaces.add(_OccupiedFace(
          path: path,
          bounds: path.getBounds(),
        ));
      }
    }
  }

  void _drawFace(
    Canvas canvas,
    _FaceDrawData fd,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    final alpha = fd.opacity * fd.brightness;
    final path = Path()
      ..moveTo(fd.x0, fd.y0)
      ..lineTo(fd.x1, fd.y1)
      ..lineTo(fd.x2, fd.y2)
      ..lineTo(fd.x3, fd.y3)
      ..close();

    final faceColor = fd.faceColor ?? baseColor;
    final fillMultiplier = isLightMode ? 0.65 : 0.35;
    final strokeMultiplier = isLightMode ? 0.90 : 0.65;

    if (fd.faceColor != null) {
      fillPaint.color = faceColor.withValues(alpha: alpha * 0.8);
      canvas.drawPath(path, fillPaint);
      strokePaint.color = faceColor.withValues(alpha: alpha * 0.9);
      canvas.drawPath(path, strokePaint);
    } else {
      fillPaint.color = baseColor.withValues(alpha: alpha * fillMultiplier);
      canvas.drawPath(path, fillPaint);
      strokePaint.color = baseColor.withValues(alpha: alpha * strokeMultiplier);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
