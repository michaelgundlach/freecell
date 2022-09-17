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
  GameState() {
    _init();
  }

  _init() {
    emptyPile() => LinkedList<PileEntry>()..add(PileEntry(null));
    var deck = _deckFromSeed();
    someCards(count) {
      var result = emptyPile();
      for (int i = 0; i < count; i++) {
        result.add(PileEntry(deck.removeAt(0)));
      }
      return result;
    }

    numFreeCells = 5;
    freeCells = List.generate(numFreeCells, (_) => emptyPile());
    foundations = List.generate(4, (_) => emptyPile());
    cascades = [for (int i = 0; i < 8; i++) someCards(i < 4 ? 7 : 6)];
    notifyListeners();
  }

  _deckFromSeed() {
    // In the order that Tynker uses: A of H S D C, 2 of H S D C, ..., K of H S D C
    var deck = [
      for (final index in [12, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        for (Suit suit in [Suit.hearts, Suit.spades, Suit.diamonds, Suit.clubs])
          PlayingCard(suit, CardValue.values[index])
    ];
    return _shuffle(deck);
  }

  _shuffle(List<PlayingCard> deck) {
    final rng = RNG(seed);
    final shuffledDeck = [];
    while (deck.isNotEmpty) {
      shuffledDeck.add(deck.removeAt(rng.pickRandomBetweenOneAnd(deck.length) - 1));
    }
    return shuffledDeck;
  }

  int _seed = 1;
  int get seed => _seed;
  set seed(value) {
    if (_seed == value) return;
    _seed = value;
    _init();
  }

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

  void moveHighlightedOnto(PileEntry target) {
    assert(highlighted != null);
    highlighted!.unlink();
    target.insertAfter(highlighted!);
    highlighted = null;
  }

  static ChangeNotifierProvider<GameState> provider = ChangeNotifierProvider<GameState>((ref) {
    return GameState();
  });
}
