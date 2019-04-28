import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffB0F9D2),
        body: SafeArea(
          child: GamePage(),
        ));
  }
}

class GamePage extends StatelessWidget {
  final StreamController _dividerController = StreamController<int>();

  dispose() {
    _dividerController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinningWheel(
            Image.asset('assets/images/wheel-6-300.png'),
            width: 310,
            height: 310,
            initialSpinAngle: _generateRandomAngle(),
            dividers: 6,
            onUpdate: _dividerController.add,
            onEnd: _dividerController.add,
          ),
          StreamBuilder(
            stream: _dividerController.stream,
            builder: (context, snapshot) =>
                snapshot.hasData ? WheelScore(snapshot.data) : Container(),
          )
        ],
      ),
    );
  }

  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
}

class WheelScore extends StatelessWidget {
  final int selected;

  WheelScore(this.selected);
  @override
  Widget build(BuildContext context) {
    return Text(
      '${_getWinner(selected)}',
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }

  String _getWinner(int divider) {
    switch (divider) {
      case 1:
        return 'Purple';
      case 2:
        return 'Magenta';
      case 3:
        return 'Red';
      case 4:
        return 'Dark Orange';
      case 5:
        return 'Light Orange';
      case 6:
        return 'Yellow';
      default:
        return '';
    }
  }
}
