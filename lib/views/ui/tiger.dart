import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';

/// Friendly tiger who controls the seed and comments upon your play.

class Tiger extends ConsumerWidget {
  const Tiger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.watch(GameState.provider).badlyPlacedCards = 1, // TODO temp for testing
      child: Stack(
        children: [Image.asset("assets/images/tiger.png")],
        // TODO: speech bubbles, sfx
      ),
    );
  }
}
