# example

A basic example on how to use the widget circular_slider in Flutter.

## Getting Started

```dart
import 'package:flutter/material.dart';

import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';

void main() => runApp(MyApp());

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
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: Container(child:
            SpinningWheel(
              Image.asset('assets/images/wheel-6-300.png'),
              width: 310,
              height: 310,
              dividers: 6,
              onEnd: _dividerController.add,
            ),
          ),
        ));
  }
}
```
