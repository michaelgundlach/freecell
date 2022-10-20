import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/util/sound.dart';

import 'model/game-state.dart';
import 'util/deck-style.dart';
import 'views/ui/game-mat.dart';
import 'views/ui/intro-screen.dart';
import 'views/ui/settings-panel.dart';

final deckStyleProvider = Provider<DeckStyle>((ref) {
  // Can't express radius as a % of width; give smaller on small screens
  const radius = kIsWeb ? 8.0 : 4.0;
  return DeckStyle(
    radius: radius,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: Colors.black45, width: 1),
    ),
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't show Android UI overlays
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Force to landscape mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freecell',
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        primaryColorDark: Colors.blue[900],
        backgroundColor: Colors.blue[300],
      ),
      home: const IntroScreen(),
    );
  }
}

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, this.isPerformingWinDance = false});
  final bool isPerformingWinDance;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Stopwatch sync = Stopwatch();

  @override
  Widget build(BuildContext context) {
    var gameState = ref.watch(GameState.provider);
    var sound = ref.watch(soundProvider);
    sound.setNumFreeCells(gameState.numFreeCells);
    // If we're in "winning" stage, right after building and displaying
    // ourselves we navigate recursively to a succession of more and more
    // settled GameScreens.
    if (gameState.stage == "winning" && !widget.isPerformingWinDance) {
      sound.playWinMusic();
      Timer.run(() => performWinDance(context, gameState));
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

  // only run by top level GameScreen.  Pushes a series of more-settled GameScreens onto the board.
  performWinDance(context, GameState gameState) {
    sync.start(); // does nothing if already running
    final nextGameState = gameState.moreSettledByOne();
    int transitionSpeed = nextGameState.settledCards <= 4
        ? (2000 * (nextGameState.settledCards) - sync.elapsed.inMilliseconds)
        : (8000 + (nextGameState.settledCards - 4) * 500 - sync.elapsed.inMilliseconds);
    transitionSpeed = max(transitionSpeed, 1);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, __) {
          if (nextGameState.stage == "winning") {
            animation.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                Timer.run(() => performWinDance(context, nextGameState));
              }
            });
          }
          return ProviderScope(
            overrides: [GameState.provider.overrideWithValue(nextGameState)],
            child: const GameScreen(isPerformingWinDance: true),
          );
        },
        transitionDuration: Duration(milliseconds: transitionSpeed),
      ),
    );
  }
}
