import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  const GameScreen({super.key, this.isWinningThingy = false});
  final bool isWinningThingy;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // This either needs to build as a game that is ready to run,
  // or as a game that immediately transitions to a more-settled game.
  // If gamestate is not winning, do the first.
  // If gamestate is winning, do the second.

  @override
  Widget build(BuildContext context) {
    var gameState = ref.watch(GameState.provider);
    // If we're in "winning" stage, right after displaying ourselves we navigate
    // recursively to a succession of more and more settled GameScreens.
    if (gameState.stage == "winning" && !widget.isWinningThingy) {
      Timer.run(() => performWinningDance(context, gameState));
    }
    // Normally, display the GameScreen for the user to play.
    return _x(context);
  }

  Widget _x(BuildContext context) {
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
  performWinningDance(context, GameState gameState) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, __) {
          final nextGameState = gameState.moreSettledByOne();
          if (nextGameState.stage == "winning") {
            animation.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                performWinningDance(context, nextGameState);
              }
            });
          }
          return ProviderScope(
            overrides: [GameState.provider.overrideWithValue(nextGameState)],
            child: const GameScreen(isWinningThingy: true),
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }
}
