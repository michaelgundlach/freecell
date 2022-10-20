import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../main.dart';
import '../../model/game-state.dart';

class FreecellCardView extends ConsumerWidget {
  const FreecellCardView({required this.card, super.key});
  final PlayingCard card;

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

    final gameState = ref.watch(GameState.provider);
    if (gameState.stage == "winning" && gameState.isAlreadySettledCard(cardView.card)) {
      // don't wrap as hero lest its flight cause a wiggle during win animation (due to rotation).
      // but do make them heroes during play, so that the redeal modal can capture them.
      return cardView;
    }
    var opacityTween = Tween(
      begin: 1.0,
      // During win dance, we want full opacity the whole time.
      end: gameState.stage == "winning" ? 1.0 : 0.3,
    );
    return Hero(
      tag: "${card.value}${card.suit}",
      child: cardView,
      flightShuttleBuilder: (_, Animation<double> animation, __, ___, ____) =>
          FadeTransition(opacity: opacityTween.animate(animation), child: cardView),
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
