import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';

/// Friendly tiger who controls the seed and comments upon your play.

class Tiger extends ConsumerWidget {
  const Tiger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(GameState.provider);
    return GestureDetector(
      onTap: () {
        // for testing
        if (gameState.seed != 999999) return;
        ref.watch(GameState.provider).stage = (gameState.stage == "playing" ? "winning" : "playing");
      },
      child: Stack(
        children: [Image.asset("assets/images/tiger.png")],
        // TODO: speech bubbles, sfx
      ),
    );
  }
}
