import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../main.dart';
import '../util/freecell-card-view.dart';
import '../util/freecell-interact-target.dart';
import '../util/pile-view.dart';
import '../../model/game-state.dart';
import '../util/text-stamp.dart';

final slopProvider = Provider<SlopTracker>((ref) => SlopTracker());

class SlopTracker {
  final Map<Suit, Map<CardValue, Matrix4>> _slops = {};
  final int maxTiltDegrees = 5;
  final int maxTranslatePixels = 10; // in any direction
  final rnd = Random();

  slop(Widget child, String stage) {
    if (child.runtimeType == FreecellInteractTarget) {
      child = (child as FreecellInteractTarget).child;
    }
    PlayingCard card = (child as FreecellCardView).card;
    _slops.putIfAbsent(card.suit, () => {}).putIfAbsent(card.value, () {
      Matrix4 slop = Matrix4.identity();
      if (card.value == CardValue.ace) return slop;
      double tilt = (stage != "playing") ? 0 : maxTiltDegrees * (rnd.nextDouble() - .5);
      slop.rotateZ(radians(tilt));
      List<double> slide = List.generate(2, (_) => maxTranslatePixels * (rnd.nextDouble() - .5));
      slop.translate(slide[0], slide[1]);
      return slop;
    });
    return _slops[card.suit]![card.value];
  }
}

class Foundations extends ConsumerStatefulWidget {
  const Foundations({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoundationsState();
}

class _FoundationsState extends ConsumerState<Foundations> {
  @override
  Widget build(BuildContext context) {
    var stage = ref.watch(GameState.provider.select((gs) => gs.stage));
    var foundations = ref.watch(GameState.provider.select((gs) => gs.foundations));
    var slopTracker = ref.watch(slopProvider);
    if (stage == "winning") {
      foundations = _fauxFoundations(foundations); // extra copy of settling card in a foundation
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final cardWidth = constraints.maxWidth / 4;
      final cardHeight = cardWidth / playingCardAspectRatio;
      return SizedBox(
        height: cardHeight,
        child: Row(
          children: foundations.mapIndexed((i, pile) {
            // Rebuild foundations when the length of this foundation changes.
            ref.watch(GameState.provider.select((gs) => pile.length));
            return PileView(
              entries: pile,
              canHighlight: (PileEntry entry) => false,
              canReceive: (PileEntry highlighted, PileEntry entry) => entry.isNextInFoundation(highlighted),
              received: (_) => setState(() {}), // rebuild
              baseBuilder: () => Container(
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
                  child: const AspectRatio(
                    aspectRatio: playingCardAspectRatio,
                    child: FractionallySizedBox(
                        widthFactor: .8,
                        heightFactor: .5,
                        alignment: FractionalOffset(0.25, 0.45),
                        child: TextStamp("A", fontFamily: "Gwendolyn", shadow: 2)),
                  ),
                ),
              ),
              positioner: (int j, Widget child) {
                return Align(
                  child: Transform(
                      alignment: FractionalOffset.center, transform: slopTracker.slop(child, stage), child: child),
                );
              },
            );
          }).toList(),
        ),
      );
    });
  }

  /// Returns foundations with a fake one thrown in containing the next settling card.  Only valid when "winning".
  List<LinkedList<PileEntry>> _fauxFoundations(List<LinkedList<PileEntry>> foundations) {
    LinkedList<PileEntry> lcopy(LinkedList<PileEntry> f) {
      LinkedList<PileEntry> l = LinkedList<PileEntry>();
      for (PileEntry pe in f) {
        l.add(PileEntry(pe.card));
      }
      return l;
    }

    List<LinkedList<PileEntry>> result = [];
    var bonusCard = ref.watch(GameState.provider.select((gs) => gs.nextSettlingCard));
    bool isAce = bonusCard.value == CardValue.ace;
    var targetFoundation = foundations.firstWhere(
      (foundation) => isAce ? foundation.last.isTheBase : foundation.last.suit == bonusCard.suit,
    );
    for (final LinkedList<PileEntry> foundation in foundations) {
      if (foundation != targetFoundation) {
        result.add(foundation);
      } else {
        targetFoundation = lcopy(foundation);
        targetFoundation.add(PileEntry(bonusCard));
        result.add(targetFoundation);
      }
    }
    return result;
  }
}
