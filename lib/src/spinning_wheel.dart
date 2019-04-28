import 'package:flutter/material.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_spinning_wheel/src/wheel_velocity.dart';

class SpinningWheel extends StatefulWidget {
  final double width;
  final double height;
  final Image image;
  final int dividers;
  final double initialSpinAngle;
  final Function onUpdate;
  final Function onEnd;

  SpinningWheel(
    this.image, {
    @required this.width,
    @required this.height,
    @required this.dividers,
    this.initialSpinAngle,
    this.onUpdate,
    this.onEnd,
  });

  @override
  _SpinningWheelState createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  // it helps calculating the velocity based on position and pixels per second velocity and angle
  WheelVelocity _wheelVelocity;

  // keeps the last local position on pan update
  Offset _localPositionOnPanUpdate;

  // duration of the animation based on the initial velocity
  double _totalDuration = 0;

  // initial velocity for the wheel when the user spins the wheel
  double _initialCircularVelocity = 0;

  // angle for each divider: 2*pi / numberOfDividers
  double _dividerAngle;

  // current (circular) distance (angle) covered during the animation
  double _currentDistance = 0;

  // initial spin angle when the wheels starts the animation
  double _initialSpinAngle;

  // dividider which is selected (positive y-coord)
  int _currentDivider;

  // spining backwards
  bool _isBackwards;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 0),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _dividerAngle = calculateAnglePerDivision(widget.dividers);
    _initialSpinAngle = widget.initialSpinAngle;

    _wheelVelocity = WheelVelocity(size: Size(widget.width, widget.height));

    _animation.addStatusListener((status) {
      _animationStatus = status;
      if (status == AnimationStatus.completed) {
        _stop(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _start,
        onPanDown: _stop,
        child: AnimatedBuilder(
            animation: _animation,
            child: Container(child: widget.image),
            builder: (context, child) {
              _updateAnimationValues();
              widget.onUpdate(_currentDivider);
              return Transform.rotate(
                angle: _initialSpinAngle + _currentDistance,
                child: child,
              );
            }),
      ),
    );
  }

  void _updateAnimationValues() {
    if (_animationStatus == AnimationStatus.forward) {
      // calculate total distance covered
      var currentTime = _totalDuration * _animation.value;
      _currentDistance =
          calculateDistance(_initialCircularVelocity, currentTime);
      if (_isBackwards) {
        _currentDistance = -_currentDistance;
      }
    }
    // calculate current divider selected
    var modulo =
        calculateModuloInCircunference(_currentDistance + _initialSpinAngle);
    _currentDivider = widget.dividers - (modulo ~/ _dividerAngle);
    if (_animationStatus != AnimationStatus.forward) {
      _initialSpinAngle = modulo;
      _currentDistance = 0;
    }
  }

  // void _onWheelTap() {
  //   if (_animationStatus == AnimationStatus.forward) {
  //     _stop(null, null);
  //   } else {
  //     _start(null);
  //   }
  // }

  void _onPanUpdate(DragUpdateDetails details) {
    RenderBox renderBox = context.findRenderObject();
    _localPositionOnPanUpdate = renderBox.globalToLocal(details.globalPosition);
    if (_wheelVelocity.isOffsetInside(_localPositionOnPanUpdate)) {
      var newAngle = _wheelVelocity.offsetToRadians(_localPositionOnPanUpdate);
      // initialSpinAngle will be added later on build
      setState(() {
        _currentDistance = newAngle - _initialSpinAngle;
      });
    }
  }

  void _stop(DragDownDetails _details) {
    _animationController.stop();
    _animationController.reset();
    widget.onEnd(_currentDivider);
  }

  void _start(DragEndDetails details) {
    var velocity = _wheelVelocity.getVelocity(
        _localPositionOnPanUpdate, details.velocity.pixelsPerSecond);
    _localPositionOnPanUpdate = null;

    _isBackwards = velocity < 0;

    _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());
    _totalDuration = calculateDurationInSeconds(_initialCircularVelocity);

    _animationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());

    _animationController.reset();
    _animationController.forward();
  }
}
