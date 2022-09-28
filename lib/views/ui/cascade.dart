import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../main.dart';
import '../../model/game-state.dart';
import 'free-spaces.dart';
import '../util/pile-view.dart';

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
    var desiredColumns = max(foundations + FreeSpaces.numberOfColumns(gs), cascadeColumns);
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
        final radius = Radius.circular(ref.watch(deckStyleProvider).radius);
        return SizedBox(
          height: pileHeight,
          child: PileView(
            entries: entries,
            canHighlight: (entry) => !entry.isTheBase,
            canReceive: (highlighted, entry) => entry.canCascade(highlighted),
            baseBuilder: () => Container(
              width: constraints.maxWidth,
              height: cardHeight,
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
                gradient: LinearGradient(
                  colors: [Theme.of(context).indicatorColor, Theme.of(context).primaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.7],
                ),
              ),
            ),
            positioner: (i, child) {
              return Positioned(top: Cascades.cardExposure * cardHeight * (i - 1), left: 0, right: 0, child: child);
            },
          ),
        );
      },
    );
  }
}
