import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../util/rng.dart';

class PileEntry extends LinkedListEntry<PileEntry> {
  PileEntry(this.card);

  // null means this is an empty spot where a card could go.  All piles start with one.
  final PlayingCard? card;

  bool get isTheBase => card == null;
  int get value => (card!.value == CardValue.ace ? 1 : card!.value.index + 2);
  Suit get suit => card!.suit;
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  // Is it currently on a lower-rank card in the cascades?
  bool badlyPlaced = false;

  /// True if `candidate` can be played on `this` in a Cascade.
  bool canCascade(PileEntry candidate) {
    if (isTheBase) return true;
    return isRed != candidate.isRed && value == candidate.value + 1;
  }

  /// True if `candidate` can be played on `this` in a Foundation.
  bool isNextInFoundation(PileEntry candidate) {
    if (isTheBase) return candidate.value == 1;
    return suit == candidate.suit && value == candidate.value - 1;
  }
}

class GameState extends ChangeNotifier {
  String _stage = "intro"; // "intro", "playing", "winning", "lost", "play again"
  get stage => _stage;
  set stage(val) {
    if (_stage == val) return;
    _stage = val;
    notifyListeners();
  }

  late List<PlayingCard> deck;
  late int badlyPlacedCards;

  late int numFreeCells;
  late List<LinkedList<PileEntry>> freeCells;
  late List<LinkedList<PileEntry>> foundations;
  late List<LinkedList<PileEntry>> cascades;

  PileEntry? _highlighted;
  PileEntry? get highlighted => _highlighted;
  set highlighted(PileEntry? val) {
    _highlighted = val;
    notifyListeners();
  }

  GameState() {
    _init();
  }

  _init() {
    badlyPlacedCards = 0;
    deck = _deckFromSeed();
    final cascadeDeck = deck.toList(); // copy to consume in someCards()
    lastCardBadlyPlaced(pile) => !pile.last.previous!.isTheBase && pile.last.previous!.value < pile.last.value;
    someCards(count) {
      var result = _emptyPile();
      for (int i = 0; i < count; i++) {
        result.add(PileEntry(cascadeDeck.removeAt(0)));
        if (lastCardBadlyPlaced(result)) {
          result.last.badlyPlaced = true;
          badlyPlacedCards++;
          print("BAD: ${result.last.value} on ${result.last.previous!.value}");
        }
      }
      return result;
    }

    numFreeCells = 2;
    freeCells = List.generate(numFreeCells, (_) => _emptyPile());
    foundations = List.generate(4, (_) => _emptyPile());
    cascades = [for (int i = 0; i < 8; i++) someCards(i < 4 ? 7 : 6)];
    notifyListeners();
  }

  LinkedList<PileEntry> _emptyPile() => LinkedList<PileEntry>()..add(PileEntry(null));

  _deckFromSeed() {
    // In the order that Tynker uses: A of H S D C, 2 of H S D C, ..., K of H S D C
    var heck = [
      for (final index in [12, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        for (Suit suit in [Suit.hearts, Suit.spades, Suit.diamonds, Suit.clubs])
          PlayingCard(suit, CardValue.values[index])
    ];
    return _shuffle(heck);
  }

  _shuffle(List<PlayingCard> deck) {
    final rng = RNG(seed);
    final shuffledDeck = <PlayingCard>[];
    while (deck.isNotEmpty) {
      shuffledDeck.add(deck.removeAt(rng.pickRandomBetweenOneAnd(deck.length) - 1));
    }
    return shuffledDeck;
  }

  int _seed = Random().nextInt(1000000); // TODO temp
  int get seed => _seed;
  set seed(value) {
    if (_seed == value) return;
    _seed = value;
    _init();
  }

  void moveHighlightedOnto(PileEntry target) {
    assert(highlighted != null);
    highlighted!.unlink();
    if (highlighted!.badlyPlaced) {
      highlighted!.badlyPlaced = false;
      badlyPlacedCards -= 1;
      if (badlyPlacedCards == 0) {
        stage = "winning";
        print("WIN");
      }
    }

    target.insertAfter(highlighted!);
    highlighted = null;
  }

  void addFreeCell() {
    numFreeCells++;
    freeCells.insert(0, _emptyPile());
    notifyListeners();
  }

  bool get freeCellsAreFull => freeCells.every((cell) => !cell.last.isTheBase);

  /// Copy of this with one auto-win dance step taken.  If it finishes the last step, sets stage to "game over".
  GameState._();
  GameState moreSettledByOne() {
    llcopy(List<LinkedList<PileEntry>> ll) {
      return ll.map((linkedlist) {
        LinkedList<PileEntry> t = LinkedList();
        for (final pe in linkedlist) {
          t.add(PileEntry(pe.card));
        }
        return t;
      }).toList();
    }

    var g = GameState._();
    g._seed = _seed;
    g._stage = _stage;
    g.badlyPlacedCards = badlyPlacedCards;
    g.cascades = llcopy(cascades);
    g.deck = deck;
    g.foundations = llcopy(foundations);
    g.freeCells = llcopy(freeCells);
    g.numFreeCells = numFreeCells;

    // Move the lowest-ranked card on the end of a cascade to its foundation.  If no cards on foundations, done.
    List<PileEntry?> pileEntries = g.cascades.map((c) => c.last.isTheBase ? null : c.last).toList();
    if (pileEntries.every((pileEntry) => pileEntry == null)) {
      g._stage = "game over";
    } else {
      pileEntries = pileEntries.where((p) => p != null).toList();
      var lowCard = pileEntries.reduce((p1, p2) => p1!.value < p2!.value ? p1 : p2);
      lowCard!.unlink();
      var targetFoundation = g.foundations.firstWhere(
        (f) => (lowCard.value == 1) ? f.last.isTheBase : !f.last.isTheBase && f.last.suit == lowCard.suit,
      );
      targetFoundation.last.insertAfter(lowCard);
    }

    return g;
  }

  static ChangeNotifierProvider<GameState> provider = ChangeNotifierProvider<GameState>((ref) {
    return GameState();
  });
}
