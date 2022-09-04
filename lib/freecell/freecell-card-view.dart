import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../main.dart';
import 'deck-style.dart';

class FreecellCardView extends ConsumerStatefulWidget {
  const FreecellCardView({required this.card, this.covered = false, super.key});
  final PlayingCard card;
  final bool covered;

  @override
  ConsumerState<FreecellCardView> createState() => _FreecellCardViewState();
}

class _FreecellCardViewState extends ConsumerState<FreecellCardView> {
  bool highlighted = false;

  @override
  Widget build(BuildContext context) {
    var deckStyle = ref.watch(deckStyleProvider);

    return GestureDetector(
      onTap: () => setState(() => highlighted = !highlighted),
      behavior: HitTestBehavior.translucent,
      child: PlayingCardView(
        card: widget.card,
        elevation: deckStyle.elevation,
        shape: deckStyle.shape,
        style: PlayingCardViewStyle(suitStyles: makeStyles()),
      ),
    );
  }

  makeStyles() {
    makeStyle(suit) {
      Color color = Colors.yellow;
      if (!highlighted) {
        color = (suit == Suit.clubs || suit == Suit.spades) ? Colors.black : Colors.red;
      }
      return SuitStyle(
        style: TextStyle(
          fontWeight: FontWeight.normal,
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
    if (widget.covered)
      return (_) => Center(child: Container(width: 10, color: Colors.blue));
    else
      return null;
  }
}
