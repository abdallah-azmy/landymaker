import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landymaker/core/widgets/particles/floating_cube_background.dart';

void main() {
  testWidgets('Screenshot logo', (WidgetTester tester) async {
    // Set a large screen size for high-res logo
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 2.0;

    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SizedBox(
              width: 512,
              height: 512,
              child: RepaintBoundary(
                key: boundaryKey,
                child: const FloatingCubeBackground(
                  cubeCount: 50,
                  isActive: true,
                  initialPreBurst: true, // Forces it to start in built logo state!
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Let the animation tick for a few frames to make sure it's fully rendered
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final RenderRepaintBoundary boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        
    // Capture the image at 2.0 pixel ratio
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final file = File('web/assets/assets/images/logo_clean.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());
    print('Logo successfully saved to \${file.absolute.path}');
    
    // Reset view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
