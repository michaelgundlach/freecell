import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Friendly tiger who controls the seed and comments upon your play.

class Tiger extends ConsumerWidget {
  const Tiger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [Image.asset("assets/images/tiger.png")],
      // TODO: speech bubbles, sfx
    );
  }
}
