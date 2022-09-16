import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/pile-view.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../model/game-state.dart';

class Foundations extends ConsumerStatefulWidget {
  const Foundations({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoundationsState();
}

class _FoundationsState extends ConsumerState<Foundations> {
  final int maxTiltDegrees = 5;
  final int maxTranslatePixels = 10; // in any direction
  final rnd = Random();
  final List<List<Matrix4>> slops = List.generate(4, (_) => [Matrix4.identity()]);

  Matrix4 _slop(i, j) {
    j = j - 1; // We only ask starting with entry #1, which we store at [0]
    while (slops[i].length <= j) {
      Matrix4 slop = Matrix4.identity();
      double tilt = maxTiltDegrees * (rnd.nextDouble() - .5);
      slop.rotateZ(radians(tilt));
      List<double> slide = List.generate(2, (_) => maxTranslatePixels * (rnd.nextDouble() - .5));
      slop.translate(slide[0], slide[1]);
      slops[i].add(slop);
    }
    return slops[i][j];
  }

  @override
  Widget build(BuildContext context) {
    var gameState = ref.watch(GameState.provider);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final cardWidth = constraints.maxWidth / 4;
      final cardHeight = cardWidth / playingCardAspectRatio;
      return SizedBox(
        height: cardHeight,
        child: Row(
          children: gameState.foundations
              .mapIndexed((i, pile) => PileView(
                    // TODO right
                    entries: pile,
                    canHighlight: (PileEntry entry) => false,
                    canReceive: (PileEntry highlighted, PileEntry entry) => entry.isNextInFoundation(highlighted),
                    baseBuilder: () => Container(
                      decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(10)),
                      child: AspectRatio(
                        aspectRatio: playingCardAspectRatio,
                        child: FractionallySizedBox(
                            widthFactor: .5,
                            heightFactor: .5,
                            child: FittedBox(
                                fit: BoxFit.contain, child: Text("A", style: Theme.of(context).textTheme.headline4))),
                      ),
                    ),

                    positioner: (int j, Widget child) {
                      return Align(
                          child: Transform(alignment: FractionalOffset.center, transform: _slop(i, j), child: child));
                    },
                  ))
              .toList(),
        ),
      );
    });
  }
}
