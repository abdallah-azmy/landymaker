import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/cube_geometry.dart' as cg;

/// Visual layout variant for [CubeLoader].
enum CubeLoaderVariant {
  /// 27 cubes in a 3x3x3 isometric cluster (brand logo). Replaces LoadingLogo.
  logo,

  /// Single cube spinner. Replaces CubeSpinner.
  single,

  /// 3 cubes in a triangular orbit. Replaces CubeProgress.
  cluster,

  /// Horizontal row of cubes with undulating wave.
  linear,

  /// Radial circle of cubes undulating in size and depth.
  circular,

  /// Staggered gravity bouncing cubes with squash and stretch.
  physics,

  /// Logo with rotation around the body diagonal axis (3 equal faces visible).
  logoCornerAxis,

  /// Logo with cascading wave animation through the 27 cubes.
  logoWave,

  /// Single cube wobbling on one corner.
  singleWobble,

  /// Clusters in a spiral orbital pattern.
  clusterSpiral,

  /// Bidirectional wave (meets in the middle).
  linearBidi,

  /// Double counter-rotating rings.
  circularDouble,

  /// Premium Rubik-style 3×3×3 cube logo with subtle breathing.
  logoPremium,

  /// Premium Logo with corner-to-corner body diagonal rotation.
  logoPremiumCornerAxis,

  /// Premium logo with gentle floating motion.
  logoPremiumFloat,

  /// Premium logo with wave passing through the cube body.
  logoPremiumWave,

  /// Premium logo with center core pulsing softly.
  logoPremiumCorePulse,

  /// Premium logo with very slow body-diagonal rotation.
  logoPremiumRotate,

  /// Experimental: premium logo with layered depth breathing.
  logoPremiumAura,
}

/// Animation state for [CubeLoader].
enum CubeLoaderState { idle, breathing, loading, rotatingLayers }

/// Size tier for rendering complexity.
enum _CubeLoaderTier { micro, tiny, small, medium, large }

// =============================================================================
// Widget
// =============================================================================

class CubeLoader extends StatefulWidget {
  final double size;
  final CubeLoaderState initialState;
  final CubeLoaderVariant variant;
  final bool interactive;
  final bool showGlow;
  final double? value;
  final bool showPercentage;
  final Color? color;

  const CubeLoader({
    super.key,
    this.size = 48.0,
    this.initialState = CubeLoaderState.breathing,
    this.variant = CubeLoaderVariant.logo,
    this.interactive = false,
    this.showGlow = true,
    this.value,
    this.showPercentage = false,
    this.color,
  });

  _CubeLoaderTier get _tier {
    if (size <= 24) return _CubeLoaderTier.micro;
    if (size <= 32) return _CubeLoaderTier.tiny;
    if (size <= 48) return _CubeLoaderTier.small;
    if (size <= 96) return _CubeLoaderTier.medium;
    return _CubeLoaderTier.large;
  }

  @override
  State<CubeLoader> createState() => _CubeLoaderState();
}

