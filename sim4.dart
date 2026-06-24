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
  
  // First, find dx and dy with rz = 0
  List<double> out1 = [0,0,0];
  List<double> out2 = [0,0,0];
  
  // Bottom vertex in our setup usually corresponds to [1,1,-1]
  rotatePoint([1, 1, -1], rx, ry, 0.0, out1);
  // Edge closest to screen is [1, -1, -1] (points up)
  rotatePoint([1, -1, -1], rx, ry, 0.0, out2);
  
  double dx = out2[0] - out1[0];
  double dy = out2[1] - out1[1]; // Y points DOWN, so dy is negative
  
  // We want the new dx to be 0 and the new dy to be negative (upwards).
  // The vector is (dx, dy). We want to rotate it by rz so that it lies on the Y-axis.
  // x_new = dx*cz - dy*sz
  // y_new = dx*sz + dy*cz
  // We want x_new = 0 => dx*cz = dy*sz => sz/cz = dx/dy => tan(rz) = dx/dy => rz = atan2(dx, dy)
  
  double rz = atan2(dx, dy);
  if (rz > pi/2) rz -= pi;
  if (rz < -pi/2) rz += pi;
  
  print("Calculated rz: $rz");
  
  // Verify with calculated rz
  rotatePoint([1, 1, -1], rx, ry, rz, out1);
  rotatePoint([1, -1, -1], rx, ry, rz, out2);
  double ndx = out2[0] - out1[0];
  double ndy = out2[1] - out1[1];
  print("New dx: $ndx, New dy: $ndy");
}
