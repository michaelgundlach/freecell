import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/pile-view.dart';
import 'package:playing_cards/playing_cards.dart';

import '../main.dart';
import '../model/game-state.dart';

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var gameState = ref.watch(gameStateProvider);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final cardWidth = constraints.maxWidth / gameState.numFreeCells;
      final cardHeight = cardWidth / playingCardAspectRatio;
      return Container(
        height: cardHeight,
        child: Row(
          children: gameState.freeCells
              .map(
                (pile) => PileView(
                  // TODO right
                  entries: pile,
                  canHighlight: (PileEntry entry) => !entry.isTheBase,
                  canReceive: (PileEntry highlighted, PileEntry entry) => entry.isTheBase,
                  baseBuilder: () => Container(
                    decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(10)),
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
                                  fit: BoxFit.contain,
                                  child: Text("FREE", style: Theme.of(context).textTheme.headline4))),
                        ),
                      ),
                    ),
                  ),
                  positioner: (int i, Widget child) => Align(child: child),
                ),
              )
              .toList(),
        ),
      );
    });
  }
}
