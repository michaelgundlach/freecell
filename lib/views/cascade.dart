import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../model/game-state.dart';
import 'pile-view.dart';

class Cascades extends ConsumerWidget {
  const Cascades({super.key});
  // Fonts seem larger on web, can't see text w/o bigger exposure
  static const cardExposure = kIsWeb ? .2 : .166;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var gs = ref.watch(GameState.provider);
    // Space evenly around columns to use up all the width required by foundations and freecells.
    const foundations = 4;
    const cascadeColumns = 8;
    final desiredColumns = max(foundations + gs.numFreeCells, cascadeColumns);
    final blankColumns = desiredColumns - cascadeColumns;
    const flexPerCascade = 1000;
    const numSpacers = 9; // start, 7 between 8 columns, and end
    final flexInAllSpacers = blankColumns * 1000;
    final flexPerSpacer = max(flexInAllSpacers ~/ numSpacers, 1); // flex of 0 (numFreeCells <= 4) barfs
    final spacer = Spacer(flex: flexPerSpacer);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        spacer,
        for (var cascade in gs.cascades) ...[
          Expanded(flex: flexPerCascade, child: Cascade(entries: cascade)),
          spacer,
        ],
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
