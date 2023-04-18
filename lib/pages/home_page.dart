import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Polyline> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            child: const Text('click'),
            onPressed: () async {
              // var b = await MapService()
              //     .getRoute(profile: ORSProfile.cyclingRoad, points: [
              //   const ORSCoordinate(latitude: 53.889932, longitude: 27.454597),
              //   const ORSCoordinate(latitude: 53.902179, longitude: 27.548226)
              // ]);
              // DBService('test').saveRoute(b[0]);
              // var a = await DBService('test').getRoutes();
              // setState(() {
              //   for (var element in a) {
              //     list.add(element.polyline);
              //   }
              // });
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(53.893009, 27.567444),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM',
          ),
          PolylineLayer(
            polylines: list,
          )
        ],
      ),
    );
  }
}
