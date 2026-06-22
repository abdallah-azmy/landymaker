import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'core/cube_geometry.dart' as cg;

/// Visual layout variant for [CubeLoader].
enum CubeLoaderVariant {
  /// 27 cubes in a 3x3x3 isometric cluster (brand logo). Replaces LoadingLogo.
  logo,

  /// Single cube spinner. Replaces CubeSpinner.
  single,

  /// 3 cubes in a triangular orbit. Replaces CubeProgress.
  cluster,
}

/// Animation state for [CubeLoader].
enum CubeLoaderState {
  idle,
  breathing,
  loading,
  success,
  error,
}

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

class _CubeLoaderState extends State<CubeLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CubeLoaderState _currentState;

  bool _isHovered = false;
  bool _isExploding = false;
  double _explodeProgress = 0.0;
  double _tapRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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
    _startExplodeSequence();
  }

  void _startExplodeSequence() {
    const totalSteps = 60;
    int step = 0;
    Timer.periodic(const Duration(milliseconds: 16), (t) {
      step++;
      final progress = step / totalSteps;
      setState(() {
        if (step < 20) {
          _explodeProgress = step / 20;
          _tapRotation += 0.15;
        } else if (step < 40) {
          _explodeProgress = 1.0 - ((step - 20) / 20);
          _tapRotation += 0.08;
        } else {
          _explodeProgress = (step - 40) / 20;
          _tapRotation += 0.05;
        }
      });
      if (step >= totalSteps) {
        t.cancel();
        setState(() {
          _isExploding = false;
          _explodeProgress = 0.0;
          _tapRotation = 0.0;
          _currentState = widget.initialState;
        });
      }
    });
  }

  void _onHover(bool hovering) {
    if (!widget.interactive) return;
    setState(() => _isHovered = hovering);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.color ?? theme.colorScheme.primary;
    final isDark = widget.color != null
        ? false
        : theme.brightness == Brightness.dark;
    final cubeColor = widget.color ?? (isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0));

    final breath = sin(_controller.value * pi * 2);
    final loadedBreath = sin(_controller.value * pi * 2 * 0.7);

    bool showPct = widget.showPercentage && widget.value != null;

    Widget loader = MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
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
                    state: _currentState,
                    variant: widget.variant,
                    tier: widget._tier,
                    primaryColor: primaryColor,
                    cubeColor: cubeColor,
                    isDark: isDark,
                    breath: sin(_controller.value * pi * 2),
                    loadedBreath: sin(_controller.value * pi * 2 * 0.7),
                    isHovered: _isHovered,
                    isExploding: _isExploding,
                    explodeProgress: _explodeProgress,
                    tapRotation: _tapRotation,
                    showGlow: widget.showGlow,
                    value: widget.value,
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
          Text(
            '${(widget.value! * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: (widget.size * 0.2).clamp(10.0, 16.0),
              fontWeight: FontWeight.bold,
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

  _CubeLoaderPainter({
    required this.animValue,
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
  });

  // ---- Pre-allocated scratch buffers (reused every frame) ----
  static final List<List<double>> _tv = List.generate(
    8,
    (_) => [0.0, 0.0, 0.0],
  );
  static final List<double> _nv = [0.0, 0.0, 0.0];
  static final Path _path = Path();
  static final List<Offset> _quadPts = List.filled(4, Offset.zero);

  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final Paint _glowPaint = Paint()
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
    final isMicro = tier == _CubeLoaderTier.micro;
    final isTiny = tier == _CubeLoaderTier.tiny;
    final isReduced = isMicro;

    final cornerRadius =
        (size.width * 0.04).clamp(isMicro ? 0.3 : 1.0, size.width * 0.08);
    final strokeWidth = isMicro ? 1.0 : isTiny ? 1.2 : 1.6;

    // Rotation
    final rotationSpeed = _rotationSpeed();
    double ry = _baseRy;
    if (!isReduced) {
      ry += animValue * pi * 2 * rotationSpeed;
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
        _paintLogo(canvas, size, rot, cornerRadius, strokeWidth, isMicro);
        break;
      case CubeLoaderVariant.single:
        _paintSingle(canvas, size, rot, cornerRadius, strokeWidth);
        break;
      case CubeLoaderVariant.cluster:
        _paintCluster(canvas, size, rot, cornerRadius, strokeWidth);
        break;
    }
  }

  // ---- Logo variant (27 cubes, 3x3x3) ----
  void _paintLogo(
    Canvas canvas,
    Size size,
    cg.RotationMatrix rot,
    double cornerRadius,
    double strokeWidth,
    bool isMicro,
  ) {
    final gapBase = size.width * 0.29;
    final cubeH = size.width * 0.24;
    final h = cubeH * 0.5;
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    final double gap;
    if (state == CubeLoaderState.breathing || state == CubeLoaderState.loading) {
      gap = gapBase + breath * (size.width * 0.04);
    } else {
      gap = gapBase;
    }

    final maxI = isMicro ? 1 : 2;
    final faces = <_FaceData>[];
    _fillPaint.color = cubeColor;

    for (int i = -maxI; i <= maxI; i++) {
      for (int j = -maxI; j <= maxI; j++) {
        for (int k = -maxI; k <= maxI; k++) {
          if (isMicro && (i.abs() + j.abs() + k.abs() > 2)) continue;

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

          // Transform cube center
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

          // Transform vertices
          for (int v = 0; v < 8; v++) {
            final vIn = cg.cubeVerts[v];
            cg.rotatePoint(
              [vIn[0] * h, vIn[1] * h, vIn[2] * h],
              rot,
              _tv[v],
            );
            _tv[v][2] += cZ; // z offset for depth sorting
          }

          // Ambient occlusion
          final occMask = cg.occludedFaces(i, j, k);

          for (int f = 0; f < 6; f++) {
            if ((occMask & (1 << f)) != 0) continue;

            final n = cg.cubeNormals[f];
            cg.rotatePoint(n, rot, _nv);
            if (_nv[2] <= 0) continue;

            double sumZ = 0;
            final faceVerts = cg.cubeFaces[f];
            for (int vi = 0; vi < 4; vi++) {
              sumZ += _tv[faceVerts[vi]][2];
            }

            final ao = cg.ambientOcclusion(i, j, k);
            for (int vi = 0; vi < 4; vi++) {
              final idx = faceVerts[vi];
              final x = centerX + _tv[idx][0];
              final y = centerY - _tv[idx][1];
              _quadPts[vi] = Offset(x, y);
            }

            final rPath = cg.buildRoundedQuad(
              _quadPts[0], _quadPts[1], _quadPts[2], _quadPts[3],
              cornerRadius,
            );

            faces.add(_FaceData(
              z: sumZ,
              path: rPath,
              faceIdx: f,
              ao: ao,
            ));
          }
        }
      }
    }

    // Sort and draw
    faces.sort((a, b) => a.z.compareTo(b.z));
    _drawFaces(canvas, faces, strokeWidth, cubeColor);
  }

  // ---- Single cube variant (replaces CubeSpinner) ----
  void _paintSingle(
    Canvas canvas,
    Size size,
    cg.RotationMatrix rot,
    double cornerRadius,
    double strokeWidth,
  ) {
    final h = size.width * 0.3;
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    for (int v = 0; v < 8; v++) {
      final vIn = cg.cubeVerts[v];
      cg.rotatePoint(
        [vIn[0] * h, vIn[1] * h, vIn[2] * h],
        rot,
        _tv[v],
      );
    }

    final faces = <_FaceData>[];
    for (int f = 0; f < 6; f++) {
      final n = cg.cubeNormals[f];
      cg.rotatePoint(n, rot, _nv);
      if (_nv[2] <= 0) continue;

      double sumZ = 0;
      final faceVerts = cg.cubeFaces[f];
      for (int vi = 0; vi < 4; vi++) {
        sumZ += _tv[faceVerts[vi]][2];
      }

      for (int vi = 0; vi < 4; vi++) {
        final idx = faceVerts[vi];
        _quadPts[vi] = Offset(px + _tv[idx][0], py - _tv[idx][1]);
      }

      final rPath = cg.buildRoundedQuad(
        _quadPts[0], _quadPts[1], _quadPts[2], _quadPts[3],
        cornerRadius,
      );
      faces.add(_FaceData(z: sumZ, path: rPath, faceIdx: f));
    }

    faces.sort((a, b) => a.z.compareTo(b.z));
    _drawFaces(canvas, faces, strokeWidth, cubeColor);
  }

  // ---- Cluster variant (3 cubes, replaces CubeProgress) ----
  void _paintCluster(
    Canvas canvas,
    Size size,
    cg.RotationMatrix rot,
    double cornerRadius,
    double strokeWidth,
  ) {
    final clusterR = size.width * 0.22;
    final cubeH = size.width * 0.13;
    final h = cubeH * 0.5;
    const nCubes = 3;
    final isDeterminate = value != null;
    final v = value ?? 0.0;

    int activeCount = nCubes;
    double edgeProgress = 0.0;
    if (isDeterminate) {
      activeCount = (v * nCubes).floor();
      edgeProgress = (v * nCubes) - activeCount;
    }

    final clusterAngle = animValue * pi * 2 * 0.2;
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

      for (int vIdx = 0; vIdx < 8; vIdx++) {
        final vIn = cg.cubeVerts[vIdx];
        cg.rotatePoint(
          [vIn[0] * h, vIn[1] * h, vIn[2] * h],
          rot,
          _tv[vIdx],
        );
      }

      final faces = <_FaceData>[];
      for (int f = 0; f < 6; f++) {
        final n = cg.cubeNormals[f];
        cg.rotatePoint(n, rot, _nv);
        if (_nv[2] <= 0) continue;

        double sumZ = 0;
        final faceVerts = cg.cubeFaces[f];
        for (int vi = 0; vi < 4; vi++) {
          sumZ += _tv[faceVerts[vi]][2];
        }

        for (int vi = 0; vi < 4; vi++) {
          final idx = faceVerts[vi];
          _quadPts[vi] = Offset(
            cubeCx + _tv[idx][0],
            cubeCy - _tv[idx][1],
          );
        }

        final rPath = cg.buildRoundedQuad(
          _quadPts[0], _quadPts[1], _quadPts[2], _quadPts[3],
          cornerRadius,
        );
        faces.add(_FaceData(z: sumZ, path: rPath, faceIdx: f));
      }

      faces.sort((a, b) => a.z.compareTo(b.z));
      clusterEntries.add(_ClusterEntry(faces: faces, brightness: cubeBrightness, yPos: cubeCy));
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

  // ---- Shared drawing ----
  void _drawFaces(Canvas canvas, List<_FaceData> faces, double strokeWidth, Color faceColor) {
    final glowEnabled = showGlow && tier.index >= _CubeLoaderTier.small.index &&
        (state == CubeLoaderState.breathing ||
         state == CubeLoaderState.loading ||
         isHovered);

    for (final face in faces) {
      final rot = _lightRot ?? cg.computeRotation(_rx, _baseRy, 0.0);
      final dot = _faceBrightness(face.faceIdx, rot);
      var brightness = (0.4 + max(0.0, dot) * 0.6) * face.ao;

      if (state == CubeLoaderState.success) {
        faceColor = Color.lerp(faceColor, const Color(0xFF22C55E), 0.3)!;
        brightness = min(1.0, brightness + 0.2);
      } else if (state == CubeLoaderState.error) {
        faceColor = Color.lerp(faceColor, const Color(0xFFEF4444), 0.3)!;
        brightness = min(1.0, brightness + 0.15);
      }

      if (state == CubeLoaderState.loading) {
        brightness += sin(animValue * pi * 2 * 2) * 0.08;
      }

      _fillPaint.color = Color.lerp(Colors.black, faceColor, brightness)!;

      _strokePaint.strokeWidth = strokeWidth;
      _strokePaint.color = _strokeColor();

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
          _glowPaint.maskFilter =
              MaskFilter.blur(BlurStyle.normal, (4 + glowAlpha * 4) * 1.0);
          canvas.drawPath(face.path, _glowPaint);
        }
      }
    }
  }

  Color _strokeColor() {
    switch (state) {
      case CubeLoaderState.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.7);
      case CubeLoaderState.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.7);
      default:
        if (isHovered) return primaryColor.withValues(alpha: 0.9);
        return primaryColor.withValues(alpha: 0.6);
    }
  }

  double _faceBrightness(int faceIdx, cg.RotationMatrix rot) {
    final n = cg.cubeNormals[faceIdx];
    cg.rotatePoint(n, rot, _nv);
    return cg.lambertBrightness(_nv[0], _nv[1], _nv[2]);
  }

  double _rotationSpeed() {
    switch (state) {
      case CubeLoaderState.idle: return 0.05;
      case CubeLoaderState.breathing: return 0.08;
      case CubeLoaderState.loading: return 0.3;
      case CubeLoaderState.success: return 0.02;
      case CubeLoaderState.error: return 0.01;
    }
  }

  @override
  bool shouldRepaint(covariant _CubeLoaderPainter oldDelegate) {
    return animValue != oldDelegate.animValue ||
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
  final double z;
  final Path path;
  final int faceIdx;
  final double ao;
  _FaceData({
    required this.z,
    required this.path,
    required this.faceIdx,
    this.ao = 1.0,
  });
}

class _ClusterEntry {
  final List<_FaceData> faces;
  final double brightness;
  final double yPos;
  _ClusterEntry({required this.faces, required this.brightness, required this.yPos});
}
