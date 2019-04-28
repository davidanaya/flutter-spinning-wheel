import 'package:flutter/material.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';

class AnimatedWheel extends StatefulWidget {
  final Image image;
  final double initialSpinAngle;
  final double velocity;
  final int dividers;
  final Function onEnd;

  AnimatedWheel(this.image,
      {this.initialSpinAngle, this.dividers, this.velocity, this.onEnd}) {
    print('initialSpintAngle: $initialSpinAngle');
  }

  @override
  _AnimatedWheelState createState() => _AnimatedWheelState();
}

class _AnimatedWheelState extends State<AnimatedWheel>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  double _totalDuration = 0;
  double _initialCircularVelocity = 0;
  double _distance = 0;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 0),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationCompleted();
      }
    });
  }

  void _onAnimationCompleted() {
    var anglePerDivider = calculateAnglePerDivision(widget.dividers);
    var totalDistanceModulo = calculateModuloInCircunference(_distance);
    var divider = totalDistanceModulo ~/ anglePerDivider;
    widget.onEnd(angle: totalDistanceModulo, divider: divider);
  }

  @override
  void didUpdateWidget(AnimatedWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    _initialCircularVelocity = pixelsPerSecondToRadians(widget.velocity);
    _totalDuration = calculateDurationInSeconds(_initialCircularVelocity);

    _animationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        child: Container(child: widget.image),
        builder: (context, child) {
          var currentTime = _totalDuration * _animation.value;
          _distance = calculateDistance(_initialCircularVelocity, currentTime);

          return Transform.rotate(
            angle: widget.initialSpinAngle + _distance,
            child: child,
          );
        });
  }
}
