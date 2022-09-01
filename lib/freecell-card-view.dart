import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

import 'deck-style.dart';

class FreecellCardView extends StatefulWidget {
  const FreecellCardView({required this.deckStyle, required this.card, super.key});
  final PlayingCard card;
  final DeckStyle deckStyle;

  @override
  State<FreecellCardView> createState() => _FreecellCardViewState();
}

class _FreecellCardViewState extends State<FreecellCardView> {
  bool highlighted = false;

  @override
  Widget build(BuildContext context) {
    var redStyle =
        SuitStyle(style: TextStyle(fontWeight: FontWeight.bold, color: highlighted ? Colors.yellow : Colors.red));
    var blackStyle =
        SuitStyle(style: TextStyle(fontWeight: FontWeight.bold, color: highlighted ? Colors.yellow : Colors.black));

    return GestureDetector(
      onTap: () {
        print('Tap on ${widget.card.value}');
        setState(() {
          highlighted = !highlighted;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: widget.deckStyle.cardHeight,
        child: PlayingCardView(
          card: widget.card,
          elevation: widget.deckStyle.elevation,
          shape: widget.deckStyle.shape,
          style: PlayingCardViewStyle(
            suitStyles: {
              Suit.clubs: blackStyle,
              Suit.hearts: redStyle,
              Suit.diamonds: redStyle,
              Suit.spades: blackStyle,
            },
          ),
        ),
      ),
    );
  }
}
