import 'package:flutter/material.dart';

class Tile {
  final int x;
  final int y;
  int val;

  Animation<double> animatedX;
  Animation<double> animatedY;
  Animation<int> animatedValue;
  Animation<double> scale;

  Tile(this.x, this.y, this.val) {
    resetAnimations();
  }

  void resetAnimations() {
    animatedX = AlwaysStoppedAnimation(this.x.toDouble());
    animatedY = AlwaysStoppedAnimation(this.y.toDouble());
    animatedValue = AlwaysStoppedAnimation(this.val);
    scale = AlwaysStoppedAnimation(1.0);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animatedX = Tween(begin: this.x.toDouble(), end: x.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: Interval(0, 0.5)));
    animatedY = Tween(begin: this.y.toDouble(), end: y.toDouble())
        .animate(CurvedAnimation(parent: parent, curve: Interval(0, 0.5)));
  }

  void jump(Animation<double> parent) {
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(.5, 1.0)));
  }

  void appear(Animation<double> parent) {
    scale = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: parent, curve: Interval(0.5, 1.0)));
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animatedValue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(val), weight: 0.01),
      TweenSequenceItem(tween: ConstantTween(newValue), weight: 0.99),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(0.5, 1.0)));
  }
}

class EmptyTile extends Tile {
  EmptyTile(int x, int y) : super(x, y, 0);
}