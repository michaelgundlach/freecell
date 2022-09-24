import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/main.dart';
import 'package:playing_cards/playing_cards.dart';

import 'pile-view.dart';
import '../model/game-state.dart';

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var gameState = ref.watch(GameState.provider);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final cardWidth = constraints.maxWidth / numberOfColumns(gameState);
      final cardHeight = cardWidth / playingCardAspectRatio;
      return SizedBox(
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (gameState.freeCellsAreFull) _moreButton(context, gameState, cardWidth),
            ...gameState.freeCells.map(
              (pile) => PileView(
                // TODO right
                entries: pile,
                canHighlight: (PileEntry entry) => !entry.isTheBase,
                canReceive: (PileEntry highlighted, PileEntry entry) => entry.isTheBase,
                baseBuilder: () => _buildBase(ref, cardWidth, context),
                positioner: (_, Widget child) => Align(child: child),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _moreButton(context, gameState, cardWidth) {
    final color = Theme.of(context).highlightColor;
    return Center(
      child: Container(
        width: cardWidth,
        height: cardWidth,
        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        child: GestureDetector(
          onTap: () => gameState.addFreeCell(),
          child: Container(
            width: cardWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(100)),
            child: Text("+", style: Theme.of(context).textTheme.headline4!),
          ),
        ),
      ),
    );
  }

  Widget _buildBase(WidgetRef ref, double cardWidth, BuildContext context) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(4.0), // same padding as PlayingCardView
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).indicatorColor,
          borderRadius: BorderRadius.circular(ref.watch(deckStyleProvider).radius),
        ),
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
                      fit: BoxFit.contain, child: Text("FREE", style: Theme.of(context).textTheme.headline4))),
            ),
          ),
        ),
      ),
    );
  }

  /// At least 4 columns (we have 8 cascades and 4 foundations) and leave room for the More button.
  static int numberOfColumns(GameState gs) => max(4, gs.numFreeCells + 1);
}
