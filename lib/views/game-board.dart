import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../model/game-state.dart';
import 'cascade.dart';
import 'constrained-aspect-ratio.dart';
import 'foundations.dart';
import 'free-spaces.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(GameState.provider);
    final maxCascade = gameState.cascades.reduce((a, b) => a.length > b.length ? a : b).length + 2;
    final boardAspectRatio = playingCardAspectRatio * 10 / (2 + (maxCascade - 1) * Cascades.cardExposure);
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedContainer(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(10))),
        duration: Duration(seconds: 30),
        child: ConstrainedAspectRatio(
          maxAspectRatio: boardAspectRatio, // If parent is too tall, grow taller
          child: Column(
            children: [
              Expanded(child: Cascades()),
              Row(children: [
                Expanded(flex: 40, child: Foundations()),
                if (gameState.numFreeCells < 6) Spacer(flex: 100 - 40 - (10 * gameState.numFreeCells)),
                Expanded(
                  flex: 10 * gameState.numFreeCells,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FreeSpaces(),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
