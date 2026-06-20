import 'dart:math';
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
  final double speed;
  final bool isActive;
  final FloatingCubeBackgroundController? controller;
  final CubeMode cubeMode;

  const FloatingCubeBackground({
    super.key,
    this.cubeCount = 50,
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
  late List<_MergeEntity> _entities;
  late List<_BaseCubeData> _baseData;
  double _lastValue = 0.0;
  Offset? _repelPoint;
  bool _hasRepelPoint = false;

  void setRepelPoint(Offset? point) {
    _repelPoint = point;
    _hasRepelPoint = point != null;
  }

  void triggerBurst(Offset point) {
    for (final e in _entities) {
      e.applyBurst(point);
    }
  }

  void _generateBaseData() {
    _baseData = List.generate(widget.cubeCount, (_) {
      final size = 6.0 + Random().nextDouble() * 18.0;
      return _BaseCubeData(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        rx: Random().nextDouble() * pi * 2,
        ry: Random().nextDouble() * pi * 2,
        rz: Random().nextDouble() * pi * 2,
        size: size,
      );
    });
  }

  void _resetFromBase() {
    _entities = _baseData.map((d) => _MergeEntity(
      x: d.x + (Random().nextDouble() - 0.5) * 0.05,
      y: d.y + (Random().nextDouble() - 0.5) * 0.05,
      size: d.size,
      targetSize: d.size,
      rx: d.rx,
      ry: d.ry,
      rz: d.rz,
    )).toList();
  }

  @override
  void initState() {
    super.initState();
    _generateBaseData();
    _resetFromBase();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _animController.addListener(_updateEntities);
    if (widget.isActive) _animController.repeat();
    widget.controller?.onRepelUpdate = setRepelPoint;
    widget.controller?.onBurst = triggerBurst;
  }

  void _updateEntities() {
    if (!mounted) return;
    final current = _animController.value;
    double dt = current - _lastValue;
    if (dt < 0) dt += 1.0;
    _lastValue = current;
    final scrollDrift = widget.controller?.scrollDrift ?? 0.0;

    for (final e in _entities) {
      e.update(
        dt,
        widget.speed,
        _hasRepelPoint ? _repelPoint : null,
        scrollDrift,
      );
    }

    if (widget.cubeMode == CubeMode.merge) {
      for (final e in _entities) {
        if (e.mergeCooldown > 0) e.mergeCooldown -= dt;
      }

      for (final e in _entities) {
        e.vx += (Random().nextDouble() - 0.5) * 0.01;
        e.vy += (Random().nextDouble() - 0.5) * 0.01;
      }

      for (final e in _entities) {
        e.renderSize += (e.targetSize - e.renderSize) * dt * 6.0;
      }

      for (int i = 0; i < _entities.length; i++) {
        for (int j = i + 1; j < _entities.length; j++) {
          final a = _entities[i], b = _entities[j];
          if (a.mergeCooldown > 0 || b.mergeCooldown > 0) continue;

          final dx = b.x - a.x;
          final dy = b.y - a.y;
          final distSq = dx * dx + dy * dy;
          if (distSq < 1e-10) continue;

          final sizeRatio = a.renderSize < b.renderSize
              ? a.renderSize / b.renderSize
              : b.renderSize / a.renderSize;
          const attractRange = 0.06;

          if (distSq < attractRange * attractRange) {
            final dist = sqrt(distSq);

            if (sizeRatio > 0.6) {
              final strength = (attractRange - dist) / attractRange * 0.005;
              a.vx += (dx / dist) * strength;
              a.vy += (dy / dist) * strength;
              b.vx -= (dx / dist) * strength;
              b.vy -= (dy / dist) * strength;
            } else {
              final strength = (attractRange - dist) / attractRange * 0.002;
              a.vx -= (dx / dist) * strength;
              a.vy -= (dy / dist) * strength;
              b.vx += (dx / dist) * strength;
              b.vy += (dy / dist) * strength;
            }

            const mergeDist = 0.018;
            if (dist > mergeDist && dist < attractRange) {
              final perpX = -dy / dist;
              final perpY = dx / dist;
              final orbitStrength =
                  (attractRange - dist) / attractRange * 0.001;
              a.vx += perpX * orbitStrength;
              a.vy += perpY * orbitStrength;
              b.vx -= perpX * orbitStrength;
              b.vy -= perpY * orbitStrength;
            }
          }
        }
      }

      final inProximity = <_MergeEntity>{};
      bool anyMerge = true;
      int passes = 0;
      while (anyMerge) {
        anyMerge = false;
        if (++passes > _entities.length) break;
        outer:
        for (int i = _entities.length - 1; i >= 0; i--) {
          for (int j = i - 1; j >= 0; j--) {
            final a = _entities[i], b = _entities[j];
            if (a.mergeCooldown > 0 || b.mergeCooldown > 0) continue;

            final dx = b.x - a.x;
            final dy = b.y - a.y;
            const mergeDist = 0.018;
            if (dx * dx + dy * dy < mergeDist * mergeDist) {
              inProximity.add(a);
              inProximity.add(b);

              if (a.mergeTimer >= 0.5 && b.mergeTimer >= 0.5) {
                final newCount = a.count + b.count;
                final totalMass = newCount;
                final newSize = a.renderSize + b.renderSize;
                _entities.add(_MergeEntity(
                  x: (a.x * a.count + b.x * b.count) / totalMass,
                  y: (a.y * a.count + b.y * b.count) / totalMass,
                  vx: (a.vx * a.count + b.vx * b.count) / totalMass,
                  vy: (a.vy * a.count + b.vy * b.count) / totalMass,
                  rx: (a.rx + b.rx) / 2,
                  ry: (a.ry + b.ry) / 2,
                  rz: (a.rz + b.rz) / 2,
                  count: newCount,
                  size: max(a.renderSize, b.renderSize),
                  targetSize: newSize,
                ));
                _entities.last.mergeCooldown = 1.0;
                _entities.removeAt(i);
                _entities.removeAt(j);
                anyMerge = true;
                break outer;
              }
            }
          }
        }
      }

      for (final e in _entities) {
        if (inProximity.contains(e)) {
          e.mergeTimer += dt;
        } else {
          e.mergeTimer = max(0.0, e.mergeTimer - dt * 3);
        }
      }
    } else if (widget.cubeMode == CubeMode.orbit) {
      for (final e in _entities) {
        if (e.parentCore == null) continue;
        e.orbitAngle += e.orbitSpeed * dt * 60 * widget.speed;
        final cosA = cos(e.orbitAngle);
        final sinA = sin(e.orbitAngle);
        e.x = e.parentCore!.x + e.orbitRadius * cosA;
        e.y = e.parentCore!.y + e.orbitRadius * sinA * cos(e.orbitTilt);
      }

      final cores = <_MergeEntity>[];
      for (final e in _entities) {
        if (e.parentCore == null && e.renderSize > 12.0) {
          cores.add(e);
        }
      }

      for (final core in cores) {
        for (final e in _entities) {
          if (identical(e, core)) continue;
          if (e.parentCore != null) continue;
          final dx = core.x - e.x;
          final dy = core.y - e.y;
          if (dx.abs() > 0.25 || dy.abs() > 0.25) continue;
          final distSq = dx * dx + dy * dy;
          if (distSq > 0.0625 || distSq < 1e-10) continue;
          final dist = sqrt(distSq);
          final force = 0.0005 / (dist + 0.01);
          e.vx += (dx / dist) * force;
          e.vy += (dy / dist) * force;
        }
      }

      for (final core in cores) {
        if (core.orbiterCount >= 12) continue;
        final captureRadius = 0.06 + core.renderSize * 0.006;
        for (final e in _entities) {
          if (identical(e, core)) continue;
          if (e.parentCore != null) continue;
          if (e.renderSize >= core.renderSize * 0.7) continue;
          final dx = e.x - core.x;
          final dy = e.y - core.y;
          if (dx.abs() > captureRadius || dy.abs() > captureRadius) continue;
          if (dx * dx + dy * dy > captureRadius * captureRadius) continue;
          final dist = sqrt(dx * dx + dy * dy);
          if (dist < 1e-10) continue;
          e.parentCore = core;
          core.orbiterCount++;
          e.orbitRadius = max(dist, 0.04);
          e.orbitAngle = atan2(dy, dx);
          e.orbitSpeed =
              (0.5 + Random().nextDouble() * 2.5) / (0.3 + e.orbitRadius * 4);
          e.orbitTilt = (Random().nextDouble() - 0.5) * 0.6;
          core.count += e.count;
        }
      }

      for (int i = 0; i < cores.length; i++) {
        for (int j = i + 1; j < cores.length; j++) {
          final a = cores[i], b = cores[j];
          final sizeRatio = a.renderSize < b.renderSize
              ? a.renderSize / b.renderSize
              : b.renderSize / a.renderSize;
          final dx = b.x - a.x;
          final dy = b.y - a.y;
          if (dx.abs() > 0.15 || dy.abs() > 0.15) continue;
          final distSq = dx * dx + dy * dy;
          if (distSq > 0.0225) continue;

          if (sizeRatio < 0.4) {
            final smaller = a.renderSize < b.renderSize ? a : b;
            final larger = a.renderSize < b.renderSize ? b : a;
            if (smaller.parentCore != null) continue;
            if (larger.orbiterCount >= 12) continue;
            final dist = sqrt(distSq);
            smaller.parentCore = larger;
            larger.orbiterCount++;
            smaller.orbitRadius = max(dist, 0.04);
            smaller.orbitAngle = atan2(dy, dx);
            smaller.orbitSpeed =
                (0.5 + Random().nextDouble() * 2.5) / (0.3 + smaller.orbitRadius * 4);
            smaller.orbitTilt = (Random().nextDouble() - 0.5) * 0.6;
            larger.count += smaller.count;
          } else {
            final dist = sqrt(distSq);
            if (dist < 1e-8) continue;
            final force = (0.15 - dist) / 0.15 * 0.03;
            a.vx -= (dx / dist) * force;
            a.vy -= (dy / dist) * force;
            b.vx += (dx / dist) * force;
            b.vy += (dy / dist) * force;
          }
        }
      }

      for (final e in _entities) {
        if (e.parentCore == null) continue;
        final core = e.parentCore!;
        if (core.orbiterCount == 0) {
          e.parentCore = null;
          continue;
        }
        final speed = sqrt(core.vx * core.vx + core.vy * core.vy);
        if (speed > 0.3 && e.orbitRadius > 0.12) {
          e.parentCore = null;
          core.orbiterCount--;
          e.vx = (Random().nextDouble() - 0.5) * 0.08;
          e.vy = (Random().nextDouble() - 0.5) * 0.08;
        }
      }

      for (final core in cores) {
        core.vx *= 0.99;
        core.vy *= 0.99;
      }

      for (final core in cores) {
        for (final e in _entities) {
          if (identical(e, core)) continue;
          if (e.parentCore != null) continue;
          final dx = e.x - core.x;
          final dy = e.y - core.y;
          if (dx.abs() > 0.03 || dy.abs() > 0.03) continue;
          final distSq = dx * dx + dy * dy;
          if (distSq > 0.0009 || distSq < 1e-8) continue;
          final dist = sqrt(distSq);
          final force = (0.03 - dist) / 0.03 * 0.015;
          e.vx += (dx / dist) * force;
          e.vy += (dy / dist) * force;
        }
      }
    } else {
      for (int i = 0; i < _entities.length; i++) {
        for (int j = i + 1; j < _entities.length; j++) {
          _entities[i].applyRepulsionFrom(_entities[j]);
        }
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
    if (widget.cubeCount != oldWidget.cubeCount) {
      if (widget.cubeCount > _baseData.length) {
        for (int i = _baseData.length; i < widget.cubeCount; i++) {
          final size = 6.0 + Random().nextDouble() * 18.0;
          _baseData.add(_BaseCubeData(
            x: Random().nextDouble(),
            y: Random().nextDouble(),
            rx: Random().nextDouble() * pi * 2,
            ry: Random().nextDouble() * pi * 2,
            rz: Random().nextDouble() * pi * 2,
            size: size,
          ));
        }
      }
      _resetFromBase();
    }
    if (oldWidget.cubeMode != widget.cubeMode) {
      _resetFromBase();
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_updateEntities);
    _animController.dispose();
    widget.controller?.onRepelUpdate = null;
    widget.controller?.onBurst = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _CubePainter(
              entities: _entities,
              brightness: brightness,
            ),
          );
        },
      ),
    );
  }
}

