import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/ui/settings-panel.dart';

import '../../model/game-state.dart';
import '../../util/sound.dart';
import 'game-mat.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, this.isPreview = false});
  final bool isPreview;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Stopwatch sync = Stopwatch();
  bool waitingOnPreview = false;

  @override
  Widget build(BuildContext context) {
    var gameState = ref.watch(GameState.provider);

    if (!widget.isPreview) {
      // During the win animation, when we display ourselves, we should immediately display the next step on top of
      // ourselves, so that one card flies to its foundation.  We remember that we are showing the preview so that we
      // don't show it more than once.
      if (gameState.stage == "winning" && !gameState.foundationsFull && !waitingOnPreview) {
        waitingOnPreview = true;
        Timer.run(() {
          _flyOneCard(gameState, context);
        });
      }
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

  /// Pushes a GameScreen(isPreview: true) onto the stack.  This will display gameState.oneAutoplayed(), which will
  /// cause one card's Hero to fly to the foundation.  Then the preview will pop and we autoplay the gameState,
  /// triggering a rebuild.
  void _flyOneCard(GameState gameState, BuildContext context) {
    // This does nothing if already running, but the first time we fly a card, this syncs the dance with the music.
    sync.start();
    // Figure out when the next music beat is, and start flying the card at that time
    int transitionSpeed = gameState.settledCards < 4
        ? (2000 * (gameState.settledCards + 1) - sync.elapsed.inMilliseconds)
        : (8000 + (gameState.settledCards - 4 + 1) * 500 - sync.elapsed.inMilliseconds);
    transitionSpeed = max(transitionSpeed, 1);
    if (gameState.seed == 3333333) transitionSpeed = 500; // for testing
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, __) {
          animation.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              waitingOnPreview = false; // allows the next build() to push the next preview
              Navigator.pop(context);
              gameState.autoplay(1); // modify gameState, triggering a rebuild.
            }
          });

          return ProviderScope(
            overrides: [
              GameState.provider.overrideWithValue(gameState.oneAutoplayed()),
              // Pass through existing Sound lest it create a new one when someone ref.watch()s it,
              // since it depends on GameState which we have explicitly changed via override
              soundProvider.overrideWithValue(ref.read(soundProvider)),
            ],
            child: const GameScreen(isPreview: true),
          );
        },
        transitionDuration: Duration(milliseconds: transitionSpeed),
        reverseTransitionDuration: const Duration(milliseconds: 1),
      ),
    );
  }
}
