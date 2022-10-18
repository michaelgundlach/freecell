import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/util/freecell-card-view.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../model/game-state.dart';
import '../util/text-stamp.dart';
import 'tiger.dart';

class CardSmear extends ConsumerStatefulWidget {
  const CardSmear({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CardSmearState();
}

class _CardSmearState extends ConsumerState<CardSmear> {
  Map<Suit, Map<CardValue, Alignment>> cardAlignments = {for (final s in Suit.values) s: {}};

  @override
  Widget build(BuildContext context) {
    final List<PlayingCard> deck = ref.watch(GameState.provider).deck;
    if (cardAlignments[Suit.clubs]!.isEmpty) {
      // TODO less ugly data wrangling?  Ask SO
      deck.forEachIndexed((i, c) {
        double w = 10, h = 5;
        // lol
        double alignX = 1 / (w - 1) * ((i ~/ h) % w) * 2 - 1;
        alignX = alignX * 0.5 + (alignX < 0 ? -1 : 1) * 0.5; // push out to edges

        double alignY = 1 / (h - 1) * (i % h) * 2 - 1;
        cardAlignments[c.suit]![c.value] = Alignment(alignX, alignY);
      });
    }
    return Stack(
      children: deck
          .map((c) => Align(
                alignment: cardAlignments[c.suit]![c.value]!,
                child: FractionallySizedBox(
                  widthFactor: 1 / 17,
                  child: FreecellCardView(card: c),
                ),
              ))
          .toList(),
    );
  }
}

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return Material(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            const Opacity(opacity: 0.5, child: CardSmear()),
            Row(
              children: [
                const Spacer(flex: 10),
                Expanded(
                  flex: 20,
                  child: Column(
                    children: [
                      const Expanded(
                        flex: 40,
                        child:
                            Hero(tag: "freecell", child: TextStamp("Freecell", fontFamily: "FleurDeLeah", shadow: 1)),
                      ),
                      const Expanded(flex: 30, child: Hero(tag: "tiger", child: Tiger())),
                      Expanded(
                        flex: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Enter a code to race your friends!", style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 5),
                      Expanded(
                        flex: 10,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.watch(GameState.provider).stage = "playing";
                            if (controller.value.text != "") {
                              ref.watch(GameState.provider).seed = int.parse(controller.value.text);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text("Deal"),
                        ),
                      ),
                      const Spacer(flex: 5),
                    ],
                  ),
                ),
                const Spacer(flex: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
