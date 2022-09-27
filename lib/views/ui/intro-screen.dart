import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../model/game-state.dart';

class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return Material(
        child: Column(children: [
      TextField(
        decoration: const InputDecoration(labelText: "Race number"),
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      ElevatedButton(
        onPressed: () {
          ref.watch(GameState.provider).seed = int.parse(controller.value.text);
          context.go("/game");
        },
        child: const Text("Start"),
      ),
    ]));
  }
}
