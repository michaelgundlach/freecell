import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../model/game-state.dart';

class GameOverDancer extends ConsumerWidget {
  /// Dances `child` back and forth when the game is over.  `stoppedChild` is used when not dancing.
  /// `curve` defaults to toggling back and forth with no swing. `running` defaults to when
  /// GameState.stage == "game over". 'tween' defaults to -45 degrees to 45 degrees.
  const GameOverDancer({super.key, this.curve, this.running, this.tween, this.stoppedChild, required this.child});

  final Curve? curve;
  final bool? running;
  final Tween<double>? tween;
  final Widget? stoppedChild;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = ref.watch(GameState.provider.select((gs) => gs.stage));
    final running = this.running ?? (stage == "game over" || stage == "winning");
    if (!running) return stoppedChild ?? child;

    // If there is a hiccup in starting, this seems to smooth it out.  Not sure it's needed in production.
    final Stopwatch winTimer = ref.watch(GameState.provider.select((gs) => gs.winTimer));
    final musicOffset = (winTimer.elapsedMilliseconds % 500) / 500;

    return CustomAnimationBuilder<double>(
      builder: (_, value, child) =>
          Transform(transform: Matrix4.rotationZ(value), alignment: Alignment.center, child: child),
      tween: tween ?? Tween(begin: -pi / 6, end: pi / 6),
      startPosition: (.493 + (stage == "winning" ? 0 : musicOffset)) % 1,
      control: stage == "winning" ? Control.stop : Control.mirror,
      curve: curve ?? _Toggle(),
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}

class _Toggle extends Curve {
  @override
  double transformInternal(double t) => t.round().toDouble();
}
