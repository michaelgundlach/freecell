import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../util/rng.dart';

class PileEntry extends LinkedListEntry<PileEntry> {
  PileEntry(this.card, {this.badlyPlaced = false});

  // null means this is an empty spot where a card could go.  All piles start with one.
  final PlayingCard? card;

  bool get isTheBase => card == null;
  int get value => (card!.value == CardValue.ace ? 1 : card!.value.index + 2);
  Suit get suit => card!.suit;
  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  // Is it currently on a lower-rank card in the cascades?
  bool badlyPlaced;

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
  String _stage = "init"; // "init", "intro", "playing", "redeal modal", "winning", "game over"
  get stage => _stage;

  late int _seed;
  int get seed => _seed;

  late int _numFreeCells;
  int get numFreeCells => _numFreeCells;

  late int _badlyPlacedCards;

  late List<PlayingCard> deck;

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
    _seed = makeRandomSeed();
    _init();
  }

  _init() {
    _badlyPlacedCards = 0;
    deck = _deckFromSeed();
    final cascadeDeck = deck.toList(); // copy to consume in someCards()
    lastCardBadlyPlaced(pile) => !pile.last.previous!.isTheBase && pile.last.previous!.value < pile.last.value;
    someCards(count) {
      var result = _emptyPile();
      for (int i = 0; i < count; i++) {
        result.add(PileEntry(cascadeDeck.removeAt(0)));
        if (lastCardBadlyPlaced(result)) {
          result.last.badlyPlaced = true;
          _badlyPlacedCards++;
        }
      }
      return result;
    }

    _numFreeCells = 3;
    freeCells = List.generate(_numFreeCells, (_) => _emptyPile());
    foundations = List.generate(4, (_) => _emptyPile());
    cascades = [for (int i = 0; i < 8; i++) someCards(i < 4 ? 7 : 6)];
  }

  LinkedList<PileEntry> _emptyPile() => LinkedList<PileEntry>()..add(PileEntry(null));

  _deckFromSeed() {
    // In the order that Tynker uses: A of H S D C, 2 of H S D C, ..., K of H S D C
    var orderedDeck = [
      for (final index in [12, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        for (Suit suit in [Suit.hearts, Suit.spades, Suit.diamonds, Suit.clubs])
          PlayingCard(suit, CardValue.values[index])
    ];
    if (_seed == 3333333) return orderedDeck.reversed.toList(); // for testing
    return _shuffle(orderedDeck);
  }

  _shuffle(List<PlayingCard> deck) {
    final rng = RNG(_seed);
    final shuffledDeck = <PlayingCard>[];
    while (deck.isNotEmpty) {
      shuffledDeck.add(deck.removeAt(rng.pickRandomBetweenOneAnd(deck.length) - 1));
    }
    return shuffledDeck;
  }

  deal([int? seed]) {
    _seed = seed ?? makeRandomSeed();
    _init();
    _stage = "playing";
    print("Starting stage 'playing' with seed $_seed");
    notifyListeners();
  }

  int makeRandomSeed() {
    List<int> digits = List.generate(6, (i) => Random().nextInt(4));
    String seedAsString = digits.map((i) => i.toString()).join('');
    return int.parse(seedAsString);
  }

  void moveHighlightedOnto(PileEntry target) {
    assert(_highlighted != null);
    _highlighted!.unlink();
    if (_highlighted!.badlyPlaced) {
      _highlighted!.badlyPlaced = false;
      _badlyPlacedCards -= 1;
    }

    target.insertAfter(_highlighted!);
    _highlighted = null;

    if (_badlyPlacedCards == 0) {
      _stage = foundationsFull ? "game over" : "winning";
      print("Changed to stage $_stage");
    }

    notifyListeners();
  }

  void addFreeCell() {
    _numFreeCells++;
    freeCells.insert(0, _emptyPile());
    notifyListeners();
  }

  bool get freeCellsAreFull => freeCells.every((cell) => !cell.last.isTheBase);

  /// Copy, autoplayed by one.
  GameState._(GameState original) {
    // Returns a deep copy of a list of linked lists of pileentries
    llcopy(List<LinkedList<PileEntry>> ll) {
      return ll.map((linkedlist) {
        LinkedList<PileEntry> t = LinkedList();
        for (PileEntry pe in linkedlist) {
          t.add(PileEntry(pe.card, badlyPlaced: pe.badlyPlaced));
        }
        return t;
      }).toList();
    }

    freeCells = llcopy(original.freeCells);
    foundations = llcopy(original.foundations);
    cascades = llcopy(original.cascades);

    _seed = original._seed;
    _stage = original._stage;
    _highlighted = original._highlighted;

    _numFreeCells = original.numFreeCells;
    _badlyPlacedCards = original._badlyPlacedCards;
    deck = original.deck.toList();
  }

  /// Returns a copy of this, autoplayed by one.  Assumes there is something to autoplay.
  GameState oneAutoplayed() {
    return GameState._(this)..autoplay();
  }

  // Autoplays one card onto a foundation (the lowest card available to play).  Assumes there is at least one to play.
  void autoplay([int count = 1]) {
    // Move the lowest-ranked card on the end of a cascade/free cell to its foundation.
    for (int i = 0; i < count; i++) {
      var stacksToPlayFrom = (cascades + freeCells);
      var optionsToPlay = stacksToPlayFrom.map((stack) => stack.last.isTheBase ? null : stack.last).toList();
      optionsToPlay = optionsToPlay.where((p) => p != null).toList();
      assert(optionsToPlay.isNotEmpty);
      var lowCard = optionsToPlay.reduce((p1, p2) => p1!.value < p2!.value ? p1 : p2);
      var targetFoundation = foundations.firstWhere(
        (f) => (lowCard!.value == 1) ? f.last.isTheBase : !f.last.isTheBase && f.last.suit == lowCard.suit,
      );
      _highlighted = lowCard!;
      moveHighlightedOnto(targetFoundation.last);
      _settledCards += 1;

      settlingCard = lowCard.card;
    }
    notifyListeners();
  }

  // False if any king is not on its foundation.
  bool get foundationsFull => foundations.every((f) => f.length == 14); // the base plus A-K

  PlayingCard? settlingCard;
  int _settledCards = 0;
  int get settledCards => _settledCards;

  // true if it's in the foundation and not the autoplayed card.
  bool isAlreadySettledCard(PlayingCard card) {
    match(c) => (c != null) && (c.suit == card.suit && c.value == card.value);
    if (match(settlingCard)) return false;
    return foundations.any((foundation) => foundation.any((pileEntry) => match(pileEntry.card)));
  }

  static ChangeNotifierProvider<GameState> provider = ChangeNotifierProvider<GameState>((ref) => GameState());
}
