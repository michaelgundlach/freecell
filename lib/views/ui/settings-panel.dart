import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../model/game-state.dart';
import '../../util/sound.dart';
import '../util/game-over-dancer.dart';
import 'tiger.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(GameState.provider);
    final sound = ref.watch(soundProvider);
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            spreadRadius: 3,
            color: Theme.of(context).primaryColorDark,
            blurRadius: 2,
          ),
        ],
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => sound.toggleMusic(),
            child: Column(
              children: [
                GameOverDancer(
                  tween: Tween(begin: -pi / 36, end: pi / 36),
                  child: Image.asset("assets/images/accordion.png"),
                ),
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
              const GameOverDancer(
                  curve: Curves.easeInOutQuint, stoppedChild: Hero(tag: "tiger", child: Tiger()), child: Tiger()),
              FittedBox(
                fit: BoxFit.fill,
                child: Text(gameState.seed.toString(), style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
