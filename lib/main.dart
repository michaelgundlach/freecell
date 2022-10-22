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
      home: const GameScreen(),
    );
  }
}

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
    var sound = ref.watch(soundProvider);

    // On very first load, push an intro screen on top of ourselves, to pop itself when it's time to deal.
    if (!widget.isPreview) {
      if (gameState.stage == "") {
        Timer.run(() => gameState.stage = "intro");
        _showInitialIntroScreen(context);
        return const SizedBox.shrink();
      }

      // TODO do this from gamestate
      sound.setNumFreeCells(gameState.numFreeCells);

      // If we just redealt after a victory, stop the win music, play regular music.
      if (gameState.stage == "playing" && sound.winMusicPlaying) {
        sound.toggleMusic(play: true);
      }

      // Once every card is well placed, start win music and start the win animation, flying cards to the foundations.
      if (gameState.stage == "playing" && gameState.badlyPlacedCards == 0) {
        // Special case: 999999 starts in victory condition, but for testing we don't want to win yet.
        // We rely on clicking the tiger to start winning (but there won't be music, oops).
        if (gameState.seed != 999999) {
          sound.toggleWinMusic(play: true);
          Timer.run(() {
            gameState.stage = "winning";
          });
          return const SizedBox.shrink();
        }
      }

      // The win animation continues as long as at least one foundation is not filled to King.  At that point
      // the cards-to-foundations animation stops and the "game over" dancing animations start.
      if (gameState.stage == "winning" && gameState.foundationsFull) {
        Timer.run(() {
          gameState.stage = "game over";
        });
        return const SizedBox.shrink();
      }

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
    if (gameState.seed == 999999) transitionSpeed = 500; // for testing
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, __) {
          animation.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              waitingOnPreview = false; // allows the next build() to push the next preview
              Navigator.pop(context);
              gameState.autoplayOne(); // modify gameState, triggering a rebuild.
            }
          });

          return ProviderScope(
            overrides: [GameState.provider.overrideWithValue(gameState.oneAutoplayed())],
            child: const GameScreen(isPreview: true),
          );
        },
        transitionDuration: Duration(milliseconds: transitionSpeed),
      ),
    );
  }

  /// On first load, push an IntroScreen on top of us -- so that when they deal, it is a Navigator.pop(), which
  /// the card Hero flightShuttleBuilder requires in order to fade into solid rather than the other way around.
  /// When they click redeal, pushing an IntroScreen on will reverse the Heroes' flights and opacities.
  void _showInitialIntroScreen(BuildContext context) {
    Timer.run(
      () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IntroScreen(),
          transitionDuration: Duration.zero,
          // For when we deal, popping IntroScreen to reveal GameScreen
          reverseTransitionDuration: const Duration(milliseconds: 4500),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
    );
  }
}
