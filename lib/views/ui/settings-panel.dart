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
                  child: Text(sound.musicPlaying ? sound.polkaNo() : "ACCORDI-ON",
                      style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Hero(tag: "tiger", child: Tiger()),
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
}
