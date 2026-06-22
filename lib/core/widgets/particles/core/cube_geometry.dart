import 'dart:math';
import 'package:flutter/material.dart';

/// Single-cube vertex data (8 corners, ±1 range).
const List<List<double>> cubeVerts = [
  [-1.0, -1.0, 1.0],
  [1.0, -1.0, 1.0],
  [1.0, 1.0, 1.0],
  [-1.0, 1.0, 1.0],
  [-1.0, -1.0, -1.0],
  [1.0, -1.0, -1.0],
  [1.0, 1.0, -1.0],
  [-1.0, 1.0, -1.0],
];

/// Face index lists (each references 4 vertices from [cubeVerts]).
const List<List<int>> cubeFaces = [
  [0, 1, 2, 3],
  [4, 5, 6, 7],
  [3, 2, 6, 7],
  [0, 1, 5, 4],
  [1, 2, 6, 5],
  [0, 3, 7, 4],
];

/// Face normals (unit vectors, one per [cubeFaces] entry).
const List<List<double>> cubeNormals = [
  [0.0, 0.0, 1.0],
  [0.0, 0.0, -1.0],
  [0.0, 1.0, 0.0],
  [0.0, -1.0, 0.0],
  [1.0, 0.0, 0.0],
  [-1.0, 0.0, 0.0],
];

/// Normalized light direction vector (pre-computed).
const double lx = 0.5;
const double ly = 0.5;
const double lz = 0.707;

/// Euler rotation trig values cache.
class RotationMatrix {
  final double cxR, sxR, cyR, syR, czR, szR;
  const RotationMatrix({
    required this.cxR,
    required this.sxR,
    required this.cyR,
    required this.syR,
    required this.czR,
    required this.szR,
  });
}

/// Compute Euler rotation trig values from angles.
RotationMatrix computeRotation(double rx, double ry, double rz) {
  return RotationMatrix(
    cxR: cos(rx), sxR: sin(rx),
    cyR: cos(ry), syR: sin(ry),
    czR: cos(rz), szR: sin(rz),
  );
}

/// Apply Euler rotation (X -> Y -> Z) to a 3D point in-place on [out].
void rotatePoint(List<double> v, RotationMatrix r, List<double> out) {
  double x = v[0], y = v[1], z = v[2];
  double y1 = y * r.cxR - z * r.sxR;
  double z1 = y * r.sxR + z * r.cxR;
  y = y1; z = z1;
  double x1 = x * r.cyR + z * r.syR;
  double z2 = -x * r.syR + z * r.cyR;
  x = x1; z = z2;
  double x2 = x * r.czR - y * r.szR;
  double y2 = x * r.szR + y * r.czR;
  x = x2; y = y2;
  out[0] = x; out[1] = y; out[2] = z;
}

/// Lambertian diffuse brightness for a face normal [nx, ny, nz].
double lambertBrightness(double nx, double ny, double nz) {
  final dot = nx * lx + ny * ly + nz * lz;
  return 0.3 + max(0.0, dot) * 0.7;
}

/// Build a rounded quad path from 4 corners with cubic bezier curves.
Path buildRoundedQuad(Offset a, Offset b, Offset c, Offset d, double r) {
  final points = [a, b, c, d];
  final path = Path();
  double minEdge = double.infinity;
  for (int i = 0; i < 4; i++) {
    final j = (i + 1) % 4;
    minEdge = min(minEdge, (points[i] - points[j]).distance);
  }
  final double cr = min(r, minEdge * 0.5);
  if (cr < 0.5) {
    path.addPolygon(points, true);
    return path;
  }
  for (int i = 0; i < 4; i++) {
    final p0 = points[(i - 1 + 4) % 4];
    final p1 = points[i];
    final p2 = points[(i + 1) % 4];
    final e1 = p0 - p1;
    final len1 = e1.distance;
    final d1 = len1 > 0.001 ? e1 / len1 : Offset.zero;
    final e2 = p2 - p1;
    final len2 = e2.distance;
    final d2 = len2 > 0.001 ? e2 / len2 : Offset.zero;
    final start = p1 + d1 * cr;
    final end = p1 + d2 * cr;
    final cp1 = p1 + d1 * cr * 0.55;
    final cp2 = p1 + d2 * cr * 0.55;
    if (i == 0) {
      path.moveTo(start.dx, start.dy);
    }
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
  }
  path.close();
  return path;
}

/// Compute ambient occlusion factor for a cube at grid position [ix, iy, iz].
double ambientOcclusion(int ix, int iy, int iz) {
  int neighbors = 0;
  if (ix > -1) neighbors++;
  if (ix < 1) neighbors++;
  if (iy > -1) neighbors++;
  if (iy < 1) neighbors++;
  if (iz > -1) neighbors++;
  if (iz < 1) neighbors++;
  // Correct AO: more neighbors = darker (lower factor)
  // Center cube (6 neighbors) -> 0.65
  // Corner cube (3 neighbors) -> 1.0
  return 1.0 - ((neighbors - 3) / 3.0) * 0.35;
}

/// Determine which faces of a cube at [ix, iy, iz] are occluded by neighbors.
/// Returns a bitmask where bit f is 1 if face f is occluded.
int occludedFaces(int ix, int iy, int iz) {
  int mask = 0;
  if (ix < 1) mask |= 1 << 4; // right face blocked by neighbor at x+1
  if (ix > -1) mask |= 1 << 5; // left face blocked by neighbor at x-1
  if (iy < 1) mask |= 1 << 2; // top face blocked by neighbor at y+1
  if (iy > -1) mask |= 1 << 3; // bottom face blocked by neighbor at y-1
  if (iz < 1) mask |= 1 << 0; // front face blocked by neighbor at z+1
  if (iz > -1) mask |= 1 << 1; // back face blocked by neighbor at z-1
  return mask;
}
