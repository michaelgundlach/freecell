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
    numFreeSpaces = 4;
    freeSpaces = List.generate(numFreeSpaces, (i) => null);
  }

  late final List<List<PlayingCard>> cascades;
  late final List<List<PlayingCard>> acePiles;
  late final List<PlayingCard?> freeSpaces;
  late int numFreeSpaces;
  PlayingCard? _highlighted;
  PlayingCard? get highlighted {
    return _highlighted;
  }

  static int value(PlayingCard card) {
    return (card.value == CardValue.ace ? 1 : card.value.index + 2); // enum is out of order)
  }

  set highlighted(PlayingCard? val) {
    _highlighted = val;
    notifyListeners();
  }

  reduceSpaces() {
    numFreeSpaces--;
    notifyListeners();
  }

  void highlight(PlayingCard card) {
    print("Highlighted $card");
    highlighted = card;
  }

  void cancelHighlight() {
    print("Cancelled highlight");
    highlighted = null;
  }

  PlayingCard _popHighlighted() {
    for (var cascade in cascades) {
      if (cascade.last == highlighted) {
        return cascade.removeLast();
      }
    }
    if (freeSpaces.contains(highlighted)) {
      var i = freeSpaces.indexOf(highlighted);
      var result = freeSpaces.removeAt(i);
      freeSpaces.insert(i, null);
      return result!;
    }
    throw Exception("No highlighted");
  }

  void placeHighlightedCard({required PlayingCard on}) {
    List<PlayingCard>? toCascade;
    for (var cascade in cascades) {
      if (cascade.last == on) {
        toCascade = cascade;
      }
    }
    toCascade!.add(_popHighlighted());
    highlighted = null;
  }

  void placeHighlightedOnFoundation(List<PlayingCard> pile) {
    pile.add(_popHighlighted());
    notifyListeners();
  }

  void moveToFreeSpace(int i, PlayingCard card) {
    freeSpaces[i] = _popHighlighted();
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
                      child: Consumer(
                        builder: (_, ref, __) => Cascade(
                          children: ref.watch(gameModelProvider).cascades[i],
                          cardExposure: .12,
                        ),
                      ),
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
            child: Row(children: const [
              Expanded(child: Foundations()),
              Expanded(child: FreeSpaces()),
            ]),
          ),
        )
      ],
    );
  }
}

class FreecellInteractTarget extends ConsumerWidget {
  final bool Function() canHighlight;
  final PlayingCard? Function() getCard;
  final bool Function(PlayingCard) canReceive;
  final void Function(PlayingCard) receive;
  final Widget child;

  const FreecellInteractTarget(
      {required this.canHighlight,
      required this.getCard,
      required this.canReceive,
      required this.receive,
      required this.child,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var highlighted = ref.watch(gameModelProvider.select((gm) => gm.highlighted));

    return GestureDetector(
      onTap: () {
        var model = ref.read(gameModelProvider);
        PlayingCard? highlighted = model.highlighted;

        // Nobody highlighted: highlight us if we are allowed to be highlighted.
        if (highlighted == null) {
          if (canHighlight()) {
            model.highlight(getCard()!);
          }
        }
        // Somebody highlighted: if it's us, cancel highlight
        else if (highlighted == getCard()) {
          model.cancelHighlight();
        }
        // Somebody highlighted and we can receive them
        else if (canReceive(highlighted)) {
          receive(highlighted);
          model.cancelHighlight();
        }
        // Somebody highlighted and we can't receive them: cancel highlight
        else {
          model.cancelHighlight();
        }
      },
      child: highlighted != null && highlighted == getCard() ? Glow(child: child) : child,
    );
  }
}

class Glow extends StatelessWidget {
  const Glow({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withAlpha(200),
            blurRadius: 3.0,
            spreadRadius: 3.0,
          )
        ],
      ),
      child: child,
    );
  }

  //@override
  Widget obuild(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OverflowBox(
        maxWidth: constraints.maxWidth + 40,
        maxHeight: constraints.maxHeight + 40,
        child: Stack(
          children: [
            // Opacity(opacity: .7, child: SizedBox.expand(child: Container(color: Colors.yellow[300]))),
            ConstrainedBox(constraints: constraints, child: child),
          ],
        ),
      );
    });
  }
}

class BlankSpot extends StatelessWidget {
  const BlankSpot({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: playingCardAspectRatio,
      child: Container(padding: EdgeInsets.all(8), child: Container(color: Colors.green)),
    );
  }
}

class Cascade extends ConsumerWidget {
  const Cascade({required this.children, this.cardExposure = 0.0, Key? key}) : super(key: key);

  final List<PlayingCard> children;
  final double cardExposure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var maxCards = 7; // how many will we make room for, given our allowed size?
    var extraSpace = (maxCards - 1) * cardExposure;
    var totalSpace = 1 + extraSpace;
    var cascadeAspectRatio = playingCardAspectRatio / totalSpace;
    return LayoutBuilder(builder: (context, constraints) {
      return AspectRatio(
        aspectRatio: cascadeAspectRatio,
        child: Stack(
          children: <Widget>[Align(alignment: Alignment(0, -1), child: BlankSpot())] +
              List.generate(children.length, (i) {
                bool uncovered = (i == children.length - 1);
                return Align(
                  alignment: Alignment(0, -1 + i / (maxCards - 1) * 2),
                  child: FreecellInteractTarget(
                    canHighlight: () => uncovered,
                    getCard: () => children[i],
                    canReceive: (card) => cascadesWell(children[i], card),
                    receive: (card) => ref.read(gameModelProvider).placeHighlightedCard(on: children[i]),
                    child: FreecellCardView(card: children[i], covered: !uncovered),
                  ),
                );
              }),
        ),
      );
    });
  }

  bool cascadesWell(PlayingCard parent, PlayingCard child) {
    if (parent.value.index != child.value.index + 1) {
      return false;
    }
    const black = [Suit.clubs, Suit.spades];
    return (black.contains(parent.suit) != black.contains(child.suit));
  }
}

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var model = ref.watch(gameModelProvider);
    return Row(
        children: List.generate(model.numFreeSpaces, (i) {
      var space = model.freeSpaces[i];
      return Expanded(
        child: FreecellInteractTarget(
          canHighlight: () => space != null,
          getCard: () => space,
          canReceive: (card) => space == null,
          receive: (card) => model.moveToFreeSpace(i, card),
          child: space == null ? BlankSpot() : FreecellCardView(card: space),
        ),
      );
    }).toList());
  }
}

class Foundations extends ConsumerWidget {
  const Foundations({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var model = ref.watch(gameModelProvider);
    return Row(
      children: model.acePiles.map((pile) {
        return Expanded(
          child: FreecellInteractTarget(
            canHighlight: () => false,
            getCard: () => null,
            canReceive: (card) => canReceive(pile, card),
            receive: (card) => model.placeHighlightedOnFoundation(pile),
            child: pile.isNotEmpty ? FreecellCardView(card: pile.last) : BlankSpot(),
          ),
        );
      }).toList(),
    );
  }

  bool canReceive(List<PlayingCard> pile, PlayingCard card) {
    if (pile.isEmpty) return card.value == CardValue.ace;
    return pile.last.suit == card.suit && GameModel.value(pile.last) == GameModel.value(card) - 1;
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
