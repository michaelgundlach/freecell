import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../model/game-state.dart';
import 'cascade.dart';
import '../util/constrained-aspect-ratio.dart';
import 'foundations.dart';
import 'free-spaces.dart';
import '../util/text-stamp.dart';

class GameMat extends ConsumerWidget {
  const GameMat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(GameState.provider);
    final longestCascade = gameState.cascades.reduce((a, b) => a.length > b.length ? a : b).length;
    final mostCards = longestCascade - 1; // ignore base at cascade[0]
    final fitThisManyCards = max(14, mostCards);
    final reservedCascadeHeight = 1 + (fitThisManyCards - 1) * Cascades.cardExposure; // 1st card, then overlaps
    const foundationHeight = 1;
    final totalCardsHeight = foundationHeight + reservedCascadeHeight;
    final cardsWidth = 4 + FreeSpaces.numberOfColumns(gameState);
    final boardAspectRatio = cardsWidth / totalCardsHeight * playingCardAspectRatio;
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: 3,
              color: Theme.of(context).primaryColorDark,
              blurRadius: 2,
            ),
          ],
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: ConstrainedAspectRatio(
          maxAspectRatio: boardAspectRatio, // If parent is too tall, grow taller
          child: Stack(
            children: [
              const Align(
                alignment: FractionalOffset(0.5, 0.67),
                child: FractionallySizedBox(
                  widthFactor: 0.42,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: TextStamp("Freecell", fontFamily: "FleurDeLeah", shadow: 1),
                  ),
                ),
              ),
              Column(
                children: [
                  const Expanded(child: Cascades()),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(children: [
                      const Expanded(flex: 40, child: Foundations()),
                      const Spacer(flex: 1),
                      Expanded(flex: 10 * FreeSpaces.numberOfColumns(gameState), child: const FreeSpaces()),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