class _CubeLoaderState extends State<CubeLoader> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _explodeController;
  late CubeLoaderState _currentState;

  bool _isHovered = false;
  int? _hoveredLayer;
  bool _isExploding = false;
  double _explodeProgress = 0.0;
  double _tapRotation = 0.0;

  // Continuously accumulated angles (no loop reset jumps)
  double _rotationAngle = 0.0;
  double _clusterOrbitAngle = 0.0;
  double _lastTickValue = 0.0;

  // Smoothed rotation speed (lerps toward target)
  double _currentSpeed = 0.08;
  double _targetSpeed = 0.08;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _targetSpeed = _speedForState(_currentState);
    _currentSpeed = _targetSpeed;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _controller.addListener(_accumulateAngles);

    _explodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 960),
    )..addListener(_onExplodeTick);
    _explodeController.addStatusListener(_onExplodeStatus);
  }

  static double _speedForState(CubeLoaderState state) {
    return switch (state) {
      CubeLoaderState.idle => 0.05,
      CubeLoaderState.breathing => 0.08,
      CubeLoaderState.loading => 0.3,
      CubeLoaderState.rotatingLayers => 0.2,
    };
  }

  void _accumulateAngles() {
    final v = _controller.value;
    double delta;
    if (v >= _lastTickValue) {
      delta = v - _lastTickValue;
    } else {
      delta = (1.0 - _lastTickValue) + v;
    }
    _targetSpeed = _speedForState(_currentState);
    _currentSpeed += (_targetSpeed - _currentSpeed) * 0.1;
    _rotationAngle += delta * _currentSpeed * pi * 2;
    _clusterOrbitAngle += delta * 0.2 * pi * 2;
    _lastTickValue = v;
  }

  void _onExplodeTick() {
    final v = _explodeController.value;
    setState(() {
      if (v < 1 / 3) {
        final t = v * 3;
        _explodeProgress = t;
        _tapRotation = 3.0 * t;
      } else if (v < 2 / 3) {
        final t = (v - 1 / 3) * 3;
        _explodeProgress = 1 - t;
        _tapRotation = 3.0 + 1.6 * t;
      } else {
        final t = (v - 2 / 3) * 3;
        _explodeProgress = t;
        _tapRotation = 4.6 + 1.0 * t;
      }
    });
  }

  void _onExplodeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isExploding = false;
        _explodeProgress = 0.0;
        _tapRotation = 0.0;
        _currentState = widget.initialState;
      });
    }
  }

  @override
  void didUpdateWidget(CubeLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialState != _currentState && !_isExploding) {
      _currentState = widget.initialState;
    }
  }

  @override
  void dispose() {
    _explodeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.interactive || _isExploding) return;
    setState(() {
      _isExploding = true;
      _explodeProgress = 0.0;
      _tapRotation = 0.0;
    });
    _explodeController.forward(from: 0);
  }

  void _onHover(bool hovering) {
    if (!widget.interactive) return;
    setState(() {
      _isHovered = hovering;
      if (!hovering) _hoveredLayer = null;
    });
  }

  void _onHoverMove(PointerHoverEvent e) {
    if (!widget.interactive || _currentState != CubeLoaderState.rotatingLayers)
      return;
    final h = widget.size;
    final y = e.localPosition.dy;
    final band = h / 3;
    setState(() {
      _hoveredLayer = switch (y) {
        _ when y < band => 1,
        _ when y < band * 2 => 0,
        _ => -1,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.color ?? theme.colorScheme.primary;
    final isDark = widget.color != null
        ? false
        : theme.brightness == Brightness.dark;
    final cubeColor =
        widget.color ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));

    final breath = sin(_controller.value * pi * 2);
    final loadedBreath = sin(_controller.value * pi * 2 * 0.7);

    bool showPct = widget.showPercentage && widget.value != null;

    Widget loader = MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      onHover: _onHoverMove,
      child: GestureDetector(
        onTap: _handleTap,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return RepaintBoundary(
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CubeLoaderPainter(
                    animValue: _controller.value,
                    rotationAngle: _rotationAngle,
                    clusterOrbitAngle: _clusterOrbitAngle,
                    state: _currentState,
                    variant: widget.variant,
                    tier: widget._tier,
                    primaryColor: primaryColor,
                    cubeColor: cubeColor,
                    isDark: isDark,
                    breath: breath,
                    loadedBreath: loadedBreath,
                    isHovered: _isHovered,
                    isExploding: _isExploding,
                    explodeProgress: _explodeProgress,
                    tapRotation: _tapRotation,
                    showGlow: widget.showGlow,
                    value: widget.value,
                    hoveredLayer: _hoveredLayer,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (!showPct) return loader;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          loader,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${(widget.value! * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: (widget.size * 0.2).clamp(10.0, 16.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Painter
// =============================================================================

class _CubeLoaderPainter extends CustomPainter {
  final double animValue;
  final double rotationAngle;
  final double clusterOrbitAngle;
  final CubeLoaderState state;
  final CubeLoaderVariant variant;
  final _CubeLoaderTier tier;
  final Color primaryColor;
  final Color cubeColor;
  final bool isDark;
  final double breath;
  final double loadedBreath;
  final bool isHovered;
  final bool isExploding;
  final double explodeProgress;
  final double tapRotation;
  final bool showGlow;
  final double? value;
  final int? hoveredLayer;

  _CubeLoaderPainter({
    required this.animValue,
    required this.rotationAngle,
    required this.clusterOrbitAngle,
    required this.state,
    required this.variant,
    required this.tier,
    required this.primaryColor,
    required this.cubeColor,
    required this.isDark,
    required this.breath,
    required this.loadedBreath,
    required this.isHovered,
    required this.isExploding,
    required this.explodeProgress,
    required this.tapRotation,
    required this.showGlow,
    this.value,
    this.hoveredLayer,
  });

  // ---- Per-instance scratch buffers (safe for concurrent painters) ----
  final List<List<double>> _tv = List.generate(8, (_) => [0.0, 0.0, 0.0]);
  final List<double> _nv = [0.0, 0.0, 0.0];
  final List<Offset> _quadPts = List.filled(4, Offset.zero);

  // ---- Preallocated face buffer (zero-allocation in paint loop) ----
  final List<_FaceData> _faceBuffer = List.generate(162, (_) => _FaceData());
  final List<int> _sortKeys = List.generate(162, (i) => i);
  int _faceCount = 0;

  final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // ---- Isometric rotation angles ----
  static const double _rx = 0.70;
  static const double _baseRy = pi / 4;

  // ---- Pre-computed rotation for lighting (cached per frame) ----
  cg.RotationMatrix? _lightRot;

  @override
  void paint(Canvas canvas, Size size) {
    final isReduced = tier == _CubeLoaderTier.micro;

    // Rotation (continuously accumulated, no loop-reset jumps)
    double ry = _baseRy;
    if (!isReduced) {
      ry += rotationAngle;
    }

    double rx = _rx;
    if (isHovered) {
      rx += 0.04;
      ry += 0.03;
    }
    if (isExploding) {
      ry += tapRotation;
    }

    final rot = cg.computeRotation(rx, ry, 0.0);
    _lightRot = cg.computeRotation(rx, ry, 0.0);

    switch (variant) {
      case CubeLoaderVariant.logo:
      case CubeLoaderVariant.logoPremiumCornerAxis:
        _paintPremiumCornerAxis(canvas, size);
        break;
      case CubeLoaderVariant.single:
        _paintSingle(canvas, size, rot);
        break;
      case CubeLoaderVariant.cluster:
        _paintCluster(canvas, size, rot);
        break;
      case CubeLoaderVariant.linear:
        _paintLinear(canvas, size, rot);
        break;
      case CubeLoaderVariant.circular:
        _paintCircular(canvas, size, rot);
        break;
      case CubeLoaderVariant.physics:
        _paintPhysics(canvas, size, rot);
        break;
      case CubeLoaderVariant.logoCornerAxis:
        _paintLogoCornerAxis(canvas, size);
        break;
      case CubeLoaderVariant.logoWave:
        _paintLogoWave(canvas, size, rot);
        break;
      case CubeLoaderVariant.singleWobble:
        _paintSingleWobble(canvas, size);
        break;
      case CubeLoaderVariant.clusterSpiral:
        _paintClusterSpiral(canvas, size, rot);
        break;
      case CubeLoaderVariant.linearBidi:
        _paintLinearBidi(canvas, size, rot);
        break;
      case CubeLoaderVariant.circularDouble:
        _paintCircularDouble(canvas, size, rot);
        break;

      case CubeLoaderVariant.logoPremium:
      case CubeLoaderVariant.logoPremiumFloat:
      case CubeLoaderVariant.logoPremiumWave:
      case CubeLoaderVariant.logoPremiumCorePulse:
      case CubeLoaderVariant.logoPremiumAura:
        _paintPremium(canvas, size, rot);
        break;
      case CubeLoaderVariant.logoPremiumRotate:
        _paintPremiumRotate(canvas, size);
        break;
    }
  }

  // ---- Logo variant (27 cubes, 3x3x3) ----
  void _paintLogo(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final gapBase = size.width * 0.275;
    final cubeH = size.width * 0.255;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    final double gap;
    if (state == CubeLoaderState.breathing ||
        state == CubeLoaderState.loading) {
      gap = gapBase + breath * (size.width * 0.04);
    } else {
      gap = gapBase;
    }

    const maxI = 1;
    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int i = -maxI; i <= maxI; i++) {
      for (int j = -maxI; j <= maxI; j++) {
        for (int k = -maxI; k <= maxI; k++) {
          double cX = i * gap;
          double cY = j * gap;
          double cZ = k * gap;

          if (isExploding) {
            final dist = sqrt(cX * cX + cY * cY + cZ * cZ);
            if (dist > 0.01) {
              final normDist = dist / (gapBase * 2.5);
              final offset = explodeProgress * normDist * size.width * 0.3;
              cX += (cX / dist) * offset;
              cY += (cY / dist) * offset;
              cZ += (cZ / dist) * offset;
            }
          }

          // Layer-specific Y-axis rotation (before global isometric transform)
          if (state == CubeLoaderState.rotatingLayers) {
            double layerRot;
            if (j == -1) {
              layerRot = rotationAngle;
            } else if (j == 0) {
              layerRot = -rotationAngle * 0.5;
            } else {
              layerRot = rotationAngle * 1.5;
            }
            // Accelerate the hovered layer in interactive mode
            if (hoveredLayer == j) {
              layerRot *= 1.8;
            }
            final lc = cos(layerRot);
            final ls = sin(layerRot);
            final nx = cX * lc + cZ * ls;
            final nz = -cX * ls + cZ * lc;
            cX = nx;
            cZ = nz;
          }

          // Transform cube center
          double y1 = cY * rot.cxR - cZ * rot.sxR;
          double z1 = cY * rot.sxR + cZ * rot.cxR;
          cY = y1;
          cZ = z1;
          double x1 = cX * rot.cyR + cZ * rot.syR;
          double z2 = -cX * rot.syR + cZ * rot.cyR;
          cX = x1;
          cZ = z2;
          double x2 = cX * rot.czR - cY * rot.szR;
          double y2 = cX * rot.szR + cY * rot.czR;
          cX = x2;
          cY = y2;

          final centerX = px + cX;
          final centerY = py - cY;
          final ao = cg.ambientOcclusion(i, j, k);

          _renderCubeFaces(
            centerX: centerX,
            centerY: centerY,
            h: h,
            cZ: cZ,
            scaleX: 1,
            scaleY: 1,
            scaleZ: 1,
            cornerRadius: cornerRadius,
            rot: rot,
            ao: ao,
          );
        }
      }
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Single cube variant (replaces CubeSpinner) ----
  void _paintSingle(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final h = size.width * 0.3;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.12).clamp(1.2, 2.5);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    _faceCount = 0;
    // Multi-axis rotation at different speeds for a random-looking tumble
    final singleRot = cg.computeRotation(
      _rx + rotationAngle * 1.4,
      _baseRy + rotationAngle * 0.7,
      rotationAngle * 0.5,
    );
    _renderCubeFaces(
      centerX: px,
      centerY: py,
      h: h,
      cZ: 0,
      scaleX: 1,
      scaleY: 1,
      scaleZ: 1,
      cornerRadius: cornerRadius,
      rot: singleRot,
    );

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Cluster variant (3 cubes, replaces CubeProgress) ----
  void _paintCluster(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final clusterR = size.width * 0.22;
    final cubeH = size.width * 0.13;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.1).clamp(0.5, 1.5);
    const nCubes = 3;
    final isDeterminate = value != null;
    final v = value ?? 0.0;

    int activeCount = nCubes;
    double edgeProgress = 0.0;
    if (isDeterminate) {
      activeCount = (v * nCubes).floor();
      edgeProgress = (v * nCubes) - activeCount;
    }

    final clusterAngle = clusterOrbitAngle;
    final clusterEntries = <_ClusterEntry>[];

    for (int i = 0; i < nCubes; i++) {
      final angle = clusterAngle + i * 2 * pi / nCubes;
      final cubeCx = size.width * 0.5 + clusterR * cos(angle);
      final cubeCy = size.height * 0.5 + clusterR * sin(angle);

      double cubeBrightness;
      if (isDeterminate) {
        if (i < activeCount) {
          cubeBrightness = 1.0;
        } else if (i == activeCount) {
          cubeBrightness = 0.3 + edgeProgress * 0.7;
        } else {
          cubeBrightness = 0.12;
        }
      } else {
        cubeBrightness = 1.0;
      }

      if (cubeBrightness < 0.01) continue;

      _faceCount = 0;
      _renderCubeFaces(
        centerX: cubeCx,
        centerY: cubeCy,
        h: h,
        cZ: 0,
        scaleX: 1,
        scaleY: 1,
        scaleZ: 1,
        cornerRadius: cornerRadius,
        rot: rot,
      );

      final cubeFaces = _faceBuffer.sublist(0, _faceCount);
      cubeFaces.sort((a, b) => a.z.compareTo(b.z));
      clusterEntries.add(
        _ClusterEntry(
          faces: cubeFaces,
          brightness: cubeBrightness,
          yPos: cubeCy,
        ),
      );
    }

    clusterEntries.sort((a, b) => a.yPos.compareTo(b.yPos));

    for (final entry in clusterEntries) {
      for (final face in entry.faces) {
        final dot = _faceBrightness(face.faceIdx, rot);
        _fillPaint.color = Color.lerp(
          Colors.black,
          cubeColor,
          (0.4 + max(0.0, dot) * 0.6) * entry.brightness,
        )!;
        canvas.drawPath(face.path, _fillPaint);
      }
    }

    _strokePaint.strokeWidth = strokeWidth;
    _strokePaint.color = primaryColor.withValues(alpha: 0.6);
    for (final entry in clusterEntries) {
      for (final face in entry.faces) {
        canvas.drawPath(face.path, _strokePaint);
      }
    }
  }

  // ---- Linear variant (5 cubes wave, replaces LinearProgressIndicator) ----
  void _paintLinear(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final nCubes = 5;
    final cubeH = size.width * 0.14;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final spacing = size.width * 0.20;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int i = 0; i < nCubes; i++) {
      final idx = i - 2;
      double cX = idx * spacing;

      final phase = animValue * pi * 2 - idx * 0.8;
      final wave = sin(phase);
      double cY = wave * size.height * 0.12;
      double cZ = cos(phase) * size.width * 0.05;

      final scale = 0.75 + (wave + 1.0) * 0.125;

      _renderCubeFaces(
        centerX: px + cX,
        centerY: py - cY,
        h: h,
        cZ: cZ,
        scaleX: scale,
        scaleY: scale,
        scaleZ: scale,
        cornerRadius: cornerRadius,
        rot: rot,
      );
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Circular variant (6 cubes undulating orbit, replaces CircularProgressIndicator) ----
  void _paintCircular(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final nCubes = 6;
    final radius = size.width * 0.32;
    final cubeH = size.width * 0.13;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int i = 0; i < nCubes; i++) {
      final angle = i * 2 * pi / nCubes + clusterOrbitAngle;
      double cX = radius * cos(angle);
      double cY = radius * sin(angle);

      final wave = sin(animValue * pi * 2 - i * 1.0);
      double cZ = wave * size.width * 0.08;
      final scale = 0.7 + (wave + 1.0) * 0.15;

      _renderCubeFaces(
        centerX: px + cX,
        centerY: py - cY,
        h: h,
        cZ: cZ,
        scaleX: scale,
        scaleY: scale,
        scaleZ: scale,
        cornerRadius: cornerRadius,
        rot: rot,
      );
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Physics variant (3 cubes elastic bounce and squash/stretch) ----
  void _paintPhysics(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final nCubes = 3;
    final cubeH = size.width * 0.14;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int i = 0; i < nCubes; i++) {
      double cX = (i - 1) * size.width * 0.28;
      final t = (animValue - i * 0.25) % 1.0;

      double height = 0.0;
      double squash = 1.0;
      if (t < 0.4) {
        final nt = t / 0.4;
        height = 1.0 - 4 * (nt - 0.5) * (nt - 0.5);
        if (nt > 0.93) {
          squash = 1.0 - (nt - 0.93) * 4.3;
        }
      } else if (t < 0.7) {
        final nt = (t - 0.4) / 0.3;
        height = 0.5 * (1.0 - 4 * (nt - 0.5) * (nt - 0.5));
        if (nt > 0.93 || nt < 0.07) {
          squash = 0.9;
        }
      } else if (t < 0.9) {
        final nt = (t - 0.7) / 0.2;
        height = 0.2 * (1.0 - 4 * (nt - 0.5) * (nt - 0.5));
      } else {
        height = 0.0;
        squash = 1.0;
      }

      double cY = -size.height * 0.24 + height * size.height * 0.48;
      double cZ = 0.0;

      double scaleX = 1.0 / sqrt(squash);
      double scaleY = squash;
      double scaleZ = scaleX;

      _renderCubeFaces(
        centerX: px + cX,
        centerY: py - cY,
        h: h,
        cZ: cZ,
        scaleX: scaleX,
        scaleY: scaleY,
        scaleZ: scaleZ,
        cornerRadius: cornerRadius,
        rot: rot,
      );
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Logo corner-axis (body diagonal rotation, 3 faces equally visible) ----
  void _paintLogoCornerAxis(Canvas canvas, Size size) {
    final n = 3;
    final spacing = size.width * 0.12;
    final cubeH = spacing * 0.7;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final offset = -(n - 1) * 0.5;

    final double bda = 1.0 / sqrt(3.0);

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int ix = 0; ix < n; ix++) {
      for (int iy = 0; iy < n; iy++) {
        for (int iz = 0; iz < n; iz++) {
          final baseX = (ix + offset) * spacing;
          final baseY = (iy + offset) * spacing;
          final baseZ = (iz + offset) * spacing;

          final t = animValue * 2 * pi + (ix + iy + iz) * 0.15;

          final rotated = <double>[baseX, baseY, baseZ];
          cg.rotatePointAxis(rotated, bda, bda, bda, t, rotated);

          _renderCubeFaces(
            centerX: px + rotated[0],
            centerY: py - rotated[1],
            h: h,
            cZ: rotated[2],
            scaleX: 1.0,
            scaleY: 1.0,
            scaleZ: 1.0,
            cornerRadius: cornerRadius,
            rot: _lightRot!,
          );
        }
      }
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Logo cascading wave (cubes pulse outward from center) ----
  void _paintLogoWave(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final n = 3;
    final spacing = size.width * 0.12;
    final cubeH = spacing * 0.7;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final offset = -(n - 1) * 0.5;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int ix = 0; ix < n; ix++) {
      for (int iy = 0; iy < n; iy++) {
        for (int iz = 0; iz < n; iz++) {
          final dist = sqrt((ix - 1) * (ix - 1) + (iy - 1) * (iy - 1) + (iz - 1) * (iz - 1));
          final phase = dist * 0.7 - animValue * 2 * pi;
          final wave = sin(phase);
          final scale = 0.6 + (wave + 1.0) * 0.2;
          final cZ = wave * spacing * 0.5;

          _renderCubeFaces(
            centerX: px + (ix + offset) * spacing,
            centerY: py - (iy + offset) * spacing,
            h: h,
            cZ: cZ + (iz + offset) * spacing * 0.3,
            scaleX: scale,
            scaleY: scale,
            scaleZ: 0.7 + (wave + 1.0) * 0.15,
            cornerRadius: cornerRadius,
            rot: rot,
          );
        }
      }
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Single wobble (wobbles on one corner) ----
  void _paintSingleWobble(Canvas canvas, Size size) {
    final cubeH = size.width * 0.35;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    final wobbleX = sin(animValue * 2 * pi) * 0.4;
    final wobbleY = cos(animValue * 2 * pi * 0.63) * 0.35;
    final wobbleZ = sin(animValue * 2 * pi * 1.17) * 0.25;
    final wobbleRot = cg.computeRotation(
      _rx + wobbleX,
      _baseRy + wobbleY,
      wobbleZ,
    );

    _renderCubeFaces(
      centerX: px,
      centerY: py,
      h: h,
      cZ: 0.0,
      scaleX: 1.0,
      scaleY: 1.0,
      scaleZ: 1.0,
      cornerRadius: cornerRadius,
      rot: wobbleRot,
    );
    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Cluster spiral (spiraling orbital pattern) ----
  void _paintClusterSpiral(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final nCubes = 8;
    final cubeH = size.width * 0.1;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int i = 0; i < nCubes; i++) {
      final t = animValue * 2 * pi + i * 2.5;
      final radius = size.width * 0.06 + i * size.width * 0.035;
      final x = radius * cos(t);
      final y = radius * sin(t);
      final z = (i - nCubes * 0.5) * size.width * 0.06;
      final scale = 0.5 + (sin(t + i) + 1.0) * 0.25;

      _renderCubeFaces(
        centerX: px + x,
        centerY: py - y,
        h: h,
        cZ: z,
        scaleX: scale,
        scaleY: scale,
        scaleZ: scale,
        cornerRadius: cornerRadius,
        rot: rot,
      );
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Linear bidirectional (wave meets in middle) ----
  void _paintLinearBidi(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final nCubes = 8;
    final cubeH = size.width * 0.1;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final totalW = size.width * 0.7;
    final spacing = totalW / (nCubes - 1);
    final startX = -totalW * 0.5;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int i = 0; i < nCubes; i++) {
      final double cX = startX + i * spacing;
      final phase1 = i * 0.8 - animValue * 2 * pi;
      final phase2 = i * 0.8 + animValue * 2 * pi;
      final wave1 = sin(phase1);
      final wave2 = sin(phase2);
      final wave = (wave1 + wave2) * 0.5;
      final cY = wave * size.height * 0.15;
      final cZ = wave * size.width * 0.1;
      final scale = 0.5 + (wave + 1.0) * 0.25;

      _renderCubeFaces(
        centerX: px + cX,
        centerY: py - cY,
        h: h,
        cZ: cZ,
        scaleX: scale,
        scaleY: scale,
        scaleZ: scale,
        cornerRadius: cornerRadius,
        rot: rot,
      );
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Circular double (two counter-rotating rings) ----
  void _paintCircularDouble(Canvas canvas, Size size, cg.RotationMatrix rot) {
    final nCubes = 6;
    final cubeH = size.width * 0.1;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.22).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.08).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final radius = size.width * 0.28;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int ring = 0; ring < 2; ring++) {
      final double sign = ring == 0 ? 1.0 : -1.0;
      final double zOffset = sign * size.width * 0.08;
      for (int i = 0; i < nCubes; i++) {
        final angle = i * 2 * pi / nCubes + animValue * 2 * pi * sign;
        final cX = radius * cos(angle);
        final cY = radius * sin(angle);
        final cZ = zOffset + sin(angle * 2 + animValue * 2 * pi) * size.width * 0.05;
        final wave = sin(animValue * 2 * pi - i * 1.0);
        final scale = 0.6 + (wave + 1.0) * 0.2;

        _renderCubeFaces(
          centerX: px + cX,
          centerY: py - cY,
          h: h,
          cZ: cZ,
          scaleX: scale,
          scaleY: scale,
          scaleZ: scale,
          cornerRadius: cornerRadius,
          rot: rot,
        );
      }
    }

    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor);
  }

  // ---- Premium logo variants ----

  void _paintPremium(Canvas canvas, Size size, cg.RotationMatrix rot) {
    const n = 3;
    final gap = size.width * 0.24;
    final cubeH = size.width * 0.19;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.25).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.10).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final offset = -(n - 1) * 0.5;
    final t = animValue;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int ix = 0; ix < n; ix++) {
      for (int iy = 0; iy < n; iy++) {
        for (int iz = 0; iz < n; iz++) {
          final dist = sqrt(
            (ix - 1) * (ix - 1) + (iy - 1) * (iy - 1) + (iz - 1) * (iz - 1),
          );

          double cX = (ix + offset) * gap;
          double cY = (iy + offset) * gap;
          double cZ = (iz + offset) * gap;
          double s = 1.0;

          switch (variant) {
            case CubeLoaderVariant.logoPremiumCornerAxis:
              // Handled by _paintPremiumCornerAxis separately.
              break;
            case CubeLoaderVariant.logoPremium:
              cZ += breath * size.width * 0.015;
              s = 1.0 + breath * 0.03;
              break;
            case CubeLoaderVariant.logoPremiumFloat:
              cY += sin(t * pi * 2) * size.width * 0.02;
              break;
            case CubeLoaderVariant.logoPremiumWave:
              final wave = sin(dist * 0.8 - t * pi * 2);
              cZ += wave * gap * 0.3;
              s = 0.85 + 0.15 * (wave * 0.5 + 0.5);
              break;
            case CubeLoaderVariant.logoPremiumCorePulse:
              final pulse = sin(t * pi * 2 * 0.8);
              if (dist < 1.5) {
                s = 1.0 + pulse * 0.06;
                cZ += pulse * size.width * 0.01;
              }
              break;
            case CubeLoaderVariant.logoPremiumAura:
              final layerBreath = sin(t * pi * 2 + dist * 0.5);
              s = 0.92 + 0.08 * (layerBreath * 0.5 + 0.5);
              cZ += layerBreath * size.width * 0.008;
              break;
            default:
              break;
          }

          double y1 = cY * rot.cxR - cZ * rot.sxR;
          double z1 = cY * rot.sxR + cZ * rot.cxR;
          cY = y1; cZ = z1;
          double x1 = cX * rot.cyR + cZ * rot.syR;
          double z2 = -cX * rot.syR + cZ * rot.cyR;
          cX = x1; cZ = z2;
          double x2 = cX * rot.czR - cY * rot.szR;
          double y2 = cX * rot.szR + cY * rot.czR;
          cX = x2; cY = y2;

          final centerX = px + cX;
          final centerY = py - cY;
          final ao = cg.ambientOcclusion(ix - 1, iy - 1, iz - 1);

          _renderCubeFaces(
            centerX: centerX,
            centerY: centerY,
            h: h,
            cZ: cZ,
            scaleX: s,
            scaleY: s,
            scaleZ: s,
            cornerRadius: cornerRadius,
            rot: rot,
            ao: ao,
          );
        }
      }
    }

    final strokeColor = isDark ? const Color(0xFF334155) : const Color(0xFF0F172A);
    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor, strokeColor: strokeColor);
  }

  void _paintPremiumCornerAxis(Canvas canvas, Size size) {
    const n = 3;
    final gap = size.width * 0.24;
    final cubeH = size.width * 0.19;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.25).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.10).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final offset = -(n - 1) * 0.5;
    final bda = 1.0 / sqrt(3.0);

    // To match logoPremium exactly, we use its base orientation but add
    // a 2D Z-rotation so it visually stands on one corner.
    // The logoPremium base orientation is rx=0.70, ry=pi/4.
    // In that orientation, the vector from the bottom corner (-1, -1, 1)
    // to the top corner (1, 1, -1) has screen coordinates cX ≈ 0.6218, cY ≈ 1.409.
    // To make this vector perfectly vertical, we rotate by rz = atan2(cX, cY).
    // M_target = RotX(asin(1/sqrt(3))) * RotY(pi/4) -> true isometric projection
    // Equivalent RotZ * RotY * RotX angles:
    const double baseRx = 0.7853981633974483; // pi / 4
    const double baseRy = 0.6154797086703873; // asin(1 / sqrt(3))
    const double cornerRz = 0.5235987755982988; // pi / 6
    
    final cornerRot = cg.computeRotation(baseRx, baseRy, cornerRz);
    _lightRot = cornerRot;

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    final cubes = <(int, int, int, List<double>)>[];
    for (int ix = 0; ix < n; ix++) {
      for (int iy = 0; iy < n; iy++) {
        for (int iz = 0; iz < n; iz++) {
          final baseX = (ix + offset) * gap;
          final baseY = (iy + offset) * gap;
          final baseZ = (iz + offset) * gap;

          // The axis connecting bottom (-1,-1,1) to top (1,1,-1) is (1, 1, -1).
          // We rotate around this axis so the silhouette rotates like a diamond.
          final rotAngle = animValue * 2 * pi / 3;
          final rotated = <double>[baseX, baseY, baseZ];
          cg.rotatePointAxis(rotated, bda, bda, -bda, rotAngle, rotated);

          // Project the 3D center to 2D screen space using the camera matrix
          final projected = <double>[0.0, 0.0, 0.0];
          cg.rotatePoint(rotated, cornerRot, projected);
          
          cubes.add((ix, iy, iz, projected));
        }
      }
    }

    // Sort cubes back-to-front by their projected Z depth
    cubes.sort((a, b) => a.$4[2].compareTo(b.$4[2]));

    final rotAngle = animValue * 2 * pi / 3;
    for (final c in cubes) {
      _faceCount = 0;
      final ix = c.$1;
      final iy = c.$2;
      final iz = c.$3;
      final projected = c.$4;

      final ao = cg.ambientOcclusion(ix - 1, iy - 1, iz - 1);
      _renderCubeFaces(
        centerX: px + projected[0],
        centerY: py - projected[1],
        h: h,
        cZ: projected[2],
        scaleX: 1.0,
        scaleY: 1.0,
        scaleZ: 1.0,
        cornerRadius: cornerRadius,
        rot: cornerRot,
        ao: ao,
        bodyAx: bda,
        bodyAy: bda,
        bodyAz: -bda,
        bodyAngle: rotAngle,
      );

      // VERY IMPORTANT: logoPremiumCornerAxis MUST use primaryColor for strokes and glows.
      _drawFaces(canvas, _faceCount, strokeWidth, cubeColor, strokeColor: primaryColor);
    }
  }

  void _paintPremiumRotate(Canvas canvas, Size size) {
    const n = 3;
    final gap = size.width * 0.24;
    final cubeH = size.width * 0.19;
    final h = cubeH * 0.5;
    final cornerRadius = (h * 0.25).clamp(0.3, max(0.3, h * 0.4)).toDouble();
    final strokeWidth = (h * 0.10).clamp(0.8, 2.0);
    final px = size.width * 0.5;
    final py = size.height * 0.5;
    final offset = -(n - 1) * 0.5;
    final bda = 1.0 / sqrt(3.0);

    _faceCount = 0;
    _fillPaint.color = cubeColor;

    for (int ix = 0; ix < n; ix++) {
      for (int iy = 0; iy < n; iy++) {
        for (int iz = 0; iz < n; iz++) {
          final baseX = (ix + offset) * gap;
          final baseY = (iy + offset) * gap;
          final baseZ = (iz + offset) * gap;

          final rotAngle = rotationAngle * 0.06;
          final rotated = <double>[baseX, baseY, baseZ];
          cg.rotatePointAxis(rotated, bda, bda, bda, rotAngle, rotated);

          final ao = cg.ambientOcclusion(ix - 1, iy - 1, iz - 1);
          _renderCubeFaces(
            centerX: px + rotated[0],
            centerY: py - rotated[1],
            h: h,
            cZ: rotated[2],
            scaleX: 1.0,
            scaleY: 1.0,
            scaleZ: 1.0,
            cornerRadius: cornerRadius,
            rot: _lightRot!,
            ao: ao,
          );
        }
      }
    }

    final strokeColor = isDark ? const Color(0xFF334155) : const Color(0xFF0F172A);
    _drawFaces(canvas, _faceCount, strokeWidth, cubeColor, strokeColor: strokeColor);
  }

  /// Insertion sort on [_sortKeys] using face depths.
  /// Nearly O(n) since faces are approximately back-to-front after cube transform.
  void _sortFaces(int count) {
    for (int i = 1; i < count; i++) {
      final key = _sortKeys[i];
      final keyZ = _faceBuffer[key].z;
      int j = i - 1;
      while (j >= 0 && _faceBuffer[_sortKeys[j]].z > keyZ) {
        _sortKeys[j + 1] = _sortKeys[j];
        j--;
      }
      _sortKeys[j + 1] = key;
    }
  }

  /// Shared face rendering — writes into [_faceBuffer] at current [_faceCount].
  void _renderCubeFaces({
    required double centerX,
    required double centerY,
    required double h,
    required double cZ,
    required double scaleX,
    required double scaleY,
    required double scaleZ,
    required double cornerRadius,
    required cg.RotationMatrix rot,
    double ao = 1.0,
    double bodyAx = 0,
    double bodyAy = 0,
    double bodyAz = 0,
    double bodyAngle = 0,
  }) {
    final _bodyV = <double>[0, 0, 0];
    final _bodyN = <double>[0, 0, 0];
    for (int v = 0; v < 8; v++) {
      final vIn = cg.cubeVerts[v];
      cg.rotatePointAxis(
        [vIn[0] * h * scaleX, vIn[1] * h * scaleY, vIn[2] * h * scaleZ],
        bodyAx, bodyAy, bodyAz, bodyAngle, _bodyV,
      );
      cg.rotatePoint(_bodyV, rot, _tv[v]);
      _tv[v][2] += cZ;
    }

    for (int f = 0; f < 6; f++) {
      final n = cg.cubeNormals[f];
      cg.rotatePointAxis(n, bodyAx, bodyAy, bodyAz, bodyAngle, _bodyN);
      cg.rotatePoint(_bodyN, rot, _nv);
      if (_nv[2] <= 0) continue;

      double sumZ = 0;
      final faceVerts = cg.cubeFaces[f];
      for (int vi = 0; vi < 4; vi++) {
        sumZ += _tv[faceVerts[vi]][2];
      }

      for (int vi = 0; vi < 4; vi++) {
        final idx = faceVerts[vi];
        final x = centerX + _tv[idx][0];
        final y = centerY - _tv[idx][1];
        _quadPts[vi] = Offset(x, y);
      }

      final rPath = cg.buildRoundedQuad(
        _quadPts[0],
        _quadPts[1],
        _quadPts[2],
        _quadPts[3],
        cornerRadius,
      );

      final fd = _faceBuffer[_faceCount++];
      fd.z = sumZ;
      fd.path = rPath;
      fd.faceIdx = f;
      fd.ao = ao;
      fd.bodyNormal = bodyAngle != 0
          ? [_bodyN[0], _bodyN[1], _bodyN[2]]
          : null;
    }
  }

  // ---- Shared drawing ----
  void _drawFaces(
    Canvas canvas,
    int count,
    double strokeWidth,
    Color faceColor, {
    Color? strokeColor,
  }) {
    final glowEnabled =
        showGlow &&
        tier.index >= _CubeLoaderTier.small.index &&
        (state == CubeLoaderState.breathing ||
            state == CubeLoaderState.loading ||
            isHovered);

    _sortFaces(count);

    for (int fi = 0; fi < count; fi++) {
      final face = _faceBuffer[_sortKeys[fi]];
      final rot = _lightRot ?? cg.computeRotation(_rx, _baseRy, 0.0);
      final lBright = _faceBrightness(face.faceIdx, rot, bodyNormal: face.bodyNormal);
      var brightness = lBright * face.ao;

      if (state == CubeLoaderState.loading) {
        brightness += sin(animValue * pi * 2 * 2) * 0.08;
      }

      _fillPaint.color = Color.lerp(Colors.black, faceColor, brightness)!;

      _strokePaint.strokeWidth = strokeWidth;
      _strokePaint.color = strokeColor ?? _strokeColor();

      canvas.drawPath(face.path, _fillPaint);
      canvas.drawPath(face.path, _strokePaint);

      // Glow
      if (glowEnabled) {
        var glowAlpha = 0.0;
        if (isHovered) {
          glowAlpha = 0.3;
        } else if (state == CubeLoaderState.breathing) {
          glowAlpha = 0.2 + max(0.0, breath) * 0.4;
        } else if (state == CubeLoaderState.loading) {
          glowAlpha = 0.2 + sin(animValue * pi * 2 * 2).abs() * 0.3;
        }

        if (glowAlpha > 0.01) {
          _glowPaint.strokeWidth = strokeWidth * 2;
          _glowPaint.color = primaryColor.withValues(alpha: glowAlpha * 0.5);
          _glowPaint.maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            (4 + glowAlpha * 4) * 1.0,
          );
          canvas.drawPath(face.path, _glowPaint);
        }
      }
    }
  }

  Color _strokeColor() {
    return primaryColor;
  }

  double _faceBrightness(int faceIdx, cg.RotationMatrix rot, {List<double>? bodyNormal}) {
    final n = bodyNormal ?? cg.cubeNormals[faceIdx];
    cg.rotatePoint(n, rot, _nv);
    return cg.lambertBrightness(_nv[0], _nv[1], _nv[2]);
  }

  @override
  bool shouldRepaint(covariant _CubeLoaderPainter oldDelegate) {
    return animValue != oldDelegate.animValue ||
        rotationAngle != oldDelegate.rotationAngle ||
        clusterOrbitAngle != oldDelegate.clusterOrbitAngle ||
        state != oldDelegate.state ||
        variant != oldDelegate.variant ||
        isHovered != oldDelegate.isHovered ||
        isExploding != oldDelegate.isExploding ||
        explodeProgress != oldDelegate.explodeProgress ||
        value != oldDelegate.value;
  }
}

// =============================================================================
// Data classes
// =============================================================================

class _FaceData {
  double z = 0;
  Path path = Path();
  int faceIdx = 0;
  double ao = 1.0;
  List<double>? bodyNormal;
}

class _ClusterEntry {
  final List<_FaceData> faces;
  final double brightness;
  final double yPos;
  _ClusterEntry({
    required this.faces,
    required this.brightness,
    required this.yPos,
  });
}
