import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../model/game-state.dart';
import '../util/sound.dart';

class FreecellInteractTarget extends ConsumerWidget {
  final bool Function() canHighlight;
  final bool Function(PileEntry) canReceive;
  final PileEntry entry;
  final Widget child;

  const FreecellInteractTarget(
      {required this.canHighlight, required this.canReceive, required this.entry, required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var highlighted = ref.watch(gameStateProvider.select((gs) => gs.highlighted));
    return GestureDetector(
      onTap: () async {
        var model = ref.read(gameStateProvider);
        PileEntry? highlighted = model.highlighted;

        // Nobody highlighted: highlight us if we are allowed to be highlighted.
        if (highlighted == null) {
          if (canHighlight()) {
            model.highlighted = entry;
            await Sound.play(Sounds.highlighted);
          }
        }
        // Somebody highlighted: if it's us, cancel highlight
        else if (highlighted == entry) {
          model.highlighted = null;
        }
        // Somebody highlighted and we can receive them
        else if (canReceive(highlighted)) {
          model.moveHighlightedOnto(entry);
          await Sound.play(Sounds.played);
        }
        // Somebody highlighted and we can't receive them: cancel highlight
        else {
          model.highlighted = null;
          await Sound.play(Sounds.failed);
        }
      },
      child: highlighted == entry ? Glow(child: child) : child,
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
