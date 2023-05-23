// ignore_for_file: prefer_final_fields, file_names

import 'dart:collection';

import 'package:diplom/logic/map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapModel extends ChangeNotifier {
  final List<Polyline> _polylines = [];
  final List<Polyline> _viewPolylines = [];
  final List<Map<String, dynamic>> _points = [
    {'ctrl': TextEditingController(), 'point': null},
    {'ctrl': TextEditingController(), 'point': null}
  ];
  final MapController mapController = MapController();
  final PanelController panelController = PanelController();
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController();
  final Map<String, dynamic> _states = {
    'editPoint': null,
  };
  final Map<String, dynamic> _tabs = {'tab': [], 'tab-view': []};
  final Map<String, dynamic> _route = {
    'map': null,
    'user': null,
    'comment': [],
  };

  UnmodifiableListView<Polyline> get polylines =>
      UnmodifiableListView(_polylines);
  UnmodifiableListView<Polyline> get viewPolylines =>
      UnmodifiableListView(_viewPolylines);
  UnmodifiableListView<Map<String, dynamic>> get points =>
      UnmodifiableListView(_points);
  UnmodifiableMapView<String, dynamic> get tabs => UnmodifiableMapView(_tabs);
  UnmodifiableMapView<String, dynamic> get states =>
      UnmodifiableMapView(_states);
  UnmodifiableMapView<String, dynamic> get route => UnmodifiableMapView(_route);

  List<Marker> get markers => _points
      .where((element) => element['point'] != null)
      .map(
        (element) => Marker(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          point: element['point'],
          width: 24,
          height: 24,
          builder: (context) => const Icon(
            Icons.radio_button_checked,
            semanticLabel: 'err',
            color: Color.fromARGB(255, 255, 100, 0),
            size: 24,
            shadows: [
              Shadow(blurRadius: 7, color: Colors.black45),
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

  void setEditPoint(int? value) {
    _states['editPoint'] = value;
    notifyListeners();
  }

  void addAllViewPolylines(List<Polyline> value) {
    _viewPolylines.clear();
    _viewPolylines.addAll(value);
    notifyListeners();
  }

  void addAllPolylines(List<Polyline> value) {
    _polylines.clear();
    _polylines.addAll(value);
    notifyListeners();
  }

  void addPolyline(Polyline p1, Polyline p2) {
    _polylines.clear();
    _viewPolylines.clear();
    _polylines.add(p1);
    _viewPolylines.add(p2);
    notifyListeners();
  }

  void changeRoute(map) {
    _route['map'] = map['map'];
    _route['user'] = map['user'];
    _route['comment'] = map['comment'];
    notifyListeners();
  }

  void addCtrl() {
    _points.insert(
        _points.length - 1, {'ctrl': TextEditingController(), 'point': null});
    notifyListeners();
  }

  void removeCtrl(int index) {
    _points.removeAt(index);
    notifyListeners();
  }

  void addPoint(LatLng value, int index) async {
    _points[index]['point'] = value;
    _points[index]['ctrl'].text = await MapService().reverseSearch(value);
    notifyListeners();
  }

  void addTab(String name, Widget view) {
    final idx = _tabs['tab'].indexWhere((el) => el.text == name);
    if (idx != -1) {
      _tabs['tab-view'].removeAt(idx);
      _tabs['tab-view'].insert(idx, view);
    } else {
      _tabs['tab'].add(Tab(
        text: name,
        height: 50,
      ));
      _tabs['tab-view'].add(view);
    }
    notifyListeners();
  }

  void clearPolyline() {
    _polylines.clear();
    notifyListeners();
  }

  void changeCtrl(int type) {
    switch (type) {
      case 0:
        if (_points.length < 2) {
          _points.add({'ctrl': TextEditingController(), 'point': null});
        }
        break;
      case 1:
        if (_points.length > 2) {
          while (_points.length != 2) {
            _points.removeAt(1);
          }
        }
        if (_points.length < 2) {
          _points.add({'ctrl': TextEditingController(), 'point': null});
        }
        break;
      case 2:
        if (_points.length > 1) {
          while (_points.length != 1) {
            _points.removeAt(1);
          }
        }
        break;
    }
    notifyListeners();
  }

  void addOneTab(String name, Widget view) {
    clearTabs();
    _tabs['tab'].add(Tab(
      text: name,
      height: 50,
    ));
    _tabs['tab-view'].add(view);
    notifyListeners();
  }

  void clearTabs() {
    _tabs['tab'].clear();
    _tabs['tab-view'].clear();
    _points.clear();
    _points.addAll([
      {'ctrl': TextEditingController(), 'point': null},
      {'ctrl': TextEditingController(), 'point': null}
    ]);
    _states['editPoint'] = null;
    _polylines.clear();
    _viewPolylines.clear();
    notifyListeners();
  }
}
