import 'dart:math';
import 'package:flutter/material.dart';

enum LoadingLogoMode {
  breathing,
  rotatingLayers,
}

class LoadingLogo extends StatefulWidget {
  final LoadingLogoMode mode;
  final double size;

  const LoadingLogo({
    Key? key,
    this.mode = LoadingLogoMode.breathing,
    this.size = 120.0,
  }) : super(key: key);

  @override
  State<LoadingLogo> createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo> with SingleTickerProviderStateMixin {
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _LoadingLogoPainter(
              animationValue: _controller.value,
              mode: widget.mode,
              primaryColor: Theme.of(context).colorScheme.primary,
              brightness: Theme.of(context).brightness,
            ),
          );
        },
      ),
    );
  }
}

class _CubeEntity {
  double X, Y, Z;
  int ix, iy, iz;
  
  _CubeEntity({
    required this.X,
    required this.Y,
    required this.Z,
    required this.ix,
    required this.iy,
    required this.iz,
  });
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

class _LoadingLogoPainter extends CustomPainter {
  final double animationValue;
  final LoadingLogoMode mode;
  final Color primaryColor;
  final Brightness brightness;

  _LoadingLogoPainter({
    required this.animationValue,
    required this.mode,
    required this.primaryColor,
    required this.brightness,
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
    final double rx = 0.70;
    final double ry = pi / 4;
    final double rz = 0.0;

    final double cx = cos(rx), sx = sin(rx);
    final double cy = cos(ry), sy = sin(ry);
    final double cz = cos(rz), sz = sin(rz);

    final double cubeSize = size.width * 0.26;
    final double gapBase = cubeSize * 1.15;
    final double h = cubeSize * 0.5;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final cubeColor = brightness == Brightness.light
        ? const Color(0xFFD8D8D8)
        : const Color(0xFF030712);

    final List<_CubeEntity> cubes = [];
    for (int i = 0; i < 27; i++) {
      int ix = (i % 3) - 1;
      int iy = ((i ~/ 3) % 3) - 1;
      int iz = (i ~/ 9) - 1;
      
      double gap = gapBase;
      
      // Animations
      if (mode == LoadingLogoMode.breathing) {
        // Pulse outward based on sine wave
        final breath = sin(animationValue * pi * 2);
        gap = gapBase + breath * (size.width * 0.05);
        
        // Add a primary color glow when breathing out
        if (breath > 0) {
           strokePaint.color = primaryColor.withOpacity(0.5 + breath * 0.5);
           strokePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + breath * 4);
        } else {
           strokePaint.color = primaryColor.withOpacity(0.5);
           strokePaint.maskFilter = null;
        }
      } else {
        strokePaint.color = primaryColor;
      }

      double X = ix * gap;
      double Y = iy * gap;
      double Z = iz * gap;

      if (mode == LoadingLogoMode.rotatingLayers) {
        // Rotate layers around Y axis independently
        // iy = -1 (top), iy = 0 (middle), iy = 1 (bottom)
        double layerRot = 0.0;
        final t = animationValue * pi * 2;
        if (iy == -1) layerRot = t;
        else if (iy == 0) layerRot = -t * 0.5;
        else if (iy == 1) layerRot = t * 1.5;

        final lc = cos(layerRot);
        final ls = sin(layerRot);
        
        final nx = X * lc + Z * ls;
        final nz = -X * ls + Z * lc;
        X = nx;
        Z = nz;
      }

      cubes.add(_CubeEntity(X: X, Y: Y, Z: Z, ix: ix, iy: iy, iz: iz));
    }

    final tv = List.generate(8, (_) => [0.0, 0.0, 0.0]);
    final px = size.width * 0.5;
    final py = size.height * 0.5;

    // Face buffering for depth sorting
    final List<Map<String, dynamic>> allFaces = [];

    for (final cube in cubes) {
      // 3D Projection of the center
      double cX = cube.X;
      double cY = cube.Y;
      double cZ = cube.Z;

      double y1 = cY * cx - cZ * sx;
      double z1 = cY * sx + cZ * cx;
      cY = y1;
      cZ = z1;

      double x1 = cX * cy + cZ * sy;
      double z2 = -cX * sy + cZ * cy;
      cX = x1;
      cZ = z2;

      double x2 = cX * cz - cY * sz;
      double y2 = cX * sz + cY * cz;
      cX = x2;
      cY = y2;

      final double centerX = px + cX;
      final double centerY = py - cY; // screen Y is inverted

      for (int i = 0; i < 8; i++) {
        double vX = _verts[i][0] * h;
        double vY = _verts[i][1] * h;
        double vZ = _verts[i][2] * h;

        // Apply same projection to vertices to keep face orientation fixed
        double vy1 = vY * cx - vZ * sx;
        double vz1 = vY * sx + vZ * cx;
        vY = vy1;
        vZ = vz1;

        double vx1 = vX * cy + vZ * sy;
        double vz2 = -vX * sy + vZ * cy;
        vX = vx1;
        vZ = vz2;

        double vx2 = vX * cz - vY * sz;
        double vy2 = vX * sz + vY * cz;
        vX = vx2;
        vY = vy2;

        tv[i][0] = vX;
        tv[i][1] = vY;
        tv[i][2] = vZ + cZ; // preserve absolute Z depth for sorting
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

        if (nz <= 0) continue; // backface culling

        double sumZ = 0.0;
        final faceVerts = _faces[f];
        for (int vi = 0; vi < 4; vi++) {
          sumZ += tv[faceVerts[vi]][2];
        }

        // Fake lighting
        final double lx = 0.1, ly = 0.05, lz = 0.5;
        final double dot = nx * lx + ny * ly + nz * lz;
        final lBrightness = 0.4 + max(0.0, dot) * 0.6;

        allFaces.add({
          'z': sumZ,
          'brightness': lBrightness,
          'x0': centerX + tv[faceVerts[0]][0],
          'y0': centerY - tv[faceVerts[0]][1],
          'x1': centerX + tv[faceVerts[1]][0],
          'y1': centerY - tv[faceVerts[1]][1],
          'x2': centerX + tv[faceVerts[2]][0],
          'y2': centerY - tv[faceVerts[2]][1],
          'x3': centerX + tv[faceVerts[3]][0],
          'y3': centerY - tv[faceVerts[3]][1],
        });
      }
    }

    allFaces.sort((a, b) => (a['z'] as double).compareTo(b['z'] as double));

    for (final face in allFaces) {
      final path = Path()
        ..moveTo(face['x0'], face['y0'])
        ..lineTo(face['x1'], face['y1'])
        ..lineTo(face['x2'], face['y2'])
        ..lineTo(face['x3'], face['y3'])
        ..close();

      fillPaint.color = Color.lerp(
        Colors.black,
        cubeColor,
        face['brightness'],
      )!;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoadingLogoPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue || mode != oldDelegate.mode;
  }
}
