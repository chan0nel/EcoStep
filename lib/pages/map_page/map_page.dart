import 'package:diplom/pages/map_page/bottom_sheet.dart';
import 'package:diplom/pages/map_page/floating_buttons.dart';
import 'package:diplom/logic/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<TextEditingController> ctrl = [
    TextEditingController(),
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const FloatingButtons(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<MapModel>(
              builder: (context, value, child) => FlutterMap(
                mapController: value.mapController,
                options: MapOptions(
                  center: LatLng(53.893009, 27.567444),
                  onTap: (tapPosition, point) {
                    final idx = value.states['editPoint'];
                    if (idx != null) {
                      value.addPoint(point, idx);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM',
                  ),
                  PolylineLayer(
                    polylines: value.polylines,
                    polylineCulling: false,
                  ),
                  MarkerLayer(
                    markers: value.markers,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomBottomSheet(ctrl: ctrl),
          ),
        ],
      ),
    );
  }
}
