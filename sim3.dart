import 'dart:math';

void rotatePoint(List<double> v, double ry, double rx, double rz, List<double> out) {
  double cx = cos(rx), sx = sin(rx);
  double cy = cos(ry), sy = sin(ry);
  double cz = cos(rz), sz = sin(rz);

  double x = v[0], y = v[1], z = v[2];
  
  // Y first
  double x1 = x * cy + z * sy;
  double z1 = -x * sy + z * cy;
  x = x1; z = z1;

  // X second
  double y1 = y * cx - z * sx;
  double z2 = y * sx + z * cx;
  y = y1; z = z2;
  
  out[0] = x; out[1] = y; out[2] = z;
}

void main() {
  double rx = atan(1/sqrt(2));
  double ry = pi / 4;
  double rz = 0.0;

  List<List<double>> verts = [
    [-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1],
    [-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1]
  ];

  double maxY = -1000;
  int bottomVertex = -1;
  List<List<double>> projected = [];

  for (int i = 0; i < 8; i++) {
    List<double> out = [0,0,0];
    rotatePoint(verts[i], ry, rx, rz, out);
    projected.add(out);
    if (out[1] > maxY) {
      maxY = out[1];
      bottomVertex = i;
    }
  }

  print("Bottom vertex index: $bottomVertex");
  for (int i = 0; i < 8; i++) {
    int diffs = 0;
    if (verts[i][0] != verts[bottomVertex][0]) diffs++;
    if (verts[i][1] != verts[bottomVertex][1]) diffs++;
    if (verts[i][2] != verts[bottomVertex][2]) diffs++;
    
    if (diffs == 1) {
      double dx = projected[i][0] - projected[bottomVertex][0];
      double dy = projected[i][1] - projected[bottomVertex][1];
      double dz = projected[i][2] - projected[bottomVertex][2];
      print("Edge to $i (${verts[i]}): dx=$dx, dy=$dy, dz=$dz");
    }
  }
}
