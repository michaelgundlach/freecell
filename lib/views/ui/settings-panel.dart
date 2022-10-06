import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';
import '../../util/sound.dart';
import 'tiger.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundProvider);
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => sound.toggleMusic(),
            child: Column(
              children: [
                Image.asset("assets/images/accordion.png"),
                FittedBox(
                  fit: BoxFit.fill,
                  child:
                      Text(sound.musicPlaying ? _polkaNo() : "POLKA PLS", style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Hero(tag: "tiger", child: Tiger(width: 100)),
              FittedBox(
                fit: BoxFit.fill,
                child:
                    Text(ref.watch(GameState.provider).seed.toString(), style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _polkaNo() {
    const options = [
      "NEVERMIND",
      "I TAKE IT BACK!",
      "TURN IT OFF!",
      "JUST KIDDING LOL",
      "STOP STOP STOP",
      "LESS POLKA",
    ];
    return options[Random().nextInt(options.length)];
  }
}
