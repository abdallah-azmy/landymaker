import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:landymaker/core/widgets/particles/core/cube_geometry.dart' as cg;

void main() {
  group('computeRotation', () {
    test('returns correct trig values for given angles', () {
      const rx = 0.5, ry = 1.0, rz = 0.25;
      final rot = cg.computeRotation(rx, ry, rz);
      expect(rot.cxR, closeTo(cos(rx), 1e-12));
      expect(rot.sxR, closeTo(sin(rx), 1e-12));
      expect(rot.cyR, closeTo(cos(ry), 1e-12));
      expect(rot.syR, closeTo(sin(ry), 1e-12));
      expect(rot.czR, closeTo(cos(rz), 1e-12));
      expect(rot.szR, closeTo(sin(rz), 1e-12));
    });

    test('zero rotation returns identity trig', () {
      final rot = cg.computeRotation(0, 0, 0);
      expect(rot.cxR, closeTo(1, 1e-12));
      expect(rot.sxR, closeTo(0, 1e-12));
      expect(rot.cyR, closeTo(1, 1e-12));
      expect(rot.syR, closeTo(0, 1e-12));
      expect(rot.czR, closeTo(1, 1e-12));
      expect(rot.szR, closeTo(0, 1e-12));
    });
  });

  group('rotatePoint', () {
    test('zero rotation leaves point unchanged', () {
      final rot = cg.computeRotation(0, 0, 0);
      final out = [0.0, 0.0, 0.0];
      cg.rotatePoint([2.0, -3.0, 5.0], rot, out);
      expect(out[0], closeTo(2.0, 1e-12));
      expect(out[1], closeTo(-3.0, 1e-12));
      expect(out[2], closeTo(5.0, 1e-12));
    });

    test('90° about X sends +Y to +Z', () {
      final rot = cg.computeRotation(pi / 2, 0, 0);
      final out = [0.0, 0.0, 0.0];
      cg.rotatePoint([0.0, 1.0, 0.0], rot, out);
      expect(out[0], closeTo(0.0, 1e-12));
      expect(out[1], closeTo(0.0, 1e-12));
      expect(out[2], closeTo(1.0, 1e-12));
    });

    test('90° about Y sends +X to -Z', () {
      final rot = cg.computeRotation(0, pi / 2, 0);
      final out = [0.0, 0.0, 0.0];
      cg.rotatePoint([1.0, 0.0, 0.0], rot, out);
      expect(out[0], closeTo(0.0, 1e-12));
      expect(out[1], closeTo(0.0, 1e-12));
      expect(out[2], closeTo(-1.0, 1e-12));
    });

    test('90° about Z sends +X to +Y', () {
      final rot = cg.computeRotation(0, 0, pi / 2);
      final out = [0.0, 0.0, 0.0];
      cg.rotatePoint([1.0, 0.0, 0.0], rot, out);
      expect(out[0], closeTo(0.0, 1e-12));
      expect(out[1], closeTo(1.0, 1e-12));
      expect(out[2], closeTo(0.0, 1e-12));
    });

    test('full cycle returns to start', () {
      final rot = cg.computeRotation(pi * 2, pi * 2, pi * 2);
      final out = [0.0, 0.0, 0.0];
      cg.rotatePoint([1.0, 2.0, 3.0], rot, out);
      expect(out[0], closeTo(1.0, 1e-12));
      expect(out[1], closeTo(2.0, 1e-12));
      expect(out[2], closeTo(3.0, 1e-12));
    });
  });

  group('lambertBrightness', () {
    test('face pointing directly at light yields max brightness', () {
      final b = cg.lambertBrightness(cg.lx, cg.ly, cg.lz);
      expect(b, closeTo(1.0, 2e-4));
    });

    test('face pointing away from light yields min brightness', () {
      final b = cg.lambertBrightness(-cg.lx, -cg.ly, -cg.lz);
      expect(b, closeTo(0.3, 1e-10));
    });

    test('perpendicular face yields intermediate brightness', () {
      // Dot = nx*lx + ny*ly + nz*lz = 1*0.5 + 0 + 0 = 0.5
      // Result = 0.3 + max(0, 0.5) * 0.7 = 0.3 + 0.35 = 0.65
      final b = cg.lambertBrightness(1.0, 0.0, 0.0);
      expect(b, closeTo(0.65, 1e-10));
    });

    test('always returns value in [0.3, 1.0]', () {
      for (final (nx, ny, nz) in [
        (1.0, 0.0, 0.0),
        (-1.0, 0.0, 0.0),
        (0.0, 1.0, 0.0),
        (0.0, -1.0, 0.0),
        (0.0, 0.0, 1.0),
        (0.0, 0.0, -1.0),
      ]) {
        final b = cg.lambertBrightness(nx, ny, nz);
        expect(b, greaterThanOrEqualTo(0.3));
        expect(b, lessThanOrEqualTo(1.0));
      }
    });
  });

  group('buildRoundedQuad', () {
    test('returns valid Path with bezier curves for large radius', () {
      final path = cg.buildRoundedQuad(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(10, 10),
        const Offset(0, 10),
        2.0,
      );
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics.first.length, greaterThan(0));
    });

    test('falls back to polygon for tiny radius', () {
      final path = cg.buildRoundedQuad(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(10, 10),
        const Offset(0, 10),
        0.1,
      );
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics.first.length, greaterThan(0));
    });

    test('clamps radius to half the minimum edge', () {
      final path = cg.buildRoundedQuad(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(10, 2),
        const Offset(0, 2),
        999.0,
      );
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics.first.length, greaterThan(0));
    });

    test('degenerate quad with collinear points still produces path', () {
      final path = cg.buildRoundedQuad(
        const Offset(0, 0),
        const Offset(10, 0),
        const Offset(20, 0),
        const Offset(30, 0),
        2.0,
      );
      final metrics = path.computeMetrics();
      expect(metrics.length, 1);
    });
  });

  group('ambientOcclusion', () {
    test('center cube (0,0,0) has 6 neighbors -> AO = 0.65', () {
      final ao = cg.ambientOcclusion(0, 0, 0);
      expect(ao, closeTo(0.65, 1e-12));
    });

    test('corner cube (-1,-1,-1) has 3 neighbors -> AO = 1.0', () {
      final ao = cg.ambientOcclusion(-1, -1, -1);
      expect(ao, closeTo(1.0, 1e-12));
    });

    test('edge cube (0,-1,-1) has 4 neighbors -> AO = 1 - 0.35/3', () {
      final ao = cg.ambientOcclusion(0, -1, -1);
      expect(ao, closeTo(1.0 - 0.35 / 3, 1e-12));
    });

    test('face cube (0,0,-1) has 5 neighbors -> AO = 1 - 2*0.35/3', () {
      final ao = cg.ambientOcclusion(0, 0, -1);
      expect(ao, closeTo(1.0 - 2 * 0.35 / 3, 1e-12));
    });

    test('result always in [0.65, 1.0] for all 27 grid positions', () {
      for (int ix = -1; ix <= 1; ix++) {
        for (int iy = -1; iy <= 1; iy++) {
          for (int iz = -1; iz <= 1; iz++) {
            final ao = cg.ambientOcclusion(ix, iy, iz);
            expect(ao, greaterThanOrEqualTo(0.65));
            expect(ao, lessThanOrEqualTo(1.0));
          }
        }
      }
    });
  });

  group('occludedFaces', () {
    test('center cube (0,0,0) has all 6 faces occluded', () {
      final mask = cg.occludedFaces(0, 0, 0);
      // Bits 0..5 all set (63 = 0b00111111)
      expect(mask, 63);
    });

    test('corner cube (-1,-1,-1) has 3 faces occluded', () {
      final mask = cg.occludedFaces(-1, -1, -1);
      // Bits 0 (front at z+1), 2 (top at y+1), 4 (right at x+1) (21 = 0b00010101)
      expect(mask, 21);
    });

    test('edge cube (0,-1,-1) has 4 faces occluded', () {
      final mask = cg.occludedFaces(0, -1, -1);
      // Bits 0 (front), 2 (top), 4 (right), 5 (left) (53 = 0b110101)
      expect(mask, 53);
    });

    test('face cube (0,0,-1) has 5 faces occluded', () {
      final mask = cg.occludedFaces(0, 0, -1);
      // Bits 0 (front), 2 (top), 3 (bottom), 4 (right), 5 (left) (61 = 0b111101)
      expect(mask, 61);
    });

    test('cube at (-9,-9,-9) has 3 potential neighbors (directional)', () {
      // The function only checks direction, not grid bounds.
      // -9 < 1 → yes for x, y, z → right, top, front faces occluded (21 = 0b010101)
      final mask = cg.occludedFaces(-9, -9, -9);
      expect(mask, 21);
    });
  });
}
