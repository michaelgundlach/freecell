import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/ui/settings-panel.dart';

import '../../model/game-state.dart';
import 'game-mat.dart';

final isCardFlyingProvider = StateProvider<bool>((ref) {
  return false;
});

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Stopwatch sync = Stopwatch();
  bool autoPlaying = false;

  @override
  Widget build(BuildContext context) {
    if (!autoPlaying && ref.watch(GameState.provider.select((gs) => gs.stage)) == "winning") {
      Timer.run(() => setState(() {
            autoPlaying = true;
            ref.read(GameState.provider).autoplay();
            Future.delayed(const Duration(milliseconds: 300), () => setState(() => autoPlaying = false));
          }));
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        image: const DecorationImage(image: AssetImage("assets/images/clouds-2.jpg"), fit: BoxFit.cover),
        color: Theme.of(context).backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Expanded(flex: 1, child: SizedBox.shrink()),
          Flexible(flex: 7, child: GameMat()),
          Expanded(flex: 1, child: SettingsPanel()),
        ],
      ),
    );
  }
}
