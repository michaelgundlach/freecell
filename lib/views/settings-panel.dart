import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/sound.dart';
import 'tiger.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => sound.toggleMusic(),
          child: Column(
            children: [
              SizedBox(width: 130, child: Image.asset("assets/images/accordion.png")),
              FittedBox(
                fit: BoxFit.fill,
                child:
                    Text(sound.musicPlaying ? _polkaNo() : "POLKA PLS", style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ),
        const Tiger(),
      ],
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
