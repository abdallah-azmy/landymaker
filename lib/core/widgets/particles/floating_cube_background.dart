// ══════════════════════════════════════════════════════════════════════════════
// AI DOCUMENTATION DIRECTIVE
//
// This file implements a 3-mode 3D cube particle system (Standard, Merge, Orbit).
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
import 'package:flutter/material.dart';
import 'package:landymaker/core/widgets/particles/cube_mode_cubit.dart';

class FloatingCubeBackgroundController {
  void Function(Offset?)? onRepelUpdate;
  void Function(Offset)? onBurst;
  void Function(Offset)? onLogoBurst;
  bool Function(Offset)? onTrySplit;
  double scrollDrift = 0.0;
  final ValueNotifier<int> cubeCount = ValueNotifier<int>(0);

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

class FloatingCubeBackground extends StatefulWidget {
  final int cubeCount;
  final double speed;
  final bool isActive;
  final FloatingCubeBackgroundController? controller;
  final CubeMode cubeMode;
  final double topExclusion;

  const FloatingCubeBackground({
    super.key,
    this.cubeCount = 50,
    this.speed = 1.0,
    this.isActive = true,
    this.controller,
    this.cubeMode = CubeMode.standard,
    this.topExclusion = 0.0,
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
  Size _screenSize = const Size(800, 800);

  void setRepelPoint(Offset? point) {
    _repelPoint = point;
    _hasRepelPoint = point != null;
  }

  void triggerBurst(Offset point) {
    for (final e in _entities) {
      e.applyBurst(point);
    }
  }

  void _triggerLogoBurst(Offset center) {
    for (final e in _entities) {
      final angle = Random().nextDouble() * 2 * pi;
      final radius = Random().nextDouble() * 0.005;
      e.x = (center.dx + cos(angle) * radius).clamp(0.0, 1.0);
      e.y = (center.dy + sin(angle) * radius).clamp(0.0, 1.0);
      final dx = e.x - center.dx;
      final dy = e.y - center.dy;
      final dist = max(sqrt(dx * dx + dy * dy), 0.001);
      final force = 0.5 + Random().nextDouble() * 0.6;
      e.vx = (dx / dist) * force + (Random().nextDouble() - 0.5) * 0.01;
      e.vy = (dy / dist) * force + (Random().nextDouble() - 0.5) * 0.01;
      e.rx = Random().nextDouble() * pi * 2;
      e.ry = Random().nextDouble() * pi * 2;
      e.rz = Random().nextDouble() * pi * 2;
    }
  }

  bool _trySplitAt(Offset normalizedPoint) {
    final sorted = List<_MergeEntity>.from(_entities)
      ..sort((a, b) => b.renderSize.compareTo(a.renderSize));
    for (final e in sorted) {
      if (e.splitLeft == null || e.splitRight == null) continue;
      final halfSize = e.renderSize * 0.5;
      final cx = e.x * _screenSize.width;
      final cy = e.y * _screenSize.height;
      final nx = normalizedPoint.dx * _screenSize.width;
      final ny = normalizedPoint.dy * _screenSize.height;
      if ((nx - cx).abs() <= halfSize && (ny - cy).abs() <= halfSize) {
        _splitEntity(e);
        return true;
      }
    }
    return false;
  }

  void _splitEntity(_MergeEntity source) {
    final leftIndices = source.splitLeft!;
    final rightIndices = source.splitRight!;
    final leftSize = leftIndices.fold(0.0, (sum, idx) => sum + _baseData[idx].size);
    final rightSize = rightIndices.fold(0.0, (sum, idx) => sum + _baseData[idx].size);
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
      y: (source.y + (Random().nextDouble() - 0.5) * 0.03).clamp(topExclusion, 1.0),
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
      y: (source.y + (Random().nextDouble() - 0.5) * 0.03).clamp(topExclusion, 1.0),
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
    final pushForce = 0.15;
    leftEntity.vx -= (dx / dist) * pushForce;
    leftEntity.vy -= (dy / dist) * pushForce;
    rightEntity.vx += (dx / dist) * pushForce;
    rightEntity.vy += (dy / dist) * pushForce;

    final idx = _entities.indexOf(source);
    if (idx >= 0) {
      _entities.removeAt(idx);
      _entities.add(leftEntity);
      _entities.add(rightEntity);
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

  void _initFromBase() {
    final topExclusion = widget.topExclusion;
    _entities = List.generate(_baseData.length, (i) {
      final d = _baseData[i];
      return _MergeEntity(
        x: d.x + (Random().nextDouble() - 0.5) * 0.05,
        y: d.y * (1.0 - topExclusion) + topExclusion + (Random().nextDouble() - 0.5) * 0.05,
        size: d.size,
        targetSize: d.size,
        rx: d.rx,
        ry: d.ry,
        rz: d.rz,
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
          newEntities.add(_MergeEntity(
            x: (e.x + (Random().nextDouble() - 0.5) * 0.05).clamp(0.0, 1.0),
            y: (e.y + (Random().nextDouble() - 0.5) * 0.05).clamp(topExclusion, 1.0),
            vx: e.vx + (Random().nextDouble() - 0.5) * 0.02,
            vy: e.vy + (Random().nextDouble() - 0.5) * 0.02,
            size: base.size,
            targetSize: base.size,
            rx: base.rx,
            ry: base.ry,
            rz: base.rz,
            baseIndices: [idx],
          ));
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

  @override
  void initState() {
    super.initState();
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
    widget.controller?.onTrySplit = _trySplitAt;
  }

  void _updateEntities() {
    if (!mounted) return;
    final current = _animController.value;
    double dt = current - _lastValue;
    if (dt < 0) dt += 1.0;
    _lastValue = current;
    final scrollDrift = widget.controller?.scrollDrift ?? 0.0;
    
    if (widget.controller != null && widget.controller!.cubeCount.value != _entities.length) {
      widget.controller!.cubeCount.value = _entities.length;
    }

    final topExclusion = widget.topExclusion;
    for (final e in _entities) {
      e.update(
        dt,
        widget.speed,
        _hasRepelPoint ? _repelPoint : null,
        scrollDrift,
        topExclusion,
      );
    }

    for (final e in _entities) {
      if (e.x.isNaN || e.x.isInfinite) e.x = 0.5;
      if (e.y.isNaN || e.y.isInfinite) e.y = (topExclusion + 1.0) * 0.5;
      if (e.renderSize.isNaN || e.renderSize.isInfinite) e.renderSize = 10.0;
      if (e.targetSize.isNaN || e.targetSize.isInfinite) e.targetSize = 10.0;
    }

    if (widget.cubeMode == CubeMode.merge) {
      for (final e in _entities) {
        if (e.mergeCooldown > 0 && !e.isSpiraling) e.mergeCooldown -= dt * 60;
      }

      for (final e in _entities) {
        if (e.isSpiraling) continue;
        e.vx += (Random().nextDouble() - 0.5) * 0.01;
        e.vy += (Random().nextDouble() - 0.5) * 0.01;
      }

      for (final e in _entities) {
        e.renderSize += (e.targetSize - e.renderSize) * dt * 180.0;
      }

      // --- Death spiral updates ---
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

            // dt is normalized over 60 seconds, so dt * 60 gives actual real-time seconds.
            a.spiralCollapseTimer += dt * 60;
            b.spiralCollapseTimer += dt * 60;
            
            const double totalDuration = 4.0;
            final collapseProgress = (a.spiralCollapseTimer / totalDuration).clamp(0.0, 1.0);

            a.spiralSpeed = 1.5 + (12.0 - 1.5) * collapseProgress;
            b.spiralSpeed = a.spiralSpeed;

            final collisionRadiusPixel = (a.renderSize + b.renderSize) * 0.2; // 0.2 creates a strong visual overlap before popping
            final totalCount = a.count + b.count;
            final effectiveTouchRadiusA = collisionRadiusPixel * (b.count / totalCount);
            final effectiveTouchRadiusB = collisionRadiusPixel * (a.count / totalCount);

            final targetRadiusA = min(effectiveTouchRadiusA, a.spiralInitialRadius);
            final targetRadiusB = min(effectiveTouchRadiusB, b.spiralInitialRadius);
            
            final shrinkCurve = collapseProgress * collapseProgress;
            
            a.spiralRadius = a.spiralInitialRadius + (targetRadiusA - a.spiralInitialRadius) * shrinkCurve;
            b.spiralRadius = b.spiralInitialRadius + (targetRadiusB - b.spiralInitialRadius) * shrinkCurve;

            a.spiralAngle += a.spiralSpeed * dt * 60 * widget.speed;
            b.spiralAngle = a.spiralAngle + pi;

            double cx = (a.x * a.count + b.x * b.count) / totalCount;
            double cy = (a.y * a.count + b.y * b.count) / totalCount;
            double cvx = (a.vx * a.count + b.vx * b.count) / totalCount;
            double cvy = (a.vy * a.count + b.vy * b.count) / totalCount;

            const double repZone = 0.1;
            const double repForce = 0.04;
            if (cy < topExclusion + repZone) cvy += (topExclusion + repZone - cy) / repZone * repForce;
            if (cy > 1.0 - repZone) cvy -= (repZone - (1.0 - cy)) / repZone * repForce;
            if (cx < repZone) cvx += (repZone - cx) / repZone * repForce;
            if (cx > 1.0 - repZone) cvx -= (repZone - (1.0 - cx)) / repZone * repForce;

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
            if (cx < 0) { newCx = 0; cvx = -cvx * 0.92; }
            if (cx > 1) { newCx = 1; cvx = -cvx * 0.92; }
            if (cy < topExclusion) { newCy = topExclusion; cvy = -cvy * 0.92; }
            if (cy > 1) { newCy = 1; cvy = -cvy * 0.92; }

            a.vx = cvx; b.vx = cvx;
            a.vy = cvy; b.vy = cvy;
            cx = newCx; cy = newCy;

            a.x = (cx + (a.spiralRadius / _screenSize.width) * cos(a.spiralAngle)).clamp(0.0, 1.0);
            a.y = (cy + (a.spiralRadius / _screenSize.height) * sin(a.spiralAngle)).clamp(topExclusion, 1.0);
            b.x = (cx + (b.spiralRadius / _screenSize.width) * cos(b.spiralAngle)).clamp(0.0, 1.0);
            b.y = (cy + (b.spiralRadius / _screenSize.height) * sin(b.spiralAngle)).clamp(topExclusion, 1.0);

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

      // --- Attraction/repulsion ---
      for (int i = 0; i < _entities.length; i++) {
        for (int j = i + 1; j < _entities.length; j++) {
          final a = _entities[i], b = _entities[j];
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

          // Third-cube repulsion: strong push outsider away
          if (a.isSpiraling != b.isSpiraling) {
            final outsider = a.isSpiraling ? b : a;
            final spiraling = a.isSpiraling ? a : b;
            
            final dx2 = outsider.x - spiraling.x;
            final dy2 = outsider.y - spiraling.y;
            final d2 = sqrt(dx2 * dx2 + dy2 * dy2);
            if (d2 < 1e-10) continue;
            
            final repelRange = max(0.1, (baseDistPixel * 5.0) / _screenSize.width); 
            if (d2 > repelRange) continue;
            
            final strength = (repelRange - d2) / repelRange * 0.15; // Very strong force

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
                 final strength = (attractRangePixel - distPixel) / attractRangePixel * 0.008;
                 a.vx += (dx / dist) * strength;
                 a.vy += (dy / dist) * strength;
                 b.vx -= (dx / dist) * strength;
                 b.vy -= (dy / dist) * strength;
               } else if (distPixel < safeDistancePixel * 0.9) {
                 final strength = (safeDistancePixel * 0.9 - distPixel) / (safeDistancePixel * 0.9) * 0.03;
                 a.vx -= (dx / dist) * strength;
                 a.vy -= (dy / dist) * strength;
                 b.vx += (dx / dist) * strength;
                 b.vy += (dy / dist) * strength;
               }

             }
           } else {
             final repelRangePixel = (baseDistPixel * 3.5).clamp(0.0, 150.0);
             if (distPixel < repelRangePixel) {
                final strength = (repelRangePixel - distPixel) / repelRangePixel * 0.005;
                a.vx -= (dx / dist) * strength;
                a.vy -= (dy / dist) * strength;
                b.vx += (dx / dist) * strength;
                b.vy += (dy / dist) * strength;
             }
          }
        }
      }

      // --- Spiral initiation ---
      for (int i = 0; i < _entities.length; i++) {
        for (int j = i + 1; j < _entities.length; j++) {
          final a = _entities[i], b = _entities[j];
          if (a.isSpiraling || b.isSpiraling) continue;
          if (a.mergeCooldown > 0 || b.mergeCooldown > 0) continue;

          final sizeRatio = a.renderSize < b.renderSize
              ? a.renderSize / b.renderSize
              : b.renderSize / a.renderSize;
          if (sizeRatio < 0.80) continue;

          final dxPixel = (b.x - a.x) * _screenSize.width;
          final dyPixel = (b.y - a.y) * _screenSize.height;
          final distPixel = max(sqrt(dxPixel * dxPixel + dyPixel * dyPixel), 0.001);

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


    } else if (widget.cubeMode == CubeMode.orbit) {
      for (final e in _entities) {
        if (e.parentCore == null) continue;
        e.orbitAngle += e.orbitSpeed * dt * 60 * widget.speed;
        final cosA = cos(e.orbitAngle);
        final sinA = sin(e.orbitAngle);
        e.x = e.parentCore!.x + e.orbitRadius * cosA;
        e.y = e.parentCore!.y + e.orbitRadius * sinA * cos(e.orbitTilt);
        e.x = e.x.clamp(0.0, 1.0);
        e.y = e.y.clamp(0.0, 1.0);
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
              (0.5 + Random().nextDouble() * 2.5) / (0.3 + e.orbitRadius * 4) * 0.75;
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
                (0.5 + Random().nextDouble() * 2.5) / (0.3 + smaller.orbitRadius * 4) * 0.75;
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

      final topExclusion3 = widget.topExclusion;
      for (final e in _entities) {
        if (e.x.isNaN || e.x.isInfinite) e.x = 0.5;
        if (e.y.isNaN || e.y.isInfinite) e.y = (topExclusion3 + 1.0) * 0.5;
        if (e.renderSize.isNaN || e.renderSize.isInfinite) e.renderSize = 10.0;
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
      oldWidget.controller?.onLogoBurst = null;
      oldWidget.controller?.onTrySplit = null;
      widget.controller?.onRepelUpdate = setRepelPoint;
      widget.controller?.onBurst = triggerBurst;
      widget.controller?.onLogoBurst = _triggerLogoBurst;
      widget.controller?.onTrySplit = _trySplitAt;
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
          _entities.add(_MergeEntity(
            baseIndices: [i],
          ));
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
    widget.controller?.onTrySplit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenSize = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : (MediaQuery.maybeSizeOf(context)?.width ?? 800.0),
          constraints.maxHeight.isFinite ? constraints.maxHeight : (MediaQuery.maybeSizeOf(context)?.height ?? 800.0),
        );
        final primaryColor = Theme.of(context).colorScheme.primary;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return CustomPaint(
                painter: _CubePainter(
                  entities: _entities,
                  brightness: brightness,
                  primaryColor: primaryColor,
                  isRtl: isRtl,
                ),
              );
            },
          ),
        );
      },
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
  double ignoreRepelTimer = 0.0;
  double _timeSinceLastChange = 0.0;

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
    double topExclusion,
  ) {
    _timeSinceLastChange += dt;
    if (_timeSinceLastChange > 0.033) {
      _timeSinceLastChange = 0.0;
      if (!isSpiraling) {
        vx += (Random().nextDouble() - 0.5) * 0.02;
        vy += (Random().nextDouble() - 0.5) * 0.02;
      }
    }

    if (ignoreRepelTimer > 0) ignoreRepelTimer -= dt * 60;

    if (repelPoint != null && !isSpiraling && ignoreRepelTimer <= 0) {
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
    if (!isSpiraling) {
      if (y < topExclusion + repZone) vy += (topExclusion + repZone - y) / repZone * repForce;
      if (y > 1.0 - repZone) vy -= (repZone - (1.0 - y)) / repZone * repForce;
      if (x < repZone) vx += (repZone - x) / repZone * repForce;
      if (x > 1.0 - repZone) vx -= (repZone - (1.0 - x)) / repZone * repForce;
    }

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

    if (!isSpiraling) {
      if (x < 0) {
        x = 0;
        vx = -vx * 0.92;
      }
      if (x > 1) {
        x = 1;
        vx = -vx * 0.92;
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
  final Color primaryColor;
  final bool isRtl;

  _CubePainter({
    required this.entities,
    required this.brightness,
    required this.primaryColor,
    required this.isRtl,
  });

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
      if (entity.x.isNaN || entity.x.isInfinite) continue;
      if (entity.y.isNaN || entity.y.isInfinite) continue;
      if (entity.renderSize.isNaN || entity.renderSize.isInfinite) continue;

      final h = entity.renderSize * 0.5;
      final px = entity.x * size.width;
      final py = entity.y * size.height;

      final double lightX = isRtl ? 0.9 : 0.1;
      final double lightY = 0.05;
      final double ldx = lightX - entity.x;
      final double ldy = entity.y - lightY; 
      final double ldz = 0.5;
      final double lDist = sqrt(ldx * ldx + ldy * ldy + ldz * ldz);
      final double lx = ldx / lDist;
      final double ly = ldy / lDist;
      final double lz = ldz / lDist;

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

        final dot = nx * lx + ny * ly + nz * lz;
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
    if (!fd.x0.isFinite || !fd.y0.isFinite ||
        !fd.x1.isFinite || !fd.y1.isFinite ||
        !fd.x2.isFinite || !fd.y2.isFinite ||
        !fd.x3.isFinite || !fd.y3.isFinite) return;

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

    strokePaint.color = primaryColor;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => true;
}
