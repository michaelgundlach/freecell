import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/main.dart';
import 'package:playing_cards/playing_cards.dart';

import '../util/pile-view.dart';
import '../../model/game-state.dart';
import '../util/text-stamp.dart';

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({super.key});

  /// At least 4 columns (we have 8 cascades and 4 foundations) and leave room for the More button.
  static int numberOfColumns(int numFreeCells) => max(4, numFreeCells + 1);

  @override
  Widget build(BuildContext context, ref) {
    var gameState = ref.watch(GameState.provider);
    int numFreeCells = ref.watch(GameState.provider.select((gs) => gs.numFreeCells));
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final cardWidth = constraints.maxWidth / FreeSpaces.numberOfColumns(numFreeCells);
      final cardHeight = cardWidth / playingCardAspectRatio;
      return SizedBox(
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _moreButton(context, ref, cardWidth),
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

  Widget _moreButton(context, ref, cardWidth) {
    Widget button = const SizedBox.shrink();
    if (ref.watch(GameState.provider.select((gs) => gs.freeCellsAreFull))) {
      button = GestureDetector(
        onTap: () => ref.read(GameState.provider).addFreeCell(),
        child: Container(
          width: cardWidth / 1.9,
          height: cardWidth / 1.9,
          decoration: BoxDecoration(color: Theme.of(context).indicatorColor, borderRadius: BorderRadius.circular(100)),
          child: const TextStamp("+"),
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
            duration: const Duration(milliseconds: 800),
            reverseDuration: const Duration(milliseconds: 0),
            switchInCurve: Curves.fastOutSlowIn,
            child: button,
          ),
        ),
      ),
    );
  }

  Widget _buildBase(BuildContext context, WidgetRef ref, double cardWidth) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.all(2), // vs playingcard having 4, so we get a little border
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).indicatorColor,
          borderRadius: BorderRadius.circular(ref.watch(deckStyleProvider).radius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColorDark,
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: AspectRatio(
          aspectRatio: playingCardAspectRatio,
          child: Align(
            alignment: const FractionalOffset(-.1, 0.85),
            child: Transform(
              transform: Matrix4.rotationZ(-.5),
              child: const FractionallySizedBox(
                widthFactor: .6,
                heightFactor: .6,
                child: TextStamp("free", fontFamily: "FleurDeLeah", shadow: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
