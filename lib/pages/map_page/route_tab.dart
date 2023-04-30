import 'package:diplom/logic/database/map_route.dart';
import 'package:flutter/material.dart';

class RouteTab extends StatelessWidget {
  final MapRoute mp;
  const RouteTab({super.key, required this.mp});

  @override
  Widget build(BuildContext context) {
    return Text(mp.toJson().toString());
  }
}
