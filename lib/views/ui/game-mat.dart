import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../model/game-state.dart';
import '../util/game-over-dancer.dart';
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
  void dispose() {
    colorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cascades = ref.watch(GameState.provider.select((gs) => gs.cascades));
    var stage = ref.watch(GameState.provider.select((gs) => gs.stage));
    var numFreeCells = ref.watch(GameState.provider.select((gs) => gs.numFreeCells));
    var settledCards = ref.watch(GameState.provider.select((gs) => gs.settledCards));

    final longestCascade = cascades.reduce((a, b) => a.length > b.length ? a : b).length;
    final mostCards = longestCascade - 1; // ignore base at cascade[0]
    final fitThisManyCards = max(14, mostCards);
    final reservedCascadeHeight = 1 + (fitThisManyCards - 1) * Cascades.cardExposure; // 1st card, then overlaps
    const foundationHeight = 1;
    final totalCardsHeight = foundationHeight + reservedCascadeHeight;
    final cardsWidth = 4 + FreeSpaces.numberOfColumns(numFreeCells);
    final boardAspectRatio = cardsWidth / totalCardsHeight * playingCardAspectRatio;
    final logo = numFreeCells < 6
        ? "Freecell"
        : {
              6: "Hi  Mom",
              7: "Really?",
              8: "Wimpcell",
              9: "Not-even-tryingcell",
              10: "Maybe try again when you're older",
              11: "Oh-come-on-cell",
              12: "Are-you-kidding-me-cell",
              13: "Now you're just curious, right?",
              14: "Can you even read the cards?"
            }[numFreeCells] ??
            "Fifty two free cells should do it...";

    if (stage == "game over" && wiggleControl == Control.stop) {
      setState(() {
        wiggleControl = Control.mirror;
        growControl = slideControl = Control.play;
      });
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        colorTimer = timer;
        r(int a, int b) => Random().nextInt(b - a) + a;
        setState(() => logoColor = Color.fromARGB(255, r(0, 200), r(100, 255), r(150, 255)));
      });
    } else if (stage == "winning" && settledCards > 0) {
      r(int a, int b) => Random().nextInt(b - a) + a;
      logoColor = Color.fromARGB(255, r(0, 200), r(100, 255), r(150, 255));
    } else if (stage == "playing" && wiggleControl != Control.stop) {
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
        builder: (context, value, child) {
          Widget logoStamp = TextStamp(
            logo,
            fontFamily: "FleurDeLeah",
            shadow: 1,
            color: logoColor, // initial null lets TextStamp choose; will be set when we win
          );
          // Make sure that when the logo starts to dance, it doesn't have to Hero transition in from the
          // previous screen, screwing up its rotation for a moment.
          if (stage != "game over") {
            logoStamp = Hero(tag: "freecell", child: logoStamp);
          }
          return Align(
            alignment: FractionalOffset(value.get('dx'), value.get('dy')),
            child: FractionallySizedBox(
              widthFactor: 0.9,
              heightFactor: 0.35,
              child: CustomAnimationBuilder<double>(
                builder: (_, scale, child) =>
                    FractionallySizedBox(widthFactor: scale, heightFactor: scale, child: child),
                tween: Tween(begin: 1, end: 2.2),
                duration: const Duration(seconds: 5),
                delay: const Duration(seconds: 2),
                control: growControl,
                child: GameOverDancer(
                  curve: Curves.easeInOutCubic,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: logoStamp,
                  ),
                ),
              ),
            ),
          );
        },
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
              Expanded(flex: 10 * FreeSpaces.numberOfColumns(numFreeCells), child: const FreeSpaces()),
            ]),
          ),
          const Expanded(child: Cascades()),
        ],
      ),
    ];
    if (stage == "game over") {
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
