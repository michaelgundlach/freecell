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
      home: GameScreen(),
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
    // TODO temp: the preview gets rebuild triggered at the last second when we place the last king.
    //   then it tries to pull the autoplayed version and crashes.
    // . Instead, we should actually override the GS above the preview GameScreen, so that when we
    // . we modify the real one, the preview GameScreen doesn't get any notifications.
    if (widget.isPreview && gameState.foundationsFull) return SizedBox.shrink();

    // TODO remove all the prints and asserts and transitionSpeed fake

    if (widget.isPreview) {
      print(" . . . In the preview widget, settledcount is ${gameState.settledCards}");
    }

    // On very first load, push an intro screen on top of ourselves, to pop itself when it's time to deal.
    if (!widget.isPreview && gameState.stage == "intro") {
      _showInitialIntroScreen(context);
      return const SizedBox.shrink();
    }

    var sound = ref.watch(soundProvider);
    // TODO do this from gamestate
    sound.setNumFreeCells(gameState.numFreeCells);

    // If we just redealt after a victory, stop the win music.
    if (!widget.isPreview && gameState.stage == "playing" && sound.winMusicPlaying) sound.toggleWinMusic(play: false);

    // Once every card is well placed, start win music and start the win animation, flying cards to the foundations.
    if (!widget.isPreview && gameState.stage == "playing" && gameState.badlyPlacedCards == 0) {
      // Special case: 999999 starts in victory condition, but for testing we don't want to win yet.
      // We rely on clicking the tiger to start winning (but there won't be music, oops).
      if (gameState.seed != 999999) {
        sound.toggleWinMusic(play: true);
        Timer.run(() {
          assert(gameState.stage == "playing" && gameState.badlyPlacedCards == 0 && gameState.seed != 999999);
          gameState.stage = "winning";
        });
        return const SizedBox.shrink();
      }
    }

    // The win animation continues as long as at least one foundation is not filled to King.  At that point
    // the cards-to-foundations animation stops and the "game over" dancing animations start.
    if (!widget.isPreview && gameState.stage == "winning" && gameState.foundationsFull) {
      Timer.run(() {
        assert(gameState.stage == "winning" && gameState.foundationsFull);
        gameState.stage = "game over";
      });
      return const SizedBox.shrink();
    }

    // During the win animation, when we display ourselves, we should immediately display the next step on top of
    // ourselves, so that one card flies to its foundation.  We remember that we are showing the preview so that we
    // don't show it more than once.
    if (gameState.stage == "winning" && !gameState.foundationsFull && !widget.isPreview && !waitingOnPreview) {
      waitingOnPreview = true;
      Timer.run(() {
        assert(gameState.stage == "winning" && !gameState.foundationsFull && !widget.isPreview && waitingOnPreview);
        print("Flying one card when settled count is ${gameState.settledCards}");
        _flyOneCard(gameState, context);
      });
    }

    // Return the normal contents, or (if preview) wrap them in a ProviderScope with an autoplayed copy of gameState.
    return _doBuild(gameState, context);
  }

  ProviderScope _doBuild(GameState gameState, BuildContext context) {
    // The regular GameScreen can now return its contents, based on gameState.stage.
    // The preview faux GameScreen tricks its contents into thinking the gameState is one step farther along, and
    // will be popped as soon as one Hero card flies to its foundation (it was created by the Navigator.push() above
    // in the actual GameScreen).
    // We can't advance the actual gameState one step, or it will trigger rebuilding of the real GameScreen.
    final isReal = !widget.isPreview;
    final overrides = isReal ? <Override>[] : [GameState.provider.overrideWithValue(gameState.oneAutoplayed())];
    return ProviderScope(
      overrides: overrides,
      child: Container(
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
      ),
    );
  }

  /// Pushes a GameScreen(isPreview: true) onto the stack.  This will display gameState.oneAutoplayed(), which will
  /// cause one card's Hero to fly to the foundation.  Then the preview will pop and we autoplay the gameState,
  /// triggering a rebuild.
  void _flyOneCard(GameState gameState, BuildContext context) {
    assert(!widget.isPreview);
    // This does nothing if already running, but the first time we fly a card, this syncs the dance with the music.
    sync.start();
    // Figure out when the next music beat is, and start flying the card at that time
    int transitionSpeed = gameState.settledCards < 4
        ? (2000 * (gameState.settledCards + 1) - sync.elapsed.inMilliseconds)
        : (8000 + (gameState.settledCards - 4 + 1) * 500 - sync.elapsed.inMilliseconds);
    transitionSpeed = max(transitionSpeed, 1);
    transitionSpeed = 100; // TODO temp
    assert(!gameState.foundationsFull);
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, __) {
          print(" . in the pageBuilder, settled count is ${gameState.settledCards}");
          animation.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              print(
                  " .  . at animation complete, settled count is ${gameState.settledCards} (all fakes are below here remember)");
              waitingOnPreview = false; // allows the next build() to push the next preview
              Navigator.pop(context);
              gameState.autoplayOne(); // modify gameState, triggering a rebuild.
            }
          });
          assert(!gameState.foundationsFull);
          return const GameScreen(isPreview: true);
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
          pageBuilder: (_, __, ___) => IntroScreen(),
          transitionDuration: Duration.zero,
          // For when we deal, popping IntroScreen to reveal GameScreen
          reverseTransitionDuration: const Duration(milliseconds: 4500),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
    );
  }
}
