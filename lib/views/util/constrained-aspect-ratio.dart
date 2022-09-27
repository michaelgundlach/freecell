import 'dart:math';

import 'package:flutter/material.dart';

class ConstrainedAspectRatio extends StatelessWidget {
  const ConstrainedAspectRatio({required this.child, required this.maxAspectRatio, super.key});
  final Widget child;
  final double maxAspectRatio;

  @override
  Widget build(BuildContext context) => CustomSingleChildLayout(delegate: _CARDelegate(maxAspectRatio), child: child);
}

class _CARDelegate extends SingleChildLayoutDelegate {
  _CARDelegate(this.maxAspectRatio);

  final double maxAspectRatio;
  Size _size = Size.zero;

  @override
  Size getSize(BoxConstraints constraints) {
    // Full height, wide as allowed
    final double w = constraints.maxWidth, h = constraints.maxHeight;
    if (h.isInfinite) {
      // Container infinitely tall; use max aspect ratio as exact aspect ratio
      assert(w.isFinite, () => "Need at least one bounded constraint for $runtimeType.");
      return _size = Size(w, w / maxAspectRatio);
    } else {
      // Finite height.  Use all of it, and go as wide as maxAspectRatio allows.
      return _size = Size(min(h * maxAspectRatio, w), h);
    }
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tight(_size);
  }

  @override
  bool shouldRelayout(covariant _CARDelegate oldDelegate) {
    return oldDelegate.maxAspectRatio != maxAspectRatio;
  }
}
