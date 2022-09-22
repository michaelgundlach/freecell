import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class DeckStyle {
  const DeckStyle({this.suitStyle, this.radius = 0.0, this.elevation, this.shape});

  final double radius;
  final SuitStyle? suitStyle;
  final double? elevation;
  final ShapeBorder? shape;
}
