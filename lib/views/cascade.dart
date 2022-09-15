import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../main.dart';
import '../model/game-state.dart';
import 'pile-view.dart';

class Cascades extends ConsumerWidget {
  const Cascades({super.key});
  static const cardExposure = .14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var gs = ref.watch(gameStateProvider);
    // We sized the GameBoard to allow 10 columns of cards (in case there are 6 free cells.)
    // Space our 8 evenly with 20% gap between them, 10% gap on either side.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        for (var cascade in gs.cascades) ...[
          Expanded(flex: 8, child: Cascade(entries: cascade)),
          if (cascade != gs.cascades.last) const Spacer(flex: 2)
        ],
        const Spacer(flex: 1),
      ],
    );
  }
}

class Cascade extends ConsumerWidget {
  final LinkedList<PileEntry> entries;

  const Cascade({required this.entries, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final cardHeight = constraints.maxWidth / playingCardAspectRatio;
        final cardsShown = max(1, 1 + (entries.length - 2) * Cascades.cardExposure);
        final pileHeight = cardHeight * cardsShown;
        return Container(
          color: Colors.yellow,
          height: pileHeight,
          child: PileView(
            entries: entries,
            canHighlight: (entry) => !entry.isTheBase,
            canReceive: (highlighted, entry) => entry.canCascade(highlighted),
            baseBuilder: () => AspectRatio(
                aspectRatio: playingCardAspectRatio,
                child: Container(width: constraints.maxWidth, color: Colors.blue[200])),
            positioner: (i, child) {
              return Positioned(top: Cascades.cardExposure * cardHeight * (i - 1), left: 0, right: 0, child: child);
            },
          ),
        );
      },
    );
  }
}
