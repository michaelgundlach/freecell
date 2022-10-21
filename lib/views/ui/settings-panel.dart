import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';
import '../../util/sound.dart';
import '../util/game-over-dancer.dart';
import 'intro-screen.dart';
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
            onTap: () {
              if (gameState.stage != "winning") sound.toggleMusic();
            },
            child: Column(
              children: [
                GameOverDancer(
                  tween: Tween(begin: -pi / 36, end: pi / 36),
                  child: Image.asset("assets/images/accordion.png"),
                ),
                Opacity(
                  opacity: gameState.stage == "winning" ? 0.5 : 1.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: ElevatedButton(
                      onPressed: () {
                        if (gameState.stage != "winning") sound.toggleMusic();
                      },
                      child: Text(sound.musicPlaying ? sound.polkaNo() : "ACCORDI-ON", textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _tigerClicked(context, ref, gameState),
            child: Column(
              children: [
                const GameOverDancer(
                  curve: Curves.easeInOutQuint,
                  stoppedChild: Hero(tag: "tiger", child: Tiger()),
                  child: Tiger(),
                ),
                FittedBox(
                  fit: BoxFit.fill,
                  child: Text(gameState.seed.toString(), style: Theme.of(context).textTheme.bodyLarge),
                ),
                Opacity(
                  opacity: gameState.stage == "winning" ? 0.5 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _tigerClicked(context, ref, gameState),
                      child: const Text("Redeal"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _tigerClicked(context, ref, gameState) {
    if (gameState.stage == "winning") return;
    if (gameState.seed == 999999 && gameState.stage == "playing") {
      // for testing
      ref.watch(soundProvider).toggleWinMusic(play: true);
      for (int i = 0; i < 50; i++) gameState.autoplayOne();
      gameState.stage = "winning";
    } else if (gameState.stage != "intro") {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black45,
          pageBuilder: (context, _, __) => const FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: IntroScreen(isDialog: true),
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
}
