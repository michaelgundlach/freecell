import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';

import 'freecell-card-view.dart';
import 'package:flutter/widgets.dart';
import 'package:playing_cards/playing_cards.dart';

import 'deck-style.dart';

/// This widget will array the passed in children in a vertical line.
/// The children will overlap, leaving just enough visible just enough to show each rank and suit.
class FreecellColumn extends StatelessWidget {
  final List<PlayingCard> children;
  final DeckStyle deckStyle;

  const FreecellColumn({required this.deckStyle, required this.children, super.key});

  @override
  Widget build(Object context) {
    return ColumnSuper(
      innerDistance: 0 * -.8,
      children: [for (var c in children) FreecellCardView(card: c)],
    );
  }
}
