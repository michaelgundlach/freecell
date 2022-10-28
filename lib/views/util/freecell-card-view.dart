import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../main.dart';
import '../../model/game-state.dart';

class FreecellCardView extends ConsumerWidget {
  const FreecellCardView({required this.card, super.key, this.opacity = 1.0, this.isFaux = false});
  final PlayingCard card;
  final double opacity;
  final bool isFaux; // during "win", a duplicate cardview grows into the foundations

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

    bool settling = ref.watch(GameState.provider.select((gs) => gs.stage == "winning" && gs.isNextSettlingCard(card)));
    if (settling) {
      Tween<double> tween;
      if (isFaux) {
        // In foundation; go down.
        tween = Tween(begin: 200.0, end: 0);
      } else if (ref.read(GameState.provider).isInFreeCells(card)) {
        // In free cell; go down.
        tween = Tween(begin: 0.0, end: 200.0);
      } else {
        // In cascades; go up.
        tween = Tween(begin: 0.0, end: -400.0);
      }
      return PlayAnimationBuilder<double>(
        builder: (BuildContext context, value, Widget? child) =>
            Transform.translate(offset: Offset(0, value), child: child),
        tween: tween,
        duration: const Duration(milliseconds: 500),
        child: cardView,
      );
    }

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
