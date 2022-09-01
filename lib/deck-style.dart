import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class DeckStyle {
  const DeckStyle({this.suitStyle, this.cardHeight, this.elevation, this.shape});

  final SuitStyle? suitStyle;
  final double? cardHeight;
  final double? elevation;
  final ShapeBorder? shape;
}
