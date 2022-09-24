import 'dart:math';

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
            _moreButton(context, gameState, cardWidth),
            ...gameState.freeCells.map(
              (pile) => PileView(
                entries: pile,
                canHighlight: (PileEntry entry) => !entry.isTheBase,
                canReceive: (PileEntry highlighted, PileEntry entry) => entry.isTheBase,
                baseBuilder: () => _buildBase(context, ref, cardWidth),
                positioner: (_, Widget child) => child,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _moreButton(context, GameState gameState, cardWidth) {
    Widget button = const SizedBox.shrink();
    if (gameState.freeCellsAreFull) {
      button = GestureDetector(
        onTap: () => gameState.addFreeCell(),
        child: Container(
          width: cardWidth / 1.9,
          height: cardWidth / 1.9,
          decoration: BoxDecoration(color: Theme.of(context).highlightColor, borderRadius: BorderRadius.circular(100)),
          child: FittedBox(fit: BoxFit.contain, child: Text("+", style: Theme.of(context).textTheme.caption)),
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(4.0),
        width: cardWidth,
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            reverseDuration: const Duration(milliseconds: 300),
            switchInCurve: Curves.fastOutSlowIn,
            switchOutCurve: Curves.fastOutSlowIn,
            child: button,
          ),
        ),
      ),
    );
  }

  Widget _buildBase(BuildContext context, WidgetRef ref, double cardWidth) {
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
                child: FittedBox(fit: BoxFit.contain, child: Text("FREE", style: Theme.of(context).textTheme.caption)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// At least 4 columns (we have 8 cascades and 4 foundations) and leave room for the More button.
  static int numberOfColumns(GameState gs) => max(4, gs.numFreeCells + 1);
}
