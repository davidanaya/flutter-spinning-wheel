import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

class RightTriangle {
  final Offset p1;
  final Offset p2;
  final Offset p3;

  /// true means triangle orientation is positive
  bool orientation;

  RightTriangle(this.p1, this.p2, this.p3) {
    orientation = _calculateOrientation(p1, p2, p3);
  }

  /// (A1.x - A3.x) * (A2.y - A3.y) - (A1.y - A3.y) * (A2.x - A3.x)
  bool _calculateOrientation(Offset p1, Offset p2, Offset p3) {
    var orientation = ((p1.dx - p3.dx) * (p2.dy - p3.dy)) -
        ((p1.dy - p3.dy) * (p2.dx - p3.dx));
    return orientation > 0;
  }

  /// all triangles must have the same orientation
  bool isOffsetInside(Offset p) {
    if ((_calculateOrientation(p1, p2, p) != orientation) ||
        (_calculateOrientation(p2, p3, p) != orientation) ||
        (_calculateOrientation(p3, p1, p) != orientation)) {
      return false;
    }
    return true;
  }
}

class WheelOctant {
  final double dx;
  final double dy;

  RightTriangle triangle;

  WheelOctant(Offset p1, Offset p2, Offset p3,
      {@required this.dx, @required this.dy})
      : triangle = RightTriangle(p1, p2, p3);

  bool _isOffsetInside(Offset p) => triangle.isOffsetInside(p);

  toString() => 'WheelOctant(dx: $dx, dy: $dy))';
}

class WheelVelocity {
  final Size size;

  Map<int, WheelOctant> _octants;

  WheelVelocity({this.size}) {
    _initializeOctants();
  }

  void _initializeOctants() {
    var origin = Offset(0, 0);
    var tCenter = size.topCenter(origin);
    var tLeft = size.topLeft(origin);
    var tRight = size.topRight(origin);
    var center = size.center(origin);
    var cLeft = size.centerLeft(origin);
    var cRight = size.centerRight(origin);
    var bCenter = size.bottomCenter(origin);
    var bLeft = size.bottomLeft(origin);
    var bRight = size.bottomRight(origin);

    _octants = Map<int, WheelOctant>();
    _octants[1] = WheelOctant(tCenter, tRight, center, dx: 0.7, dy: 0.3);
    _octants[2] = WheelOctant(tRight, cRight, center, dx: 0, dy: 1);
    _octants[3] = WheelOctant(cRight, bRight, center, dx: -0.3, dy: 0.7);
    _octants[4] = WheelOctant(bRight, bCenter, center, dx: -1, dy: 0);
    _octants[5] = WheelOctant(bCenter, bLeft, center, dx: -0.7, dy: -0.3);
    _octants[6] = WheelOctant(bLeft, cLeft, center, dx: 0, dy: -1);
    _octants[7] = WheelOctant(cLeft, tLeft, center, dx: 0.3, dy: -0.7);
    _octants[8] = WheelOctant(tLeft, tCenter, center, dx: 1, dy: 0);
  }

  int _getOctantFromOffset(Offset p) {
    // this HAS TO BE be improved
    if (_octants[1]._isOffsetInside(p)) return 1;
    if (_octants[2]._isOffsetInside(p)) return 2;
    if (_octants[3]._isOffsetInside(p)) return 3;
    if (_octants[4]._isOffsetInside(p)) return 4;
    if (_octants[5]._isOffsetInside(p)) return 5;
    if (_octants[6]._isOffsetInside(p)) return 6;
    if (_octants[7]._isOffsetInside(p)) return 7;
    if (_octants[8]._isOffsetInside(p)) return 8;
    return _getOutsideCuadrantFromOffset(p);
  }

  int _getOutsideCuadrantFromOffset(Offset p) {
    if (p.dx < 0) {
      return p.dy < (size.height / 2) ? 7 : 6;
    }
    if (p.dx > size.width) {
      return p.dy < (size.height / 2) ? 2 : 3;
    }
    if (p.dy < 0) {
      return p.dx < (size.width / 2) ? 8 : 1;
    }
    if (p.dy > size.height) {
      return p.dx < (size.width / 2) ? 5 : 4;
    }
    return -1;
  }

  double getVelocity(Offset position, Offset pixelsPerSecond) {
    var cuadrant = _getOctantFromOffset(position);
    if (cuadrant == -1) return 0;
    var octant = _octants[cuadrant];
    var velocity =
        (octant.dx * pixelsPerSecond.dx) + (octant.dy * pixelsPerSecond.dy);
    // print('oct $octant, pps $pixelsPerSecond, cuad $cuadrant, vel $velocity');
    return velocity;
  }

  bool isOffsetInside(Offset position) {
    if (position.dx < 0 || position.dx > size.width) {
      return false;
    }
    if (position.dy < 0 || position.dy > size.height) {
      return false;
    }
    return true;
  }

  double offsetToRadians(Offset position) {
    var a = position.dx - (size.width / 2);
    var b = (size.height / 2) - position.dy;
    // we want to start from positive y axis
    var angle = atan2(b, a);
    var normalized = _normalizeAngle(angle);

    return normalized;
  }

  double _normalizeAngle(double angle) {
    if (angle > 0) {
      return angle > (pi / 2) ? ((5 * pi / 2) - angle) : ((pi / 2) - angle);
    } else {
      return (pi / 2) - angle;
    }
  }
}
