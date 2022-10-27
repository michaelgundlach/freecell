import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../main.dart';

class FreecellCardView extends ConsumerWidget {
  const FreecellCardView({required this.card, super.key, this.opacity = 1.0});
  final PlayingCard card;
  final double opacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var deckStyle = ref.watch(deckStyleProvider);
    final cardView = PlayingCardView(
      card: card,
      elevation: deckStyle.elevation,
      shape: deckStyle.shape,
      style: PlayingCardViewStyle(
        suitStyles: makeStyles(),
        suitBesideLabel: true,
      ),
    );

    return Hero(
      tag: "${card.value}${card.suit}",
      child: Opacity(opacity: opacity, child: cardView),
      flightShuttleBuilder: (_, animation, flightDirection, fromHeroContext, toHeroContext) {
        double fromOpacity = ((fromHeroContext.widget as Hero).child as Opacity).opacity;
        double toOpacity = ((toHeroContext.widget as Hero).child as Opacity).opacity;
        Tween<double> tween = flightDirection == HeroFlightDirection.push
            ? Tween(begin: fromOpacity, end: toOpacity)
            : Tween(begin: toOpacity, end: fromOpacity);
        return FadeTransition(opacity: tween.animate(animation), child: cardView);
      },
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
