import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';
import '../../util/sound.dart';

class FreecellInteractTarget extends ConsumerWidget {
  final bool Function() canHighlight;
  final bool Function(PileEntry) canReceive;
  final void Function(PileEntry) received;
  final PileEntry entry;
  final Widget child;

  const FreecellInteractTarget(
      {required this.canHighlight,
      required this.canReceive,
      required this.received,
      required this.entry,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var amHighlighted = ref.watch(GameState.provider.select((gs) => gs.highlighted == entry));
    var sound = ref.watch(soundProvider);
    return GestureDetector(
      onTapDown: (_) {
        var gameState = ref.read(GameState.provider);
        if (gameState.stage != "playing") return; // probably winning
        PileEntry? highlighted = gameState.highlighted;

        // Nobody highlighted: highlight us if we are allowed to be highlighted.
        if (highlighted == null) {
          if (canHighlight()) {
            gameState.highlighted = entry;
            sound.sfx(Sounds.highlighted);
          }
        }
        // Somebody highlighted: if it's us, cancel highlight
        else if (highlighted == entry) {
          gameState.highlighted = null;
        }
        // Somebody highlighted and we can receive them
        else if (canReceive(highlighted)) {
          gameState.moveHighlightedOnto(entry);
          received(entry);
          sound.sfx(Sounds.played);
        }
        // Somebody highlighted and we can't receive them: cancel highlight
        else {
          gameState.highlighted = null;
          sound.sfx(Sounds.failed);
        }
      },
      child: amHighlighted ? Glow(child: child) : child,
    );
  }
}

class Glow extends StatelessWidget {
  const Glow({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withAlpha(200),
            blurRadius: 3.0,
            spreadRadius: 3.0,
          )
        ],
      ),
      child: child,
    );
  }
}
