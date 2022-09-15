import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/cascade.dart';
import 'package:freecell/views/constrained-aspect-ratio.dart';
import 'package:playing_cards/playing_cards.dart';

import 'freecell/deck-style.dart';
import 'model/game-state.dart';
import 'views/foundations.dart';
import 'views/free-spaces.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't show Android UI overlays
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // Force to landscape mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  runApp(const ProviderScope(child: MyApp()));
}

final deckStyleProvider = Provider<DeckStyle>((ref) {
  return DeckStyle(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: const BorderSide(color: Colors.black, width: 1),
    ),
  );
});

final gameStateProvider = ChangeNotifierProvider<GameState>((ref) {
  return GameState();
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Colors.orange,
          displayColor: Colors.blue,
        ),
      ),
      home: WillPopScope(
        // Ignore back button, preventing it from closing (and destroying) the app
        onWillPop: () async => false,
        child: Container(padding: const EdgeInsets.all(10), color: Colors.green[400], child: const GameBoard()),
      ),
    );
  }
}

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final maxCascade = gameState.cascades.reduce((a, b) => a.length > b.length ? a : b).length + 2;
    final boardAspectRatio = playingCardAspectRatio * 10 / (2 + (maxCascade - 1) * Cascades.cardExposure);
    return Align(
      alignment: Alignment.topLeft,
      child: AnimatedContainer(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(10))),
        duration: Duration(seconds: 30),
        child: ConstrainedAspectRatio(
          maxAspectRatio: boardAspectRatio, // If parent is too tall, grow taller
          child: Column(
            children: [
              Expanded(child: Cascades()),
              Container(
                child: Row(children: [
                  Expanded(flex: 40, child: Foundations()),
                  Spacer(flex: 100 - 40 - (10 * gameState.numFreeCells)),
                  Expanded(
                    flex: 10 * gameState.numFreeCells,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FreeSpaces(),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlankSpot extends StatelessWidget {
  const BlankSpot({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: playingCardAspectRatio,
      child: Container(padding: const EdgeInsets.all(5), child: Container(color: Colors.green)),
    );
  }
}
