import 'dart:math';

void rotatePoint(List<double> v, double rx, double ry, double rz, List<double> out) {
  double cx = cos(rx), sx = sin(rx);
  double cy = cos(ry), sy = sin(ry);
  double cz = cos(rz), sz = sin(rz);

  double x = v[0], y = v[1], z = v[2];
  
  double y1 = y * cx - z * sx;
  double z1 = y * sx + z * cx;
  y = y1; z = z1;
  
  double x1 = x * cy + z * sy;
  double z2 = -x * sy + z * cy;
  x = x1; z = z2;
  
  double x2 = x * cz - y * sz;
  double y2 = x * sz + y * cz;
  x = x2; y = y2;
  
  out[0] = x; out[1] = y; out[2] = z;
}

void main() {
  double rx = 0.85;
  double ry = pi / 4;
  double rz = 0.5003747769;

  List<List<double>> verts = [
    [-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1],
    [-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1]
  ];

  double maxY = -1000;
  int bottomVertex = -1;
  List<List<double>> projected = [];

  for (int i = 0; i < 8; i++) {
    List<double> out = [0,0,0];
    rotatePoint(verts[i], rx, ry, rz, out);
    projected.add(out);
    // Y points DOWN on screen, so highest Y is lowest on screen
    if (out[1] > maxY) {
      maxY = out[1];
      bottomVertex = i;
    }
  }

  print("Bottom vertex index: $bottomVertex");
  print("Bottom vertex 3D: ${verts[bottomVertex]}");
  print("Bottom vertex Proj: ${projected[bottomVertex]}");

  // Find edges from bottom vertex
  for (int i = 0; i < 8; i++) {
    int diffs = 0;
    if (verts[i][0] != verts[bottomVertex][0]) diffs++;
    if (verts[i][1] != verts[bottomVertex][1]) diffs++;
    if (verts[i][2] != verts[bottomVertex][2]) diffs++;
    
    if (diffs == 1) { // It's an edge
      double dx = projected[i][0] - projected[bottomVertex][0];
      double dy = projected[i][1] - projected[bottomVertex][1];
      double dz = projected[i][2] - projected[bottomVertex][2];
      print("Edge to $i (${verts[i]}): dx=$dx, dy=$dy, dz=$dz");
    }
  }
}
