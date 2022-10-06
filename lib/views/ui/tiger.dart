import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Friendly tiger who controls the seed and comments upon your play.

class Tiger extends ConsumerWidget {
  const Tiger({required this.width, super.key});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [Image.asset("assets/images/tiger.png")],
        // TODO: speech bubbles, sfx
      ),
    );
  }
}
