import 'dart:math';

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
    final longestCascade = gameState.cascades.reduce((a, b) => a.length > b.length ? a : b).length;
    final mostCards = longestCascade - 1; // ignore base at cascade[0]
    final fitThisManyCards = max(14, mostCards);
    final reservedCascadeHeight = 1 + (fitThisManyCards - 1) * Cascades.cardExposure; // 1st card, then overlaps
    const foundationHeight = 1;
    final totalCardsHeight = foundationHeight + reservedCascadeHeight;
    final cardsWidth = 4 + max(4, gameState.numFreeCells);
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
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  const Expanded(child: Cascades()),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(children: [
                      const Expanded(flex: 40, child: Foundations()),
                      const Spacer(flex: 1),
                      Expanded(flex: 10 * max(gameState.numFreeCells, 4), child: const FreeSpaces()),
                    ]),
                  ),
                ],
              ),
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                      child: Text(ref.watch(GameState.provider).seed.toString(),
                          style: TextStyle(color: Theme.of(context).primaryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
