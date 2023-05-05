import 'dart:math';

import 'package:diplom/logic/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class SliverHeader extends StatelessWidget {
  final String text;
  const SliverHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 30.0,
        maxHeight: 60.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: Colors.black12),
            ),
            color: Color.fromARGB(210, 255, 179, 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text),
              // TextButton(onPressed: () {}, child: const Text('Показать все'))
            ],
          ),
        ),
      ),
    );
  }
}
