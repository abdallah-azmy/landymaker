import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landymaker/core/widgets/particles/floating_cube_background.dart';

void main() {
  testWidgets('Generate Logo', (WidgetTester tester) async {
    final int totalCubes = 27; // 3x3x3
    final double gap = 24.0;
    
    // Isometric angles
    final double rx = 0.7853981633974483; // 45 deg
    final double ry = 0.6154797086703873; // 35.26 deg
    final double rz = 0.5235987755982988; // 30 deg

    final double cx = cos(rx), sx = sin(rx);
    final double cy = cos(ry), sy = sin(ry);
    final double cz = cos(rz), sz = sin(rz);

    List<CubeEntity> entities = [];
    
    for (int i = 0; i < totalCubes; i++) {
      int ix = (i % 3) - 1;
      int iy = ((i ~/ 3) % 3) - 1;
      int iz = (i ~/ 9) - 1;

      double X = ix * gap, Y = iy * gap, Z = iz * gap;
      
      // Rotate coordinates
      double y1 = Y * cx - Z * sx, z1 = Y * sx + Z * cx;
      Y = y1; Z = z1;
      double x1 = X * cy + Z * sy, z2 = -X * sy + Z * cy;
      X = x1; Z = z2;
      double x2 = X * cz - Y * sz, y2 = X * sz + Y * cz;
      X = x2; Y = y2;

      final e = CubeEntity();
      e.depth = Z;
      e.x = 0.5 + X / 512.0;
      e.y = 0.5 - Y / 512.0;
      e.rx = rx;
      e.ry = ry;
      e.rz = rz;
      e.renderSize = 19.0;
      e.targetSize = 19.0;
      e.ao = 1.0; // Needs proper AO calculation!

      // Quick AO calc
      double distSq = (ix*ix + iy*iy + iz*iz).toDouble();
      if (distSq == 0) e.ao = 0.5;
      else if (distSq == 1) e.ao = 0.75;
      else if (distSq == 2) e.ao = 0.9;
      else e.ao = 1.0;

      entities.add(e);
    }

    final painter = CubePainter(
      entities: entities,
      trailPool: TrailPool(),
      qualityMode: QualityMode.high,
      brightness: Brightness.dark, // Logo should match dark bg
      primaryColor: const Color(0xFF00E5FF),
      isRtl: true,
      isLogoState: true,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw background (transparent)
    // We want the final PNG to be transparent!
    
    // Scale up for high-res!
    // Original size ~512x512. Let's make it 1024x1024 for high res.
    // The painter uses size internally, so we just pass size.
    final size = const Size(1024, 1024);
    
    // Wait, the coordinates X/512.0 were based on screen width. If size is 1024, it will use e.x * 1024.
    // 0.5 + X / 512.0 * 1024 = 512 + 2X. 
    // This is perfect!
    
    painter.paint(canvas, size);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    // Crop to the actual logo bounds if possible? Or just save it all.
    // Let's just save it.
    
    File('web/assets/assets/images/logo_generated.png').writeAsBytesSync(byteData!.buffer.asUint8List());
    print('Saved to web/assets/assets/images/logo_generated.png');
  });
}
