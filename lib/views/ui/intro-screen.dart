import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/game-state.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(context: context, barrierDismissible: false, builder: _builder);
    });
  }

  Widget _builder(_) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: .8,
        heightFactor: .8,
        child: Container(color: Colors.green),
      ),
    );
  }

  @override
  Widget build(context) => const SizedBox.shrink();
}

class iIntroScreen extends ConsumerWidget {
  const iIntroScreen({super.key});

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
        },
        child: const Text("Start"),
      ),
    ]));
  }
}
