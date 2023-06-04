import 'dart:math';
import 'package:diplom/logic/provider/list_provider.dart';
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
  final String name;
  const SliverHeader({super.key, required this.text, required this.name});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 35.0,
        maxHeight: 60.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: const Border(
              bottom: BorderSide(width: 1, color: Colors.black12),
            ),
            color: Theme.of(context).colorScheme.brightness == Brightness.light
                ? const Color(0xffffb300)
                : const Color(0xffe4a010),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () {
                  Provider.of<ListModel>(context, listen: false)
                      .changeShown(name);
                },
                icon: Consumer<ListModel>(
                  builder: (context, value, child) {
                    return value.shown[name] == true
                        ? const Icon(Icons.arrow_drop_up)
                        : const Icon(Icons.arrow_drop_down);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
