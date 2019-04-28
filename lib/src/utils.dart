import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

const Map<int, Offset> cuadrants = const {
  1: Offset(0.5, 0.5),
  2: Offset(-0.5, 0.5),
  3: Offset(-0.5, -0.5),
  4: Offset(0.5, -0.5),
};

const pi_0_5 = pi * 0.5;
const pi_2_5 = pi * 2.5;
const pi_2 = pi * 2;

class SpinVelocity {
  final double height;
  final double width;

  double get width_0_5 => width / 2;
  double get height_0_5 => height / 2;

  SpinVelocity({@required this.height, @required this.width});

  double getVelocity(Offset position, Offset pps) {
    var cuadrantIndex = _getCuadrantFromOffset(position);
    var cuadrant = cuadrants[cuadrantIndex];
    return (cuadrant.dx * pps.dx) + (cuadrant.dy * pps.dy);
  }

  /// transforms (x,y) into radians assuming we start at positive y axis as 0
  double offsetToRadians(Offset position) {
    var a = position.dx - width_0_5;
    var b = height_0_5 - position.dy;
    var angle = atan2(b, a);
    return _normalizeAngle(angle);
  }

  int _getCuadrantFromOffset(Offset p) => p.dx > width_0_5
      ? (p.dy > height_0_5 ? 2 : 1)
      : (p.dy > height_0_5 ? 3 : 4);

  // radians go from 0 to pi (positive y axis) and 0 to -pi (negative y axis)
  // we need radians from positive y axis (0) clockwise back to y axis (2pi)
  double _normalizeAngle(double angle) => angle > 0
      ? (angle > pi_0_5 ? (pi_2_5 - angle) : (pi_0_5 - angle))
      : pi_0_5 - angle;

  bool contains(Offset p) => Size(width, height).contains(p);
}

class NonUniformCircularMotion {
  final double resistance;

  NonUniformCircularMotion({@required this.resistance});

  /// returns the acceleration based on the resistance provided in the constructor
  double get acceleration => resistance * -7 * pi;

  /// distance covered in a specified time with initial velocity
  /// 𝜑=𝜑0+𝜔·𝑡+1/2·𝛼·𝑡2
  distance(double velocity, double time) =>
      (velocity * time) + (0.5 * acceleration * pow(time, 2));

  /// movement duration with initial velocity
  duration(double velocity) => -velocity / acceleration;

  /// modulo in a circunference
  modulo(double angle) => angle % (2 * pi);

  /// angle per division in a circunference with x dividers
  anglePerDivision(int dividers) => (2 * pi) / dividers;
}

/// transforms pixels per second as used by Flutter to radians
/// this is a custom interpreation, it could be updated to adjust the velocity
double pixelsPerSecondToRadians(double pps) {
  // 100 ppx will equal 2pi radians
  return (pps * 2 * pi) / 1000;
}
