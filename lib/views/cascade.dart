import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../model/game-state.dart';
import 'pile-view.dart';

class Cascades extends ConsumerWidget {
  const Cascades({super.key});
  static const cardExposure = .14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var gs = ref.watch(GameState.provider);
    // We sized the GameBoard to allow 4 + numFreeCells columns of cards (8 minimum).
    // Give 1000 to each cascade, then fill space with enough to equal (4+numFreecells)*1000.
    final spacer = Spacer(flex: max(1, (gs.numFreeCells - 4) * 100));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        spacer,
        for (var cascade in gs.cascades) ...[
          Expanded(flex: 1000, child: Cascade(entries: cascade)),
          spacer,
        ],
        spacer,
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
        return SizedBox(
          height: pileHeight,
          child: PileView(
            entries: entries,
            canHighlight: (entry) => !entry.isTheBase,
            canReceive: (highlighted, entry) => entry.canCascade(highlighted),
            baseBuilder: () => AspectRatio(
                aspectRatio: playingCardAspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: constraints.maxWidth,
                )),
            positioner: (i, child) {
              return Positioned(top: Cascades.cardExposure * cardHeight * (i - 1), left: 0, right: 0, child: child);
            },
          ),
        );
      },
    );
  }
}
