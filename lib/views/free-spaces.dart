import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/main.dart';
import 'package:playing_cards/playing_cards.dart';

import '../util/deck-style.dart';
import 'pile-view.dart';
import '../model/game-state.dart';

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var gameState = ref.watch(GameState.provider);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final cardWidth = constraints.maxWidth / max(gameState.numFreeCells, 4);
      final cardHeight = cardWidth / playingCardAspectRatio;
      return SizedBox(
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: gameState.freeCells
              .mapIndexed(
                (int i, pile) => PileView(
                  // TODO right
                  entries: pile,
                  canHighlight: (PileEntry entry) => !entry.isTheBase,
                  canReceive: (PileEntry highlighted, PileEntry entry) => entry.isTheBase,
                  baseBuilder: () => _buildBase(ref, cardWidth, context, i),
                  positioner: (int i, Widget child) => Align(child: child),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Container _buildBase(WidgetRef ref, double cardWidth, BuildContext context, int i) {
    final deckStyle = ref.watch(deckStyleProvider);
    final gameState = ref.watch(GameState.provider);
    final color = i == 0 ? Theme.of(context).highlightColor : Theme.of(context).indicatorColor;
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(4), // same padding as PlayingCardView
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(deckStyle.radius)),
        child: AspectRatio(
          aspectRatio: playingCardAspectRatio,
          child: Center(
            child: Transform(
              transform: Matrix4.rotationZ(-.5),
              alignment: FractionalOffset.center,
              child: FractionallySizedBox(
                  widthFactor: .7,
                  heightFactor: .7,
                  child: FittedBox(
                      fit: BoxFit.contain, child: Text(_cellText(i), style: Theme.of(context).textTheme.headline4))),
            ),
          ),
        ),
      ),
    );
  }

  /// Text to show in free space card.
  _cellText(i) {
    if (i != 0) return "FREE";
    return "MORE";
  }
}
