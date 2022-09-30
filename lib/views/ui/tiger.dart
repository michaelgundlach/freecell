import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';

/// Friendly tiger who controls the seed and comments upon your play.

class Tiger extends ConsumerWidget {
  const Tiger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          children: [
            Image.asset("assets/images/tiger.png"),
            FittedBox(
              fit: BoxFit.fill,
              child: Text(ref.watch(GameState.provider).seed.toString(), style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        )
      ],
    );
  }
}
