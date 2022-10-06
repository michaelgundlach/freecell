import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../main.dart';

class FreecellCardView extends ConsumerWidget {
  const FreecellCardView({required this.card, this.covered = false, super.key});
  final PlayingCard card;
  // TODO replace with "badlyPlaced" to count down to win condition, complete with encouragement
  final bool covered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var deckStyle = ref.watch(deckStyleProvider);

    return Hero(
      tag: "${card.value}${card.suit}",
      child: PlayingCardView(
        card: card,
        elevation: deckStyle.elevation,
        shape: deckStyle.shape,
        style: PlayingCardViewStyle(
          suitStyles: makeStyles(),
          suitBesideLabel: true,
        ),
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
      );
    }

    return {for (Suit suit in STANDARD_SUITS) suit: makeStyle(suit)};
  }
}
