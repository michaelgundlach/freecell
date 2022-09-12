import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/pile-view.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../main.dart';
import '../model/game-state.dart';

class Foundations extends ConsumerStatefulWidget {
  const Foundations({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoundationsState();
}

class _FoundationsState extends ConsumerState<Foundations> {
  final r = Random();
  final List<List<double>> rotations = List.generate(4, (_) => [0]);

  double _rotation(i, j) {
    j = j - 1; // We only ask starting with entry #1
    int maxTiltDegrees = 4;
    while (rotations[i].length <= j) {
      double rot;
      do {
        rot = (r.nextDouble() - .5) * maxTiltDegrees;
      } while (rotations[i].isNotEmpty && (rotations[i].last - rot).abs() < .9);
      rotations[i].add(rot);
    }
    return rotations[i][j];
  }

  @override
  Widget build(BuildContext context) {
    var model = ref.watch(gameStateProvider);
    return Row(
      children: model.foundations
          .mapIndexed((i, pile) => PileView(
                // TODO right
                entries: pile,
                canHighlight: (PileEntry entry) => false,
                canReceive: (PileEntry highlighted, PileEntry entry) => entry.isNextInFoundation(highlighted),
                baseBuilder: () => Container(width: 150, color: Colors.blue, child: Text("A")),
                positioner: (int j, Widget child) {
                  return Align(
                      child: Transform(
                          alignment: FractionalOffset.center,
                          transform: Matrix4.rotationZ(radians(_rotation(i, j))),
                          child: child));
                },
              ))
          .toList(),
    );
  }
}
