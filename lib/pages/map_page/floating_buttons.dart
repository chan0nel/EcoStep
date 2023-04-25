// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:diplom/logic/map_service.dart';
import 'package:diplom/logic/providers.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FloatingButtons extends StatelessWidget {
  const FloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapModel>(
      builder: (context, value, child) => value.states['hideSheet'] != true
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: FloatingActionButton(
                    onPressed: () async {
                      final pos = await MapService().determinePosition();
                      value.mapController
                          .move(LatLng(pos.latitude, pos.longitude), 15);
                    },
                    heroTag: null,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                const SizedBox(height: 10.0),
                FloatingActionButton(
                  onPressed: () {
                    value.setHideSheet(false);
                  },
                  heroTag: null,
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
