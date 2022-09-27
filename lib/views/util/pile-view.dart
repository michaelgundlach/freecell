import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'freecell-card-view.dart';
import '../../model/game-state.dart';
import 'freecell-interact-target.dart';

class PileView extends StatelessWidget {
  final LinkedList<PileEntry> entries;
  final bool Function(PileEntry entry) canHighlight;
  final bool Function(PileEntry highlighted, PileEntry entry) canReceive;
  final void Function(PileEntry entry)? received;
  final Widget Function() baseBuilder;
  final Widget Function(int i, Widget child) positioner;

  const PileView(
      {required this.entries,
      required this.canHighlight,
      required this.canReceive,
      required this.baseBuilder,
      required this.positioner,
      this.received,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: entries.mapIndexed(_makeStackEntry).toList());
  }

  /// Return a Stack entry for this base or this freecell card, possibly highlighted and possibly interactable.
  Widget _makeStackEntry(int i, PileEntry entry) {
    var result = entry.isTheBase ? baseBuilder() : FreecellCardView(card: entry.card!);
    if (entry == entries.last) {
      result = FreecellInteractTarget(
        canHighlight: () => canHighlight(entry),
        canReceive: (PileEntry highlighted) => canReceive(highlighted, entry),
        received: received ?? (_) {},
        entry: entry,
        child: result,
      );
    }
    return entry.isTheBase ? Align(alignment: Alignment.topCenter, child: result) : positioner(i, result);
  }
}