class _BaseCubeData {
  final double x, y;
  final double rx, ry, rz;
  final double size;

  _BaseCubeData({
    required this.x,
    required this.y,
    required this.rx,
    required this.ry,
    required this.rz,
    required this.size,
  });
}

class _MergeEntity {
  double x, y;
  int count;
  double vx, vy;
  final double _baseVx, _baseVy;
  double rx, ry, rz;
  double vrx, vry, vrz;
  double renderSize;
  double targetSize;
  double mergeTimer = 0.0;
  double mergeCooldown = 0.0;
  double _timeSinceLastChange = 0.0;

  _MergeEntity? parentCore;
  double orbitRadius = 0.0;
  double orbitAngle = 0.0;
  double orbitSpeed = 0.0;
  double orbitTilt = 0.0;
  int orbiterCount = 0;

  _MergeEntity({
    double? x,
    double? y,
    double? vx,
    double? vy,
    int count = 1,
    double? rx,
    double? ry,
    double? rz,
    double? size,
    double? targetSize,
  }) : x = x ?? Random().nextDouble(),
       y = y ?? Random().nextDouble(),
       count = count,
       vx = vx ?? (Random().nextDouble() - 0.5) * 0.05,
       vy = vy ?? (Random().nextDouble() - 0.5) * 0.05,
       _baseVx = vx ?? (Random().nextDouble() - 0.5) * 0.05,
       _baseVy = vy ?? (Random().nextDouble() - 0.5) * 0.05,
       rx = rx ?? Random().nextDouble() * pi * 2,
       ry = ry ?? Random().nextDouble() * pi * 2,
       rz = rz ?? Random().nextDouble() * pi * 2,
       vrx = (Random().nextDouble() - 0.5) * 1.5,
       vry = (Random().nextDouble() - 0.5) * 2.5,
       vrz = (Random().nextDouble() - 0.5) * 0.8,
       renderSize = size ?? (6.0 + Random().nextDouble() * 18.0),
       targetSize = targetSize ?? size ?? (6.0 + Random().nextDouble() * 18.0);

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

