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
      var height = constraints.maxHeight; // The height of the row of cascades
      var width = constraints.maxWidth; // The width of the cascade
      var cardHeight = width / playingCardAspectRatio;
      return PileView(
        entries: ref.watch(gameStateProvider).cascades[cascadeNum],
        canHighlight: (entry) => !entry.isTheBase,
        canReceive: (highlighted, entry) => entry.canCascade(highlighted),
        baseBuilder: () => Container(color: Colors.blue[200]),
        positioner: (i, child) => Positioned(top: .14 * cardHeight * i, width: width, child: child),
      );
    });
  }
}
