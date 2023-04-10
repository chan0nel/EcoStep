import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM',
          ),
        ],
      ),
    );
  }
}
