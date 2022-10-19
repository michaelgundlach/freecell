import 'package:flutter/material.dart';

/// Text that grows to fit its container, with nice coloring and drop shadow.
class TextStamp extends StatelessWidget {
  const TextStamp(this.text, {this.fontFamily, this.shadow, super.key, this.color});
  final String text;
  final String? fontFamily;
  final double? shadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(text,
          style: Theme.of(context).textTheme.headline1!.copyWith(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).primaryColorDark,
            shadows: [Shadow(color: Theme.of(context).backgroundColor, offset: Offset(shadow ?? 0, shadow ?? 0))],
          )),
    );
  }
}