    const double repZone = 0.1;
    const double repForce = 0.04;
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

  void applyRepulsionFrom(_MergeEntity other) {
    if (identical(this, other)) return;
    final sizeRatio = renderSize < other.renderSize
        ? renderSize / other.renderSize
        : other.renderSize / renderSize;
    if (sizeRatio < 0.5) return;

    final dx = x - other.x;
    final dy = y - other.y;
    if (dx.abs() > 0.06 || dy.abs() > 0.06) return;

    final distSq = dx * dx + dy * dy;
    if (distSq > 0.0036 || distSq < 1e-8) return;

    final dist = sqrt(distSq);
    final force = (0.06 - dist) / 0.06 * 0.04;
    vx += (dx / dist) * force;
    vy += (dy / dist) * force;
  }
}

class _FaceDrawData {
  final double z;
  final double brightness;
  final double x0, y0, x1, y1, x2, y2, x3, y3;

  _FaceDrawData({
    required this.z,
    required this.brightness,
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
}

class _CubePainter extends CustomPainter {
  final List<_MergeEntity> entities;
  final Brightness brightness;

  _CubePainter({
    required this.entities,
    required this.brightness,
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

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final cubeColor = brightness == Brightness.light
        ? const Color(0xFFD8D8D8)
        : const Color(0xFF505050);

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

    if (entities.isEmpty) return;

    final allData = <_CubeDrawData>[];

    for (final entity in entities) {
      final h = entity.renderSize * 0.5;
      final px = entity.x * size.width;
      final py = entity.y * size.height;

      final cx = cos(entity.rx), sx = sin(entity.rx);
      final cy = cos(entity.ry), sy = sin(entity.ry);
      final cz = cos(entity.rz), sz = sin(entity.rz);

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

      if (faceBuffer.isEmpty) continue;

      if (faceBuffer.length > 1) {
        faceBuffer.sort((a, b) => a.z.compareTo(b.z));
      }

      allData.add(
        _CubeDrawData(
          size: entity.renderSize,
          left: minX,
          right: maxX,
          top: minY,
          bottom: maxY,
          faces: faceBuffer,
        ),
      );
    }

    allData.sort((a, b) => a.size.compareTo(b.size));

    for (final cubeData in allData) {
      if (cubeData.faces.isEmpty) continue;
      for (final fd in cubeData.faces) {
        _drawFace(canvas, fd, fillPaint, strokePaint, cubeColor);
      }
    }
  }

  void _drawFace(
    Canvas canvas,
    _FaceDrawData fd,
    Paint fillPaint,
    Paint strokePaint,
    Color cubeColor,
  ) {
    final path = Path()
      ..moveTo(fd.x0, fd.y0)
      ..lineTo(fd.x1, fd.y1)
      ..lineTo(fd.x2, fd.y2)
      ..lineTo(fd.x3, fd.y3)
      ..close();

    final b = fd.brightness;

    fillPaint.color = Color.from(
      alpha: 1.0,
      red: (cubeColor.r * b).clamp(0.0, 1.0),
      green: (cubeColor.g * b).clamp(0.0, 1.0),
      blue: (cubeColor.b * b).clamp(0.0, 1.0),
    );
    canvas.drawPath(path, fillPaint);

    strokePaint.color = Color.from(
      alpha: 1.0,
      red: (cubeColor.r * b * 0.7).clamp(0.0, 1.0),
      green: (cubeColor.g * b * 0.7).clamp(0.0, 1.0),
      blue: (cubeColor.b * b * 0.7).clamp(0.0, 1.0),
    );
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
