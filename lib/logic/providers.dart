import 'dart:collection';

import 'package:diplom/widgets/cust_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

class MapModel extends ChangeNotifier {
  final List<Polyline> _polylines = [];
  final List<Map<String, dynamic>> _points = [
    {'ctrl': TextEditingController(), 'point': null},
    {'ctrl': TextEditingController(), 'point': null}
  ];
  final MapController mapController = MapController();
  final Map<String, dynamic> _states = {
    'hideSheet': true,
    'editPoint': null,
  };

  UnmodifiableListView<Polyline> get polylines =>
      UnmodifiableListView(_polylines);
  UnmodifiableListView<Map<String, dynamic>> get points =>
      UnmodifiableListView(_points);
  UnmodifiableMapView<String, dynamic> get states =>
      UnmodifiableMapView(_states);

  List<Marker> get markers => _points
      .where((element) => element['point'] != null)
      .map(
        (element) => Marker(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          point: element['point'],
          width: 36,
          height: 36,
          builder: (context) => const Icon(
            Icons.place,
            color: Colors.blueAccent,
            size: 36,
            shadows: [
              Shadow(blurRadius: 10, color: Colors.black26),
            ],
          ),
        ),
      )
      .toList();

  List<ORSCoordinate> get pointList => _points
      .where(
        (element) => element['point'] != null,
      )
      .map((e) => ORSCoordinate(
          latitude: e['point'].latitude, longitude: e['point'].longitude))
      .toList();

  void setHideSheet(bool value) {
    _states['hideSheet'] = value;
    notifyListeners();
  }

  void setEditPoint(int value) {
    _states['editPoint'] = value;
    notifyListeners();
  }

  void addPolyline(Polyline value) {
    _polylines.add(value);
    notifyListeners();
  }

  void addAllPolylines(List<Polyline> value) {
    _polylines.addAll(value);
    notifyListeners();
  }

  void addCtrl() {
    _points.insert(
        _points.length - 1, {'ctrl': TextEditingController(), 'point': null});
    notifyListeners();
  }

  void addPoint(LatLng value, int index) {
    _points[index]['point'] = value;
    _points[index]['ctrl'].text = value.toString();
    notifyListeners();
  }

  void clear() {
    _polylines.clear();
    _points.clear();
    notifyListeners();
  }
}
