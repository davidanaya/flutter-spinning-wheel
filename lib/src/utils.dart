import 'dart:math';

const acceleration = -0.4 * pi;

double calculateDistance(double initialVelocity, double time) {
  // var finalVelocity = initialVelocity + (acceleration * time);
  // return ((initialVelocity + finalVelocity) / 2) * time;
  var distance = (initialVelocity * time) + (0.5 * acceleration * time * time);
  return distance;
}

double calculateDurationInSeconds(double initialVelocity) {
  return -initialVelocity / acceleration;
}

double pixelsPerSecondToRadians(double pps) {
  // 100 ppx will equal 2pi radians
  return (pps * 2 * pi) / 1000;
}

double calculateAnglePerDivision(int divider) {
  return (2 * pi) / divider;
}

double calculateModuloInCircunference(double angle) {
  return angle % (2 * pi);
}
