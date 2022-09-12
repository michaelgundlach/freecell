import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../main.dart';

class FreecellCardView extends ConsumerWidget {
  const FreecellCardView({required this.card, this.covered = false, super.key});
  final PlayingCard card;
  final bool covered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var deckStyle = ref.watch(deckStyleProvider);

    return PlayingCardView(
      card: card,
      elevation: deckStyle.elevation,
      shape: deckStyle.shape,
      style: PlayingCardViewStyle(
        suitStyles: makeStyles(),
        suitBesideLabel: true,
      ),
    );
  }

  makeStyles() {
    makeStyle(suit) {
      var color = (suit == Suit.clubs || suit == Suit.spades) ? Colors.black : Colors.red;
      return SuitStyle(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
        cardContentBuilders: cardContentBuilders(suit),
      );
    }

    return {for (Suit suit in STANDARD_SUITS) suit: makeStyle(suit)};
  }

  Map<CardValue, Widget Function(BuildContext)> cardContentBuilders(Suit suit) {
    Map<CardValue, Widget Function(BuildContext)> result = {};
    for (var value in SUITED_VALUES) {
      var builder = makeCardBuilder(suit, value);
      if (builder != null) result[value] = builder;
    }
    return result;
  }

  Widget Function(BuildContext)? makeCardBuilder(Suit suit, CardValue value) {
    if (covered) {
      return (_) => Container();
    } else {
      return null;
    }
  }
}
