import 'package:flutter/material.dart';
import 'package:my_game/twenty_forty_eight_widget.dart';

void main() {
  runApp(TwentyFortyEightApp());
}

class TwentyFortyEightApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      home: TwentyFortyEightWidget(),
    );
  }
}