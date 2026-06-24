// ══════════════════════════════════════════════════════════════════════════════
// AI DOCUMENTATION DIRECTIVE
//
// This file implements a V2 3-mode 3D cube particle system (Standard, Merge, Orbit)
// with Spatial Hashing, Isolate offloading, Adaptive Rendering, Trail Particles,
// Burst Dust, and mouse hover repulsion.
//
// BEFORE EDITING this file, an AI model MUST read and understand the complete
// rules, constants, and behavioral contracts in:
//
//   docs/ai/FLOATING_CUBE_BACKGROUND.md
//
// RULE UPDATE PROTOCOL:
// If the edit introduces or changes any behavioral rule, constant value, mode
// transition logic, entity lifecycle, or physics parameter, the AI MUST first
// update docs/ai/FLOATING_CUBE_BACKGROUND.md to reflect the new behavior, then
// proceed with the code change. Both files must remain in sync.
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';
import 'core/cube_geometry.dart' as cg;

// ─────────────────────────────────────────────────────────────────────────────
// PERFORMANCE & QUALITY
// ─────────────────────────────────────────────────────────────────────────────

enum _QualityMode { high, low }

class _AdaptiveQuality {
  _QualityMode mode = _QualityMode.high;
  int _slowFrameCount = 0;

  void update(double dt) {
    if (dt > 0.033) {
      _slowFrameCount++;
      if (_slowFrameCount >= 15) mode = _QualityMode.low;
    } else {
      _slowFrameCount = 0;
      mode = _QualityMode.high;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPATIAL HASH GRID  (O(n) collision detection via 11×11 cell grid)
// ─────────────────────────────────────────────────────────────────────────────

class _SpatialHashGrid {
  static const int _gridSize = 11;
  static const int _totalCells = _gridSize * _gridSize;
  static const double _cellSize = 0.1;

  final List<List<int>> _cells;
  final List<bool> _occupied;

  _SpatialHashGrid()
    : _cells = List.generate(_totalCells, (_) => <int>[]),
      _occupied = List.filled(_totalCells, false);

  void clear() {
    for (int i = 0; i < _totalCells; i++) {
      if (_occupied[i]) {
        _cells[i].clear();
        _occupied[i] = false;
      }
    }
  }

  void insert(int index, double x, double y) {
    final cx = (x / _cellSize).floor().clamp(0, _gridSize - 1);
    final cy = (y / _cellSize).floor().clamp(0, _gridSize - 1);
    final key = cy * _gridSize + cx;
    _cells[key].add(index);
    _occupied[key] = true;
  }

  void queryNeighbors(double x, double y, List<int> out) {
    final cx = (x / _cellSize).floor().clamp(0, _gridSize - 1);
    final cy = (y / _cellSize).floor().clamp(0, _gridSize - 1);
    out.clear();

    final int startX = cx > 0 ? cx - 1 : 0;
    final int endX = cx < _gridSize - 1 ? cx + 1 : _gridSize - 1;
    final int startY = cy > 0 ? cy - 1 : 0;
    final int endY = cy < _gridSize - 1 ? cy + 1 : _gridSize - 1;

    for (int row = startY; row <= endY; row++) {
      for (int col = startX; col <= endX; col++) {
        final key = row * _gridSize + col;
        if (_occupied[key]) {
          out.addAll(_cells[key]);
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRAIL PARTICLES (Ring Buffer — no GC allocations per frame)
// ─────────────────────────────────────────────────────────────────────────────

class _TrailParticle {
  double x = 0;
  double y = 0;
  double size = 0;
  double opacity = 0;
  double vx = 0;
  double vy = 0;
}

const int _kTrailPoolSize = 500;

class _TrailPool {
  final List<_TrailParticle> particles;
  int _writeIndex = 0;

  _TrailPool()
    : particles = List.generate(_kTrailPoolSize, (_) => _TrailParticle());

  void spawn(double x, double y, double size) {
    final p = particles[_writeIndex % _kTrailPoolSize];
    p.x = x;
    p.y = y;
    final s = (size / 12.0).clamp(0.3, 2.5);
    p.size = (0.5 + Random().nextDouble() * 0.7) * s;
    p.opacity = 0.5 + Random().nextDouble() * 0.3;
    p.vx = 0;
    p.vy = 0;
    _writeIndex = (_writeIndex + 1) % _kTrailPoolSize;
  }

  void spawnBurst(
    double x,
    double y,
    int count, {
    double spread = 0.05,
    double entitySize = 12.0,
  }) {
    for (int i = 0; i < count; i++) {
      final theta = Random().nextDouble() * 2 * pi;
      final phi = acos(2 * Random().nextDouble() - 1);
      final r = spread * (pow(Random().nextDouble(), 1.0 / 3.0) as double);
      final dx = r * sin(phi) * cos(theta);
      final dy = r * sin(phi) * sin(theta);
      final dz = r * cos(phi);

      final p = particles[_writeIndex % _kTrailPoolSize];
      p.x = x + dx;
      p.y = y + dy;

      final dist = max(sqrt(dx * dx + dy * dy + dz * dz), 0.001);
      final speed = (0.8 + Random().nextDouble() * 1.5) * (dist / spread);
      p.vx = (dx / dist) * speed + (Random().nextDouble() - 0.5) * 0.002;
      p.vy = (dy / dist) * speed + (Random().nextDouble() - 0.5) * 0.002;

      final zFactor = dz / spread;
      final scale = (entitySize / 12.0).clamp(0.3, 2.5);
      p.size = ((2.5 + Random().nextDouble() * 3.5) + zFactor * 1.5) * scale;
      p.opacity = (0.5 + Random().nextDouble() * 0.3) + zFactor * 0.25;
      _writeIndex = (_writeIndex + 1) % _kTrailPoolSize;
    }
  }

  void update(double dt) {
    final realDt = _realSec(dt);
    for (int i = 0; i < _kTrailPoolSize; i++) {
      final p = particles[i];
      if (p.opacity <= 0) continue;

      p.x += p.vx * realDt;
      p.y += p.vy * realDt;

      p.vx *= pow(0.96, realDt) as double;
      p.vy *= pow(0.96, realDt) as double;

      if (p.vx != 0 || p.vy != 0) {
        p.size -= realDt * 0.12;
        if (p.size < 0) p.size = 0;
      }

      p.opacity -= realDt * 0.02;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ISOLATE / WEBWORKER OFFLOADING
// ─────────────────────────────────────────────────────────────────────────────

class _PhysicsPayload {
  final Float64List positions;
  final Float64List sizes;
  final int entityCount;
  final int mode;

  _PhysicsPayload({
    required this.positions,
    required this.sizes,
    required this.entityCount,
    required this.mode,
  });
}

class _PhysicsResult {
  final Float64List forceDeltas;

  _PhysicsResult({required this.forceDeltas});
}

@pragma('vm:isolate-untagged')
_PhysicsResult _physicsWorker(_PhysicsPayload p) {
  final forces = Float64List(p.entityCount * 2);
  final n = p.entityCount;

  if (p.mode == 0 || p.mode == 1) {
    for (int i = 0; i < n; i++) {
      final ix = p.positions[i * 2];
      final iy = p.positions[i * 2 + 1];
      final isz = p.sizes[i];

      for (int j = i + 1; j < n; j++) {
        final jx = p.positions[j * 2];
        final jy = p.positions[j * 2 + 1];
        final jsz = p.sizes[j];

        final sizeRatio = isz < jsz ? isz / jsz : jsz / isz;
        if (sizeRatio < 0.5) continue;

        final dx = ix - jx;
        final dy = iy - jy;
        if (dx.abs() > 0.06 || dy.abs() > 0.06) continue;

        final distSq = dx * dx + dy * dy;
        if (distSq > 0.0036 || distSq < 1e-8) continue;

        final dist = sqrt(distSq);
        final force = (0.06 - dist) / 0.06 * 0.04;
        final fx = (dx / dist) * force;
        double fy = (dy / dist) * force;

        if (p.mode == 1 && iy > 0.8 && jy > 0.8) {
          fy *=
              0.02; // Severely damp vertical repulsion near floor to prevent popcorn effect
        }

        forces[i * 2] += fx;
        forces[i * 2 + 1] += fy;
        forces[j * 2] -= fx;
        forces[j * 2 + 1] -= fy;
      }
    }
  }

  return _PhysicsResult(forceDeltas: forces);
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────

class FloatingCubeBackgroundController {
  void Function(Offset?)? onRepelUpdate;
  void Function(Offset)? onBurst;
  void Function(Offset)? onLogoBurst;
  void Function()? onGatherIntoLogo;
  bool Function(Offset)? onTrySplit;
  double scrollDrift = 0.0;
  final ValueNotifier<int> cubeCount = ValueNotifier<int>(0);

  void gatherIntoLogo() {
    onGatherIntoLogo?.call();
  }

  void repelAt(Offset? normalizedPosition) {
    onRepelUpdate?.call(normalizedPosition);
  }

  void burstAt(Offset normalizedPosition) {
    onBurst?.call(normalizedPosition);
  }

  void triggerLogoBurst(Offset normalizedPosition) {
    onLogoBurst?.call(normalizedPosition);
  }

  bool trySplit(Offset normalizedPosition) {
    return onTrySplit?.call(normalizedPosition) ?? false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class FloatingCubeBackground extends StatefulWidget {
  final int cubeCount;
  final double speed;
  final bool isActive;
  final FloatingCubeBackgroundController? controller;
  final CubeMode cubeMode;
  final double topExclusion;
  final bool initialPreBurst;

  const FloatingCubeBackground({
    super.key,
    this.cubeCount = 50,
    this.speed = 1.0,
    this.isActive = true,
    this.controller,
    this.cubeMode = CubeMode.standard,
    this.topExclusion = 0.0,
    this.initialPreBurst = true,
  });

  @override
  State<FloatingCubeBackground> createState() => _FloatingCubeBackgroundState();
}

/// Convert AnimationController `dt` (fraction of 60s) to real seconds.
/// The background's `AnimationController` runs 0→1 over 60 seconds,
/// so `dt * 60` gives the actual elapsed time in seconds.
double _realSec(double dt) => dt * 60;

class _FloatingCubeBackgroundState extends State<FloatingCubeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_MergeEntity> _entities;
  late List<_BaseCubeData> _baseData;
  double _lastValue = 0.0;
  Offset? _repelPoint;
  bool _hasRepelPoint = false;
  Size _screenSize = const Size(800, 800);
  late bool _isPreBurst;
  bool _isGathering = false;

  // V2 features
  final _spatialHash = _SpatialHashGrid();
  final _trailPool = _TrailPool();
  final _adaptiveQuality = _AdaptiveQuality();
  final _neighborScratch = <int>[];
  Future<void>? _isolateFuture;

  // ── Controller wiring ─────────────────────────────────────────────────

  void setRepelPoint(Offset? point) {
    _repelPoint = point;
    _hasRepelPoint = point != null;
  }

  void triggerBurst(Offset point) {
    final bool isGravity = widget.cubeMode == CubeMode.gravity;
    for (final e in _entities) {
      e.applyBurst(point, isGravity: isGravity);
      final dx = e.x - point.dx;
      final dy = e.y - point.dy;
      final d = sqrt(dx * dx + dy * dy);
      if (d < 0.001) continue;
      if (isGravity) {
        final sizeFactor = (e.renderSize / 12.0).clamp(0.3, 3.0);
        if (d < 0.8) {
          // Massive upward shockwave impulse based on size and distance
          final force = (0.8 - d) / 0.8 * 2.5 * (1.0 / sizeFactor);
          e.vx += (dx / d) * force;
          e.vy -= force * 1.5; // Always push strongly upwards against gravity
        }
      } else if (d < 0.35) {
        final extraForce = (0.35 - d) / 0.35 * 0.4;
        e.vx += (dx / d) * extraForce;
        e.vy += (dy / d) * extraForce;
      }
    }
  }

  void _triggerLogoBurst(Offset center) {
    _isPreBurst = false;
    for (int i = 0; i < _entities.length; i++) {
      final e = _entities[i];
      final d = _baseData[e.baseIndices.first];

      // Restore original base sizes
      e.targetSize = d.size;

      // Unhide the core cubes by restoring their size and giving them a tiny random offset
      if (i >= 27) {
        final angle = Random().nextDouble() * 2 * pi;
        final radius = Random().nextDouble() * 0.005;
        e.x = center.dx + cos(angle) * radius;
        e.y = center.dy + sin(angle) * radius;
        e.renderSize = d.size;
      }

      // Calculate vector from center to their CURRENT position
      double dx = e.x - center.dx;
      double dy = e.y - center.dy;
      double dist = sqrt(dx * dx + dy * dy);

      // Failsafe for perfectly centered elements
      if (dist < 0.001) {
        final angle = Random().nextDouble() * 2 * pi;
        dx = cos(angle) * 0.01;
        dy = sin(angle) * 0.01;
        dist = 0.01;
      }

      // Massive explosive physical force outward
      final force = 0.8 + Random().nextDouble() * 0.8;
      e.vx = (dx / dist) * force + (Random().nextDouble() - 0.5) * 0.05;
      e.vy = (dy / dist) * force + (Random().nextDouble() - 0.5) * 0.05;

      // Note: We DO NOT randomize e.rx, e.ry, e.rz here.
      // The massive vx/vy velocities will naturally spin them out of their
      // isometric Rubik's cube alignment in the physics loop.
    }
    // Spawn a massive flash particle effect
    _trailPool.spawnBurst(
      center.dx,
      center.dy,
      150,
      spread: 0.15,
      entitySize: 40.0,
    );
  }

  bool _trySplitAt(Offset normalizedPoint) {
    final sorted = List<_MergeEntity>.from(_entities)
      ..sort((a, b) => b.renderSize.compareTo(a.renderSize));
    for (final e in sorted) {
      if (e.splitLeft == null || e.splitRight == null) continue;
      // Hit area needs to cover the 3D rotated corners (sqrt(3) * halfSize) + fat finger tolerance
      final hitboxRadius = e.renderSize * 1.2;
      final cx = e.x * _screenSize.width;
      final cy = e.y * _screenSize.height;
      final nx = normalizedPoint.dx * _screenSize.width;
      final ny = normalizedPoint.dy * _screenSize.height;

      final dx = nx - cx;
      final dy = ny - cy;
      if (dx * dx + dy * dy <= hitboxRadius * hitboxRadius) {
        _splitEntity(e);
        return true;
      }
    }
    return false;
  }

  void _splitEntity(_MergeEntity source) {
    final leftIndices = source.splitLeft!;
    final rightIndices = source.splitRight!;
    final leftSize = leftIndices.fold(
      0.0,
      (sum, idx) => sum + _baseData[idx].size,
    );
    final rightSize = rightIndices.fold(
      0.0,
      (sum, idx) => sum + _baseData[idx].size,
    );
    final topExclusion = widget.topExclusion;

    if (source.spiralPartner != null) {
      final partner = source.spiralPartner!;
      partner.spiralPartner = null;
      partner.mergeCooldown = 2.0;
      partner.vx += (Random().nextDouble() - 0.5) * 0.1;
      partner.vy += (Random().nextDouble() - 0.5) * 0.1;
      source.spiralPartner = null;
    }

    final leftEntity = _MergeEntity(
      x: (source.x + (Random().nextDouble() - 0.5) * 0.03).clamp(0.0, 1.0),
      y: (source.y + (Random().nextDouble() - 0.5) * 0.03).clamp(
        topExclusion,
        1.0,
      ),
      vx: source.vx + (Random().nextDouble() - 0.5) * 0.02,
      vy: source.vy + (Random().nextDouble() - 0.5) * 0.02,
      count: leftIndices.length,
      size: leftSize,
      targetSize: leftSize,
      rx: source.rx + (Random().nextDouble() - 0.5) * 0.5,
      ry: source.ry + (Random().nextDouble() - 0.5) * 0.5,
      rz: source.rz + (Random().nextDouble() - 0.5) * 0.5,
      baseIndices: leftIndices,
    );
    leftEntity.splitLeft = source.splitLeftLeft;
    leftEntity.splitRight = source.splitLeftRight;

    final rightEntity = _MergeEntity(
      x: (source.x + (Random().nextDouble() - 0.5) * 0.03).clamp(0.0, 1.0),
      y: (source.y + (Random().nextDouble() - 0.5) * 0.03).clamp(
        topExclusion,
        1.0,
      ),
      vx: source.vx + (Random().nextDouble() - 0.5) * 0.02,
      vy: source.vy + (Random().nextDouble() - 0.5) * 0.02,
      count: rightIndices.length,
      size: rightSize,
      targetSize: rightSize,
      rx: source.rx + (Random().nextDouble() - 0.5) * 0.5,
      ry: source.ry + (Random().nextDouble() - 0.5) * 0.5,
      rz: source.rz + (Random().nextDouble() - 0.5) * 0.5,
      baseIndices: rightIndices,
    );
    rightEntity.splitLeft = source.splitRightLeft;
    rightEntity.splitRight = source.splitRightRight;

    leftEntity.mergeCooldown = 2.0;
    rightEntity.mergeCooldown = 2.0;

    leftEntity.ignoreRepelTimer = 1.0;
    rightEntity.ignoreRepelTimer = 1.0;

    final dx = rightEntity.x - leftEntity.x;
    final dy = rightEntity.y - leftEntity.y;
    final dist = max(sqrt(dx * dx + dy * dy), 0.001);
    final pushForce = 0.3;
    leftEntity.vx -= (dx / dist) * pushForce;
    leftEntity.vy -= (dy / dist) * pushForce;
    rightEntity.vx += (dx / dist) * pushForce;
    rightEntity.vy += (dy / dist) * pushForce;

    _trailPool.spawnBurst(
      source.x,
      source.y,
      40,
      spread: 0.06,
      entitySize: source.renderSize,
    );

    final idx = _entities.indexOf(source);
    if (idx >= 0) {
      _entities.removeAt(idx);
      _entities.add(leftEntity);
      _entities.add(rightEntity);
    }
  }

  // ── Lifecycle helpers ─────────────────────────────────────────────────

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

  void _initFromBase() {
    _entities = List.generate(_baseData.length, (i) {
      final d = _baseData[i];
      return _MergeEntity(
        x: _isPreBurst ? 0.5 : Random().nextDouble(),
        y: _isPreBurst ? 0.5 : Random().nextDouble(),
        size: d.size,
        targetSize: d.size,
        rx: _isPreBurst ? pi / 4 : d.rx,
        ry: _isPreBurst ? pi / 4 : d.ry,
        rz: _isPreBurst ? 0.0 : d.rz,
        vx: _isPreBurst ? 0.0 : null,
        vy: _isPreBurst ? 0.0 : null,
        baseIndices: [i],
      );
    });
  }

  void _splitMergedEntities() {
    final topExclusion = widget.topExclusion;
    final newEntities = <_MergeEntity>[];
    for (final e in _entities) {
      e.spiralPartner = null;
      if (e.count > 1) {
        for (final idx in e.baseIndices) {
          final base = _baseData[idx];
          newEntities.add(
            _MergeEntity(
              x: (e.x + (Random().nextDouble() - 0.5) * 0.05).clamp(0.0, 1.0),
              y: (e.y + (Random().nextDouble() - 0.5) * 0.05).clamp(
                topExclusion,
                1.0,
              ),
              vx: e.vx + (Random().nextDouble() - 0.5) * 0.02,
              vy: e.vy + (Random().nextDouble() - 0.5) * 0.02,
              size: base.size,
              targetSize: base.size,
              rx: base.rx,
              ry: base.ry,
              rz: base.rz,
              baseIndices: [idx],
            ),
          );
        }
      } else {
        newEntities.add(e);
      }
    }
    _entities = newEntities;
  }

  void _freeOrbiters() {
    for (final e in _entities) {
      if (e.parentCore != null) {
        e.parentCore!.orbiterCount--;
        e.parentCore = null;
      }
    }
  }

  void _resetMergeState() {
    for (final e in _entities) {
      e.mergeTimer = 0.0;
      e.mergeCooldown = 0.0;
      e.spiralPartner = null;
    }
  }

  // ── Isolate offloading ────────────────────────────────────────────────

  void _tryRunIsolate() {
    if (_isolateFuture != null) return;
    final n = _entities.length;
    if (n < 50) return;

    final positions = Float64List(n * 2);
    final sizes = Float64List(n);
    for (int i = 0; i < n; i++) {
      final e = _entities[i];
      positions[i * 2] = e.x;
      positions[i * 2 + 1] = e.y;
      sizes[i] = e.renderSize;
    }

    final payload = _PhysicsPayload(
      positions: positions,
      sizes: sizes,
      entityCount: n,
      mode: widget.cubeMode == CubeMode.gravity ? 1 : 0,
    );

    _isolateFuture = compute(_physicsWorker, payload).then((result) {
      if (!mounted) return;
      final clampedN = min(result.forceDeltas.length ~/ 2, _entities.length);
      for (int i = 0; i < clampedN; i++) {
        _entities[i].vx += result.forceDeltas[i * 2];
        _entities[i].vy += result.forceDeltas[i * 2 + 1];
      }
      _isolateFuture = null;
    });
  }

  // ── Isolate offloading ────────────────────────────────────────────────

  // ── Init / Update ─────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _isPreBurst = widget.initialPreBurst;
    _generateBaseData();
    _initFromBase();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _animController.addListener(_updateEntities);
    if (widget.isActive) _animController.repeat();
    widget.controller?.onRepelUpdate = setRepelPoint;
    widget.controller?.onBurst = triggerBurst;
    widget.controller?.onLogoBurst = _triggerLogoBurst;
    widget.controller?.onGatherIntoLogo = _startGatherIntoLogo;
    widget.controller?.onTrySplit = _trySplitAt;
  }

  void _startGatherIntoLogo() {
    _isGathering = true;
    _isPreBurst = false;
  }

  void _updateEntities() {
    if (!mounted) return;
    final current = _animController.value;
    double dt = current - _lastValue;
    if (dt < 0) dt += 1.0;
    _lastValue = current;
    final scrollDrift = (widget.controller?.scrollDrift ?? 0.0).clamp(-0.08, 0.08);

    // ── Adaptive quality tracking ──
    _adaptiveQuality.update(dt);
    final bool lowQuality = _adaptiveQuality.mode == _QualityMode.low;

    // ── Cube count notifier ──
    if (widget.controller != null &&
        widget.controller!.cubeCount.value != _entities.length) {
      widget.controller!.cubeCount.value = _entities.length;
    }

    final topExclusion = widget.topExclusion;

    if (_isGathering) {
      final double gap = 24.0;
      final double rx = 0.85;
      final double ry = pi / 4;
      final double rz = 0.5003747769;
      final double cx = cos(rx), sx = sin(rx);
      final double cy = cos(ry), sy = sin(ry);
      final double cz = cos(rz), sz = sin(rz);

      bool allArrived = true;

      for (int i = 0; i < _entities.length; i++) {
        final e = _entities[i];
        if (i < 27) {
          int ix = (i % 3) - 1;
          int iy = ((i ~/ 3) % 3) - 1;
          int iz = (i ~/ 9) - 1;

          double X = ix * gap;
          double Y = iy * gap;
          double Z = iz * gap;

          double y1 = Y * cx - Z * sx;
          double z1 = Y * sx + Z * cx;
          Y = y1;
          Z = z1;

          double x1 = X * cy + Z * sy;
          double z2 = -X * sy + Z * cy;
          X = x1;
          Z = z2;

          double x2 = X * cz - Y * sz;
          double y2 = X * sz + Y * cz;
          X = x2;
          Y = y2;
          
          e.depth = Z;

          double targetX = 0.5 + X / _screenSize.width;
          double targetY = 0.5 - Y / _screenSize.height;

          double dx = targetX - e.x;
          double dy = targetY - e.y;

          // Easing
          e.x += dx * 0.06;
          e.y += dy * 0.06;

          // Dampen physical velocity
          e.vx *= 0.8;
          e.vy *= 0.8;

          // Ease rotation to match isometric projection
          // We must handle angle wrapping for smooth rotation
          double drx = (rx - e.rx) % (2 * pi);
          if (drx > pi)
            drx -= 2 * pi;
          else if (drx < -pi)
            drx += 2 * pi;
          e.rx += drx * 0.06;

          double dry = (ry - e.ry) % (2 * pi);
          if (dry > pi)
            dry -= 2 * pi;
          else if (dry < -pi)
            dry += 2 * pi;
          e.ry += dry * 0.06;

          double drz = (rz - e.rz) % (2 * pi);
          if (drz > pi)
            drz -= 2 * pi;
          else if (drz < -pi)
            drz += 2 * pi;
          e.rz += drz * 0.06;

          e.targetSize = 19.0;
          e.renderSize += (19.0 - e.renderSize) * 0.08;

          if (dx.abs() > 0.005 ||
              dy.abs() > 0.005 ||
              drx.abs() > 0.1 ||
              (19.0 - e.renderSize).abs() > 1.0) {
            allArrived = false;
          }
        } else {
          // Surplus cubes go to center and vanish
          double dx = 0.5 - e.x;
          double dy = 0.5 - e.y;
          e.x += dx * 0.06;
          e.y += dy * 0.06;
          e.targetSize = 0.0;
          e.renderSize += (0.0 - e.renderSize) * 0.1;
          if (e.renderSize > 1.0) {
            allArrived = false;
          }
        }
      }

      if (allArrived) {
        _isGathering = false;
        _isPreBurst = true;
      }
      return; // Skip normal physics while gathering
    }

    // ── Entity update (repulsion + physics) ──
    if (_isPreBurst) {
      final double gap = 24.0; // Spacing between cubes
      final double rx = 0.85; // CornerAxis tilt (matches new brand logo)
      final double ry = pi / 4; // Isometric 45 deg turn
      final double rz = 0.5003747769; // Makes it rest on a single corner

      final double cx = cos(rx), sx = sin(rx);
      final double cy = cos(ry), sy = sin(ry);
      final double cz = cos(rz), sz = sin(rz);

      for (int i = 0; i < _entities.length; i++) {
        final e = _entities[i];
        if (i < 27) {
          // Construct a 3x3x3 grid
          int ix = (i % 3) - 1;
          int iy = ((i ~/ 3) % 3) - 1;
          int iz = (i ~/ 9) - 1;

          double X = ix * gap;
          double Y = iy * gap;
          double Z = iz * gap;

          // Rotate around X
          double y1 = Y * cx - Z * sx;
          double z1 = Y * sx + Z * cx;
          Y = y1;
          Z = z1;

          // Rotate around Y
          double x1 = X * cy + Z * sy;
          double z2 = -X * sy + Z * cy;
          X = x1;
          Z = z2;

          // Rotate around Z
          double x2 = X * cz - Y * sz;
          double y2 = X * sz + Y * cz;
          X = x2;
          Y = y2;
          
          e.depth = Z;

          // Map to 2D screen delta
          double dx = X;
          double dy = -Y;

          e.x = 0.5 + dx / _screenSize.width;
          e.y = 0.5 + dy / _screenSize.height;
          e.rx = rx;
          e.ry = ry;
          e.rz = rz;
          e.renderSize = 19.0;
          e.targetSize = 19.0;
        } else {
          // Hide surplus cubes at the core
          e.x = 0.5;
          e.y = 0.5;
          e.renderSize = 0.0;
          e.targetSize = 0.0;
        }
        e.vx = 0;
        e.vy = 0;
      }
      return; // Skip all other physics while in pre-burst state
    }

    final bool gravity = widget.cubeMode == CubeMode.gravity;
    final bool isMergeMode = widget.cubeMode == CubeMode.merge;
    for (final e in _entities) {
      e.update(
        dt,
        widget.speed,
        _hasRepelPoint ? _repelPoint : null,
        scrollDrift,
        topExclusion,
        gravity: gravity,
        isMergeMode: isMergeMode,
      );
    }

    // ── NaN safety guard ──
    for (final e in _entities) {
      if (e.x.isNaN || e.x.isInfinite) e.x = 0.5;
      if (e.y.isNaN || e.y.isInfinite) e.y = (topExclusion + 1.0) * 0.5;
      if (e.renderSize.isNaN || e.renderSize.isInfinite) e.renderSize = 10.0;
      if (e.targetSize.isNaN || e.targetSize.isInfinite) e.targetSize = 10.0;
    }

    // ── Trail particles ──
    if (!lowQuality) {
      for (final e in _entities) {
        final speed = sqrt(e.vx * e.vx + e.vy * e.vy);
        if (speed > 0.15) {
          _trailPool.spawn(
            e.x + (Random().nextDouble() - 0.5) * 0.01,
            e.y + (Random().nextDouble() - 0.5) * 0.01,
            e.renderSize,
          );
        }
      }
      _trailPool.update(dt);
    }

    // ── MODE-SPECIFIC PHYSICS ───────────────────────────────────────────

    if (widget.cubeMode == CubeMode.merge) {
      _updateMergeMode(dt, topExclusion);
    } else if (widget.cubeMode == CubeMode.orbit) {
      _updateOrbitMode(dt, topExclusion);
    } else if (widget.cubeMode == CubeMode.gravity) {
      // No additional physics — gravity is applied per-entity in update()
    } else {
      // Standard mode: spatial hash + isolate offloading
      _spatialHash.clear();
      for (int i = 0; i < _entities.length; i++) {
        _spatialHash.insert(i, _entities[i].x, _entities[i].y);
      }
      for (int i = 0; i < _entities.length; i++) {
        final e = _entities[i];
        _spatialHash.queryNeighbors(e.x, e.y, _neighborScratch);
        for (final j in _neighborScratch) {
          if (j <= i) continue;
          e.applyRepulsionFrom(_entities[j]);
        }
      }
      // Fire-and-forget isolate for additional O(n²) check on large pools
      _tryRunIsolate();
    }

    // ── Scroll drift reset ──
    if (widget.controller != null) {
      widget.controller!.scrollDrift = 0.0; // ⚠️ scrollDrift is clamped to ±0.08 at read site with multiplier 2.0 — do NOT change these values without testing scroll behavior
    }
  }

  // ── Merge Mode ────────────────────────────────────────────────────────

  void _updateMergeMode(double dt, double topExclusion) {
    // Cooldown & random perturbation
    for (final e in _entities) {
      if (e.mergeCooldown > 0 && !e.isSpiraling) e.mergeCooldown -= _realSec(dt);
    }
    for (final e in _entities) {
      if (e.isSpiraling) continue;
      e.vx += (Random().nextDouble() - 0.5) * 0.01;
      e.vy += (Random().nextDouble() - 0.5) * 0.01;
    }

    // Size lerp
    for (final e in _entities) {
      e.renderSize += (e.targetSize - e.renderSize) * dt * 180.0;
    }

    // ── Death spiral updates ──
    {
      bool spiralMergeHappened = true;
      int spiralPasses = 0;
      while (spiralMergeHappened) {
        spiralMergeHappened = false;
        if (++spiralPasses > _entities.length) break;
        final processed = <_MergeEntity>{};
        for (final a in _entities.toList()) {
          if (a.spiralPartner == null) continue;
          if (processed.contains(a)) continue;
          final b = a.spiralPartner!;
          if (b.spiralPartner != a) {
            a.spiralPartner = null;
            continue;
          }
          processed.add(a);
          processed.add(b);

          a.spiralCollapseTimer += _realSec(dt);
          b.spiralCollapseTimer += _realSec(dt);

          const double totalDuration = 4.0;
          final collapseProgress = (a.spiralCollapseTimer / totalDuration)
              .clamp(0.0, 1.0);

          a.spiralSpeed = 1.5 + (12.0 - 1.5) * collapseProgress;
          b.spiralSpeed = a.spiralSpeed;

          final collisionRadiusPixel = (a.renderSize + b.renderSize) * 0.2;
          final totalCount = a.count + b.count;
          final effectiveTouchRadiusA =
              collisionRadiusPixel * (b.count / totalCount);
          final effectiveTouchRadiusB =
              collisionRadiusPixel * (a.count / totalCount);

          final targetRadiusA = min(
            effectiveTouchRadiusA,
            a.spiralInitialRadius,
          );
          final targetRadiusB = min(
            effectiveTouchRadiusB,
            b.spiralInitialRadius,
          );

          final shrinkCurve = collapseProgress * collapseProgress;

          a.spiralRadius =
              a.spiralInitialRadius +
              (targetRadiusA - a.spiralInitialRadius) * shrinkCurve;
          b.spiralRadius =
              b.spiralInitialRadius +
              (targetRadiusB - b.spiralInitialRadius) * shrinkCurve;

          a.spiralAngle += a.spiralSpeed * _realSec(dt) * widget.speed;
          b.spiralAngle = a.spiralAngle + pi;

          double cx = (a.x * a.count + b.x * b.count) / totalCount;
          double cy = (a.y * a.count + b.y * b.count) / totalCount;
          double cvx = (a.vx * a.count + b.vx * b.count) / totalCount;
          double cvy = (a.vy * a.count + b.vy * b.count) / totalCount;

          const double repZone = 0.1;
          const double repForce = 0.04;
          if (cy < topExclusion + repZone) {
            cvy += (topExclusion + repZone - cy) / repZone * repForce;
          }
          if (cy > 1.0 - repZone) {
            cvy -= (repZone - (1.0 - cy)) / repZone * repForce;
          }
          if (cx < repZone) {
            cvx += (repZone - cx) / repZone * repForce;
          }
          if (cx > 1.0 - repZone) {
            cvx -= (repZone - (1.0 - cx)) / repZone * repForce;
          }

          if (_hasRepelPoint && _repelPoint != null) {
            final dx = cx - _repelPoint!.dx;
            final dy = cy - _repelPoint!.dy;
            final dist = sqrt(dx * dx + dy * dy);
            if (dist < 0.25 && dist > 0.001) {
              final force = (0.25 - dist) / 0.25 * 0.30;
              cvx += (dx / dist) * force;
              cvy += (dy / dist) * force;
            }
          }

          double newCx = cx;
          double newCy = cy;
          if (cx < 0) {
            newCx = 0;
            cvx = -cvx * 0.92;
          }
          if (cx > 1) {
            newCx = 1;
            cvx = -cvx * 0.92;
          }
          if (cy < topExclusion) {
            newCy = topExclusion;
            cvy = -cvy * 0.92;
          }
          if (cy > 1) {
            newCy = 1;
            cvy = -cvy * 0.92;
          }

          a.vx = cvx;
          b.vx = cvx;
          a.vy = cvy;
          b.vy = cvy;
          cx = newCx;
          cy = newCy;

          a.x = (cx + (a.spiralRadius / _screenSize.width) * cos(a.spiralAngle))
              .clamp(0.0, 1.0);
          a.y =
              (cy + (a.spiralRadius / _screenSize.height) * sin(a.spiralAngle))
                  .clamp(topExclusion, 1.0);
          b.x = (cx + (b.spiralRadius / _screenSize.width) * cos(b.spiralAngle))
              .clamp(0.0, 1.0);
          b.y =
              (cy + (b.spiralRadius / _screenSize.height) * sin(b.spiralAngle))
                  .clamp(topExclusion, 1.0);

          if (collapseProgress >= 0.999) {
            final newSize = a.targetSize + b.targetSize;
            cvx += (Random().nextDouble() - 0.5) * 0.05;
            cvy += (Random().nextDouble() - 0.5) * 0.05;

            final merged = _MergeEntity(
              x: cx,
              y: cy,
              vx: cvx,
              vy: cvy,
              rx: (a.rx + b.rx) / 2,
              ry: (a.ry + b.ry) / 2,
              rz: (a.rz + b.rz) / 2,
              count: totalCount,
              size: max(a.renderSize, b.renderSize),
              targetSize: newSize,
              baseIndices: [...a.baseIndices, ...b.baseIndices],
            );
            merged.splitLeft = a.baseIndices;
            merged.splitRight = b.baseIndices;
            merged.splitLeftLeft = a.splitLeft;
            merged.splitLeftRight = a.splitRight;
            merged.splitRightLeft = b.splitLeft;
            merged.splitRightRight = b.splitRight;
            _entities.add(merged);
            _entities.last.mergeCooldown = 2.0;

            a.spiralPartner = null;
            b.spiralPartner = null;
            _entities.remove(a);
            _entities.remove(b);
            spiralMergeHappened = true;
            break;
          }
        }
      }
    }

    // ── Spatial hash: attract / repel / third-cube repulsion ──
    _spatialHash.clear();
    for (int i = 0; i < _entities.length; i++) {
      _spatialHash.insert(i, _entities[i].x, _entities[i].y);
    }

    for (int i = 0; i < _entities.length; i++) {
      final a = _entities[i];
      _spatialHash.queryNeighbors(a.x, a.y, _neighborScratch);
      for (final j in _neighborScratch) {
        if (j <= i) continue;
        final b = _entities[j];
        if (a.isSpiraling && b.isSpiraling) continue;

        final dx = b.x - a.x;
        final dy = b.y - a.y;
        final distSq = dx * dx + dy * dy;
        if (distSq < 1e-10) continue;
        final dist = sqrt(distSq);

        final dxPixel = dx * _screenSize.width;
        final dyPixel = dy * _screenSize.height;
        final distPixel = sqrt(dxPixel * dxPixel + dyPixel * dyPixel);

        final baseDistPixel = a.renderSize + b.renderSize;

        // Third-cube repulsion
        if (a.isSpiraling != b.isSpiraling) {
          final outsider = a.isSpiraling ? b : a;
          final spiraling = a.isSpiraling ? a : b;

          final dx2 = outsider.x - spiraling.x;
          final dy2 = outsider.y - spiraling.y;
          final d2 = sqrt(dx2 * dx2 + dy2 * dy2);
          if (d2 < 1e-10) continue;

          final repelRange = max(
            0.1,
            (baseDistPixel * 5.0) / _screenSize.width,
          );
          if (d2 > repelRange) continue;

          final strength = (repelRange - d2) / repelRange * 0.15;

          outsider.vx += (dx2 / d2) * strength;
          outsider.vy += (dy2 / d2) * strength;

          final driftStrength = strength * 0.1;
          spiraling.vx -= (dx2 / d2) * driftStrength;
          spiraling.vy -= (dy2 / d2) * driftStrength;
          if (spiraling.spiralPartner != null) {
            spiraling.spiralPartner!.vx -= (dx2 / d2) * driftStrength;
            spiraling.spiralPartner!.vy -= (dy2 / d2) * driftStrength;
          }
          continue;
        }

        if (a.mergeCooldown > 0 || b.mergeCooldown > 0) continue;

        final sizeRatio = a.renderSize < b.renderSize
            ? a.renderSize / b.renderSize
            : b.renderSize / a.renderSize;

        if (sizeRatio >= 0.80) {
          final safeDistancePixel = (baseDistPixel * 3.0).clamp(0.0, 150.0);
          final attractRangePixel = (baseDistPixel * 8.0).clamp(0.0, 300.0);

          if (distPixel < attractRangePixel) {
            if (distPixel > safeDistancePixel) {
              final strength =
                  (attractRangePixel - distPixel) / attractRangePixel * 0.008;
              a.vx += (dx / dist) * strength;
              a.vy += (dy / dist) * strength;
              b.vx -= (dx / dist) * strength;
              b.vy -= (dy / dist) * strength;
            } else if (distPixel < safeDistancePixel * 0.9) {
              final strength =
                  (safeDistancePixel * 0.9 - distPixel) /
                  (safeDistancePixel * 0.9) *
                  0.03;
              a.vx -= (dx / dist) * strength;
              a.vy -= (dy / dist) * strength;
              b.vx += (dx / dist) * strength;
              b.vy += (dy / dist) * strength;
            }
          }
        } else {
          final repelRangePixel = (baseDistPixel * 3.5).clamp(0.0, 150.0);
          if (distPixel < repelRangePixel) {
            final strength =
                (repelRangePixel - distPixel) / repelRangePixel * 0.005;
            a.vx -= (dx / dist) * strength;
            a.vy -= (dy / dist) * strength;
            b.vx += (dx / dist) * strength;
            b.vy += (dy / dist) * strength;
          }
        }
      }
    }

    // ── Spiral initiation (also spatial-hash accelerated) ──
    _spatialHash.clear();
    for (int i = 0; i < _entities.length; i++) {
      _spatialHash.insert(i, _entities[i].x, _entities[i].y);
    }

    for (int i = 0; i < _entities.length; i++) {
      final a = _entities[i];
      _spatialHash.queryNeighbors(a.x, a.y, _neighborScratch);
      for (final j in _neighborScratch) {
        if (j <= i) continue;
        final b = _entities[j];
        if (a.isSpiraling || b.isSpiraling) continue;
        if (a.mergeCooldown > 0 || b.mergeCooldown > 0) continue;

        final sizeRatio = a.renderSize < b.renderSize
            ? a.renderSize / b.renderSize
            : b.renderSize / a.renderSize;
        if (sizeRatio < 0.80) continue;

        final dxPixel = (b.x - a.x) * _screenSize.width;
        final dyPixel = (b.y - a.y) * _screenSize.height;
        final distPixel = max(
          sqrt(dxPixel * dxPixel + dyPixel * dyPixel),
          0.001,
        );

        final baseDistPixel = a.renderSize + b.renderSize;
        final safeDistancePixel = (baseDistPixel * 3.0).clamp(0.0, 150.0);

        if (distPixel > safeDistancePixel * 1.5) continue;

        final totalInitRadius = distPixel;

        final totalCount = a.count + b.count;
        a.spiralInitialRadius = totalInitRadius * (b.count / totalCount);
        b.spiralInitialRadius = totalInitRadius * (a.count / totalCount);

        a.spiralPartner = b;
        b.spiralPartner = a;
        a.spiralAngle = atan2(-dyPixel, -dxPixel);
        b.spiralAngle = a.spiralAngle + pi;
        a.spiralRadius = a.spiralInitialRadius;
        b.spiralRadius = b.spiralInitialRadius;

        a.spiralSpeed = 1.5;
        b.spiralSpeed = 1.5;
        a.spiralCollapseTimer = 0.0;
        b.spiralCollapseTimer = 0.0;
      }
    }
  }

  // ── Orbit Mode ────────────────────────────────────────────────────────

  void _updateOrbitMode(double dt, double topExclusion) {
    // Orbiter position updates
    for (final e in _entities) {
      if (e.parentCore == null) continue;
      e.orbitAngle += e.orbitSpeed * _realSec(dt) * widget.speed;
      final cosA = cos(e.orbitAngle);
      final sinA = sin(e.orbitAngle);
      e.x = e.parentCore!.x + e.orbitRadius * cosA;
      e.y = e.parentCore!.y + e.orbitRadius * sinA * cos(e.orbitTilt);
      e.x = e.x.clamp(0.0, 1.0);
      e.y = e.y.clamp(0.0, 1.0);
    }

    // Collect cores
    final cores = <_MergeEntity>[];
    for (final e in _entities) {
      if (e.parentCore == null && e.renderSize > 12.0) {
        cores.add(e);
      }
    }

    // ── Core gravitational pull (spatial-hash accelerated) ──
    _spatialHash.clear();
    for (int i = 0; i < _entities.length; i++) {
      _spatialHash.insert(i, _entities[i].x, _entities[i].y);
    }

    for (final core in cores) {
      _spatialHash.queryNeighbors(core.x, core.y, _neighborScratch);
      for (final j in _neighborScratch) {
        final e = _entities[j];
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

    // ── Core capture (spatial-hash accelerated) ──
    for (final core in cores) {
      if (core.orbiterCount >= 12) continue;
      final captureRadius = 0.06 + core.renderSize * 0.006;
      _spatialHash.queryNeighbors(core.x, core.y, _neighborScratch);
      for (final j in _neighborScratch) {
        final e = _entities[j];
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
            (0.5 + Random().nextDouble() * 2.5) /
            (0.3 + e.orbitRadius * 4) *
            0.75;
        e.orbitTilt = (Random().nextDouble() - 0.5) * 0.6;
        core.count += e.count;
      }
    }

    // ── Core-core repulsion & absorption (direct loops: cores are few) ──
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
              (0.5 + Random().nextDouble() * 2.5) /
              (0.3 + smaller.orbitRadius * 4) *
              0.75;
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

    // ── Escape checks ──
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

    // ── Core-core second pass (tight repulsion) ──
    for (int i = 0; i < cores.length; i++) {
      for (int j = i + 1; j < cores.length; j++) {
        final a = cores[i], b = cores[j];
        final dx = b.x - a.x;
        final dy = b.y - a.y;
        if (dx.abs() > 0.2 || dy.abs() > 0.2) continue;
        final distSq = dx * dx + dy * dy;
        if (distSq > 0.04 || distSq < 1e-10) continue;
        final dist = sqrt(distSq);
        final force = (0.2 - dist) / 0.2 * 0.02;
        a.vx -= (dx / dist) * force;
        a.vy -= (dy / dist) * force;
        b.vx += (dx / dist) * force;
        b.vy += (dy / dist) * force;
      }
    }

    // ── Core close-range repulsion (spatial-hash accelerated) ──
    for (final core in cores) {
      _spatialHash.queryNeighbors(core.x, core.y, _neighborScratch);
      for (final j in _neighborScratch) {
        final e = _entities[j];
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

    // ── NaN safety ──
    final topExclusion3 = widget.topExclusion;
    for (final e in _entities) {
      if (e.x.isNaN || e.x.isInfinite) e.x = 0.5;
      if (e.y.isNaN || e.y.isInfinite) e.y = (topExclusion3 + 1.0) * 0.5;
      if (e.renderSize.isNaN || e.renderSize.isInfinite) e.renderSize = 10.0;
    }
  }

  // ── didUpdateWidget / dispose / build ──────────────────────────────────

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
      oldWidget.controller?.onLogoBurst = null;
      oldWidget.controller?.onGatherIntoLogo = null;
      oldWidget.controller?.onTrySplit = null;
      widget.controller?.onRepelUpdate = setRepelPoint;
      widget.controller?.onBurst = triggerBurst;
      widget.controller?.onLogoBurst = _triggerLogoBurst;
      widget.controller?.onGatherIntoLogo = _startGatherIntoLogo;
      widget.controller?.onTrySplit = _trySplitAt;
    }
    if (widget.cubeCount != oldWidget.cubeCount) {
      if (widget.cubeCount > _baseData.length) {
        for (int i = _baseData.length; i < widget.cubeCount; i++) {
          final size = 6.0 + Random().nextDouble() * 18.0;
          _baseData.add(
            _BaseCubeData(
              x: Random().nextDouble(),
              y: Random().nextDouble(),
              rx: Random().nextDouble() * pi * 2,
              ry: Random().nextDouble() * pi * 2,
              rz: Random().nextDouble() * pi * 2,
              size: size,
            ),
          );
          _entities.add(_MergeEntity(baseIndices: [i]));
        }
      }
    }
    if (oldWidget.cubeMode != widget.cubeMode) {
      if (oldWidget.cubeMode == CubeMode.merge) {
        _splitMergedEntities();
      }
      if (oldWidget.cubeMode == CubeMode.orbit) {
        _freeOrbiters();
      }
      if (widget.cubeMode == CubeMode.merge) {
        _resetMergeState();
      }
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_updateEntities);
    _animController.dispose();
    widget.controller?.onRepelUpdate = null;
    widget.controller?.onBurst = null;
    widget.controller?.onLogoBurst = null;
    widget.controller?.onGatherIntoLogo = null;
    widget.controller?.onTrySplit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Guaranteed to be exactly the viewport size, fixing the "top of screen" bug.
    final mSize = MediaQuery.sizeOf(context);
    _screenSize = Size(
      mSize.width <= 0 ? 800 : mSize.width,
      mSize.height <= 0 ? 800 : mSize.height,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _CubePainter(
              entities: _entities,
              trailPool: _trailPool,
              qualityMode: _adaptiveQuality.mode,
              brightness: brightness,
              primaryColor: primaryColor,
              isRtl: isRtl,
              repelPoint: _hasRepelPoint ? _repelPoint : null,
              isLogoState: _isPreBurst || _isGathering,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BASE DATA
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// ENTITY  (V2: mouse repulsion)
// ─────────────────────────────────────────────────────────────────────────────

class _MergeEntity {
  double x, y;
  int count;
  double vx, vy;
  final double _baseVx, _baseVy;
  double rx, ry, rz;
  double vrx, vry, vrz;
  double renderSize;
  double targetSize;
  double depth = 0.0;
  double mergeTimer = 0.0;
  double mergeCooldown = 0.0;
  double ignoreRepelTimer = 0.0;
  double _timeSinceLastChange = 0.0;
  double lastScrollDrift = 0.0;

  _MergeEntity? parentCore;
  double orbitRadius = 0.0;
  double orbitAngle = 0.0;
  double orbitSpeed = 0.0;
  double orbitTilt = 0.0;
  int orbiterCount = 0;

  _MergeEntity? spiralPartner;
  double spiralInitialRadius = 0.0;
  double spiralAngle = 0.0;
  double spiralRadius = 0.0;
  double spiralSpeed = 0.0;
  double spiralCollapseTimer = 0.0;
  bool get isSpiraling => spiralPartner != null;

  final List<int> baseIndices;
  List<int>? splitLeft;
  List<int>? splitRight;
  List<int>? splitLeftLeft;
  List<int>? splitLeftRight;
  List<int>? splitRightLeft;
  List<int>? splitRightRight;

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
    List<int>? baseIndices,
  }) : x = x ?? Random().nextDouble(),
       baseIndices = baseIndices ?? List.generate(count, (i) => i),
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
    double topExclusion, {
    bool gravity = false,
    bool isMergeMode = false,
  }) {
    _timeSinceLastChange += dt;
    if (_timeSinceLastChange > 0.033) {
      _timeSinceLastChange = 0.0;
      if (!isSpiraling && !gravity) {
        vx += (Random().nextDouble() - 0.5) * 0.02;
        vy += (Random().nextDouble() - 0.5) * 0.02;
      }
    }

    if (ignoreRepelTimer > 0) ignoreRepelTimer -= _realSec(dt);

    if (repelPoint != null && !isSpiraling && ignoreRepelTimer <= 0) {
      final dx = x - repelPoint.dx;
      final dy = y - repelPoint.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < 0.25 && dist > 0.001) {
        // Decrease repulsion in merge mode to make it easier to click cubes
        final double forceMultiplier = isMergeMode ? 0.08 : 0.30;
        final force = (0.25 - dist) / 0.25 * forceMultiplier;
        vx += (dx / dist) * force;
        vy += (dy / dist) * force;
      }
    }

    vy -= scrollDrift * 2.0; // ⚠️ scrollDrift is clamped to ±0.08 at read site — do NOT raise multiplier above 2.0 or remove the clamp without testing scroll behavior

    const double repZone = 0.1;
    const double repForce = 0.04;
    if (!isSpiraling) {
      if (y < topExclusion + repZone) {
        vy += (topExclusion + repZone - y) / repZone * repForce;
      }
      if (!gravity) {
        if (y > 1.0 - repZone) {
          vy -= (repZone - (1.0 - y)) / repZone * repForce;
        }
        if (x < repZone) vx += (repZone - x) / repZone * repForce;
        if (x > 1.0 - repZone) vx -= (repZone - (1.0 - x)) / repZone * repForce;
      }
    }

    final double realDt = _realSec(dt);

    if (gravity) {
      // ── GRAVITY MODE PHYSICS ──
      // 1. Uniform downward acceleration
      vy += 0.005 * realDt * speedMultiplier;

      // 2. Air resistance
      //    Horizontal: light drag so cubes cross the screen with visible arcs
      vx = vx * max(0.0, 1.0 - 0.005 * realDt);
      //    Vertical: minimal drag — gravity dominates, terminal velocity emerges naturally
      vy = vy * max(0.0, 1.0 - 0.001 * realDt);

      // 3. Rotational air resistance (same for all gravity cubes)
      vrx *= max(0.0, 1.0 - 0.005 * realDt);
      vry *= max(0.0, 1.0 - 0.005 * realDt);
      vrz *= max(0.0, 1.0 - 0.005 * realDt);

      // 4. Maximum speed caps (4x faster as requested)
      if (vx > 0.6) vx = 0.6;
      if (vx < -0.6) vx = -0.6;
      if (vy < -1.0) vy = -1.0; // 4x upward speed
      if (vy > 1.2) vy = 1.2; // 4x downward speed
    } else {
      // ── STANDARD/MERGE/ORBIT MODE PHYSICS ──
      final double speed = sqrt(vx * vx + vy * vy);
      if (speed > 0.35) {
        vx = (vx / speed) * 0.35;
        vy = (vy / speed) * 0.35;
      }
      final double decay = max(0.0, 1.0 - 1.5 * realDt);
      vx = _baseVx + (vx - _baseVx) * decay;
      vy = _baseVy + (vy - _baseVy) * decay;
    }

    // ── Position update (always — resting only clamps y after the fact) ──
    x += vx * realDt * speedMultiplier;
    y += vy * realDt * speedMultiplier;

    if (!isSpiraling) {
      if (x < 0) {
        x = 0;
        vx =
            -vx *
            (gravity
                ? 0.6
                : 0.92); // Heavy speed loss on wall bounce in gravity
        if (gravity) vy *= 0.8; // Wall friction slows downward/upward speed
      }
      if (x > 1) {
        x = 1;
        vx = -vx * (gravity ? 0.6 : 0.92);
        if (gravity) vy *= 0.8;
      }
      if (y < topExclusion) {
        y = topExclusion;
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
      if (y >= 1.0) {
        y = 1.0;
        if (gravity) {
          if (vy.abs() < 0.008) {
            // ── Settle: tiny bounce becomes rest ──
            vy = 0.0;
            // Strong floor friction kills horizontal slide
            vx *= max(0.0, 1.0 - 0.25 * realDt);
            vrx *= max(0.0, 1.0 - 0.25 * realDt);
            vry *= max(0.0, 1.0 - 0.25 * realDt);
            vrz *= max(0.0, 1.0 - 0.25 * realDt);
          } else {
            // ── Rubber bounce ──
            final elasticity =
                0.45 + (Random().nextDouble() * 0.10); // Slower, heavier bounce
            vy = -vy * elasticity;
            // Heavy impact friction on horizontal slide to stop them sliding across the floor
            vx *= 0.5;
            vx += (Random().nextDouble() - 0.5) * 0.003;
            vrx *= 0.8;
            vry *= 0.8;
            vrz *= 0.8;
          }
        } else {
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
      }
    }

    rx += vrx * _realSec(dt) * speedMultiplier;
    ry += vry * _realSec(dt) * speedMultiplier;
    rz += vrz * _realSec(dt) * speedMultiplier;
  }

  void applyBurst(Offset point, {bool isGravity = false}) {
    final dx = x - point.dx;
    final dy = y - point.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (isGravity) {
      if (dist < 0.8 && dist > 0.001) {
        // Shockwave from the floor in gravity mode
        final force = (0.8 - dist) / 0.8 * 1.5; // Massive force
        vx += (dx / dist) * force;
        // Force them upwards strongly
        vy -= force * 1.2;
      }
    } else {
      if (dist < 0.65 && dist > 0.001) {
        final force = (0.65 - dist) / 0.65 * 0.6;
        vx += (dx / dist) * force;
        vy += (dy / dist) * force;
      }
    }
  }

  void applyRepulsionFrom(_MergeEntity other) {
    if (identical(this, other)) return;
    final sizeRatio = renderSize < other.renderSize
        ? renderSize / other.renderSize
        : other.renderSize / renderSize;
    if (sizeRatio < 0.5) return;

    double dx = x - other.x;
    double dy = y - other.y;
    if (dx.abs() > 0.06 || dy.abs() > 0.06) return;

    final distSq = dx * dx + dy * dy;
    if (distSq > 0.0036 || distSq < 1e-8) return;

    final dist = sqrt(distSq);
    final force = (0.06 - dist) / 0.06 * 0.04;
    vx += (dx / dist) * force;
    vy += (dy / dist) * force;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RENDERING DATA CLASSES
// ─────────────────────────────────────────────────────────────────────────────

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
  final double depth;
  final double left, right, top, bottom;
  final List<_FaceDrawData> faces;

  _CubeDrawData({
    required this.size,
    required this.depth,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.faces,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER (V2: trails in front, adaptive quality)
// ─────────────────────────────────────────────────────────────────────────────

class _CubePainter extends CustomPainter {
  final List<_MergeEntity> entities;
  final _TrailPool trailPool;
  final _QualityMode qualityMode;
  final Brightness brightness;
  final Color primaryColor;
  final bool isRtl;
  final Offset? repelPoint;
  final bool isLogoState;

  _CubePainter({
    required this.entities,
    required this.trailPool,
    required this.qualityMode,
    required this.brightness,
    required this.primaryColor,
    required this.isRtl,
    this.repelPoint,
    this.isLogoState = false,
  });

  static final _nvScratch = [0.0, 0.0, 0.0];

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final cubeColor = brightness == Brightness.light
        ? const Color(0xFFD8D8D8)
        : const Color(0xFF505050);

    // ── Transform vertices ──
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
    if (size.width <= 0 || size.height <= 0)
      return; // Prevent drawing at top-left when constraints aren't ready

    final allData = <_CubeDrawData>[];

    // Only draw stroke in high quality (adaptive rendering)
    final bool drawStroke = qualityMode == _QualityMode.high;

    for (final entity in entities) {
      if (entity.x.isNaN || entity.x.isInfinite) continue;
      if (entity.y.isNaN || entity.y.isInfinite) continue;
      if (entity.renderSize.isNaN || entity.renderSize.isInfinite) continue;

      final h = entity.renderSize * 0.5;
      final px = entity.x * size.width;
      final py = entity.y * size.height;

      final double lightX, lightY;
      final rp = repelPoint;
      if (rp != null) {
        lightX = rp.dx;
        lightY = rp.dy;
      } else {
        lightX = isRtl ? 0.9 : 0.1;
        lightY = 0.05;
      }
      final double ldx = lightX - entity.x;
      final double ldy = entity.y - lightY;
      final double ldz = 0.5;
      final double lDist = sqrt(ldx * ldx + ldy * ldy + ldz * ldz);
      final double lx = ldx / lDist;
      final double ly = ldy / lDist;
      final double lz = ldz / lDist;

      final rot = cg.computeRotation(entity.rx, entity.ry, entity.rz);
      for (int i = 0; i < 8; i++) {
        cg.rotatePoint(cg.cubeVerts[i], rot, tv[i]);
        tv[i][0] *= h;
        tv[i][1] *= h;
        tv[i][2] *= h;
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
        cg.rotatePoint(cg.cubeNormals[f], rot, _nvScratch);
        final double nx = _nvScratch[0], ny = _nvScratch[1], nz = _nvScratch[2];
        if (nz <= 0) continue;

        final dot = nx * lx + ny * ly + nz * lz;
        final brightness = 0.25 + max(0.0, dot) * 0.75;

        double sumZ = 0.0;
        for (int vi = 0; vi < 4; vi++) {
          sumZ += tv[cg.cubeFaces[f][vi]][2];
        }

        final faceVerts = cg.cubeFaces[f];
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
          depth: entity.depth,
          left: minX,
          right: maxX,
          top: minY,
          bottom: maxY,
          faces: faceBuffer,
        ),
      );
    }

    allData.sort((a, b) => isLogoState ? a.depth.compareTo(b.depth) : a.size.compareTo(b.size));

    for (final cubeData in allData) {
      if (cubeData.faces.isEmpty) continue;
      final h = cubeData.size * 0.5;
      for (final fd in cubeData.faces) {
        _drawFace(canvas, fd, fillPaint, strokePaint, cubeColor, drawStroke, h);
      }
    }

    // ── Trail / Dust Particles (in front of cubes) ──
    if (qualityMode == _QualityMode.high) {
      final trailPaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < _kTrailPoolSize; i++) {
        final tp = trailPool.particles[i];
        if (tp.opacity <= 0) continue;
        trailPaint.color = Color.from(
          alpha: (tp.opacity * 0.35).clamp(0.0, 1.0),
          red: primaryColor.r,
          green: primaryColor.g,
          blue: primaryColor.b,
        );
        canvas.drawCircle(
          Offset(tp.x * size.width, tp.y * size.height),
          tp.size,
          trailPaint,
        );
      }
    }
  }

  void _drawFace(
    Canvas canvas,
    _FaceDrawData fd,
    Paint fillPaint,
    Paint strokePaint,
    Color cubeColor,
    bool drawStroke,
    double h,
  ) {
    if (!fd.x0.isFinite ||
        !fd.y0.isFinite ||
        !fd.x1.isFinite ||
        !fd.y1.isFinite ||
        !fd.x2.isFinite ||
        !fd.y2.isFinite ||
        !fd.x3.isFinite ||
        !fd.y3.isFinite)
      return;

    final Path path;
    if (isLogoState) {
      final cr = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
      path = cg.buildRoundedQuad(
        Offset(fd.x0, fd.y0),
        Offset(fd.x1, fd.y1),
        Offset(fd.x2, fd.y2),
        Offset(fd.x3, fd.y3),
        cr,
      );
    } else {
      path = Path()
        ..moveTo(fd.x0, fd.y0)
        ..lineTo(fd.x1, fd.y1)
        ..lineTo(fd.x2, fd.y2)
        ..lineTo(fd.x3, fd.y3)
        ..close();
    }

    final b = fd.brightness;

    fillPaint.color = Color.from(
      alpha: 1.0,
      red: (cubeColor.r * b).clamp(0.0, 1.0),
      green: (cubeColor.g * b).clamp(0.0, 1.0),
      blue: (cubeColor.b * b).clamp(0.0, 1.0),
    );
    canvas.drawPath(path, fillPaint);

    if (drawStroke) {
      strokePaint.color = primaryColor;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
