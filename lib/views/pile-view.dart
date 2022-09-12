import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../freecell/freecell-card-view.dart';
import '../model/game-state.dart';
import 'freecell-interact-target.dart';

class PileView extends StatelessWidget {
  final LinkedList<PileEntry> entries;
  final bool Function(PileEntry entry) canHighlight;
  final bool Function(PileEntry highlighted, PileEntry entry) canReceive;
  final Widget Function() baseBuilder;
  final Widget Function(int i, Widget child) positioner;

  const PileView(
      {required this.entries,
      required this.canHighlight,
      required this.canReceive,
      required this.baseBuilder,
      required this.positioner,
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
        entry: entry,
        child: result,
      );
    }
    return entry.isTheBase ? Align(alignment: Alignment.topCenter, child: result) : positioner(i, result);
  }
}

/*
                      child: PileView(
                        width: full width? no, only wide enough that you can stack all the cards well given the offset
                          function.  
                        dont_forget_to:
                            "let it grow somehow, maybe with overflowbox, to make room for any babies it places",
                        entries: cascade,
                        eachCardOffsetRelativeToLast: as a percentage of card width and height
                            "a little bit lower so we can see the label",
                            we are told we are card # 5 and we give an offset from base.  5 * exposure_pct * card height
                        baseBuilder: () => "a nice empty space picture",
                      ),

                      each Foundation:
                        size: who knows
                        child: PileView(
                          growth via overflowbox is intrinsic to PileView, not an option passed in
                          entries: foundation[i],
                          eachCardOffsetRelativeToLast: very tiny vertical offset - bonus if we can rotate
                            looks like we want an offset relative to base.  so it needs ot be told which # in pile it is
                          baseBuilder: () => "a little ace logo"
                        )
                      )

                      each FreeCell:
                        size: who knows
                        child: PileView(
                          same growth deal.  it is given a size, it uses all of it, it locks cards to that size.
                          baseBuilder: a free cell
                          cardoffset: 0
                          canReceive: entries.isEmpty
                          receive: gamestate.move


                        )

                      */