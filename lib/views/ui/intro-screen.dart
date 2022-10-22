import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/util/freecell-card-view.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../model/game-state.dart';
import '../../util/sound.dart';
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
        double alignX = 1 / (w - 1) * ((i ~/ h) % w) * 2 - 1;
        double alignY = 1 / (h - 1) * (i % h) * 2 - 1;
        cardAlignments[c.suit]![c.value] = Alignment(alignX, alignY);
      });
    }
    return Stack(
      children: deck
          .map((c) => Align(
                alignment: cardAlignments[c.suit]![c.value]!,
                child: FractionallySizedBox(
                  widthFactor: 1 / 15,
                  child: FreecellCardView(card: c),
                ),
              ))
          .toList(),
    );
  }
}

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key, this.isDialog = false});
  final bool isDialog;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  // Way too much work in order to start playing music and tiger dancing on web
  // when race textfield clicked (since Chrome disables autoplay.)
  bool tigerMayDance = !kIsWeb;
  FocusNode raceFocusNode = FocusNode();
  Sound? sound;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      raceFocusNode.addListener(() {
        if (raceFocusNode.hasFocus) {
          setState(() => tigerMayDance = true);
          sound!.toggleMusic(play: true, fade: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(GameState.provider);
    final controller = TextEditingController();
    sound ??= ref.watch(soundProvider);

    sound!.wakeUp();

    void deal([value]) {
      gameState.stage = "playing";
      if (widget.isDialog) {
        // If they enter the same number, actually redeal, by triggering a seed change.
        gameState.seed = 0;
      }
      if (controller.value.text != "") {
        gameState.seed = int.parse(controller.value.text);
      } else {
        gameState.seed = Random().nextInt(1000000);
      }
      if (kIsWeb && !widget.isDialog) sound!.toggleMusic(play: true, fade: true);
      Navigator.pop(context);
    }

    var x = 50.0, y = 10.0, yOffset = 0;
    MovieTween tigerTween = MovieTween()
      ..scene(begin: Duration.zero, duration: const Duration(milliseconds: 2000))
          .tween('x', Tween(begin: -x / 2, end: 0.0), curve: Curves.easeIn)
          .tween('y', Tween(begin: -y / 2 + yOffset, end: y / 2 + yOffset), curve: Curves.easeInOut)
          .thenFor(duration: const Duration(milliseconds: 2000))
          .tween('x', Tween(begin: 0.0, end: x / 2), curve: Curves.easeOut)
          .tween('y', Tween(begin: y / 2 + yOffset, end: -y / 2 + yOffset), curve: Curves.easeInOut);

    return Material(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            const Opacity(opacity: 0.3, child: CardSmear()),
            Row(
              children: [
                const Spacer(flex: 10),
                Expanded(
                  flex: 20,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 40,
                        child: CustomAnimationBuilder<double>(
                          builder: (BuildContext context, value, Widget? child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          tween: Tween(begin: 1, end: 1.03),
                          duration: const Duration(seconds: 4),
                          startPosition: 0.5,
                          curve: Curves.easeInOut,
                          control: widget.isDialog ? Control.stop : Control.mirror,
                          child: const Hero(
                            tag: "freecell",
                            child: TextStamp("Freecell", fontFamily: "FleurDeLeah", shadow: 1),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: CustomAnimationBuilder(
                          builder: (context, value, child) => Transform(
                            transform: Matrix4.translationValues(value.get('x'), value.get('y'), 0),
                            child: child,
                          ),
                          tween: tigerTween,
                          startPosition: .5,
                          duration: tigerTween.duration,
                          control: widget.isDialog || !tigerMayDance ? Control.stop : Control.mirror,
                          child: const Hero(tag: "tiger", child: Tiger()),
                        ),
                      ),
                      const Spacer(flex: 2),
                      SizedBox(
                        height: 40,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Enter a code to race your friends!", style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  autofocus: false, // kIsWeb, // kbd blocks view on mobile
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: deal,
                                  focusNode: raceFocusNode,
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: const InputDecoration(contentPadding: EdgeInsets.only(bottom: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: deal,
                            child: const Text("Deal"),
                          ),
                          if (widget.isDialog) const SizedBox(width: 10),
                          if (widget.isDialog)
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                        ],
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
