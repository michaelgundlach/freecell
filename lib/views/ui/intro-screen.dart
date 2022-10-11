import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/util/freecell-card-view.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../model/game-state.dart';
import '../util/text-stamp.dart';
import 'tiger.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return Material(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Expanded(
              flex: 40,
              child: Hero(tag: "freecell", child: TextStamp("Freecell", fontFamily: "FleurDeLeah", shadow: 1)),
            ),
            const Expanded(flex: 30, child: Hero(tag: "tiger", child: Tiger())),
            const Spacer(flex: 5),
            Expanded(
              flex: 8,
              child: Text("Enter a code to race your friends!", style: Theme.of(context).textTheme.headline4),
            ),
            Expanded(
              flex: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.watch(GameState.provider).stage = "playing";
                      if (controller.value.text != "") {
                        ref.watch(GameState.provider).seed = int.parse(controller.value.text);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Deal"),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 5),
            Expanded(
              flex: 10,
              child: FlatCardFan(
                children: standardFiftyTwoCardDeck().map((c) => FreecellCardView(card: c)).toList(),
              ),
            ),
            //const Spacer(flex: 10),
          ],
        ),
      ),
    );
  }
}
