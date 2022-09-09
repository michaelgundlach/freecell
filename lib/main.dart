import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/freecell/freecell-card-view.dart';
import 'package:playing_cards/playing_cards.dart';

import 'freecell/deck-style.dart';

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
// const playingCardAspectRatio = 64 / 89;

class GameState extends ChangeNotifier {
  GameState() {
    var deck = standardFiftyTwoCardDeck()..shuffle();
    someCards(count) {
      var result = deck.sublist(0, count);
      deck.removeRange(0, count);
      return result;
    }

    cascades = [for (int i = 0; i < 8; i++) someCards(i < 4 ? 7 : 6)];
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
    return (card.value == CardValue.ace
        ? 1
        : card.value.index + 2); // enum is out of order)
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
    highlighted = card;
  }

  void cancelHighlight() {
    highlighted = null;
  }

  PlayingCard _popHighlighted() {
    for (var cascade in cascades) {
      if (cascade.isNotEmpty && cascade.last == highlighted) {
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
      if (cascade.isNotEmpty && cascade.last == on) {
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

  placeNewCascade(PlayingCard card, List<PlayingCard> children) {
    children.add(_popHighlighted());
    notifyListeners();
  }
}

final gameModelProvider = ChangeNotifierProvider<GameState>((ref) {
  return GameState();
});

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
            child: Row(
              children: [
                for (int i = 0; i < 8; i++)
                  Expanded(
                    child: Consumer(
                      builder: (_, ref, __) => Cascade(
                        children: ref.watch(gameModelProvider).cascades[i],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Container(
            color: Colors.red,
            child: Row(children: const [
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
    var highlighted =
        ref.watch(gameModelProvider.select((gm) => gm.highlighted));

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
      child: highlighted != null && highlighted == getCard()
          ? Glow(child: child)
          : child,
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
}

class BlankSpot extends StatelessWidget {
  const BlankSpot({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: playingCardAspectRatio,
      child: Container(
          padding: const EdgeInsets.all(5),
          child: Container(color: Colors.green)),
    );
  }
}

class Cascade extends ConsumerWidget {
  const Cascade({required this.children, Key? key}) : super(key: key);

  final List<PlayingCard> children;
  final double cardExposure = .22;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var maxCards =
        15; // how many will we make room for, given our allowed size?
    var extraSpace = (maxCards - 1) * cardExposure;
    var totalSpace = 1 + extraSpace;
    var cascadeAspectRatio = playingCardAspectRatio / totalSpace;
    return LayoutBuilder(builder: (context, constraints) {
      return AspectRatio(
        aspectRatio: cascadeAspectRatio,
        child: Stack(children: [
          Align(
            alignment: const Alignment(0, -1),
            child: FreecellInteractTarget(
              canHighlight: () => false,
              getCard: () => null,
              canReceive: (card) => true,
              receive: (card) =>
                  ref.read(gameModelProvider).placeNewCascade(card, children),
              child: const BlankSpot(),
            ),
          ),
          for (var i = 0; i < children.length; i++)
            Align(
              alignment: Alignment(0, -1 + i / (maxCards - 1) * 2),
              child: FreecellInteractTarget(
                canHighlight: () => i == children.length - 1,
                getCard: () => children[i],
                canReceive: (card) => cascadesWell(children[i], card),
                receive: (card) => ref
                    .read(gameModelProvider)
                    .placeHighlightedCard(on: children[i]),
                child: FreecellCardView(
                    card: children[i], covered: i != children.length - 1),
              ),
            )
        ]),
      );
    });
  }

  bool cascadesWell(PlayingCard parent, PlayingCard child) {
    if (GameState.value(parent) != GameState.value(child) + 1) {
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
      return FreecellInteractTarget(
        canHighlight: () => space != null,
        getCard: () => space,
        canReceive: (card) => space == null,
        receive: (card) => model.moveToFreeSpace(i, card),
        child:
            space == null ? const BlankSpot() : FreecellCardView(card: space),
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
        return FreecellInteractTarget(
          canHighlight: () => false,
          getCard: () => null,
          canReceive: (card) => canReceive(pile, card),
          receive: (card) => model.placeHighlightedOnFoundation(pile),
          child: pile.isNotEmpty
              ? FreecellCardView(card: pile.last)
              : const BlankSpot(),
        );
      }).toList(),
    );
  }

  bool canReceive(List<PlayingCard> pile, PlayingCard card) {
    if (pile.isEmpty) return card.value == CardValue.ace;
    return pile.last.suit == card.suit &&
        GameState.value(pile.last) == GameState.value(card) - 1;
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
        primarySwatch: Colors.green,
      ),
      home: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.green,
          child: const GameBoard()),
    );
  }
}
