import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/cascade.dart';
import 'package:playing_cards/playing_cards.dart';

import 'freecell/deck-style.dart';
import 'model/game-state.dart';
import 'views/foundations.dart';
import 'views/free-spaces.dart';

void main() {
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
        primarySwatch: Colors.green,
      ),
      home: Container(padding: const EdgeInsets.all(20), color: Colors.green, child: const GameBoard()),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 80,
          child: Container(
            color: Colors.green,
            child: Row(children: [for (var i = 0; i < 8; i++) Expanded(child: Cascade(cascadeNum: i))]),
          ),
        ),
        Expanded(
          flex: 20,
          child: Container(
            color: Colors.red,
            child: Row(children: [
              Foundations(),
              Spacer(),
              FreeSpaces(),
            ]),
          ),
        )
      ],
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
