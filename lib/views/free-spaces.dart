import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freecell/views/pile-view.dart';

import '../main.dart';
import '../model/game-state.dart';

class FreeSpaces extends ConsumerWidget {
  const FreeSpaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var model = ref.watch(gameStateProvider);
    return Row(
      children: model.freeCells
          .map((pile) => PileView(
                // TODO right
                entries: pile,
                canHighlight: (PileEntry entry) => !entry.isTheBase,
                canReceive: (PileEntry highlighted, PileEntry entry) => entry.isTheBase,
                baseBuilder: () => Container(width: 120, color: Colors.blue, child: Text("F!")),
                positioner: (int i, Widget child) => Align(child: child),
              ))
          .toList(),
    );
  }
}
