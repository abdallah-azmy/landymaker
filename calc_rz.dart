import 'dart:math';

void main() {
  double rx = 0.85;
  double ry = pi / 4;
  double rz = atan(tan(rx) * sin(ry));
  print(rz);
}
