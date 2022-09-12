import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:playing_cards/playing_cards.dart';

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
    emptyPile() => LinkedList<PileEntry>()..add(PileEntry(null));
    var deck = standardFiftyTwoCardDeck()..shuffle();
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
  }

  late int numFreeCells;
  late final List<LinkedList<PileEntry>> freeCells;
  late final List<LinkedList<PileEntry>> foundations;
  late final List<LinkedList<PileEntry>> cascades;

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
}