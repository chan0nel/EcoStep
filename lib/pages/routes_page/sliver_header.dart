import 'dart:math';

import 'package:flutter/material.dart';

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
        minHeight: 60.0,
        maxHeight: 100.0,
        child: Container(
          decoration: BoxDecoration(
            border: const Border(
              bottom: BorderSide(width: 1, color: Colors.black12),
            ),
            color: Colors.lightBlue[200],
          ),
          child: Center(
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
