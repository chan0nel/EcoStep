import 'package:flutter/material.dart';
import 'dart:math' as math;

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final int angle;
  const InfoChip(
      {super.key, required this.icon, required this.text, this.angle = 0});

  @override
  Widget build(BuildContext context) {
    Color c = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).colorScheme.onSecondary.withAlpha(10)
        : Theme.of(context).colorScheme.onSecondary.withAlpha(40);

    return Chip(
        side: const BorderSide(style: BorderStyle.none),
        backgroundColor: c,
        avatar: Transform.rotate(
          angle: angle * math.pi / 180,
          child: Icon(
            icon,
            size: 18,
          ),
        ),
        label: Text(text));
  }
}
