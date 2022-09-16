import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import 'util/deck-style.dart';
import 'views/game-board.dart';

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
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.black45, width: 1),
    ),
  );
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
