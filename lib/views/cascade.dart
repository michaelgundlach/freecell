import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../main.dart';
import 'pile-view.dart';

class Cascade extends ConsumerWidget {
  final int cascadeNum;
  const Cascade({required this.cascadeNum, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      var exposure = .14;
      var height = constraints.maxHeight; // The height of the row of cascades
      var width = constraints.maxWidth; // The width of the cascade
      var maxCardsVisible = 15; // size cards so this many will completely show in stack
      var heightAsMultipleOfCardHeight = 1 + exposure * (maxCardsVisible - 1);
      var cascadeAspectRatio = playingCardAspectRatio / heightAsMultipleOfCardHeight;
      double w, h;
      if (height < width / cascadeAspectRatio) {
        // Our container is too short; constrain width so we are not too tall
        h = height;
        w = h * cascadeAspectRatio;
      } else {
        // Our container is too narrow; constrain height so we are not too wide
        w = width;
        h = w / cascadeAspectRatio;
        // Except actually, use the full height.  TODO figure this out elegantly
        cascadeAspectRatio = w / height;
      }
      var cardHeight = w / playingCardAspectRatio;
      return Center(
          child: AspectRatio(
              aspectRatio: cascadeAspectRatio,
              child: PileView(
                entries: ref.watch(gameStateProvider).cascades[cascadeNum],
                canHighlight: (entry) => !entry.isTheBase,
                canReceive: (highlighted, entry) => entry.canCascade(highlighted),
                baseBuilder: () => Container(height: cardHeight, color: Colors.blue[200]),
                positioner: (i, child) => Positioned(top: exposure * cardHeight * (i - 1), width: w, child: child),
              )));
    });
  }
}
