import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/freecell/freecell-card-view.dart';
import 'package:playing_cards/playing_cards.dart';

import 'freecell/deck-style.dart';
import 'freecell/freecell-stack.dart';

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
// Sucky non-exporting playing_cards package
const playingCardAspectRatio = 64 / 89;

class GameModel extends ChangeNotifier {
  GameModel() {
    var deck = standardFiftyTwoCardDeck()..shuffle();
    someCards(count) {
      var result = deck.sublist(0, count);
      deck.removeRange(0, count);
      return result;
    }

    cascades = [for (int i = 0; i < 8; i++) someCards(i < 4 ? 7 : 6)];
    print(cascades.map((stack) => stack.map((p) => '${p.suit} ${p.value}').toList().join(' ')).toList().join('|||'));
    acePiles = [[], [], [], []];
    numFreeSpots = 4;
    freeSpots = List.generate(numFreeSpots, (i) => null);
  }

  late final List<List<PlayingCard>> cascades;
  late final List<List<PlayingCard>> acePiles;
  late final List<PlayingCard?> freeSpots;
  late int numFreeSpots;

  reduceSpots() {
    numFreeSpots--;
    notifyListeners();
  }
}

final gameModelProvider = ChangeNotifierProvider<GameModel>((ref) {
  return GameModel();
});

class FreecellConstants {
  static const padding = 10.0;
}

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 70,
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.all(FreecellConstants.padding),
            child: Row(
              children: [
                for (int i = 0; i < 8; i++)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      color: Colors.yellow,
                      child: Consumer(builder: (_, ref, __) => Cascade(ref.watch(gameModelProvider).cascades[i])),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 30,
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.all(FreecellConstants.padding),
            child: Row(children: [
              Expanded(child: Foundations()),
              Expanded(child: FreeSpaces()),
            ]),
          ),
        )
      ],
    );
  }
}

class Cascade extends ConsumerWidget {
  const Cascade(this.children, {Key? key}) : super(key: key);

  final List<PlayingCard> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var maxCards = 7; // how many will we make room for, given our allowed size?
    var cardExposure = .22; // % of card uncovered by descendant
    var extraSpace = (maxCards - 1) * cardExposure;
    var totalSpace = 1 + extraSpace;
    var cascadeAspectRatio = playingCardAspectRatio / totalSpace;
    return LayoutBuilder(builder: (context, constraints) {
      return AspectRatio(
        aspectRatio: cascadeAspectRatio,
        child: Stack(
          children: List.generate(children.length, (i) {
            return Align(
              alignment: Alignment(0, -1 + i / (maxCards - 1) * 2),
              child: FreecellCardView(card: children[i], covered: i < children.length - 1),
            );
          }),
        ),
      );
    });
  }
}

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var slots = ref.watch(gameModelProvider.select((gm) => gm.numFreeSpots));
    return Row(
      children: List.generate(slots, (index) {
        // Temp to prove I can send data to the model and back!
        return Expanded(
          child: GestureDetector(
            onTap: () => ref.read(gameModelProvider).reduceSpots(),
            child: Consumer(
              builder: (context, ref, _) => Container(
                margin: EdgeInsets.all(FreecellConstants.padding),
                height: double.infinity,
                color: Colors.yellow,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class Foundations extends StatelessWidget {
  const Foundations({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: GameBoard(), // const MyHomePage(title: 'Freecell!!!!!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final deck = standardFiftyTwoCardDeck()..shuffle();
    var i = 0;
    FreecellColumn stack(int n) {
      i = i + n;
      return FreecellColumn(deckStyle: DeckStyle(), children: deck.sublist(i - n, i));
    }

    p() {
      setState(() {
        print("hi");
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: double.infinity, height: double.infinity),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (var i = 0; i < 8; i++) stack(i >= 4 ? 6 : 7)],
        ),
      ),
    );
  }
}
