import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/util/freecell-card-view.dart';
import 'package:playing_cards/playing_cards.dart';

import '../../model/game-state.dart';
import '../util/text-stamp.dart';
import 'tiger.dart';

class InitroScreen extends ConsumerWidget {
  const InitroScreen({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final gs = ref.watch(GameState.provider);
    return Center(
      child: FractionallySizedBox(
        widthFactor: .8,
        heightFactor: .8,
        child: Container(
          color: Colors.green,
          child: Center(
            child: TextButton(
              onPressed: () {
                gs.stage = "playing";
                Navigator.pop(context);
              },
              child: const Text("Play"),
            ),
          ),
        ),
      ),
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
      child: Column(
        children: [
          const Hero(tag: "freecell", child: TextStamp("Freecell", fontFamily: "FleurDeLeah", shadow: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Hero(tag: "tiger", child: Tiger(width: 80)),
              Text("Enter a code to race your friends!"),
            ],
          ),
          Row(
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
          const Spacer(),
          SizedBox(
            height: 80,
            child: FlatCardFan(
              children: standardFiftyTwoCardDeck().map((c) => FreecellCardView(card: c)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
