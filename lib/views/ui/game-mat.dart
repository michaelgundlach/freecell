import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../model/game-state.dart';
import 'cascade.dart';
import '../util/constrained-aspect-ratio.dart';
import 'foundations.dart';
import 'free-spaces.dart';
import '../util/text-stamp.dart';

class GameMat extends ConsumerStatefulWidget {
  const GameMat({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameMatState();
}

class _GameMatState extends ConsumerState<GameMat> {
  Control wiggleControl = Control.stop, growControl = Control.stop, slideControl = Control.stop;
  Timer? colorTimer;
  Color? logoColor;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(GameState.provider);
    final longestCascade = gameState.cascades.reduce((a, b) => a.length > b.length ? a : b).length;
    final mostCards = longestCascade - 1; // ignore base at cascade[0]
    final fitThisManyCards = max(14, mostCards);
    final reservedCascadeHeight = 1 + (fitThisManyCards - 1) * Cascades.cardExposure; // 1st card, then overlaps
    const foundationHeight = 1;
    final totalCardsHeight = foundationHeight + reservedCascadeHeight;
    final cardsWidth = 4 + FreeSpaces.numberOfColumns(gameState);
    final boardAspectRatio = cardsWidth / totalCardsHeight * playingCardAspectRatio;
    final logo = gameState.numFreeCells < 6
        ? "Freecell"
        : {
              6: "Hi  Mom",
              7: "Really?",
              8: "Wimpcell",
              9: "Not-even-tryingcell",
              10: "Losercell",
              11: "Oh-come-on-cell",
              12: "Are-you-kidding-me-cell",
              13: "Now you're just curious, right?",
              14: "Can you even read the cards?"
            }[gameState.numFreeCells] ??
            "Fifty two free cells should do it...";

    if (gameState.stage == "game over" && wiggleControl == Control.stop) {
      wiggleControl = Control.mirror;
      growControl = slideControl = Control.play;
      Timer.periodic(const Duration(milliseconds: 600), (timer) {
        r(int a, int b) => Random().nextInt(b - a) + a;
        setState(() => logoColor = Color.fromARGB(255, r(0, 200), r(100, 255), r(150, 255)));
        // TODO temp
        if (gameState.stage == "playing") {
          timer.cancel();
        }
      });
    }
    // TODO temp
    else if (gameState.stage == "playing" && wiggleControl != Control.stop) {
      wiggleControl = growControl = slideControl = Control.stop;
    }
    List<Widget> stackChildren = [
      CustomAnimationBuilder(
        tween: MovieTween()
          ..tween('dx', Tween(begin: 0.25, end: 0.1), duration: const Duration(milliseconds: 500))
          ..tween('dy', Tween(begin: 0.67, end: 0.5), duration: const Duration(milliseconds: 500)),
        duration: const Duration(seconds: 5),
        delay: const Duration(seconds: 2),
        control: slideControl,
        builder: (context, value, child) => Align(
          alignment: FractionalOffset(value.get('dx'), value.get('dy')),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.35,
            child: CustomAnimationBuilder<double>(
              builder: (_, scale, child) => FractionallySizedBox(widthFactor: scale, heightFactor: scale, child: child),
              tween: Tween(begin: 1, end: 2.2),
              duration: const Duration(seconds: 5),
              delay: const Duration(seconds: 2),
              control: growControl,
              child: CustomAnimationBuilder<double>(
                builder: (_, rotation, child) => Transform(
                  transform: Matrix4.rotationZ(rotation),
                  alignment: Alignment.center,
                  child: child,
                ),
                tween: Tween(begin: -pi / 6, end: pi / 6),
                startPosition: 0.493,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                control: wiggleControl,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Hero(
                      tag: "freecell",
                      child: TextStamp(
                        logo,
                        fontFamily: "FleurDeLeah",
                        shadow: 1,
                        color: logoColor, // initial null lets TextStamp choose; will be set when we win
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
      Column(
        // Force cascades to render after foundations, so win animation doesn't fly cards underneath foundations
        verticalDirection: VerticalDirection.up,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Row(children: [
              const Expanded(flex: 40, child: Foundations()),
              const Spacer(flex: 1),
              Expanded(flex: 10 * FreeSpaces.numberOfColumns(gameState), child: const FreeSpaces()),
            ]),
          ),
          const Expanded(child: Cascades()),
        ],
      ),
    ];
    if (gameState.stage == "game over") {
      stackChildren = stackChildren.reversed.toList(); // put logo above cards for win animation
    }
    return Container(
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
          children: stackChildren,
        ),
      ),
    );
  }
}
